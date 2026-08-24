import 'package:acbmin_site/entity/Item.dart';
import 'package:acbmin_site/entity/Transaccion.dart';
import 'package:acbmin_site/services/almacen_autos/SalidaTransaccion.dart';
import 'package:acbmin_site/services/almacen_autos/buscar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:acbmin_site/ui/responsive.dart';

class Paginasalidaitem extends StatefulWidget {
  final String? serie;
  const Paginasalidaitem({super.key, this.serie});

  @override
  State<Paginasalidaitem> createState() => _PaginasalidaitemState();
}

class _PaginasalidaitemState extends State<Paginasalidaitem> {
  var formKey = GlobalKey<FormState>();
  Color colorHoverRegresar = Colors.black;
  String? serie;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    serie = widget.serie;
  }

  @override
  Widget build(BuildContext context) {
    var keyCampoSerie = new GlobalKey<FormFieldState>();
    TextEditingController controladorSerie = new TextEditingController();
    controladorSerie.text = (serie!.isEmpty ? "" : serie)!;
    TextEditingController controladorNombre = new TextEditingController();
    TextEditingController controladorDescripcion = new TextEditingController();
    TextEditingController controladorRequerimiento =
        new TextEditingController();
    TextEditingController controladorVale = new TextEditingController();
    TextEditingController controladorCantidad = new TextEditingController();
    TextEditingController controladorCantidadDisponible =
        new TextEditingController();
    TextEditingController controladorVehiculo = new TextEditingController();
    TextEditingController controladorPlaca = new TextEditingController();
    TextEditingController controladorLocalidad = new TextEditingController();
    TextEditingController controladorMarca = new TextEditingController();
    TextEditingController controladorModelo = new TextEditingController();
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 64,
            color: const Color(0xfff6c500),
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
                    size: 28,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(context.pagePadding),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(padding: EdgeInsets.symmetric(vertical: 5.h)),
                          Text(
                            "Salida de Material",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: context.isMobile ? 0 : 24),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    key: keyCampoSerie,
                                    controller: controladorSerie,
                                    validator: (value) {
                                      return value!.trim().isEmpty
                                          ? "Campo Vacío"
                                          : null;
                                    },
                                    decoration: InputDecoration(
                                        labelText: "Número de Serie",
                                        labelStyle: TextStyle(
                                            fontWeight: FontWeight.bold),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25.w),
                                            borderSide: BorderSide())),
                                  ),
                                ),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10.w)),
                                ElevatedButton(
                                    onPressed: () async {
                                      keyCampoSerie.currentState?.validate();
                                      Item? item = await buscarItem(
                                          controladorSerie.text);
                                      if (item == null) {
                                        return ventanaNoEncontrado();
                                      }
                                      controladorNombre.text = item.nombre!;
                                      controladorDescripcion.text =
                                          item.descripcion!;
                                      controladorMarca.text = item.marca!;
                                      controladorModelo.text = item.modelo!;
                                      controladorCantidadDisponible.text =
                                          item.cantidad.toString();
                                      controladorLocalidad.text =
                                          item.localidad!;
                                    },
                                    child: Icon(Icons.search))
                              ],
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: context.isMobile ? 0 : 24),
                            child: TextFormField(
                              readOnly: true,
                              controller: controladorNombre,
                              validator: (value) {
                                return value!.trim().isEmpty
                                    ? "Campo Vacío"
                                    : null;
                              },
                              decoration: InputDecoration(
                                  labelText: "Nombre",
                                  labelStyle:
                                      TextStyle(fontWeight: FontWeight.bold),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.w),
                                      borderSide: BorderSide())),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: context.isMobile ? 0 : 24),
                            child: TextFormField(
                              controller: controladorDescripcion,
                              readOnly: true,
                              validator: (value) {
                                return value!.trim().isEmpty
                                    ? "Campo Vacío"
                                    : null;
                              },
                              decoration: InputDecoration(
                                  labelText: "Descripción",
                                  labelStyle:
                                      TextStyle(fontWeight: FontWeight.bold),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.w),
                                      borderSide: BorderSide())),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: context.isMobile ? 0 : 24),
                            child: TextFormField(
                              controller: controladorMarca,
                              readOnly: true,
                              validator: (value) {
                                return value!.trim().isEmpty
                                    ? "Campo Vacío"
                                    : null;
                              },
                              decoration: InputDecoration(
                                  labelText: "Marca",
                                  labelStyle:
                                      TextStyle(fontWeight: FontWeight.bold),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.w),
                                      borderSide: BorderSide())),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: context.isMobile ? 0 : 24),
                            child: TextFormField(
                              controller: controladorModelo,
                              readOnly: true,
                              validator: (value) {
                                return value!.trim().isEmpty
                                    ? "Campo Vacío"
                                    : null;
                              },
                              decoration: InputDecoration(
                                  labelText: "Modelo",
                                  labelStyle:
                                      TextStyle(fontWeight: FontWeight.bold),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.w),
                                      borderSide: BorderSide())),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: context.isMobile ? 0 : 24),
                            child: TextFormField(
                              controller: controladorCantidadDisponible,
                              readOnly: true,
                              validator: (value) {
                                return value!.trim().isEmpty
                                    ? "Campo Vacío"
                                    : null;
                              },
                              decoration: InputDecoration(
                                  labelText: "Cantidad Disponible",
                                  labelStyle:
                                      TextStyle(fontWeight: FontWeight.bold),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.w),
                                      borderSide: BorderSide())),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: context.isMobile ? 0 : 24),
                            child: TextFormField(
                              controller: controladorLocalidad,
                              readOnly: true,
                              validator: (value) {
                                return value!.trim().isEmpty
                                    ? "Campo Vacío"
                                    : null;
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
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: context.isMobile ? 0 : 24),
                            child: TextFormField(
                              controller: controladorRequerimiento,
                              validator: (value) {
                                return value!.trim().isEmpty
                                    ? "Campo Vacío"
                                    : null;
                              },
                              decoration: InputDecoration(
                                  labelText: "Requerimiento",
                                  labelStyle:
                                      TextStyle(fontWeight: FontWeight.bold),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.w),
                                      borderSide: BorderSide())),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: context.isMobile ? 0 : 24),
                            child: TextFormField(
                              controller: controladorVale,
                              validator: (value) {
                                return value!.trim().isEmpty
                                    ? "Campo Vacío"
                                    : null;
                              },
                              decoration: InputDecoration(
                                  labelText: "Vale de Almacén",
                                  labelStyle:
                                      TextStyle(fontWeight: FontWeight.bold),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.w),
                                      borderSide: BorderSide())),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: context.isMobile ? 0 : 24),
                            child: TextFormField(
                              controller: controladorCantidad,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  return "Campo Vacío";
                                }
                                if (int.parse(value) <=
                                    int.parse(
                                        controladorCantidadDisponible.text)) {
                                  return null;
                                }
                                return "Validar Cantidades";
                              },
                              decoration: InputDecoration(
                                  labelText: "Cantidad",
                                  labelStyle:
                                      TextStyle(fontWeight: FontWeight.bold),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.w),
                                      borderSide: BorderSide())),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: context.isMobile ? 0 : 24),
                            child: TextFormField(
                              controller: controladorVehiculo,
                              validator: (value) {
                                return value!.trim().isEmpty
                                    ? "Campo Vacío"
                                    : null;
                              },
                              decoration: InputDecoration(
                                  labelText: "Vehículo",
                                  labelStyle:
                                      TextStyle(fontWeight: FontWeight.bold),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.w),
                                      borderSide: BorderSide())),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: context.isMobile ? 0 : 24),
                            child: TextFormField(
                              controller: controladorPlaca,
                              validator: (value) {
                                return value!.trim().isEmpty
                                    ? "Campo Vacío"
                                    : null;
                              },
                              decoration: InputDecoration(
                                  labelText: "Placa",
                                  labelStyle:
                                      TextStyle(fontWeight: FontWeight.bold),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.w),
                                      borderSide: BorderSide())),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h)),
                          SizedBox(
                            height: 52,
                            width: context.isMobile ? double.infinity : 220,
                            child: ElevatedButton(
                                onPressed: () async {
                                  if (!formKey.currentState!.validate()) {
                                    return null;
                                  }
                                  DateTime fecha = new DateTime.now();
                                  Transaccion transaccion = new Transaccion();
                                  transaccion.tipo = "Salida";
                                  transaccion.fecha =
                                      "${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute}:${fecha.second}";
                                  transaccion.cantidad =
                                      int.parse(controladorCantidad.text);
                                  transaccion.nombre = controladorNombre.text;
                                  transaccion.marca = controladorMarca.text;
                                  transaccion.modelo = controladorModelo.text;
                                  transaccion.serie = controladorSerie.text;
                                  transaccion.descripcion =
                                      controladorDescripcion.text;
                                  transaccion.modeloAuto =
                                      controladorVehiculo.text;
                                  transaccion.localidad =
                                      controladorLocalidad.text;
                                  transaccion.placa = controladorPlaca.text;
                                  transaccion.requerimiento =
                                      controladorRequerimiento.text;
                                  transaccion.valeAlmacen =
                                      controladorVale.text;
                                  String status =
                                      await SalidaTransaccion(transaccion);
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
                                                            "SALIDA GUARDADA EXITOSAMENTE",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize:
                                                                    0.025.sh,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                        : Text(
                                                            "ERROR, VALIDE LOS DATOS",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize:
                                                                    0.025.sh,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                    Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical:
                                                                    10.h)),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                          "OK",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize:
                                                                  0.025.sh,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
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
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.w)),
                                    Icon(
                                      Icons.save,
                                      size: 20,
                                    )
                                  ],
                                )),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h)),
                        ],
                      ),
                    ),
                  ),
                )),
          )
        ],
      ),
    );
  }

  void ventanaNoEncontrado() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            scrollable: true,
            insetPadding:
                EdgeInsets.symmetric(horizontal: 0.1.sw, vertical: 0.1.sh),
            title: Text("Error",
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 0.03.sh, fontWeight: FontWeight.bold)),
            content: Center(
              child: Text("Artículo No Encontrado, Verifique"),
            )));
  }
}
