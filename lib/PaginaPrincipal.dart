import 'package:acbmin_site/PaginaMENU.dart';
import 'package:acbmin_site/entity/Usuario.dart';
import 'package:acbmin_site/entity/UsuarioGlobal.dart';
import 'package:acbmin_site/security/auth_service.dart';
import 'package:acbmin_site/services/usuarios/Login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:acbmin_site/services/usuarios/ObtenerUsuarioEmail.dart';
import 'package:acbmin_site/ui/responsive.dart';

class Paginaprincipal extends StatelessWidget {
  const Paginaprincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape
        ? PaginaPrincipalHorizontal()
        : PaginaPrincipalHorizontal();
  }
}

class PaginaPrincipalHorizontal extends StatefulWidget {
  const PaginaPrincipalHorizontal({super.key});

  @override
  State<PaginaPrincipalHorizontal> createState() =>
      _PaginaprincipalEscritorioState();
}

class _PaginaprincipalEscritorioState extends State<PaginaPrincipalHorizontal> {
  Color colorHoverHome = Colors.black;
  Color colorHoverIngreso = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        leading: IconButton(
          tooltip: 'Inicio',
          onPressed: () {},
          icon: const Icon(Icons.home),
        ),
        title: const Text(
          'Inicio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => mostrarDialogoIngreso(context),
            icon: const Icon(Icons.login),
            label: Text(context.isMobile ? 'Ingresar' : 'Iniciar sesión'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final titleSize =
              (constraints.maxWidth * 0.032).clamp(24.0, 48.0).toDouble();
          final topSpacing =
              (constraints.maxHeight * 0.08).clamp(20.0, 64.0).toDouble();

          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'lib/assets/class_classroom.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                semanticLabel: 'Salón de clases',
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [Color(0x66000000), Colors.transparent],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.isMobile ? 16 : 32,
                    topSpacing,
                    context.isMobile ? 16 : 32,
                    16,
                  ),
                  child: Semantics(
                    header: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LandingTitleLine(
                          text: 'ACBMIN',
                          fontSize: titleSize * 0.78,
                        ),
                        const SizedBox(height: 4),
                        _LandingTitleLine(
                          text: 'Área de Control de Bienes',
                          fontSize: titleSize,
                        ),
                        _LandingTitleLine(
                          text: 'Muebles e Inmuebles',
                          fontSize: titleSize,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LandingTitleLine extends StatelessWidget {
  const _LandingTitleLine({required this.text, required this.fontSize});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xffef3f0f),
            fontSize: fontSize,
            height: 1.05,
            fontWeight: FontWeight.w900,
            shadows: const [
              Shadow(
                color: Color(0xff641900),
                offset: Offset(2, 2),
                blurRadius: 0,
              ),
              Shadow(
                color: Colors.black54,
                offset: Offset.zero,
                blurRadius: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- LÓGICA DE INGRESO MODIFICADA ---
void mostrarDialogoIngreso(BuildContext context) {
  TextEditingController correoController = TextEditingController();
  TextEditingController contrasenaController = TextEditingController();
  showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
            // Usamos dialogContext para el diálogo
            scrollable: true,
            insetPadding: EdgeInsets.all(context.isMobile ? 16 : 40),
            title: Text("Ingresar",
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            content: Form(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: context.isMobile ? double.maxFinite : 420,
                  child: TextFormField(
                    controller: correoController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                        labelText: "Usuario", prefixIcon: Icon(Icons.person)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: context.isMobile ? double.maxFinite : 420,
                  child: TextFormField(
                    controller: contrasenaController,
                    obscureText: true,
                    onFieldSubmitted: (_) {},
                    decoration: const InputDecoration(
                        labelText: "Contraseña", prefixIcon: Icon(Icons.lock)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () async {
                      // 1. Obtenemos el token.
                      String? token = await Login(
                          correoController.text, contrasenaController.text);

                      // 2. Verificamos si el token es nulo (credenciales incorrectas)
                      if (token == null) {
                        // Usamos el 'context' del build principal para mostrar el SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Usuario o contraseña incorrectos.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return; // Detenemos la ejecución
                      }

                      // 3. Si el token SÍ existe, continuamos
                      await authService
                          .saveToken(token); // Ya no se necesita '!'

                      try {
                        // 4. Obtenemos datos del usuario
                        Usuario usuario =
                            await obtenerUsuarioEmail(correoController.text);
                        usuarioGlobal =
                            usuario; // Guardamos el usuario globalmente.

                        // 5. Navegamos al menú principal
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Paginamenu()));
                      } catch (e) {
                        // Manejo de error si falla la obtención de datos del usuario
                        print("Error al obtener detalles del usuario: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Error al obtener datos del usuario.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text("Ingresar",
                        style: TextStyle(
                            fontSize: 0.025.sh, fontWeight: FontWeight.bold)))
              ],
            )),
          ));
}
