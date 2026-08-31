import { Injectable, UnauthorizedException, NotFoundException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import * as qrcode from 'qrcode';
import { OTP } from 'otplib';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { Verificar2FADto } from './dto/verificar-2fa.dto';

const otp = new OTP();

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  // Paso 1 de 2: valida correo + clave
  async login(datos: LoginDto) {
    const usuario = await this.prisma.usuario.findUnique({
      where: { correo: datos.correo },
    });

    if (!usuario) {
      throw new UnauthorizedException('Correo o clave incorrectos');
    }

    const claveValida = await bcrypt.compare(datos.clave, usuario.claveHash);
    if (!claveValida) {
      throw new UnauthorizedException('Correo o clave incorrectos');
    }

    // Si el usuario todavía NO tiene su 2FA configurado, se lo generamos ahora
    if (!usuario.secretoTOTP) {
      const secreto = otp.generateSecret();

      await this.prisma.usuario.update({
        where: { id: usuario.id },
        data: { secretoTOTP: secreto },
      });

      // Genera la URL especial que Google Authenticator entiende
      const otpauthUri = otp.generateURI({
        issuer: 'GymSphere AI',
        label: usuario.correo,
        secret: secreto,
      });
      const qrImagen = await qrcode.toDataURL(otpauthUri);

      return {
        requiereConfiguracion2FA: true,
        qrImagen, // imagen en base64 lista para mostrar en Flutter
        mensaje: 'Escanea este código QR con Google Authenticator y luego verifica tu código',
      };
    }

    // Si ya tiene 2FA configurado, solo le pedimos el código
    return {
      requiereConfiguracion2FA: false,
      mensaje: 'Ingresa el código de tu app autenticadora',
    };
  }

  // Paso 2 de 2: valida el código de 6 dígitos y entrega el token de sesión
  async verificar2FA(datos: Verificar2FADto) {
    const usuario = await this.prisma.usuario.findUnique({
      where: { correo: datos.correo },
    });

    if (!usuario || !usuario.secretoTOTP) {
      throw new NotFoundException('Usuario no encontrado o sin 2FA configurado');
    }

    const resultado = await otp.verify({
      secret: usuario.secretoTOTP,
      token: datos.codigo,
    });

    if (!resultado.valid) {
      throw new UnauthorizedException('Código incorrecto o expirado');
    }

    // Genera el token de sesión con el id y el rol del usuario
    const token = this.jwtService.sign({
      id: usuario.id,
      correo: usuario.correo,
      rol: usuario.rol,
    });

    return {
      token,
      usuario: {
        id: usuario.id,
        nombre: usuario.nombre,
        correo: usuario.correo,
        rol: usuario.rol,
      },
    };
  }
}