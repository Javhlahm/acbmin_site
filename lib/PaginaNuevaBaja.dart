// ... (imports) ...
import 'package:acbmin_site/entity/BajaBien.dart';
import 'package:acbmin_site/entity/UsuarioGlobal.dart';
import 'package:acbmin_site/services/bajas/crear_baja.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class PaginaNuevaBaja extends StatefulWidget {
  const PaginaNuevaBaja({super.key});

  @override
  State<PaginaNuevaBaja> createState() => _PaginaNuevaBajaState();
}

class _PaginaNuevaBajaState extends State<PaginaNuevaBaja> {
  final _formKey = GlobalKey<FormState>();

  // Controladores existentes...
  final _areaBajaController = TextEditingController();
  final _personaBajaController = TextEditingController();
  final _rfcBajaController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _numeroInventarioController = TextEditingController();
  final _fechaEntregaActivosController = TextEditingController();
  // --- Nuevo Controlador ---
  final _observacionesController = TextEditingController();
  // -------------------------

  bool _isSaving = false;

  @override
  void dispose() {
    // ... (dispose existentes) ...
    _areaBajaController.dispose();
    _personaBajaController.dispose();
    _rfcBajaController.dispose();
    _descripcionController.dispose();
    _numeroInventarioController.dispose();
    _fechaEntregaActivosController.dispose();
    // --- Dispose Nuevo ---
    _observacionesController.dispose();
    // ---------------------
    super.dispose();
  }

  // Modificar _crearBaja para incluir observaciones
  void _crearBaja() async {
    if (_formKey.currentState!.validate() && !_isSaving) {
      if (!mounted) return;
      setState(() {
        _isSaving = true;
      });

      final String? nombreCapturista = usuarioGlobal?.nombre;

      final nuevaBaja = BajaBien(
        folio: 0,
        estatus: 'Pendiente',
        capturadoPor: nombreCapturista ?? 'Desconocido',
        areaBaja: _areaBajaController.text.trim(),
        personaBaja: _personaBajaController.text.trim(),
        rfcBaja: _rfcBajaController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        numeroInventario: _numeroInventarioController.text.trim(),
        fechaEntregaActivos: _fechaEntregaActivosController.text.trim().isEmpty
            ? null
            : _fechaEntregaActivosController.text.trim(),
        fechaAutorizado: null,
        // --- Añadir Observaciones ---
        observaciones: _observacionesController.text.trim().isEmpty
            ? null // Enviar null si está vacío
            : _observacionesController.text.trim(),
        // --------------------------
      );

      BajaBien? bajaCreada = await crearBaja(nuevaBaja);

      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });

      if (bajaCreada != null) {
        Navigator.pop(context, bajaCreada);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al crear la baja. Intente de nuevo.'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  // ... (_buildSectionTitle, _selectDate sin cambios) ...
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _fechaEntregaActivosController.text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /* ... AppBar sin cambios ... */
        title: Text(
          "Nueva Baja de Bien",
          style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 25.0.dg),
        ),
        backgroundColor: Color(0xfff6c500),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
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
                        // ... (Campos Inventario, Descripcion) ...
                        TextFormField(
                          controller: _numeroInventarioController,
                          decoration: const InputDecoration(
                              labelText: 'Número de Inventario'),
                          enabled: !_isSaving,
                          validator: (v) => (v?.trim().isEmpty ?? true)
                              ? 'Campo requerido'
                              : null,
                        ),
                        SizedBox(height: 12.h),
                        TextFormField(
                          controller: _descripcionController,
                          decoration: const InputDecoration(
                              labelText: 'Descripción del Bien'),
                          maxLines: 2,
                          enabled: !_isSaving,
                          validator: (v) => (v?.trim().isEmpty ?? true)
                              ? 'Campo requerido'
                              : null,
                        ),

                        Divider(height: 20.h, thickness: 1),
                        _buildSectionTitle(
                            'Datos del Área o C.T. que da de Baja'),
                        // ... (Campos Area, Clave CT, Persona, RFC) ...
                        TextFormField(
                          controller: _areaBajaController,
                          decoration: const InputDecoration(
                              labelText: 'Área o C.T. que da de Baja'),
                          enabled: !_isSaving,
                          validator: (v) => (v?.trim().isEmpty ?? true)
                              ? 'Campo requerido'
                              : null,
                        ),

                        SizedBox(height: 12.h),
                        TextFormField(
                          controller: _personaBajaController,
                          decoration: const InputDecoration(
                              labelText: 'Nombre de quien da de Baja'),
                          enabled: !_isSaving,
                          validator: (v) => (v?.trim().isEmpty ?? true)
                              ? 'Campo requerido'
                              : null,
                        ),
                        SizedBox(height: 12.h),
                        TextFormField(
                          controller: _rfcBajaController,
                          decoration: const InputDecoration(
                              labelText: 'RFC de quien da de Baja'),
                          enabled: !_isSaving,
                          validator: (v) => (v?.trim().isEmpty ?? true)
                              ? 'Campo requerido'
                              : null,
                        ),

                        Divider(height: 20.h, thickness: 1),
                        _buildSectionTitle(
                            'Entrega a Activos Fijos (Opcional)'),
                        // ... (Campo Fecha Entrega con DatePicker) ...
                        TextFormField(
                          controller: _fechaEntregaActivosController,
                          decoration: InputDecoration(
                              labelText: 'Fecha de Entrega a Activos Fijos',
                              hintText: 'YYYY-MM-DD',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.calendar_today),
                                onPressed: _isSaving
                                    ? null
                                    : () => _selectDate(context),
                              )),
                          readOnly: true,
                          onTap: _isSaving ? null : () => _selectDate(context),
                          enabled: !_isSaving,
                        ),

                        // --- Añadir Sección Observaciones ---
                        Divider(height: 20.h, thickness: 1),
                        _buildSectionTitle('Observaciones (Opcional)'),
                        TextFormField(
                          controller: _observacionesController,
                          decoration: const InputDecoration(
                            labelText: 'Observaciones',
                            hintText:
                                'Motivo de la baja, detalles adicionales...',
                            alignLabelWithHint:
                                true, // Para que el label se alinee arriba en multiline
                          ),
                          maxLines: 3, // Permitir varias líneas
                          enabled: !_isSaving,
                          // No necesita validador
                        ),
                        // ------------------------------------

                        SizedBox(height: 30.h),
                        // ... (Botón Crear y progreso) ...
                        Center(
                          child: Column(
                            children: [
                              ElevatedButton.icon(
                                icon: Icon(Icons.save),
                                label: const Text('Crear Solicitud de Baja'),
                                onPressed: _isSaving ? null : _crearBaja,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 15.h, horizontal: 30.w),
                                  backgroundColor: Colors.amber,
                                  foregroundColor: Colors.black,
                                  textStyle: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold),
                                  disabledBackgroundColor: Colors.grey.shade300,
                                  disabledForegroundColor: Colors.grey.shade500,
                                ),
                              ),
                              if (_isSaving)
                                Padding(
                                  padding: EdgeInsets.only(top: 15.h),
                                  child: CircularProgressIndicator(),
                                ),
                            ],
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
