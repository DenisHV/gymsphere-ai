import { Injectable, ConflictException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { CrearUsuarioDto } from './dto/crear-usuario.dto';

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
}