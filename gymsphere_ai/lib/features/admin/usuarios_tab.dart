import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/usuarios_service.dart';

class UsuariosTab extends StatefulWidget {
  const UsuariosTab({super.key});

  @override
  State<UsuariosTab> createState() => _UsuariosTabState();
}

class _UsuariosTabState extends State<UsuariosTab> {
  List<dynamic> _usuarios = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final lista = await UsuariosService.listar();
      setState(() => _usuarios = lista);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _cargando = false);
    }
  }

  void _abrirFormulario({Map<String, dynamic>? usuarioExistente}) {
    showDialog(
      context: context,
      builder: (context) => _FormularioUsuario(
        usuarioExistente: usuarioExistente,
        onGuardado: _cargarUsuarios,
      ),
    );
  }

  Future<void> _confirmarEliminar(Map<String, dynamic> usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.tertiary,
        title: const Text('¿Eliminar usuario?', style: TextStyle(color: AppColors.secondary)),
        content: Text(
          '¿Seguro que quieres eliminar a "${usuario['nombre']}"? Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await UsuariosService.eliminar(usuario['id'] as int);
        _cargarUsuarios();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
          );
        }
      }
    }
  }

  Future<void> _resetear2FA(Map<String, dynamic> usuario) async {
    try {
      await UsuariosService.resetear2FA(usuario['id'] as int);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('2FA reiniciado. El usuario verá un QR nuevo en su próximo login.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'GESTIÓN DE USUARIOS',
                style: TextStyle(color: AppColors.secondary, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _abrirFormulario(),
                icon: const Icon(Icons.add, color: AppColors.neutral, size: 18),
                label: const Text('NUEVO USUARIO', style: TextStyle(color: AppColors.neutral, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_cargando)
            const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
          else if (_error != null)
            Expanded(child: Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent))))
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: _usuarios.map((u) => _filaUsuario(u as Map<String, dynamic>)).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _filaUsuario(Map<String, dynamic> usuario) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.tertiary, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(usuario['nombre'], style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                Text(usuario['correo'], style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(border: Border.all(color: AppColors.primary), borderRadius: BorderRadius.circular(4)),
              child: Text(usuario['rol'], style: const TextStyle(color: AppColors.primary, fontSize: 11), textAlign: TextAlign.center),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.security_outlined, color: Colors.amber, size: 20),
            tooltip: 'Reiniciar 2FA',
            onPressed: () => _resetear2FA(usuario),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.secondary, size: 20),
            onPressed: () => _abrirFormulario(usuarioExistente: usuario),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: () => _confirmarEliminar(usuario),
          ),
        ],
      ),
    );
  }
}

// Formulario emergente para crear o editar
class _FormularioUsuario extends StatefulWidget {
  final Map<String, dynamic>? usuarioExistente;
  final VoidCallback onGuardado;

  const _FormularioUsuario({this.usuarioExistente, required this.onGuardado});

  @override
  State<_FormularioUsuario> createState() => _FormularioUsuarioState();
}

class _FormularioUsuarioState extends State<_FormularioUsuario> {
  late TextEditingController _nombreCtrl;
  late TextEditingController _correoCtrl;
  final TextEditingController _claveCtrl = TextEditingController();
  String _rolSeleccionado = 'MIEMBRO';
  bool _guardando = false;
  String? _error;

  bool get _esEdicion => widget.usuarioExistente != null;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.usuarioExistente?['nombre'] ?? '');
    _correoCtrl = TextEditingController(text: widget.usuarioExistente?['correo'] ?? '');
    _rolSeleccionado = widget.usuarioExistente?['rol'] ?? 'MIEMBRO';
  }

  Future<void> _guardar() async {
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      if (_esEdicion) {
        final cambios = <String, dynamic>{
          'nombre': _nombreCtrl.text.trim(),
          'correo': _correoCtrl.text.trim(),
          'rol': _rolSeleccionado,
        };
        if (_claveCtrl.text.isNotEmpty) cambios['clave'] = _claveCtrl.text;
        await UsuariosService.actualizar(widget.usuarioExistente!['id'] as int, cambios);
      } else {
        await UsuariosService.crear(
          nombre: _nombreCtrl.text.trim(),
          correo: _correoCtrl.text.trim(),
          clave: _claveCtrl.text,
          rol: _rolSeleccionado,
        );
      }
      if (mounted) {
        Navigator.pop(context);
        widget.onGuardado();
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.tertiary,
      title: Text(
        _esEdicion ? 'Editar usuario' : 'Nuevo usuario',
        style: const TextStyle(color: AppColors.secondary),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
              ),
            TextField(
              controller: _nombreCtrl,
              style: const TextStyle(color: AppColors.secondary),
              decoration: const InputDecoration(labelText: 'Nombre', labelStyle: TextStyle(color: Colors.grey)),
            ),
            TextField(
              controller: _correoCtrl,
              style: const TextStyle(color: AppColors.secondary),
              decoration: const InputDecoration(labelText: 'Correo', labelStyle: TextStyle(color: Colors.grey)),
            ),
            TextField(
              controller: _claveCtrl,
              obscureText: true,
              style: const TextStyle(color: AppColors.secondary),
              decoration: InputDecoration(
                labelText: _esEdicion ? 'Nueva clave (opcional)' : 'Clave',
                labelStyle: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _rolSeleccionado,
              dropdownColor: AppColors.tertiary,
              style: const TextStyle(color: AppColors.secondary),
              decoration: const InputDecoration(labelText: 'Rol', labelStyle: TextStyle(color: Colors.grey)),
              items: const [
                DropdownMenuItem(value: 'MIEMBRO', child: Text('MIEMBRO')),
                DropdownMenuItem(value: 'ADMINISTRADOR', child: Text('ADMINISTRADOR')),
                DropdownMenuItem(value: 'RECEPCION', child: Text('RECEPCION')),
              ],
              onChanged: (valor) => setState(() => _rolSeleccionado = valor!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _guardando ? null : _guardar,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: _guardando
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neutral))
              : Text(_esEdicion ? 'Guardar' : 'Crear', style: const TextStyle(color: AppColors.neutral)),
        ),
      ],
    );
  }
}