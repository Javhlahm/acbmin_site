import 'package:flutter/material.dart';
import '../entity/Resguardo.dart'; // Asegúrate que la ruta sea correcta
import '../entity/UsuarioGlobal.dart'; // <-- IMPORTAR USUARIO GLOBAL
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaginaNuevoResguardo extends StatefulWidget {
  const PaginaNuevoResguardo({super.key});

  @override
  State<PaginaNuevoResguardo> createState() => _PaginaNuevoResguardoState();
}

class _PaginaNuevoResguardoState extends State<PaginaNuevoResguardo> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final _numeroInventarioController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _areaEntregaController = TextEditingController();
  final _nombreEntregaController = TextEditingController();
  final _rfcEntregaController = TextEditingController();
  final _areaRecibeController = TextEditingController();
  final _nombreRecibeController = TextEditingController();
  final _rfcRecibeController = TextEditingController();
  final _observacionesController = TextEditingController();

  // Variable de estado para el tipo de resguardo seleccionado
  String _tipoResguardoSeleccionado = 'Traspaso de resguardo';
  bool _camposEntregaHabilitados = true;

  @override
  void dispose() {
    // Limpiar controladores al destruir el widget
    _numeroInventarioController.dispose();
    _descripcionController.dispose();
    _areaEntregaController.dispose();
    _nombreEntregaController.dispose();
    _rfcEntregaController.dispose();
    _areaRecibeController.dispose();
    _nombreRecibeController.dispose();
    _rfcRecibeController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  void _cambiarTipoResguardo(String? valor) {
    if (valor != null) {
      setState(() {
        _tipoResguardoSeleccionado = valor;
        _camposEntregaHabilitados = (valor == 'Traspaso de resguardo');
        // Limpiar campos si se deshabilita
        if (!_camposEntregaHabilitados) {
          _areaEntregaController.clear();
          _nombreEntregaController.clear();
          _rfcEntregaController.clear();
        }
      });
    }
  }

  void _crearResguardo() {
    if (_formKey.currentState!.validate()) {
      // Simulación de generación de folio
      final int nuevoFolio =
          DateTime.now().millisecondsSinceEpoch % 10000 + 1000;

      // *** OBTENER NOMBRE DEL USUARIO GLOBAL ***
      final String? nombreCapturista = usuarioGlobal?.nombre;

      final nuevoResguardo = Resguardo(
        folio: nuevoFolio,
        fechaAutorizado: null,
        estatus: 'Pendiente',
        tipoResguardo: _tipoResguardoSeleccionado,
        numeroInventario: _numeroInventarioController.text,
        descripcion: _descripcionController.text,
        areaEntrega:
            _camposEntregaHabilitados ? _areaEntregaController.text : 'N/A',
        nombreEntrega:
            _camposEntregaHabilitados ? _nombreEntregaController.text : 'N/A',
        rfcEntrega:
            _camposEntregaHabilitados ? _rfcEntregaController.text : 'N/A',
        areaRecibe: _areaRecibeController.text,
        nombreRecibe: _nombreRecibeController.text,
        rfcRecibe: _rfcRecibeController.text,
        observaciones: _observacionesController.text.trim().isEmpty
            ? null
            : _observacionesController.text,
        capturadoPor:
            nombreCapturista ?? 'Desconocido', // <-- ASIGNAR NOMBRE CAPTURISTA
      );

      Navigator.pop(context, nuevoResguardo);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black54),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nuevo Resguardo Interno",
          style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 25.0.dg),
        ),
        backgroundColor: Color(0xfff6c500),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: 20.h, horizontal: 10.w), // Margen exterior
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800.w), // Ancho máximo
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r)),
                child: Padding(
                  padding: EdgeInsets.all(25.w), // Padding interno
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Tipo de Resguardo'),
                        RadioListTile<String>(
                          title: const Text('Traspaso de resguardo'),
                          value: 'Traspaso de resguardo',
                          groupValue: _tipoResguardoSeleccionado,
                          onChanged: _cambiarTipoResguardo,
                        ),
                        RadioListTile<String>(
                          title: const Text('Nueva adquisición'),
                          value: 'Nueva adquisición',
                          groupValue: _tipoResguardoSeleccionado,
                          onChanged: _cambiarTipoResguardo,
                        ),
                        Divider(height: 20.h, thickness: 1),
                        _buildSectionTitle('Datos del Bien'),
                        TextFormField(
                          controller: _numeroInventarioController,
                          decoration: const InputDecoration(
                              labelText: 'Número de Inventario'),
                          validator: (value) => (value?.trim().isEmpty ?? true)
                              ? 'Campo requerido'
                              : null,
                        ),
                        SizedBox(height: 12.h),
                        TextFormField(
                          controller: _descripcionController,
                          decoration:
                              const InputDecoration(labelText: 'Descripción'),
                          maxLines: 2,
                          validator: (value) => (value?.trim().isEmpty ?? true)
                              ? 'Campo requerido'
                              : null,
                        ),
                        Divider(height: 20.h, thickness: 1),
                        _buildSectionTitle('Datos de Quien Entrega'),
                        TextFormField(
                          controller: _areaEntregaController,
                          decoration: InputDecoration(
                              labelText: 'Área que Entrega',
                              filled: !_camposEntregaHabilitados,
                              fillColor: Colors.grey[200]),
                          enabled: _camposEntregaHabilitados,
                          validator: (value) => (_camposEntregaHabilitados &&
                                  (value?.trim().isEmpty ?? true))
                              ? 'Campo requerido'
                              : null,
                        ),
                        SizedBox(height: 12.h),
                        TextFormField(
                          controller: _nombreEntregaController,
                          decoration: InputDecoration(
                              labelText: 'Nombre de quien Entrega',
                              filled: !_camposEntregaHabilitados,
                              fillColor: Colors.grey[200]),
                          enabled: _camposEntregaHabilitados,
                          validator: (value) => (_camposEntregaHabilitados &&
                                  (value?.trim().isEmpty ?? true))
                              ? 'Campo requerido'
                              : null,
                        ),
                        SizedBox(height: 12.h),
                        TextFormField(
                          controller: _rfcEntregaController,
                          decoration: InputDecoration(
                              labelText: 'RFC de quien Entrega',
                              filled: !_camposEntregaHabilitados,
                              fillColor: Colors.grey[200]),
                          enabled: _camposEntregaHabilitados,
                          validator: (value) => (_camposEntregaHabilitados &&
                                  (value?.trim().isEmpty ?? true))
                              ? 'Campo requerido'
                              : null,
                        ),
                        Divider(height: 20.h, thickness: 1),
                        _buildSectionTitle('Datos de Quien Recibe'),
                        TextFormField(
                          controller: _areaRecibeController,
                          decoration: const InputDecoration(
                              labelText: 'Área que Recibe'),
                          validator: (value) => (value?.trim().isEmpty ?? true)
                              ? 'Campo requerido'
                              : null,
                        ),
                        SizedBox(height: 12.h),
                        TextFormField(
                          controller: _nombreRecibeController,
                          decoration: const InputDecoration(
                              labelText: 'Nombre de quien Recibe'),
                          validator: (value) => (value?.trim().isEmpty ?? true)
                              ? 'Campo requerido'
                              : null,
                        ),
                        SizedBox(height: 12.h),
                        TextFormField(
                          controller: _rfcRecibeController,
                          decoration: const InputDecoration(
                              labelText: 'RFC de quien Recibe'),
                          validator: (value) => (value?.trim().isEmpty ?? true)
                              ? 'Campo requerido'
                              : null,
                        ),
                        Divider(height: 20.h, thickness: 1),
                        _buildSectionTitle('Observaciones (Opcional)'),
                        TextFormField(
                          controller: _observacionesController,
                          decoration: const InputDecoration(
                            labelText: 'Observaciones',
                            hintText: 'Detalles adicionales...',
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(height: 30.h),
                        Center(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.save),
                            label: const Text('Crear Resguardo'),
                            onPressed: _crearResguardo,
                            style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15.h, horizontal: 30.w),
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                textStyle: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
