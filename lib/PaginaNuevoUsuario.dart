import 'package:acbmin_site/entity/Usuario.dart';
import 'package:acbmin_site/services/NuevoUsuario.dart';
import 'package:acbmin_site/ui/responsive.dart';
import 'package:flutter/material.dart';

class Paginanuevousuario extends StatefulWidget {
  const Paginanuevousuario({super.key});

  @override
  State<Paginanuevousuario> createState() => _PaginanuevousuarioState();
}

class _PaginanuevousuarioState extends State<Paginanuevousuario> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final contrasenaController = TextEditingController();
  bool admin = false;
  bool tallerAutos = false;
  bool resguardosInternos = false;
  bool bajasBienes = false;
  bool _guardando = false;

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || _guardando) return;
    final roles = <String>[
      if (admin) 'admin',
      if (tallerAutos) 'taller_autos',
      if (resguardosInternos) 'resguardos_internos',
      if (bajasBienes) 'bajas_bienes',
    ];
    if (roles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un rol.')),
      );
      return;
    }
    setState(() => _guardando = true);
    final usuario = Usuario()
      ..nombre = nombreController.text.trim()
      ..email = correoController.text.trim()
      ..contrasena = contrasenaController.text
      ..roles = roles
      ..status = 'ACTIVO';
    await NuevoUsuario(usuario);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.isMobile ? 'Nuevo usuario' : 'ACBMIN: NUEVO USUARIO',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: context.isMobile ? 20 : 28,
          ),
        ),
      ),
      body: ResponsiveFormCard(
        maxWidth: 720,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nombreController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator: (value) =>
                    (value?.trim().isEmpty ?? true) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: correoController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) return 'Campo requerido';
                  if (!email.contains('@')) return 'Correo no válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: contrasenaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 24),
              Text('Roles', style: Theme.of(context).textTheme.titleMedium),
              _roleTile('Administrador', admin,
                  (value) => setState(() => admin = value)),
              _roleTile('Taller de autos', tallerAutos,
                  (value) => setState(() => tallerAutos = value)),
              _roleTile('Resguardos internos', resguardosInternos,
                  (value) => setState(() => resguardosInternos = value)),
              _roleTile('Bajas de bienes', bajasBienes,
                  (value) => setState(() => bajasBienes = value)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_guardando ? 'Guardando…' : 'Guardar usuario'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleTile(String label, bool value, ValueChanged<bool> onChanged) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(label),
      value: value,
      onChanged: _guardando ? null : (value) => onChanged(value ?? false),
    );
  }
}
