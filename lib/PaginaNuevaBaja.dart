import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart'; // Para formatear fecha si es necesario

// Importar entidad BajaBien y UsuarioGlobal
import 'entity/BajaBien.dart';
import 'entity/UsuarioGlobal.dart';

class PaginaNuevaBaja extends StatefulWidget {
  const PaginaNuevaBaja({super.key});

  @override
  State<PaginaNuevaBaja> createState() => _PaginaNuevaBajaState();
}

class _PaginaNuevaBajaState extends State<PaginaNuevaBaja> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de BajaBien
  final _areaBajaController = TextEditingController();
  final _claveCentroTrabajoController = TextEditingController();
  final _personaBajaController = TextEditingController();
  final _rfcBajaController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _numeroInventarioController = TextEditingController();
  final _fechaEntregaActivosController =
      TextEditingController(); // Puede ser opcional

  @override
  void dispose() {
    // Limpiar todos los controladores
    _areaBajaController.dispose();
    _claveCentroTrabajoController.dispose();
    _personaBajaController.dispose();
    _rfcBajaController.dispose();
    _descripcionController.dispose();
    _numeroInventarioController.dispose();
    _fechaEntregaActivosController.dispose();
    super.dispose();
  }

  void _crearBaja() {
    if (_formKey.currentState!.validate()) {
      // Simulación de generación de folio (igual que en resguardos)
      final int nuevoFolio =
          DateTime.now().millisecondsSinceEpoch % 10000 + 1000;

      // Obtener nombre del usuario global
      final String? nombreCapturista = usuarioGlobal?.nombre;

      // Crear instancia de BajaBien con los datos del formulario
      final nuevaBaja = BajaBien(
        folio: nuevoFolio,
        estatus: 'Pendiente', // Estatus inicial
        capturadoPor: nombreCapturista ?? 'Desconocido', // Asignar capturista
        areaBaja: _areaBajaController.text,
        claveCentroTrabajo: _claveCentroTrabajoController.text,
        personaBaja: _personaBajaController.text,
        rfcBaja: _rfcBajaController.text,
        descripcion: _descripcionController.text,
        numeroInventario: _numeroInventarioController.text,
        // Fecha entrega es opcional, guardar solo si no está vacío
        fechaEntregaActivos: _fechaEntregaActivosController.text.trim().isEmpty
            ? null
            : _fechaEntregaActivosController.text,
        // fechaAutorizado se establecerá al aprobar/rechazar
        fechaAutorizado: null,
      );

      // Devolver la nueva baja a la página anterior
      Navigator.pop(context, nuevaBaja);
    }
  }

  // Helper para títulos de sección (igual que antes)
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

  // Función para mostrar DatePicker (opcional, para fecha entrega)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000), // Rango de fechas seleccionables
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        // Formatear la fecha como YYYY-MM-DD
        _fechaEntregaActivosController.text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nueva Baja de Bien", // Título cambiado
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
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800.w),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r)),
                child: Padding(
                  padding: EdgeInsets.all(25.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Datos del Bien a dar de Baja'),
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
                          decoration: const InputDecoration(
                              labelText: 'Descripción del Bien'),
                          maxLines: 2,
                          validator: (value) => (value?.trim().isEmpty ?? true)
                              ? 'Campo requerido'
                              : null,
                        ),
                        Divider(height: 20.h, thickness: 1),
                        _buildSectionTitle('Datos del Área que da de Baja'),
                        TextFormField(
                          controller: _areaBajaController,
                          decoration: const InputDecoration(
                              labelText: 'Área que da de Baja'),
                          validator: (value) => (value?.trim().isEmpty ?? true)
                              ? 'Campo requerido'
                              : null,
                        ),
                        SizedBox(height: 12.h),
                        TextFormField(
                          controller: _claveCentroTrabajoController,
                          decoration: const InputDecoration(
                              labelText: 'Clave de Centro de Trabajo'),
                          validator: (value) => (value?.trim().isEmpty ?? true)
                              ? 'Campo requerido'
                              : null,
                        ),
                        SizedBox(height: 12.h),
                        TextFormField(
                          controller: _personaBajaController,
                          decoration: const InputDecoration(
                              labelText: 'Nombre de quien da de Baja'),
                          validator: (value) => (value?.trim().isEmpty ?? true)
                              ? 'Campo requerido'
                              : null,
                        ),
                        SizedBox(height: 12.h),
                        TextFormField(
                          controller: _rfcBajaController,
                          decoration: const InputDecoration(
                              labelText: 'RFC de quien da de Baja'),
                          validator: (value) => (value?.trim().isEmpty ?? true)
                              ? 'Campo requerido'
                              : null,
                        ),
                        Divider(height: 20.h, thickness: 1),
                        _buildSectionTitle(
                            'Entrega a Activos Fijos (Opcional)'),
                        TextFormField(
                          controller: _fechaEntregaActivosController,
                          decoration: InputDecoration(
                              labelText: 'Fecha de Entrega a Activos Fijos',
                              hintText: 'YYYY-MM-DD',
                              suffixIcon: IconButton(
                                // Icono para abrir DatePicker
                                icon: Icon(Icons.calendar_today),
                                onPressed: () => _selectDate(context),
                              )),
                          readOnly: true, // Para forzar el uso del DatePicker
                          onTap: () =>
                              _selectDate(context), // Abrir DatePicker al tocar
                          // Sin validador, ya que es opcional
                        ),
                        SizedBox(height: 30.h),
                        Center(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.save),
                            label: const Text(
                                'Crear Solicitud de Baja'), // Texto botón
                            onPressed:
                                _crearBaja, // Llama a la función adaptada
                            style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15.h, horizontal: 30.w),
                                backgroundColor: Colors.amber, // Mismo color
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
