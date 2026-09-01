import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { CrearUsuarioDto } from './dto/crear-usuario.dto';
import { ActualizarUsuarioDto } from './dto/actualizar-usuario.dto';

@Injectable()
export class UsuariosService {
  constructor(private prisma: PrismaService) {}

  async crear(datos: CrearUsuarioDto) {
    // Verificar que el correo no esté ya registrado
    const existente = await this.prisma.usuario.findUnique({
      where: { correo: datos.correo },
    });

    if (existente) {
      throw new ConflictException('Ya existe un usuario con ese correo');
    }

    // Encriptar la contraseña antes de guardarla
    const claveHash = await bcrypt.hash(datos.clave, 10);

    const nuevoUsuario = await this.prisma.usuario.create({
      data: {
        nombre: datos.nombre,
        correo: datos.correo,
        claveHash: claveHash,
        rol: datos.rol,
      },
    });

    // Nunca devolvemos la clave, ni siquiera la encriptada
    const { claveHash: _omitir, ...usuarioSinClave } = nuevoUsuario;
    return usuarioSinClave;
  }
  
    async listarTodos() {
    const usuarios = await this.prisma.usuario.findMany({ orderBy: { id: 'asc' } });
    return usuarios.map(({ claveHash, secretoTOTP, ...resto }) => resto);
  }

  async obtenerUno(id: number) {
    const usuario = await this.prisma.usuario.findUnique({ where: { id } });
    if (!usuario) throw new NotFoundException('Usuario no encontrado');
    const { claveHash, secretoTOTP, ...resto } = usuario;
    return resto;
  }

  async actualizar(id: number, datos: ActualizarUsuarioDto) {
    const dataActualizar: any = {};
    if (datos.nombre) dataActualizar.nombre = datos.nombre;
    if (datos.correo) dataActualizar.correo = datos.correo;
    if (datos.rol) dataActualizar.rol = datos.rol;
    if (datos.clave) dataActualizar.claveHash = await bcrypt.hash(datos.clave, 10);

    const actualizado = await this.prisma.usuario.update({
      where: { id },
      data: dataActualizar,
    });
    const { claveHash, secretoTOTP, ...resto } = actualizado;
    return resto;
  }

  async eliminar(id: number) {
    await this.prisma.usuario.delete({ where: { id } });
    return { mensaje: 'Usuario eliminado correctamente' };
  }

  async resetear2FA(id: number) {
    await this.prisma.usuario.update({ where: { id }, data: { secretoTOTP: null } });
    return { mensaje: 'El 2FA fue reiniciado. El usuario verá un nuevo QR en su próximo login.' };
  }
}