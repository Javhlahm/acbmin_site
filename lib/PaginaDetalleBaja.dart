import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// Importar entidad BajaBien y UsuarioGlobal
import 'entity/BajaBien.dart';
import 'entity/UsuarioGlobal.dart';

// Enum y clase Result adaptados para Bajas
enum DetalleBajaResultAction { updated, deleted, none }

class DetalleBajaResult {
  final DetalleBajaResultAction action;
  final BajaBien? baja; // Cambiado a BajaBien
  DetalleBajaResult(this.action, {this.baja});
}

class PaginaDetalleBaja extends StatefulWidget {
  final BajaBien bajaInicial; // Recibe BajaBien
  const PaginaDetalleBaja({super.key, required this.bajaInicial});

  @override
  State<PaginaDetalleBaja> createState() => _PaginaDetalleBajaState();
}

class _PaginaDetalleBajaState extends State<PaginaDetalleBaja> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isAdmin = false;
  bool _puedeAccionarPorEstatus = true; // Para editar/eliminar/aprobar/rechazar

  // Controladores adaptados para BajaBien
  late TextEditingController _folioController;
  late TextEditingController _numeroInventarioController;
  late TextEditingController _descripcionController;
  late TextEditingController _areaBajaController;
  late TextEditingController _claveCentroTrabajoController;
  late TextEditingController _personaBajaController;
  late TextEditingController _rfcBajaController;
  late TextEditingController _fechaEntregaActivosController;
  late TextEditingController _capturadoPorController;
  late TextEditingController _fechaAutorizadoController;
  late TextEditingController _estatusController;

  late BajaBien _bajaActual; // Usa BajaBien

  @override
  void initState() {
    super.initState();
    _bajaActual = widget.bajaInicial.copyWith(); // Copia inicial
    _isAdmin =
        usuarioGlobal?.roles?.contains('admin') ?? false; // Verifica rol admin
    _puedeAccionarPorEstatus = (_bajaActual.estatus?.toLowerCase() !=
        'aprobado'); // No se puede accionar si está aprobado

    // Inicializar controladores con datos de _bajaActual
    final folioFormatter = NumberFormat("0000");
    _folioController = TextEditingController(
        text:
            'BICB-${folioFormatter.format(_bajaActual.folio)}'); // Formato BICB-XXXX
    _numeroInventarioController =
        TextEditingController(text: _bajaActual.numeroInventario);
    _descripcionController =
        TextEditingController(text: _bajaActual.descripcion);
    _areaBajaController = TextEditingController(text: _bajaActual.areaBaja);
    _claveCentroTrabajoController =
        TextEditingController(text: _bajaActual.claveCentroTrabajo);
    _personaBajaController =
        TextEditingController(text: _bajaActual.personaBaja);
    _rfcBajaController = TextEditingController(text: _bajaActual.rfcBaja);
    _fechaEntregaActivosController =
        TextEditingController(text: _bajaActual.fechaEntregaActivos ?? '');
    _capturadoPorController =
        TextEditingController(text: _bajaActual.capturadoPor ?? '');
    _fechaAutorizadoController =
        TextEditingController(text: _bajaActual.fechaAutorizado ?? '');
    _estatusController =
        TextEditingController(text: _bajaActual.estatus ?? 'Pendiente');
  }

  @override
  void dispose() {
    // Disponer todos los controladores
    _folioController.dispose();
    _numeroInventarioController.dispose();
    _descripcionController.dispose();
    _areaBajaController.dispose();
    _claveCentroTrabajoController.dispose();
    _personaBajaController.dispose();
    _rfcBajaController.dispose();
    _fechaEntregaActivosController.dispose();
    _capturadoPorController.dispose();
    _fechaAutorizadoController.dispose();
    _estatusController.dispose();
    super.dispose();
  }

  // Activa/desactiva el modo edición
  void _toggleEdit() {
    // No permitir editar si ya está aprobado
    if (!_puedeAccionarPorEstatus && !_isEditing) return;

    setState(() {
      _isEditing = !_isEditing;
      // Si se cancela la edición, restaurar datos originales
      if (!_isEditing) {
        _bajaActual = widget.bajaInicial.copyWith();
        _actualizarControladoresVisuales();
        // Re-evaluar si se puede accionar basado en el estatus restaurado
        _puedeAccionarPorEstatus =
            (_bajaActual.estatus?.toLowerCase() != 'aprobado');
      }
    });
  }

  // Actualiza los controladores con los datos de _bajaActual
  void _actualizarControladoresVisuales() {
    final folioFormatter = NumberFormat("0000");
    _folioController.text = 'BICB-${folioFormatter.format(_bajaActual.folio)}';
    _numeroInventarioController.text = _bajaActual.numeroInventario;
    _descripcionController.text = _bajaActual.descripcion;
    _areaBajaController.text = _bajaActual.areaBaja;
    _claveCentroTrabajoController.text = _bajaActual.claveCentroTrabajo;
    _personaBajaController.text = _bajaActual.personaBaja;
    _rfcBajaController.text = _bajaActual.rfcBaja;
    _fechaEntregaActivosController.text = _bajaActual.fechaEntregaActivos ?? '';
    _capturadoPorController.text = _bajaActual.capturadoPor ?? '';
    _fechaAutorizadoController.text = _bajaActual.fechaAutorizado ?? '';
    _estatusController.text = _bajaActual.estatus ?? 'Pendiente';
  }

  // Guarda los cambios realizados en modo edición
  void _guardarCambios() {
    if (_formKey.currentState!.validate()) {
      final String? nombreEditor = usuarioGlobal?.nombre; // Quién está editando
      bool limpiarFechaEntrega =
          _fechaEntregaActivosController.text.trim().isEmpty;

      // Crear una copia actualizada de la baja
      _bajaActual = _bajaActual.copyWith(
        numeroInventario: _numeroInventarioController.text,
        descripcion: _descripcionController.text,
        areaBaja: _areaBajaController.text,
        claveCentroTrabajo: _claveCentroTrabajoController.text,
        personaBaja: _personaBajaController.text,
        rfcBaja: _rfcBajaController.text,
        fechaEntregaActivos:
            limpiarFechaEntrega ? null : _fechaEntregaActivosController.text,
        clearFechaEntregaActivos:
            limpiarFechaEntrega, // Flag para limpiar si estaba vacío
        capturadoPor:
            nombreEditor ?? 'Desconocido', // Actualizar quién modificó
      );

      // Regresar a la página anterior con la baja actualizada
      Navigator.pop(
          context,
          DetalleBajaResult(DetalleBajaResultAction.updated,
              baja: _bajaActual));
    }
  }

  // Muestra diálogo de confirmación para eliminar
  void _confirmarEliminar() {
    // No permitir eliminar si ya está aprobado
    if (!_puedeAccionarPorEstatus) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text(
              '¿Está seguro que desea eliminar la baja ${_bajaActual.folioFormateado}? Esta acción no se puede deshacer.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra confirmación
                _eliminarBaja(); // Procede a eliminar
              },
            ),
          ],
        );
      },
    );
  }

  // Lógica para eliminar (en este caso, solo notifica a la página anterior)
  void _eliminarBaja() {
    Navigator.pop(context,
        DetalleBajaResult(DetalleBajaResultAction.deleted, baja: _bajaActual));
  }

  // Cambia el estatus (Aprobado/Rechazado/Pendiente) - Solo Admin
  void _cambiarEstatus(String nuevoEstatus) {
    if (!_isAdmin) return; // Solo admin puede cambiar estatus

    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    // Limpiar fecha autorizado si no es 'Aprobado'
    bool limpiarFecha = nuevoEstatus.toLowerCase() != 'aprobado';

    final BajaBien bajaActualizada = _bajaActual.copyWith(
        estatus: nuevoEstatus,
        // Establecer fecha autorizado solo si se aprueba
        fechaAutorizado: !limpiarFecha ? formatter.format(now) : null,
        clearFechaAutorizado:
            limpiarFecha, // Flag para limpiar si no es aprobado
        capturadoPor:
            usuarioGlobal?.nombre ?? 'Desconocido' // Quién hizo el cambio
        );

    // Actualizar estado local y salir
    setState(() {
      _bajaActual = bajaActualizada;
      // Una vez aprobado, ya no se puede accionar más
      _puedeAccionarPorEstatus = (nuevoEstatus.toLowerCase() != 'aprobado');
      _actualizarControladoresVisuales(); // Refrescar campos en UI
    });

    // Esperar un momento y luego cerrar la página devolviendo el resultado
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        Navigator.pop(
            context,
            DetalleBajaResult(DetalleBajaResultAction.updated,
                baja: bajaActualizada));
      }
    });
  }

  // Helper para títulos de sección
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

  // Helper para crear campos de texto (igual que en Resguardos)
  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    bool editable = false, // Si el campo puede ser editado en modo edición
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    VoidCallback? onTap, // Para DatePicker
    bool readOnlyOverride = false, // Para forzar readOnly (DatePicker)
  }) {
    // El campo es editable si estamos en modo edición Y el campo está marcado como editable Y se puede accionar por estatus
    bool fieldEnabledForEditing =
        _isEditing && editable && _puedeAccionarPorEstatus;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: TextFormField(
        controller: controller,
        // Solo lectura si NO está habilitado para edición O si se fuerza con override
        readOnly: !fieldEnabledForEditing || readOnlyOverride,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          contentPadding:
              EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
          // Fondo gris si no es editable
          filled: !fieldEnabledForEditing,
          fillColor: !fieldEnabledForEditing ? Colors.grey[200] : Colors.white,
          // Añadir icono si hay onTap (para DatePicker)
          suffixIcon: onTap != null
              ? IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: fieldEnabledForEditing ? onTap : null,
                )
              : null,
        ),
        validator: fieldEnabledForEditing
            ? validator
            : null, // Validador solo si es editable
        onTap:
            fieldEnabledForEditing ? onTap : null, // onTap solo si es editable
      ),
    );
  }

  // Función para mostrar DatePicker (igual que en Nueva Baja)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_fechaEntregaActivosController.text) ??
          DateTime.now(), // Usa fecha actual o la existente
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

  // Función para el botón "Generar Acta PDF" (pendiente)
  void _generarActaPDF() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Funcionalidad "Generar Acta de Baja PDF" pendiente.'),
        backgroundColor: Colors.cyan));
    // TODO: Implementar llamada a backend para generar PDF
  }

  @override
  Widget build(BuildContext context) {
    final String folioMostrado = _folioController.text;
    // Variable para saber si la baja está aprobada
    final bool estaAprobado = _bajaActual.estatus?.toLowerCase() == 'aprobado';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detalle Baja: $folioMostrado", // Título adaptado
          style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 25.0.dg),
        ),
        backgroundColor: Color(0xfff6c500),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          // Devolver 'none' si no hubo cambios
          onPressed: () => Navigator.pop(
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
                        // --- Campos del formulario ---
                        _buildInfoField(
                            label: 'Folio',
                            controller: _folioController,
                            editable: false), // No editable
                        SizedBox(height: 12.h),

                        _buildSectionTitle('Datos del Bien'),
                        _buildInfoField(
                            label: 'No. Inventario',
                            controller: _numeroInventarioController,
                            editable: true, // Editable en modo edición
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
                        _buildInfoField(
                            label: 'Área Baja',
                            controller: _areaBajaController,
                            editable: true,
                            validator: (v) => (v?.trim().isEmpty ?? true)
                                ? 'Requerido'
                                : null),
                        _buildInfoField(
                            label: 'Clave CT',
                            controller: _claveCentroTrabajoController,
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
                        _buildInfoField(
                          label: 'Fecha Entrega Activos',
                          controller: _fechaEntregaActivosController,
                          editable: true, // Editable
                          readOnlyOverride:
                              true, // Forzar solo lectura para usar DatePicker
                          onTap: () => _selectDate(context), // Abrir DatePicker
                          // Sin validador porque es opcional
                        ),
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

                        SizedBox(height: 30.h),

                        // --- Botones de Acción ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (_isEditing) // Guardar Cambios (si está editando)
                              ElevatedButton.icon(
                                icon: Icon(Icons.save),
                                label: Text('Guardar Cambios'),
                                onPressed: _guardarCambios,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white),
                              )
                            else if (_puedeAccionarPorEstatus) // Modificar (si no edita y puede accionar)
                              ElevatedButton.icon(
                                icon: Icon(Icons.edit),
                                label: Text('Modificar Baja'), // Texto cambiado
                                onPressed: _toggleEdit,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.black),
                              ),

                            // Eliminar (si no edita y puede accionar)
                            if (!_isEditing && _puedeAccionarPorEstatus)
                              ElevatedButton.icon(
                                icon: Icon(Icons.delete_forever),
                                label: Text('Eliminar Baja'), // Texto cambiado
                                onPressed: _confirmarEliminar,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white),
                              ),

                            // Cancelar (si está editando)
                            if (_isEditing)
                              TextButton(
                                  onPressed: _toggleEdit,
                                  child: Text('Cancelar')),
                          ],
                        ),
                        SizedBox(height: 15.h), // Espacio

                        // Botón Generar Acta PDF (Visible si está APROBADO y NO editando)
                        if (!_isEditing && estaAprobado)
                          Center(
                            // Centrar el botón
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.picture_as_pdf),
                              label: Text(
                                  'Generar Acta de Baja'), // Texto cambiado
                              onPressed:
                                  _generarActaPDF, // Llama a la función (pendiente)
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.teal, // Color distintivo
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.w, vertical: 12.h)),
                            ),
                          ),

                        // --- Botones de Admin (si es admin y NO está editando) ---
                        if (_isAdmin && !_isEditing)
                          Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Aprobar (habilitado si NO está aprobado)
                                ElevatedButton.icon(
                                  icon: Icon(Icons.check_circle),
                                  label: Text('Aprobar Baja'),
                                  onPressed: !estaAprobado
                                      ? () => _cambiarEstatus('Aprobado')
                                      : null, // Deshabilitado si ya está aprobado
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.grey,
                                  ),
                                ),
                                // Rechazar (habilitado si NO está rechazado)
                                ElevatedButton.icon(
                                  icon: Icon(Icons.cancel),
                                  label: Text('Rechazar Baja'),
                                  onPressed:
                                      (_bajaActual.estatus?.toLowerCase() !=
                                              'rechazado')
                                          ? () => _cambiarEstatus('Rechazado')
                                          : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.grey,
                                  ),
                                ),
                                // Poner Pendiente (Visible solo si está RECHAZADO)
                                if (_bajaActual.estatus?.toLowerCase() ==
                                    'rechazado')
                                  ElevatedButton.icon(
                                    icon: Icon(Icons.hourglass_empty),
                                    label: Text('Poner Pendiente'),
                                    onPressed: () =>
                                        _cambiarEstatus('Pendiente'),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white),
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
