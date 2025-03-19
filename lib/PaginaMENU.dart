import 'package:acbmin_site/PaginaInventarioTaller.dart';
import 'package:acbmin_site/PaginaUsuarios.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Paginamenu extends StatelessWidget {
  final String usuarioLogeado;
  const Paginamenu({super.key, required this.usuarioLogeado});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape
        ? PaginaMenuHorizontal()
        : PaginaMenuHorizontal();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(7.0.w),
            height: 0.10.sh,
            color: Color(0xfff6c500),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      child: Icon(
                        Icons.logout_sharp,
                        size: 0.07.sh,
                        color: colorHoverSalir,
                      ),
                      onTap: () {
                        funcionSalir(context);
                      },
                      onHover: (value) {
                        setState(() {
                          colorHoverSalir =
                              value == true ? Colors.red : Colors.black;
                        });
                      },
                    ),
                    Container(
                      width: .8.sw,
                      alignment: Alignment.center,
                      child: Text(
                        "ACBMIN MÓDULOS",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 35.0.dg),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("lib/assets/menu_wallpaper.jpg"),
                  fit: BoxFit.fill),
            ),
            height: 0.90.sh,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Paginainventariotaller()));
                    },
                    onTapDown: (details) {
                      setState(() {
                        colorCardTaller =
                            const Color.fromARGB(255, 198, 121, 4);
                      });
                    },
                    onTapUp: (details) {
                      setState(() {
                        colorCardTaller = Colors.orange;
                      });
                    },
                    onHover: (value) {
                      setState(() {
                        colorCardTaller =
                            value == true ? Colors.orange : Colors.amber;
                      });
                    },
                    child: Card(
                      color: colorCardTaller,
                      child: Padding(
                        padding: EdgeInsets.all(8.0.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.garage,
                              size: 0.15.sh,
                            ),
                            Text(
                              "Almacén del Taller de Vehículos",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.dg),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Paginausuarios()));
                    },
                    onTapDown: (details) {
                      setState(() {
                        colorCardUsuarios =
                            const Color.fromARGB(255, 198, 121, 4);
                      });
                    },
                    onTapUp: (details) {
                      setState(() {
                        colorCardUsuarios = Colors.orange;
                      });
                    },
                    onHover: (value) {
                      setState(() {
                        colorCardUsuarios =
                            value == true ? Colors.orange : Colors.amber;
                      });
                    },
                    child: Card(
                      color: colorCardUsuarios,
                      child: Padding(
                        padding: EdgeInsets.all(8.0.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.supervised_user_circle,
                              size: 0.15.sh,
                            ),
                            Text(
                              "Control de Acceso",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.dg),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

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
                              Navigator.pop(context);
                              Navigator.pop(context);
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
                              Navigator.pop(context);
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
