import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// Importa entidades y servicios necesarios
import 'entity/Resguardo.dart';
import 'entity/UsuarioGlobal.dart';
import 'services/resguardos/actualizar_resguardo.dart';
import 'services/resguardos/eliminar_resguardo.dart';
import 'services/resguardos/generar_reporte_resguardo.dart'; // Importa el servicio del reporte

// Importa 'package:web' y 'dart:js_interop' para la lógica web (se usan dentro de generar_reporte_resguardo.dart)
// No es necesario importarlos directamente aquí si ya están en el servicio.
import 'package:flutter/foundation.dart' show kIsWeb; // Para saber si es web

// Enum y clase Result para comunicar el resultado a la página anterior
enum DetalleResguardoResultAction { updated, deleted, none }

class DetalleResguardoResult {
  final DetalleResguardoResultAction action;
  final Resguardo? resguardo;
  DetalleResguardoResult(this.action, {this.resguardo});
}

class PaginaDetalleResguardo extends StatefulWidget {
  final Resguardo resguardoInicial;
  const PaginaDetalleResguardo({super.key, required this.resguardoInicial});

  @override
  State<PaginaDetalleResguardo> createState() => _PaginaDetalleResguardoState();
}

class _PaginaDetalleResguardoState extends State<PaginaDetalleResguardo> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isAdmin = false;
  bool _puedeAccionarPorEstatus = true;
  bool _isSaving = false; // Para deshabilitar botones durante operaciones async

  // Controladores
  late TextEditingController _folioController;
  late TextEditingController _numeroInventarioController;
  late TextEditingController _descripcionController;
  late TextEditingController _areaEntregaController;
  late TextEditingController _nombreEntregaController;
  late TextEditingController _rfcEntregaController;
  late TextEditingController _areaRecibeController;
  late TextEditingController _nombreRecibeController;
  late TextEditingController _rfcRecibeController;
  late TextEditingController _capturadoPorController;
  late TextEditingController _fechaAutorizadoController;
  late TextEditingController _estatusController;
  late TextEditingController _observacionesController;

  String _tipoResguardoSeleccionado = 'Traspaso de resguardo';
  bool _camposEntregaHabilitados = true;
  late Resguardo _resguardoActual;

  @override
  void initState() {
    super.initState();
    _resguardoActual = widget.resguardoInicial.copyWith();
    _isAdmin = usuarioGlobal?.roles?.contains('admin') ?? false;
    _puedeAccionarPorEstatus =
        (_resguardoActual.estatus?.toLowerCase() != 'aprobado');

    // Inicializar controladores
    final folioFormatter = NumberFormat("0000");
    _folioController =
        TextEditingController(text: _resguardoActual.folioFormateado);
    _numeroInventarioController =
        TextEditingController(text: _resguardoActual.numeroInventario);
    _descripcionController =
        TextEditingController(text: _resguardoActual.descripcion);
    _areaEntregaController =
        TextEditingController(text: _resguardoActual.areaEntrega);
    _nombreEntregaController =
        TextEditingController(text: _resguardoActual.nombreEntrega);
    _rfcEntregaController =
        TextEditingController(text: _resguardoActual.rfcEntrega);
    _areaRecibeController =
        TextEditingController(text: _resguardoActual.areaRecibe);
    _nombreRecibeController =
        TextEditingController(text: _resguardoActual.nombreRecibe);
    _rfcRecibeController =
        TextEditingController(text: _resguardoActual.rfcRecibe);
    _capturadoPorController =
        TextEditingController(text: _resguardoActual.capturadoPor ?? '');
    _fechaAutorizadoController =
        TextEditingController(text: _resguardoActual.fechaAutorizado ?? '');
    _estatusController =
        TextEditingController(text: _resguardoActual.estatus ?? 'Pendiente');
    _observacionesController =
        TextEditingController(text: _resguardoActual.observaciones ?? '');
    _tipoResguardoSeleccionado = _resguardoActual.tipoResguardo;
    _camposEntregaHabilitados =
        (_tipoResguardoSeleccionado == 'Traspaso de resguardo');
  }

  @override
  void dispose() {
    // Liberar controladores
    _folioController.dispose();
    _numeroInventarioController.dispose();
    _descripcionController.dispose();
    _areaEntregaController.dispose();
    _nombreEntregaController.dispose();
    _rfcEntregaController.dispose();
    _areaRecibeController.dispose();
    _nombreRecibeController.dispose();
    _rfcRecibeController.dispose();
    _capturadoPorController.dispose();
    _fechaAutorizadoController.dispose();
    _estatusController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (!_puedeAccionarPorEstatus && !_isEditing) return;
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _resguardoActual = widget.resguardoInicial.copyWith();
        _actualizarControladoresVisuales();
        _tipoResguardoSeleccionado = _resguardoActual.tipoResguardo;
        _camposEntregaHabilitados =
            (_tipoResguardoSeleccionado == 'Traspaso de resguardo');
        _puedeAccionarPorEstatus =
            (_resguardoActual.estatus?.toLowerCase() != 'aprobado');
      }
    });
  }

  void _actualizarControladoresVisuales() {
    _folioController.text = _resguardoActual.folioFormateado;
    _numeroInventarioController.text = _resguardoActual.numeroInventario;
    _descripcionController.text = _resguardoActual.descripcion;
    _areaEntregaController.text = _resguardoActual.areaEntrega;
    _nombreEntregaController.text = _resguardoActual.nombreEntrega;
    _rfcEntregaController.text = _resguardoActual.rfcEntrega;
    _areaRecibeController.text = _resguardoActual.areaRecibe;
    _nombreRecibeController.text = _resguardoActual.nombreRecibe;
    _rfcRecibeController.text = _resguardoActual.rfcRecibe;
    _capturadoPorController.text = _resguardoActual.capturadoPor ?? '';
    _fechaAutorizadoController.text = _resguardoActual.fechaAutorizado ?? '';
    _estatusController.text = _resguardoActual.estatus ?? 'Pendiente';
    _observacionesController.text = _resguardoActual.observaciones ?? '';
  }

  void _cambiarTipoResguardo(String? valor) {
    if (valor != null && _isEditing) {
      setState(() {
        _tipoResguardoSeleccionado = valor;
        _camposEntregaHabilitados = (valor == 'Traspaso de resguardo');
        if (!_camposEntregaHabilitados) {
          _areaEntregaController.clear();
          _nombreEntregaController.clear();
          _rfcEntregaController.clear();
        }
      });
    }
  }

  void _guardarCambios() async {
    if (_formKey.currentState!.validate() && !_isSaving) {
      if (!mounted) return;
      setState(() {
        _isSaving = true;
      });

      final String? nombreEditor = usuarioGlobal?.nombre;
      bool limpiarObservaciones = _observacionesController.text.trim().isEmpty;

      _resguardoActual = _resguardoActual.copyWith(
        tipoResguardo: _tipoResguardoSeleccionado,
        numeroInventario: _numeroInventarioController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        areaEntrega: _camposEntregaHabilitados
            ? _areaEntregaController.text.trim()
            : 'N/A',
        nombreEntrega: _camposEntregaHabilitados
            ? _nombreEntregaController.text.trim()
            : 'N/A',
        rfcEntrega: _camposEntregaHabilitados
            ? _rfcEntregaController.text.trim()
            : 'N/A',
        areaRecibe: _areaRecibeController.text.trim(),
        nombreRecibe: _nombreRecibeController.text.trim(),
        rfcRecibe: _rfcRecibeController.text.trim(),
        observaciones:
            limpiarObservaciones ? null : _observacionesController.text.trim(),
        clearObservaciones: limpiarObservaciones,
        capturadoPor: nombreEditor ?? 'Desconocido',
      );

      bool success =
          await actualizarResguardo(_resguardoActual.folio, _resguardoActual);

      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });

      if (success) {
        Navigator.pop(
            context,
            DetalleResguardoResult(DetalleResguardoResultAction.updated,
                resguardo: _resguardoActual));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al guardar los cambios. Intente de nuevo.'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _confirmarEliminar() {
    if (!_puedeAccionarPorEstatus || _isSaving) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text(
              '¿Está seguro que desea eliminar el resguardo ${_resguardoActual.folioFormateado}?'),
          actions: <Widget>[
            TextButton(
                child: Text('Cancelar'),
                onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _eliminarResguardo();
              },
            ),
          ],
        );
      },
    );
  }

  void _eliminarResguardo() async {
    if (_isSaving) return;
    if (!mounted) return;
    setState(() {
      _isSaving = true;
    });

    bool success = await eliminarResguardo(_resguardoActual.folio);

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });

    if (success) {
      Navigator.pop(
          context,
          DetalleResguardoResult(DetalleResguardoResultAction.deleted,
              resguardo: _resguardoActual));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al eliminar el resguardo. Intente de nuevo.'),
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
    // ----- FORMATO DE FECHA CORREGIDO -----
    final formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss"); // Usar 'T'
    // ------------------------------------
    bool limpiarFecha = nuevoEstatus.toLowerCase() != 'aprobado';

    final Resguardo resguardoActualizado = _resguardoActual.copyWith(
        estatus: nuevoEstatus,
        fechaAutorizado: !limpiarFecha ? formatter.format(now) : null,
        clearFechaAutorizado: limpiarFecha,
        capturadoPor: usuarioGlobal?.nombre ?? 'Desconocido');

    bool success = await actualizarResguardo(
        resguardoActualizado.folio, resguardoActualizado);

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });

    if (success) {
      setState(() {
        _resguardoActual = resguardoActualizado;
        _puedeAccionarPorEstatus = (nuevoEstatus.toLowerCase() != 'aprobado');
        _actualizarControladoresVisuales();
      });
      Future.delayed(Duration(milliseconds: 150), () {
        if (mounted) {
          Navigator.pop(
              context,
              DetalleResguardoResult(DetalleResguardoResultAction.updated,
                  resguardo: resguardoActualizado));
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al cambiar el estatus. Intente de nuevo.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // Llama al servicio para generar el PDF y manejar la descarga
  void _generarResguardoPDF() async {
    if (_isSaving) return;
    if (!mounted) return;
    setState(() {
      _isSaving = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Generando reporte PDF...'),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 2),
    ));

    bool success =
        await generarYMostrarReporteResguardo(_resguardoActual.folio);

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
      // else { Mensaje específico si implementas guardado/apertura no-web }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al generar o mostrar el reporte PDF.'),
          backgroundColor: Colors.red));
    }
  }

  // --- Widgets Helper ---
  Widget _buildSectionTitle(String title) {
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
    bool enabled = true,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    bool fieldEnabledForEditing =
        _isEditing && editable && enabled && _puedeAccionarPorEstatus;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: TextFormField(
        controller: controller,
        readOnly: !fieldEnabledForEditing,
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          contentPadding:
              EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
          filled: !enabled || !fieldEnabledForEditing,
          fillColor: (!enabled || !fieldEnabledForEditing)
              ? Colors.grey[200]
              : Colors.white,
        ),
        validator: fieldEnabledForEditing ? validator : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String folioMostrado = _folioController.text;
    bool puedeEditarEntrega =
        _isEditing && _camposEntregaHabilitados && _puedeAccionarPorEstatus;
    final bool estaAprobado =
        _resguardoActual.estatus?.toLowerCase() == 'aprobado';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detalle Resguardo: $folioMostrado",
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
              : () => Navigator.pop(context,
                  DetalleResguardoResult(DetalleResguardoResultAction.none)),
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
                            editable: false,
                            enabled: false),
                        SizedBox(height: 12.h),
                        _buildSectionTitle('Tipo de Resguardo'),
                        IgnorePointer(
                          ignoring: !_isEditing || !_puedeAccionarPorEstatus,
                          child: Opacity(
                            opacity: (_isEditing && _puedeAccionarPorEstatus)
                                ? 1.0
                                : 0.6,
                            child: Column(
                              children: [
                                RadioListTile<String>(
                                  title: const Text('Traspaso de resguardo'),
                                  value: 'Traspaso de resguardo',
                                  groupValue: _tipoResguardoSeleccionado,
                                  onChanged: _cambiarTipoResguardo,
                                  visualDensity: VisualDensity.compact,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                RadioListTile<String>(
                                  title: const Text('Nueva adquisición'),
                                  value: 'Nueva adquisición',
                                  groupValue: _tipoResguardoSeleccionado,
                                  onChanged: _cambiarTipoResguardo,
                                  visualDensity: VisualDensity.compact,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(height: 20.h, thickness: 1),
                        _buildSectionTitle('Datos del Bien'),
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
                        _buildSectionTitle('Datos de Quien Entrega'),
                        _buildInfoField(
                            label: 'Área Entrega',
                            controller: _areaEntregaController,
                            editable: true,
                            enabled: _camposEntregaHabilitados,
                            validator: (v) => (puedeEditarEntrega &&
                                    (v?.trim().isEmpty ?? true))
                                ? 'Requerido'
                                : null),
                        _buildInfoField(
                            label: 'Nombre Entrega',
                            controller: _nombreEntregaController,
                            editable: true,
                            enabled: _camposEntregaHabilitados,
                            validator: (v) => (puedeEditarEntrega &&
                                    (v?.trim().isEmpty ?? true))
                                ? 'Requerido'
                                : null),
                        _buildInfoField(
                            label: 'RFC Entrega',
                            controller: _rfcEntregaController,
                            editable: true,
                            enabled: _camposEntregaHabilitados,
                            validator: (v) => (puedeEditarEntrega &&
                                    (v?.trim().isEmpty ?? true))
                                ? 'Requerido'
                                : null),
                        Divider(height: 20.h, thickness: 1),
                        _buildSectionTitle('Datos de Quien Recibe'),
                        _buildInfoField(
                            label: 'Área Recibe',
                            controller: _areaRecibeController,
                            editable: true,
                            validator: (v) => (v?.trim().isEmpty ?? true)
                                ? 'Requerido'
                                : null),
                        _buildInfoField(
                            label: 'Nombre Recibe',
                            controller: _nombreRecibeController,
                            editable: true,
                            validator: (v) => (v?.trim().isEmpty ?? true)
                                ? 'Requerido'
                                : null),
                        _buildInfoField(
                            label: 'RFC Recibe',
                            controller: _rfcRecibeController,
                            editable: true,
                            validator: (v) => (v?.trim().isEmpty ?? true)
                                ? 'Requerido'
                                : null),
                        Divider(height: 20.h, thickness: 1),
                        _buildSectionTitle('Historial y Estatus'),
                        _buildInfoField(
                            label: 'Capturado Por',
                            controller: _capturadoPorController,
                            editable: false,
                            enabled: false),
                        _buildInfoField(
                            label: 'Fecha Autorizado',
                            controller: _fechaAutorizadoController,
                            editable: false,
                            enabled: false),
                        _buildInfoField(
                            label: 'Estatus',
                            controller: _estatusController,
                            editable: false,
                            enabled: false),
                        Divider(height: 20.h, thickness: 1),
                        _buildSectionTitle('Observaciones'),
                        _buildInfoField(
                            label: 'Observaciones',
                            controller: _observacionesController,
                            editable: true,
                            maxLines: 3),
                        SizedBox(height: 30.h),

                        // --- Botones de Acción ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (_isEditing) // Guardar
                              ElevatedButton.icon(
                                icon: Icon(Icons.save),
                                label: Text('Guardar Cambios'),
                                onPressed: _isSaving ? null : _guardarCambios,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.grey),
                              ),
                            if (_puedeAccionarPorEstatus) // Modificar
                              ElevatedButton.icon(
                                icon: Icon(Icons.edit),
                                label: Text('Modificar Folio'),
                                onPressed: _isSaving ? null : _toggleEdit,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.black,
                                    disabledBackgroundColor: Colors.grey),
                              ),
                            if (!_isEditing &&
                                _puedeAccionarPorEstatus) // Eliminar
                              ElevatedButton.icon(
                                icon: Icon(Icons.delete_forever),
                                label: Text('Eliminar Folio'),
                                onPressed:
                                    _isSaving ? null : _confirmarEliminar,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        Colors.grey.shade400),
                              ),
                            if (_isEditing) // Cancelar
                              TextButton(
                                  onPressed: _isSaving ? null : _toggleEdit,
                                  child: Text('Cancelar')),
                          ],
                        ),
                        SizedBox(height: 15.h),

                        // Botón Generar Resguardo PDF
                        if (!_isEditing && estaAprobado)
                          Center(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.picture_as_pdf),
                              label: Text('Generar Resguardo'),
                              onPressed: _isSaving
                                  ? null
                                  : _generarResguardoPDF, // Llama a la función actualizada
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.w, vertical: 12.h)),
                            ),
                          ),

                        // Botones de Admin
                        if (_isAdmin && !_isEditing)
                          Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  icon: Icon(Icons.check_circle),
                                  label: Text('Aprobar'),
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
                                  label: Text('Rechazar'),
                                  onPressed: (_resguardoActual.estatus
                                                  ?.toLowerCase() !=
                                              'rechazado' &&
                                          !_isSaving)
                                      ? () => _cambiarEstatus('Rechazado')
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Colors.grey),
                                ),
                                if (_resguardoActual.estatus?.toLowerCase() ==
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
