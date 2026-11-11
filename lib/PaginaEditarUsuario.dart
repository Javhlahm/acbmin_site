import 'package:acbmin_site/entity/Usuario.dart';
import 'package:acbmin_site/security/app_roles.dart';
import 'package:acbmin_site/services/usuarios/EditarUsuario.dart';
import 'package:acbmin_site/services/usuarios/ObtenerUsuarioEmail.dart';
import 'package:acbmin_site/services/usuarios/mensaje_error.dart';
import 'package:acbmin_site/ui/responsive.dart';
import 'package:flutter/material.dart';

class Paginaeditarusuario extends StatefulWidget {
  const Paginaeditarusuario({super.key, required this.usuarioSeleccionado});

  final String usuarioSeleccionado;

  @override
  State<Paginaeditarusuario> createState() => _PaginaeditarusuarioState();
}

class _PaginaeditarusuarioState extends State<Paginaeditarusuario> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final contrasenaController = TextEditingController();
  late final Future<Usuario> _usuario;
  bool admin = false;
  bool jefe = false;
  bool tallerAutos = false;
  bool resguardosInternos = false;
  bool bajasBienes = false;
  bool entregaEquipo = false;
  bool almacenGeneral = false;
  bool activo = true; // un usuario inactivo no puede iniciar sesión
  bool _datosCargados = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _usuario = obtenerUsuarioEmail(widget.usuarioSeleccionado);
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  void _cargar(Usuario usuario) {
    if (_datosCargados) return;
    nombreController.text = usuario.nombre ?? '';
    correoController.text = usuario.email ?? '';
    final roles = usuario.roles ?? const <String>[];
    // Se traducen los permisos recibidos del backend a los controles del
    // formulario para conservarlos correctamente durante la edición.
    admin = roles.contains(AppRoles.admin);
    jefe = roles.contains(AppRoles.jefe);
    tallerAutos = roles.contains(AppRoles.tallerAutos);
    resguardosInternos = roles.contains(AppRoles.resguardosInternos);
    bajasBienes = roles.contains(AppRoles.bajasBienes);
    entregaEquipo = roles.contains(AppRoles.entregaEquipo);
    almacenGeneral = roles.contains(AppRoles.almacenGeneral);
    activo = (usuario.status ?? 'ACTIVO').trim().toUpperCase() == 'ACTIVO';
    _datosCargados = true;
  }

  Future<void> _actualizar(Usuario usuario) async {
    if (!_formKey.currentState!.validate() || _guardando) return;
    final roles = <String>[
      if (admin) AppRoles.admin,
      if (jefe) AppRoles.jefe,
      if (tallerAutos) AppRoles.tallerAutos,
      if (resguardosInternos) AppRoles.resguardosInternos,
      if (bajasBienes) AppRoles.bajasBienes,
      if (entregaEquipo) AppRoles.entregaEquipo,
      if (almacenGeneral) AppRoles.almacenGeneral,
    ];
    if (roles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un rol.')),
      );
      return;
    }
    setState(() => _guardando = true);
    usuario
      ..nombre = nombreController.text.trim()
      ..email = correoController.text.trim()
      ..contrasena = contrasenaController.text
      ..roles = roles
      ..status = activo ? 'ACTIVO' : 'INACTIVO';
    final resultado = await EditarUsuario(usuario);
    if (!mounted) return;
    if (resultado != 'OK') {
      // No se guardó: se queda en el formulario y explica por qué.
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(resultado.toString()), backgroundColor: Colors.red));
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.isMobile ? 'Editar usuario' : 'ACBMIN: EDITAR USUARIO',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: context.isMobile ? 20 : 28,
          ),
        ),
      ),
      body: FutureBuilder<Usuario>(
        future: _usuario,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final usuario = snapshot.data;
          if (usuario == null) {
            return const Center(child: Text('No se encontró el usuario.'));
          }
          _cargar(usuario);
          return ResponsiveFormCard(
            maxWidth: 720,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: nombreController,
                    decoration:
                        const InputDecoration(labelText: 'Nombre completo'),
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? 'Campo requerido'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: correoController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Correo'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: contrasenaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Nueva contraseña (opcional)',
                        helperText:
                            'Al menos $largoMinimoContrasena caracteres. Al cambiarla se cierran sus sesiones abiertas.'),
                    validator: (value) =>
                        validarContrasena(value, obligatoria: false),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Usuario activo'),
                    subtitle: Text(activo
                        ? 'Puede iniciar sesión'
                        : 'No puede iniciar sesión y sus sesiones abiertas se cierran'),
                    value: activo,
                    onChanged: _guardando
                        ? null
                        : (valor) => setState(() => activo = valor),
                  ),
                  const SizedBox(height: 24),
                  Text('Roles', style: Theme.of(context).textTheme.titleMedium),
                  _roleTile('Administrador', admin,
                      (value) => setState(() => admin = value)),
                  _roleTile('Jefe (todos los módulos y aprueba; sin usuarios)', jefe,
                      (value) => setState(() => jefe = value)),
                  _roleTile('Taller de autos', tallerAutos,
                      (value) => setState(() => tallerAutos = value)),
                  _roleTile('Resguardos internos', resguardosInternos,
                      (value) => setState(() => resguardosInternos = value)),
                  _roleTile('Bajas de bienes', bajasBienes,
                      (value) => setState(() => bajasBienes = value)),
                  _roleTile('Entrega de Equipo', entregaEquipo,
                      (value) => setState(() => entregaEquipo = value)),
                  _roleTile('Almacén General', almacenGeneral,
                      (value) => setState(() => almacenGeneral = value)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _guardando ? null : () => _actualizar(usuario),
                    icon: _guardando
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(_guardando ? 'Actualizando…' : 'Actualizar'),
                  ),
                ],
              ),
            ),
          );
        },
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
