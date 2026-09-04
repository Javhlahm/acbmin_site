import 'package:acbmin_site/PaginaInventarioTaller.dart';
import 'package:acbmin_site/PaginaPrincipal.dart';
import 'package:acbmin_site/PaginaResguardos.dart'; // Importar la página de Resguardos
import 'package:acbmin_site/PaginaBajas.dart'; // Importar la nueva página de Bajas
import 'package:acbmin_site/PaginaUsuarios.dart';
import 'package:acbmin_site/entity/UsuarioGlobal.dart';
import 'package:acbmin_site/features/entregas_equipo/presentation/entrega_equipo_list_page.dart';
import 'package:acbmin_site/security/app_roles.dart';
import 'package:acbmin_site/security/auth_service.dart';
import 'package:acbmin_site/ui/responsive.dart';
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
  Color colorCardResguardos = Colors.amber;
  Color colorCardBajas = Colors.amber; // Color para la nueva tarjeta de Bajas
  Color colorCardEntregaEquipo = Colors.amber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "MENÚ ACBMIN",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: responsiveTitleSize(context),
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
          icon: Icon(Icons.logout, size: 28, color: colorHoverSalir),
          tooltip: 'Cerrar sesión',
        ),
        actions: [
          if (usuarioGlobal?.nombre != null && !context.isMobile)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  usuarioGlobal!.nombre!,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
          if (usuarioGlobal?.nombre != null && context.isMobile)
            Tooltip(
              message: usuarioGlobal!.nombre!,
              child: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.account_circle_outlined),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("lib/assets/menu_wallpaper.jpg"),
              fit: BoxFit.cover),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cards = <Widget>[
              // Tarjeta Almacén Taller (si tiene rol)
              if (usuarioGlobal?.roles?.contains(AppRoles.tallerAutos) ?? false)
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
                  onTapDown: () => setState(() =>
                      colorCardTaller = const Color.fromARGB(255, 198, 121, 4)),
                  onTapUp: () =>
                      setState(() => colorCardTaller = Colors.orange),
                ),

              // Tarjeta Resguardos (si tiene rol 'admin', ajustar si es otro rol)
              if (usuarioGlobal?.roles?.contains(AppRoles.resguardosInternos) ??
                  false)
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

              // La tarjeta no se construye si la sesión no incluye el permiso;
              // esto también funciona en móvil, sin depender de hover.
              if (usuarioGlobal?.roles?.contains(AppRoles.entregaEquipo) ??
                  false)
                _buildMenuCard(
                  context: context,
                  icon: Icons.computer,
                  title: "Entrega de Equipo",
                  color: colorCardEntregaEquipo,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EntregaEquipoListPage(),
                    ),
                  ),
                  onHover: (hovering) => setState(() => colorCardEntregaEquipo =
                      hovering ? Colors.orange : Colors.amber),
                  onTapDown: () => setState(() => colorCardEntregaEquipo =
                      const Color.fromARGB(255, 198, 121, 4)),
                  onTapUp: () =>
                      setState(() => colorCardEntregaEquipo = Colors.orange),
                ),

              // *** NUEVA TARJETA PARA BAJAS DE BIENES ***
              // Asumiendo que solo los admins pueden verla
              if (usuarioGlobal?.roles?.contains(AppRoles.bajasBienes) ?? false)
                _buildMenuCard(
                  context: context,
                  icon: Icons.archive, // Icono sugerido para bajas
                  title: "Bajas de Bienes", // Título del módulo
                  color: colorCardBajas, // Usa el nuevo color
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PaginaBajas())), // Navega a PaginaBajas
                  onHover: (hovering) => setState(() =>
                      colorCardBajas = hovering ? Colors.orange : Colors.amber),
                  onTapDown: () => setState(() =>
                      colorCardBajas = const Color.fromARGB(255, 198, 121, 4)),
                  onTapUp: () => setState(() => colorCardBajas = Colors.orange),
                ),
              // *** FIN NUEVA TARJETA ***

              // Tarjeta Control de Acceso (si tiene rol 'admin')
              if (usuarioGlobal?.roles?.contains(AppRoles.admin) ?? false)
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
            ];

            final columns = context.isShort && constraints.maxWidth >= 700
                ? cards.length.clamp(1, 4)
                : constraints.maxWidth < 600
                    ? (constraints.maxWidth < 380 ? 1 : 2)
                    : constraints.maxWidth < 1024
                        ? 2
                        : cards.length.clamp(1, 4);
            final horizontalPadding = context.isMobile ? 12.0 : 24.0;
            final availableWidth = constraints.maxWidth - horizontalPadding * 2;
            final cardWidth = (availableWidth - (columns - 1) * 16) / columns;
            final cardHeight = context.isShort ? 170.0 : 210.0;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1320),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: cards
                        .map((card) => SizedBox(
                              width: cardWidth.clamp(160, 310),
                              height: cardHeight,
                              child: card,
                            ))
                        .toList(),
                  ),
                ),
              ),
            );
          },
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
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: context.isShort ? 54 : 78),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
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
