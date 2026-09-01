import { IsEmail, IsOptional, IsEnum, MinLength } from 'class-validator';
import { Rol } from '@prisma/client';

export class ActualizarUsuarioDto {
  @IsOptional()
  nombre?: string;

  @IsOptional()
  @IsEmail({}, { message: 'El correo no es válido' })
  correo?: string;

  @IsOptional()
  @MinLength(8, { message: 'La clave debe tener al menos 8 caracteres' })
  clave?: string;

  @IsOptional()
  @IsEnum(Rol, { message: 'El rol debe ser MIEMBRO, ADMINISTRADOR o RECEPCION' })
  rol?: Rol;
}