import 'package:flutter/material.dart';

class Paginacrud extends StatelessWidget {
  const Paginacrud({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > 800
        ? PaginacrudEscritorio()
        : PaginacrudMovil();
  }
}

class PaginacrudEscritorio extends StatefulWidget {
  const PaginacrudEscritorio({super.key});

  @override
  State<PaginacrudEscritorio> createState() => _PaginacrudEscritorioState();
}

class _PaginacrudEscritorioState extends State<PaginacrudEscritorio> {
  num tamanoLogout = 1;
  Color colorTarjeta = Colors.amber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(7.0),
            height: MediaQuery.of(context).size.height * 0.10,
            color: Color(0xfff6c500),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  child: Icon(
                    Icons.logout_sharp,
                    size: MediaQuery.of(context).size.height *
                        0.07 *
                        tamanoLogout,
                  ),
                  onTap: () {
                    funcionSalir(context);
                  },
                  onHover: (value) {
                    setState(() {
                      tamanoLogout = value == true ? 1.15 : 1;
                    });
                  },
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
            height: MediaQuery.of(context).size.height * 0.90,
            child: Center(
              child: InkWell(
                onTap: () {
                  print("taller presionado");
                },
                onTapDown: (details) {
                  setState(() {
                    colorTarjeta = const Color.fromARGB(255, 198, 121, 4);
                  });
                },
                onTapUp: (details) {
                  setState(() {
                    colorTarjeta = Colors.orange;
                  });
                },
                onHover: (value) {
                  setState(() {
                    colorTarjeta = value == true ? Colors.orange : Colors.amber;
                  });
                },
                child: Card(
                  color: colorTarjeta,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.garage,
                          size: MediaQuery.of(context).size.height * 0.15,
                        ),
                        Text(
                          "Almacén de Taller Automotríz",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
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
            insetPadding: EdgeInsets.symmetric(horizontal: 100, vertical: 100),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: Text(
              "¿Salir de la Aplicación?",
              textAlign: TextAlign.center,
            ),
            content: FittedBox(
              child: Container(
                height: 50,
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
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.05),
                              )),
                          SizedBox(
                            width: 10.0,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "No",
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.05),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ));
  ;
}

class PaginacrudMovil extends StatefulWidget {
  const PaginacrudMovil({super.key});

  @override
  State<PaginacrudMovil> createState() => _PaginacrudMovilState();
}

class _PaginacrudMovilState extends State<PaginacrudMovil> {
  Color colorTarjeta = Colors.amber;
  Color? colorSalirPresionado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            height: MediaQuery.of(context).size.height * 0.10,
            color: Color(0xfff6c500),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      funcionSalir(context);
                    });
                  },
                  onTapDown: (details) {
                    setState(() {
                      colorSalirPresionado = Colors.red;
                    });
                  },
                  onTapUp: (details) {
                    setState(() {
                      colorSalirPresionado = Colors.black;
                    });
                  },
                  child: Icon(
                    Icons.logout_outlined,
                    size: MediaQuery.of(context).size.height * 0.07,
                    color: colorSalirPresionado,
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
          Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage("lib/assets/menu_wallpaper.jpg"))),
              height: MediaQuery.of(context).size.height * 0.90,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flex(
                    direction: Axis.horizontal,
                    children: [
                      InkWell(
                        onTap: () {
                          print("taller presionado");
                        },
                        onTapDown: (details) {
                          setState(() {
                            colorTarjeta = Colors.orange;
                          });
                        },
                        onTapUp: (details) {
                          setState(() {
                            colorTarjeta = Colors.amber;
                          });
                        },
                        child: Card(
                          color: colorTarjeta,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.garage,
                                  size:
                                      MediaQuery.of(context).size.height * 0.15,
                                ),
                                Text(
                                  "Almacén de Taller Automotríz",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
