import 'package:acbmin_site/entity/Transaccion.dart';
import 'package:acbmin_site/services/almacen_autos/EntradaTransaccion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Paginaingresoitem extends StatelessWidget {
  const Paginaingresoitem({super.key});

  @override
  Widget build(BuildContext context) {
    return paginaIngresoItem();
  }
}

class paginaIngresoItem extends StatefulWidget {
  const paginaIngresoItem({super.key});

  @override
  State<paginaIngresoItem> createState() => _paginaIngresoItemState();
}

class _paginaIngresoItemState extends State<paginaIngresoItem> {
  TextEditingController controladorNombre = new TextEditingController();
  TextEditingController controladorCantidad = new TextEditingController();
  TextEditingController controladorCategoria = new TextEditingController();
  TextEditingController controladorMarca = new TextEditingController();
  TextEditingController controladorModelo = new TextEditingController();
  TextEditingController controladorSerie = new TextEditingController();
  TextEditingController controladorDescripcion = new TextEditingController();
  TextEditingController controladorVehiculo = new TextEditingController();
  TextEditingController controladorNotas = new TextEditingController();
  TextEditingController controladorLocalidad = new TextEditingController();
  Color colorHoverRegresar = Colors.black;
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var landscape =
        ScreenUtil().orientation == Orientation.landscape ? true : false;

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(15.0, 7.0, 25.0, 7.0).w,
            height: 0.10.sh,
            color: Color(0xfff6c500),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  onHover: (value) {
                    setState(() {
                      colorHoverRegresar =
                          value == true ? Colors.red : Colors.black;
                    });
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: colorHoverRegresar,
                    size: landscape ? 0.07.sh : 0.03.sh,
                  ),
                )
              ],
            ),
          ),
          Container(
            height: 0.9.sh,
            width: 1.sw,
            child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(padding: EdgeInsets.symmetric(vertical: 5.h)),
                      Text(
                        "Ingreso de Nuevo Material",
                        style: TextStyle(
                            fontSize: 20.dg, fontWeight: FontWeight.bold),
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10.h)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.h),
                        child: TextFormField(
                          controller: controladorNombre,
                          validator: (value) {
                            return value!.trim().isEmpty ? "Campo Vacío" : null;
                          },
                          decoration: InputDecoration(
                              labelText: "Nombre del Artículo",
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.w),
                                  borderSide: BorderSide())),
                        ),
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10.h)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.h),
                        child: TextFormField(
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: controladorCantidad,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Campo Vacío";
                            }
                            int? cantidad = int.tryParse(value);
                            if (cantidad == null || cantidad <= 0) {
                              return "Cantidad Inválida";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              labelText: "Cantidad del Artículo",
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.w),
                                  borderSide: BorderSide())),
                        ),
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10.h)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.h),
                        child: TextFormField(
                          controller: controladorCategoria,
                          validator: (value) {
                            return value!.trim().isEmpty ? "Campo Vacío" : null;
                          },
                          decoration: InputDecoration(
                              labelText: "Categoría del Artículo",
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.w),
                                  borderSide: BorderSide())),
                        ),
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10.h)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.h),
                        child: TextFormField(
                          controller: controladorMarca,
                          validator: (value) {
                            return value!.trim().isEmpty ? "Campo Vacío" : null;
                          },
                          decoration: InputDecoration(
                              labelText: "Marca del Artículo",
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.w),
                                  borderSide: BorderSide())),
                        ),
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10.h)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.h),
                        child: TextFormField(
                          controller: controladorModelo,
                          validator: (value) {
                            return value!.trim().isEmpty ? "Campo Vacío" : null;
                          },
                          decoration: InputDecoration(
                              labelText: "Modelo del Artículo",
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.w),
                                  borderSide: BorderSide())),
                        ),
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10.h)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.h),
                        child: TextFormField(
                          controller: controladorSerie,
                          validator: (value) {
                            return value!.trim().isEmpty ? "Campo Vacío" : null;
                          },
                          decoration: InputDecoration(
                              labelText: "Serie del Artículo",
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.w),
                                  borderSide: BorderSide())),
                        ),
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10.h)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.h),
                        child: TextFormField(
                          controller: controladorDescripcion,
                          validator: (value) {
                            return value!.trim().isEmpty ? "Campo Vacío" : null;
                          },
                          decoration: InputDecoration(
                              labelText: "Descripción del Artículo",
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.w),
                                  borderSide: BorderSide())),
                        ),
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10.h)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.h),
                        child: TextFormField(
                          controller: controladorVehiculo,
                          validator: (value) {
                            return value!.trim().isEmpty ? "Campo Vacío" : null;
                          },
                          decoration: InputDecoration(
                              labelText: "Automóvil",
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.w),
                                  borderSide: BorderSide())),
                        ),
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10.h)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.h),
                        child: TextFormField(
                          controller: controladorLocalidad,
                          validator: (value) {
                            return value!.trim().isEmpty ? "Campo Vacío" : null;
                          },
                          decoration: InputDecoration(
                              labelText: "Localidad de Almacén",
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.w),
                                  borderSide: BorderSide())),
                        ),
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10.h)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.h),
                        child: TextFormField(
                          controller: controladorNotas,
                          keyboardType: TextInputType.multiline,
                          minLines: 5,
                          maxLines: 10,
                          validator: (value) {
                            return null;
                          },
                          decoration: InputDecoration(
                              labelText: "Notas",
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.w),
                                  borderSide: BorderSide())),
                        ),
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10.h)),
                      Container(
                        height: 100.h,
                        width: 200.h,
                        child: ElevatedButton(
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) {
                                return null;
                              }
                              DateTime fecha = new DateTime.now();
                              Transaccion transaccion = new Transaccion();
                              transaccion.tipo = "Entrada";
                              transaccion.fecha =
                                  "${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute}:${fecha.second}";
                              transaccion.cantidad =
                                  int.parse(controladorCantidad.text);
                              transaccion.nombre = controladorNombre.text;
                              transaccion.categoria = controladorCategoria.text;
                              transaccion.marca = controladorMarca.text;
                              transaccion.modelo = controladorModelo.text;
                              transaccion.serie = controladorSerie.text;
                              transaccion.descripcion =
                                  controladorDescripcion.text;
                              transaccion.modeloAuto = controladorVehiculo.text;
                              transaccion.localidad = controladorLocalidad.text;
                              transaccion.notas = controladorNotas.text;
                              String status =
                                  await EntradaTransaccion(transaccion);
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        insetPadding: EdgeInsets.symmetric(
                                            horizontal: 0.1.sw,
                                            vertical: 0.33.sh),
                                        content: Container(
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                status == "OK"
                                                    ? Text(
                                                        "ARTÍCULO GUARDADO EXITOSAMENTE",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 0.025.sh,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                                    : Text(
                                                        "ERROR AL AGREGAR, VALIDE QUE NO EXISTA",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 0.025.sh,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10.h)),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      "OK",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 0.025.sh,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Guardar",
                                  style: TextStyle(
                                      fontSize: 20.dg,
                                      fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10.w)),
                                Icon(
                                  Icons.save,
                                  size: 20.dg,
                                )
                              ],
                            )),
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10.h)),
                    ],
                  ),
                )),
          )
        ],
      ),
    );
  }
}
