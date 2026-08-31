import { Controller, Post, Body } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { Verificar2FADto } from './dto/verificar-2fa.dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  async login(@Body() datos: LoginDto) {
    return this.authService.login(datos);
  }

  @Post('verificar-2fa')
  async verificar2FA(@Body() datos: Verificar2FADto) {
    return this.authService.verificar2FA(datos);
  }
}