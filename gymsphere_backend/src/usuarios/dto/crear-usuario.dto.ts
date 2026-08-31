import { IsEmail, IsNotEmpty, IsEnum, MinLength } from 'class-validator';
import { Rol } from '@prisma/client';

export class CrearUsuarioDto {
  @IsNotEmpty({ message: 'El nombre es obligatorio' })
  nombre!: string;

  @IsEmail({}, { message: 'El correo no es válido' })
  correo!: string;

  @MinLength(8, { message: 'La clave debe tener al menos 8 caracteres' })
  clave!: string;

  @IsEnum(Rol, { message: 'El rol debe ser MIEMBRO, ENTRENADOR o ADMINISTRADOR' })
  rol!: Rol;
}