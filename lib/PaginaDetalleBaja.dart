// ... (imports) ...
import 'package:acbmin_site/entity/BajaBien.dart';
import 'package:acbmin_site/entity/UsuarioGlobal.dart';
import 'package:acbmin_site/services/bajas/actualizar_baja.dart';
import 'package:acbmin_site/services/bajas/eliminar_baja.dart';
import 'package:acbmin_site/services/bajas/generar_reporte_baja.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// Enum y clase Result adaptados para Bajas
enum DetalleBajaResultAction { updated, deleted, none }

class DetalleBajaResult {
  final DetalleBajaResultAction action;
  final BajaBien? baja; // Cambiado a BajaBien
  DetalleBajaResult(this.action, {this.baja});
}

class PaginaDetalleBaja extends StatefulWidget {
  final BajaBien bajaInicial;
  const PaginaDetalleBaja({super.key, required this.bajaInicial});

  @override
  State<PaginaDetalleBaja> createState() => _PaginaDetalleBajaState();
}

class _PaginaDetalleBajaState extends State<PaginaDetalleBaja> {
  // ... (Variables _formKey, _isEditing, _isAdmin, _puedeAccionar, _isSaving sin cambios) ...
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isAdmin = false;
  bool _puedeAccionarPorEstatus = true;
  bool _isSaving = false;

  // Controladores existentes...
  late TextEditingController _folioController;
  late TextEditingController _numeroInventarioController;
  late TextEditingController _descripcionController;
  late TextEditingController _areaBajaController;
  late TextEditingController _personaBajaController;
  late TextEditingController _rfcBajaController;
  late TextEditingController _fechaEntregaActivosController;
  late TextEditingController _capturadoPorController;
  late TextEditingController _fechaAutorizadoController;
  late TextEditingController _estatusController;
  // --- Nuevo Controlador ---
  late TextEditingController _observacionesController;
  // -------------------------

  late BajaBien _bajaActual;

