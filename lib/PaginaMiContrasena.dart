import 'package:acbmin_site/services/usuarios/CambiarMiContrasena.dart';
import 'package:acbmin_site/services/usuarios/mensaje_error.dart';
import 'package:acbmin_site/ui/responsive.dart';
import 'package:flutter/material.dart';

/// Cualquier usuario cambia aquí su propia contraseña. Pide la actual para que
/// nadie la cambie en una sesión que se quedó abierta.
class PaginaMiContrasena extends StatefulWidget {
  const PaginaMiContrasena({super.key});

  @override
  State<PaginaMiContrasena> createState() => _PaginaMiContrasenaState();
}

class _PaginaMiContrasenaState extends State<PaginaMiContrasena> {
  final _formKey = GlobalKey<FormState>();
  final actualController = TextEditingController();
  final nuevaController = TextEditingController();
  final confirmarController = TextEditingController();
  bool _guardando = false;

  @override
  void dispose() {
    actualController.dispose();
    nuevaController.dispose();
    confirmarController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || _guardando) return;
    setState(() => _guardando = true);
    final error =
        await cambiarMiContrasena(actualController.text, nuevaController.text);
    if (!mounted) return;
    setState(() => _guardando = false);
    final avisos = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    if (error != null) {
      // No se cambió: se queda en la pantalla y explica por qué.
      avisos.showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red));
      return;
    }
    avisos.showSnackBar(const SnackBar(
        content: Text(
            'Contraseña cambiada. Se cerraron tus sesiones en otros equipos.'),
        backgroundColor: Colors.green));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.isMobile ? 'Mi contraseña' : 'ACBMIN: CAMBIAR MI CONTRASEÑA',
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
        maxWidth: 520,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: actualController,
                obscureText: true,
                textInputAction: TextInputAction.next,
                decoration:
                    const InputDecoration(labelText: 'Contraseña actual'),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nuevaController,
                obscureText: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                    labelText: 'Contraseña nueva',
                    helperText: 'Al menos $largoMinimoContrasena caracteres'),
                validator: (value) {
                  final error = validarContrasena(value, obligatoria: true);
                  if (error != null) return error;
                  if (value == actualController.text) {
                    return 'Debe ser distinta de la actual';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmarController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _guardar(),
                decoration: const InputDecoration(
                    labelText: 'Confirma la contraseña nueva'),
                validator: (value) => value != nuevaController.text
                    ? 'No coincide con la contraseña nueva'
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock_reset),
                label: Text(_guardando ? 'Guardando…' : 'Cambiar contraseña'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
