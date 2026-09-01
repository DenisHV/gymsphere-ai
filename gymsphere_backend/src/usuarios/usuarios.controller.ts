import {
  Controller,
  Post,
  Get,
  Patch,
  Delete,
  Body,
  Param,
  ParseIntPipe,
  UseGuards,
} from '@nestjs/common';
import { UsuariosService } from './usuarios.service';
import { CrearUsuarioDto } from './dto/crear-usuario.dto';
import { ActualizarUsuarioDto } from './dto/actualizar-usuario.dto';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';

@Controller('usuarios')
export class UsuariosController {
  constructor(private readonly usuariosService: UsuariosService) {}

  @Post('registro')
  async registrar(@Body() datos: CrearUsuarioDto) {
    return this.usuariosService.crear(datos);
  }

  @Get()
  @UseGuards(RolesGuard)
  @Roles('ADMINISTRADOR')
  async listar() {
    return this.usuariosService.listarTodos();
  }

  @Get(':id')
  @UseGuards(RolesGuard)
  @Roles('ADMINISTRADOR')
  async obtenerUno(@Param('id', ParseIntPipe) id: number) {
    return this.usuariosService.obtenerUno(id);
  }

  @Patch(':id')
  @UseGuards(RolesGuard)
  @Roles('ADMINISTRADOR')
  async actualizar(@Param('id', ParseIntPipe) id: number, @Body() datos: ActualizarUsuarioDto) {
    return this.usuariosService.actualizar(id, datos);
  }

  @Delete(':id')
  @UseGuards(RolesGuard)
  @Roles('ADMINISTRADOR')
  async eliminar(@Param('id', ParseIntPipe) id: number) {
    return this.usuariosService.eliminar(id);
  }

  @Patch(':id/reset-2fa')
  @UseGuards(RolesGuard)
  @Roles('ADMINISTRADOR')
  async resetear2FA(@Param('id', ParseIntPipe) id: number) {
    return this.usuariosService.resetear2FA(id);
  }
}