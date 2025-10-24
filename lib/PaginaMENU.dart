import 'package:acbmin_site/PaginaInventarioTaller.dart';
import 'package:acbmin_site/PaginaPrincipal.dart';
import 'package:acbmin_site/PaginaResguardos.dart'; // Importar la nueva página
import 'package:acbmin_site/PaginaUsuarios.dart';
import 'package:acbmin_site/entity/UsuarioGlobal.dart';
import 'package:acbmin_site/security/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Paginamenu extends StatelessWidget {
  const Paginamenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Forzamos el layout horizontal por simplicidad, puedes ajustar esto si necesitas layout vertical
    return PaginaMenuHorizontal();
  }
}

class PaginaMenuHorizontal extends StatefulWidget {
  const PaginaMenuHorizontal({super.key});

  @override
  State<PaginaMenuHorizontal> createState() => _PaginacrudEscritorioState();
}

class _PaginacrudEscritorioState extends State<PaginaMenuHorizontal> {
  Color colorHoverSalir = Colors.black;
  Color colorCardTaller = Colors.amber;
  Color colorCardUsuarios = Colors.amber;
  Color colorCardResguardos = Colors.amber; // Color para la nueva tarjeta

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff6c500),
        centerTitle: true,
        title: Text(
          "MENÚ ACBMIN",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 45.0.dg,
          ),
        ),
        leading: IconButton(
          onPressed: () async {
            await authService.deleteToken();
            usuarioGlobal = null;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Paginaprincipal()),
            );
          },
          icon: Icon(Icons.logout, size: 0.07.sh, color: colorHoverSalir),
          tooltip: 'Cerrar Sesión', // Tooltip para el botón de salir
        ),
        actions: [
          if (usuarioGlobal?.nombre != null)
            Center(
              // Centrar verticalmente el nombre
              child: Text(
                usuarioGlobal!.nombre!,
                style: TextStyle(
                    fontSize: 25.dg,
                    fontWeight: FontWeight.bold,
                    color: Colors.black), // Color legible
              ),
            ),
          Padding(padding: EdgeInsets.only(right: 20.dg)),
        ],
      ),
      body: Container(
        // Usar Container para el fondo
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                  "lib/assets/menu_wallpaper.jpg"), // Fondo existente
              fit: BoxFit.cover),
        ),
        child: Center(
          child: SingleChildScrollView(
            // Para evitar overflow si hay muchas tarjetas
            scrollDirection: Axis.horizontal, // O Axis.vertical según prefieras
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tarjeta Almacén Taller (si tiene rol)
                if (usuarioGlobal?.roles?.contains("taller_autos") ?? false)
                  _buildMenuCard(
                    context: context,
                    icon: Icons.garage,
                    title: "Almacén Taller Vehículos",
                    color: colorCardTaller,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Paginainventariotaller())),
                    onHover: (hovering) => setState(() => colorCardTaller =
                        hovering ? Colors.orange : Colors.amber),
                    onTapDown: () => setState(() => colorCardTaller =
                        const Color.fromARGB(255, 198, 121, 4)),
                    onTapUp: () =>
                        setState(() => colorCardTaller = Colors.orange),
                  ),

                // Tarjeta Resguardos (si tiene rol 'admin', ajustar si es otro rol)
                if (usuarioGlobal?.roles?.contains("admin") ?? false) ...[
                  SizedBox(width: 20.w), // Espacio entre tarjetas
                  _buildMenuCard(
                    context: context,
                    icon: Icons.assignment, // Icono para resguardos
                    title: "Resguardos Bienes",
                    color: colorCardResguardos,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PaginaResguardos())),
                    onHover: (hovering) => setState(() => colorCardResguardos =
                        hovering ? Colors.orange : Colors.amber),
                    onTapDown: () => setState(() => colorCardResguardos =
                        const Color.fromARGB(255, 198, 121, 4)),
                    onTapUp: () =>
                        setState(() => colorCardResguardos = Colors.orange),
                  ),
                ],

                // Tarjeta Control de Acceso (si tiene rol 'admin')
                if (usuarioGlobal?.roles?.contains("admin") ?? false) ...[
                  SizedBox(width: 20.w), // Espacio entre tarjetas
                  _buildMenuCard(
                    context: context,
                    icon: Icons.supervised_user_circle,
                    title: "Control de Acceso",
                    color: colorCardUsuarios,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Paginausuarios())),
                    onHover: (hovering) => setState(() => colorCardUsuarios =
                        hovering ? Colors.orange : Colors.amber),
                    onTapDown: () => setState(() => colorCardUsuarios =
                        const Color.fromARGB(255, 198, 121, 4)),
                    onTapUp: () =>
                        setState(() => colorCardUsuarios = Colors.orange),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget helper para crear las tarjetas del menú y evitar repetición
  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required ValueChanged<bool> onHover,
    required VoidCallback onTapDown,
    required VoidCallback onTapUp,
  }) {
    return InkWell(
      onTap: onTap,
      onHover: onHover,
      onTapDown: (_) =>
          onTapDown(), // Usar (_) para ignorar details si no se necesita
      onTapUp: (_) =>
          onTapUp(), // Usar (_) para ignorar details si no se necesita
      child: Card(
        color: color,
        elevation: 5, // Sombra para destacar
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r)), // Bordes redondeados
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: 20.h, horizontal: 30.w), // Padding interno
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ajustar tamaño al contenido
            children: [
              Icon(icon, size: 0.15.sh), // Icono grande
              SizedBox(height: 10.h), // Espacio
              Text(
                title,
                textAlign: TextAlign.center, // Centrar texto
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.dg,
                  color: Colors.black, // Asegurar texto legible
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// La función funcionSalir no se usa actualmente con el botón de logout en AppBar,
// pero la dejamos por si se necesita en otro lugar.
void funcionSalir(context) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            insetPadding:
                EdgeInsets.symmetric(horizontal: 0.1.sw, vertical: 0.33.sh),
            title: Text(
              "¿Salir de la Aplicación?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 0.03.sh, fontWeight: FontWeight.bold),
            ),
            content: Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Cierra dialogo
                              // Considera si realmente quieres cerrar toda la app o solo ir a login
                              // SystemNavigator.pop(); // Cierra la app (funciona en móvil)
                              // Para web/desktop, mejor navegar a login:
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Paginaprincipal()),
                                (Route<dynamic> route) =>
                                    false, // Elimina todas las rutas anteriores
                              );
                            },
                            child: Text(
                              "OK",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 0.025.sh,
                                  fontWeight: FontWeight.bold),
                            )),
                        SizedBox(
                          width: 10.w,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Solo cierra dialogo
                            },
                            child: Text(
                              "NO",
                              style: TextStyle(
                                  fontSize: 0.025.sh,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ));
}
