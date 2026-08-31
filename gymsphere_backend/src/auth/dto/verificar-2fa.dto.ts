import { IsEmail, IsNotEmpty, Length } from 'class-validator';

export class Verificar2FADto {
  @IsEmail({}, { message: 'El correo no es válido' })
  correo!: string;

  @Length(6, 6, { message: 'El código debe tener 6 dígitos' })
  codigo!: string;
}