  @override
  void initState() {
    super.initState();
    _bajaActual = widget.bajaInicial.copyWith();
    _isAdmin = usuarioGlobal?.roles?.contains('admin') ?? false;
    _puedeAccionarPorEstatus =
        (_bajaActual.estatus?.toLowerCase() != 'aprobado');

    // Inicializar controladores...
    _folioController = TextEditingController(text: _bajaActual.folioFormateado);
    _numeroInventarioController =
        TextEditingController(text: _bajaActual.numeroInventario);
    _descripcionController =
        TextEditingController(text: _bajaActual.descripcion);
    _areaBajaController = TextEditingController(text: _bajaActual.areaBaja);
    _personaBajaController =
        TextEditingController(text: _bajaActual.personaBaja);
    _rfcBajaController = TextEditingController(text: _bajaActual.rfcBaja);
    _fechaEntregaActivosController = TextEditingController(
        text: _bajaActual.fechaEntregaActivos != null
            ? DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(_bajaActual.fechaEntregaActivos!))
            : '');
    _capturadoPorController =
        TextEditingController(text: _bajaActual.capturadoPor ?? '');
    _fechaAutorizadoController = TextEditingController(
        text: _bajaActual.fechaAutorizado != null
            ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(
                _bajaActual.fechaAutorizado!.replaceFirst('T', ' ')))
            : '');
    _estatusController =
        TextEditingController(text: _bajaActual.estatus ?? 'Pendiente');
    // --- Inicializar Nuevo Controlador ---
    _observacionesController =
        TextEditingController(text: _bajaActual.observaciones ?? '');
    // -----------------------------------
  }

  @override
  void dispose() {
    // ... (dispose existentes) ...
    _folioController.dispose();
    _numeroInventarioController.dispose();
    _descripcionController.dispose();
    _areaBajaController.dispose();
    _personaBajaController.dispose();
    _rfcBajaController.dispose();
    _fechaEntregaActivosController.dispose();
    _capturadoPorController.dispose();
    _fechaAutorizadoController.dispose();
    _estatusController.dispose();
    // --- Dispose Nuevo ---
    _observacionesController.dispose();
    // ---------------------
    super.dispose();
  }

  // Modificar _toggleEdit para resetear observaciones al cancelar
  void _toggleEdit() {
    if (!_puedeAccionarPorEstatus && !_isEditing) return;
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _bajaActual =
            widget.bajaInicial.copyWith(); // Restaura desde el original
        _actualizarControladoresVisuales(); // Actualiza TODOS los campos
        _puedeAccionarPorEstatus =
            (_bajaActual.estatus?.toLowerCase() != 'aprobado');
      }
    });
  }

  // Modificar _actualizarControladoresVisuales para incluir observaciones
  void _actualizarControladoresVisuales() {
    _folioController.text = _bajaActual.folioFormateado;
    _numeroInventarioController.text = _bajaActual.numeroInventario;
    _descripcionController.text = _bajaActual.descripcion;
    _areaBajaController.text = _bajaActual.areaBaja;
    _personaBajaController.text = _bajaActual.personaBaja;
    _rfcBajaController.text = _bajaActual.rfcBaja;
    _fechaEntregaActivosController.text =
        _bajaActual.fechaEntregaActivos != null
            ? DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(_bajaActual.fechaEntregaActivos!))
            : '';
    _capturadoPorController.text = _bajaActual.capturadoPor ?? '';
    _fechaAutorizadoController.text = _bajaActual.fechaAutorizado != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(
            DateTime.parse(_bajaActual.fechaAutorizado!.replaceFirst('T', ' ')))
        : '';
    _estatusController.text = _bajaActual.estatus ?? 'Pendiente';
    // --- Actualizar Observaciones ---
    _observacionesController.text = _bajaActual.observaciones ?? '';
    // ------------------------------
  }

  // Modificar _guardarCambios para incluir observaciones
  void _guardarCambios() async {
    if (_formKey.currentState!.validate() && !_isSaving) {
      if (!mounted) return;
      setState(() {
        _isSaving = true;
      });

      final String? nombreEditor = usuarioGlobal?.nombre;
      bool limpiarFechaEntrega =
          _fechaEntregaActivosController.text.trim().isEmpty;
      // --- Flag para Observaciones ---
      bool limpiarObservaciones = _observacionesController.text.trim().isEmpty;
      // -----------------------------

      _bajaActual = _bajaActual.copyWith(
        numeroInventario: _numeroInventarioController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        areaBaja: _areaBajaController.text.trim(),
        personaBaja: _personaBajaController.text.trim(),
        rfcBaja: _rfcBajaController.text.trim(),
        fechaEntregaActivos: limpiarFechaEntrega
            ? null
            : _fechaEntregaActivosController.text.trim(),
        clearFechaEntregaActivos: limpiarFechaEntrega,
        capturadoPor: nombreEditor ?? 'Desconocido',
        // --- Añadir Observaciones al copyWith ---
        observaciones:
            limpiarObservaciones ? null : _observacionesController.text.trim(),
        clearObservaciones: limpiarObservaciones, // Pasar flag
        // ----------------------------------------
      );

      bool success = await actualizarBaja(_bajaActual.folio, _bajaActual);

      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });

      if (success) {
        Navigator.pop(
            context,
            DetalleBajaResult(DetalleBajaResultAction.updated,
                baja: _bajaActual));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al guardar los cambios.'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  // ... (_confirmarEliminar, _eliminarBaja, _cambiarEstatus, _generarActaPDF, _buildSectionTitle, _buildInfoField, _selectDate sin cambios estructurales) ...
  void _confirmarEliminar() {
    if (!_puedeAccionarPorEstatus || _isSaving) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text(
              '¿Está seguro de eliminar la baja ${_bajaActual.folioFormateado}?'),
          actions: <Widget>[
            TextButton(
                child: Text('Cancelar'),
                onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _eliminarBaja();
              },
            ),
          ],
        );
      },
    );
  }

  void _eliminarBaja() async {
    if (_isSaving) return;
    if (!mounted) return;
    setState(() {
      _isSaving = true;
    });
    bool success = await eliminarBaja(_bajaActual.folio);
    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });
    if (success) {
      Navigator.pop(
          context,
          DetalleBajaResult(DetalleBajaResultAction.deleted,
              baja: _bajaActual));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al eliminar la baja.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _cambiarEstatus(String nuevoEstatus) async {
    if (!_isAdmin || _isSaving) return;
    if (!mounted) return;
    setState(() {
      _isSaving = true;
    });

    final now = DateTime.now();
    final formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
    bool limpiarFecha = nuevoEstatus.toLowerCase() != 'aprobado';

    final BajaBien bajaActualizada = _bajaActual.copyWith(
        estatus: nuevoEstatus,
        fechaAutorizado: !limpiarFecha ? formatter.format(now) : null,
        clearFechaAutorizado: limpiarFecha,
        capturadoPor: usuarioGlobal?.nombre ?? 'Desconocido');

    bool success = await actualizarBaja(bajaActualizada.folio, bajaActualizada);

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });

    if (success) {
      setState(() {
        _bajaActual = bajaActualizada;
        _puedeAccionarPorEstatus = (nuevoEstatus.toLowerCase() != 'aprobado');
        _actualizarControladoresVisuales();
      });
      Future.delayed(Duration(milliseconds: 150), () {
        if (mounted) {
          Navigator.pop(
              context,
              DetalleBajaResult(DetalleBajaResultAction.updated,
                  baja: bajaActualizada));
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al cambiar el estatus.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _generarActaPDF() async {
    if (_isSaving) return;
    if (!mounted) return;
    setState(() {
      _isSaving = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Generando Acta de Baja PDF...'),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 2),
    ));
    bool success = await generarYMostrarReporteBaja(_bajaActual.folio);
    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (success) {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('La descarga del PDF ha comenzado.'),
            backgroundColor: Colors.green));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al generar o mostrar el Acta PDF.'),
          backgroundColor: Colors.red));
    }
  }

  Widget _buildSectionTitle(String title) {
    /* ... sin cambios ... */
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(title,
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black54)),
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    bool editable = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    bool readOnlyOverride = false,
  }) {
    /* ... sin cambios ... */
    bool fieldEnabledForEditing =
        _isEditing && editable && _puedeAccionarPorEstatus;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: TextFormField(
        controller: controller,
        readOnly: !fieldEnabledForEditing || readOnlyOverride,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          contentPadding:
              EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
          filled: !fieldEnabledForEditing,
          fillColor: !fieldEnabledForEditing ? Colors.grey[200] : Colors.white,
          suffixIcon: onTap != null
              ? IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: fieldEnabledForEditing ? onTap : null,
                )
              : null,
        ),
        validator: fieldEnabledForEditing ? validator : null,
        onTap: fieldEnabledForEditing ? onTap : null,
        enabled: !_isSaving,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    /* ... sin cambios ... */
    DateTime initial = DateTime.tryParse(_fechaEntregaActivosController.text) ??
        DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
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
    // ... (folioMostrado, estaAprobado sin cambios) ...
    final String folioMostrado = _folioController.text;
    final bool estaAprobado = _bajaActual.estatus?.toLowerCase() == 'aprobado';

    return Scaffold(
      appBar: AppBar(
        /* ... AppBar sin cambios ... */
        title: Text(
          "Detalle Baja: $folioMostrado",
          style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 25.0.dg),
        ),
        backgroundColor: Color(0xfff6c500),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _isSaving
              ? null
              : () => Navigator.pop(
                  context, DetalleBajaResult(DetalleBajaResultAction.none)),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Campos del Formulario ---
                        _buildInfoField(
                            label: 'Folio',
                            controller: _folioController,
                            editable: false),
                        SizedBox(height: 12.h),

                        _buildSectionTitle('Datos del Bien'),
                        // ... (Campos Inventario, Descripcion) ...
                        _buildInfoField(
                            label: 'No. Inventario',
                            controller: _numeroInventarioController,
                            editable: true,
                            validator: (v) => (v?.trim().isEmpty ?? true)
                                ? 'Requerido'
                                : null),
                        _buildInfoField(
                            label: 'Descripción',
                            controller: _descripcionController,
                            editable: true,
                            maxLines: 2,
                            validator: (v) => (v?.trim().isEmpty ?? true)
                                ? 'Requerido'
                                : null),

                        Divider(height: 20.h, thickness: 1),
                        _buildSectionTitle('Datos del Área que da de Baja'),
                        // ... (Campos Area, Clave CT, Persona, RFC) ...
                        _buildInfoField(
                            label: 'Área o C.T. Baja',
                            controller: _areaBajaController,
                            editable: true,
                            validator: (v) => (v?.trim().isEmpty ?? true)
                                ? 'Requerido'
                                : null),

                        _buildInfoField(
                            label: 'Persona Baja',
                            controller: _personaBajaController,
                            editable: true,
                            validator: (v) => (v?.trim().isEmpty ?? true)
                                ? 'Requerido'
                                : null),
                        _buildInfoField(
                            label: 'RFC Baja',
                            controller: _rfcBajaController,
                            editable: true,
                            validator: (v) => (v?.trim().isEmpty ?? true)
                                ? 'Requerido'
                                : null),

                        Divider(height: 20.h, thickness: 1),
                        _buildSectionTitle('Historial y Estatus'),
                        // ... (Campo Fecha Entrega con DatePicker) ...
                        _buildInfoField(
                          label: 'Fecha Entrega Activos',
                          controller: _fechaEntregaActivosController,
                          editable: true,
                          readOnlyOverride: true,
                          onTap: () => _selectDate(context),
                        ),
                        // ... (Campos Capturado Por, Fecha Autorizado, Estatus) ...
                        _buildInfoField(
                            label: 'Capturado Por',
                            controller: _capturadoPorController,
                            editable: false),
                        _buildInfoField(
                            label: 'Fecha Autorizado',
                            controller: _fechaAutorizadoController,
                            editable: false),
                        _buildInfoField(
                            label: 'Estatus',
                            controller: _estatusController,
                            editable: false),

                        // --- Añadir Sección Observaciones ---
                        Divider(height: 20.h, thickness: 1),
                        _buildSectionTitle('Observaciones'),
                        _buildInfoField(
                          label: 'Observaciones',
                          controller: _observacionesController,
                          editable: true, // Hacerlo editable en modo edición
                          maxLines: 3,
                          // Sin validador, ya que suele ser opcional
                        ),
                        // ------------------------------------

                        SizedBox(height: 30.h),

                        // --- Botones de Acción (Guardar/Modificar/Eliminar/Cancelar) ---
                        // (Sin cambios, ya manejan _isSaving)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (_isEditing)
                              ElevatedButton.icon(
                                icon: Icon(Icons.save),
                                label: Text('Guardar Cambios'),
                                onPressed: _isSaving ? null : _guardarCambios,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.grey),
                              ),
                            if (_puedeAccionarPorEstatus)
                              ElevatedButton.icon(
                                icon: Icon(Icons.edit),
                                label: Text('Modificar Baja'),
                                onPressed: _isSaving ? null : _toggleEdit,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.black,
                                    disabledBackgroundColor: Colors.grey),
                              ),
                            if (!_isEditing && _puedeAccionarPorEstatus)
                              ElevatedButton.icon(
                                icon: Icon(Icons.delete_forever),
                                label: Text('Eliminar Baja'),
                                onPressed:
                                    _isSaving ? null : _confirmarEliminar,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        Colors.grey.shade400),
                              ),
                            if (_isEditing)
                              TextButton(
                                  onPressed: _isSaving ? null : _toggleEdit,
                                  child: Text('Cancelar')),
                          ],
                        ),
                        SizedBox(height: 15.h),

                        // --- Botón Generar Acta PDF ---
                        // (Sin cambios, ya maneja _isSaving)
                        if (!_isEditing && estaAprobado)
                          Center(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.picture_as_pdf),
                              label: Text('Generar Acta de Baja'),
                              onPressed: _isSaving ? null : _generarActaPDF,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.w, vertical: 12.h)),
                            ),
                          ),

                        // --- Botones de Admin ---
                        // (Sin cambios, ya manejan _isSaving)
                        if (_isAdmin && !_isEditing)
                          Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  icon: Icon(Icons.check_circle),
                                  label: Text('Aprobar Baja'),
                                  onPressed: !estaAprobado && !_isSaving
                                      ? () => _cambiarEstatus('Aprobado')
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Colors.grey),
                                ),
                                ElevatedButton.icon(
                                  icon: Icon(Icons.cancel),
                                  label: Text('Rechazar Baja'),
                                  onPressed:
                                      (_bajaActual.estatus?.toLowerCase() !=
                                                  'rechazado' &&
                                              !_isSaving)
                                          ? () => _cambiarEstatus('Rechazado')
                                          : null,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Colors.grey),
                                ),
                                if (_bajaActual.estatus?.toLowerCase() ==
                                    'rechazado')
                                  ElevatedButton.icon(
                                    icon: Icon(Icons.hourglass_empty),
                                    label: Text('Poner Pendiente'),
                                    onPressed: _isSaving
                                        ? null
                                        : () => _cambiarEstatus('Pendiente'),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: Colors.grey),
                                  ),
                              ],
                            ),
                          ),

                        // Indicador de progreso
                        if (_isSaving)
                          Padding(
                            padding: EdgeInsets.only(top: 15.h),
                            child: Center(child: CircularProgressIndicator()),
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
