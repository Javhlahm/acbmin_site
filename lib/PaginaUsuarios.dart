import 'package:acbmin_site/PaginaEditarUsuario.dart';
import 'package:acbmin_site/PaginaNuevoUsuario.dart';
import 'package:acbmin_site/entity/Usuario.dart';
import 'package:acbmin_site/entity/UsuarioGlobal.dart';
import 'package:acbmin_site/services/usuarios/ObtenerUsuarios.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:acbmin_site/ui/tabla_datos.dart';
import 'package:acbmin_site/ui/responsive.dart';

late List<Usuario> datosExportacion;
late Future<List<Usuario>> listaUsuarios;
String? UsuarioSeleccionado = "";

class Paginausuarios extends StatefulWidget {
  @override
  State<Paginausuarios> createState() => _PaginausuariosState();
}

class _PaginausuariosState extends State<Paginausuarios> {
  // --- INICIO DE CÓDIGO MODIFICADO ---
  @override
  void initState() {
    super.initState();
    // Se llama a la API aquí en lugar de en el 'build'
    listaUsuarios = obtenerUsuarios();
  }
  // --- FIN DE CÓDIGO MODIFICADO ---

  /// Abre el formulario de alta o edición y, si se guardó, recarga la lista
  /// para que se vean los cambios (roles, estatus...).
  Future<void> _abrir(Widget pagina) async {
    final guardado = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (context) => pagina));
    if (guardado == true && mounted) {
      setState(() => listaUsuarios = obtenerUsuarios());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.isMobile ? "Usuarios" : "ACBMIN: USUARIOS",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: context.isMobile ? 20 : 28),
        ),
        backgroundColor: Color(0xfff6c500),
        actions: [
          IconButton(
              tooltip: 'Actualizar usuarios',
              onPressed: () {
                // Se refresca la lista llamando a setState
                setState(() {
                  listaUsuarios = obtenerUsuarios();
                });
              },
              icon: Icon(
                Icons.refresh,
                size: 30.0,
                color: Colors.black,
              )),
          !context.isMobile
              ? InkWell(
                  child: Text(
                    "Nuevo Usuario",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 18),
                  ),
                  onTap: () {
                    _abrir(Paginanuevousuario());
                  },
                )
              : IconButton(
                  tooltip: 'Nuevo usuario',
                  onPressed: () {
                    _abrir(Paginanuevousuario());
                  },
                  icon: Icon(
                    Icons.add,
                    color: Colors.black,
                  )),
          const SizedBox(width: 4),
          !context.isMobile
              ? InkWell(
                  child: Text(
                    "Editar Usuario",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 18),
                  ),
                  onTap: () {
                    if (UsuarioSeleccionado!.isEmpty ||
                        UsuarioSeleccionado == null) {
                      return;
                    }
                    _abrir(Paginaeditarusuario(
                      usuarioSeleccionado: UsuarioSeleccionado!,
                    ));
                  },
                )
              : IconButton(
                  tooltip: 'Editar usuario seleccionado',
                  onPressed: () {
                    if (UsuarioSeleccionado!.isEmpty ||
                        UsuarioSeleccionado == null) {
                      return;
                    }
                    _abrir(Paginaeditarusuario(
                      usuarioSeleccionado: UsuarioSeleccionado!,
                    ));
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Colors.black,
                  )),
          if (context.isDesktop) ...[
            const SizedBox(width: 12),
            Text(
              usuarioGlobal!.nombre!,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(width: 20),
          ],
        ],
      ),
      body: FutureBuilder(
          future: listaUsuarios, // Ahora usa la variable de estado
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
              datosExportacion = snapshot.data!;
              return SizedBox.expand(
                child: TablaDatos(
                    alSeleccionar: (fila) {
                      setState(() {
                        UsuarioSeleccionado = fila['email'] as String?;
                      });
                    },
                    columnas: [
                      ColumnaTabla(
                          titulo: "Nombre",
                          campo: "nombre",
                          ancho: context.isMobile ? 150 : .25.sw),
                      ColumnaTabla(
                          titulo: "Correo",
                          campo: "email",
                          ancho: context.isMobile ? 200 : .25.sw),
                      ColumnaTabla(
                          titulo: "Roles",
                          campo: "roles",
                          ancho: context.isMobile ? 190 : .25.sw),
                      ColumnaTabla(
                          titulo: "Estatus",
                          campo: "status",
                          ancho: context.isMobile ? 120 : .25.sw),
                    ],
                    filas: snapshot.data!.map((usuario) {
                      return <String, Object?>{
                        "nombre": usuario.nombre,
                        "email": usuario.email,
                        "roles": usuario.roles,
                        "status": usuario.status,
                      };
                    }).toList()),
              );
            }
          }),
    );
  }
}
