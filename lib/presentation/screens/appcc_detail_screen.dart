import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/appcc.dart';
import '../../data/models/appcc_limpieza.dart';
import '../../data/models/appcc_temperatura.dart';
import '../../data/models/appcc_producto.dart';
import '../../data/models/appcc_freidora.dart';
import '../viewmodels/appcc_viewmodel.dart';

class AppccDetailScreen extends StatefulWidget {
  final Appcc appcc;

  const AppccDetailScreen({super.key, required this.appcc});

  @override
  State<AppccDetailScreen> createState() => _AppccDetailScreenState();
}

class _AppccDetailScreenState extends State<AppccDetailScreen> {
  AppccLimpieza? _limpieza;
  AppccTemperatura? _temperatura;
  AppccProducto? _producto;
  AppccFreidora? _freidora;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final appccViewModel = Provider.of<AppccViewModel>(context, listen: false);
    final datos = await appccViewModel.getAppccDetalle(widget.appcc.idAppcc);

    if (datos != null) {
      setState(() {
        _limpieza = datos['limpieza'];
        _temperatura = datos['temperatura'];
        _producto = datos['producto'];
        _freidora = datos['freidora'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Color _getColorTurno(String turno) {
    switch (turno) {
      case 'mañana':
        return AppTheme.albaranMerma;
      case 'tarde':
        return AppTheme.albaranSalida;
      case 'noche':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconTurno(String turno) {
    switch (turno) {
      case 'mañana':
        return Icons.wb_sunny_outlined;
      case 'tarde':
        return Icons.wb_twilight_outlined;
      case 'noche':
        return Icons.nightlight_outlined;
      default:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle APPCC')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Información general
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getColorTurno(
                            widget.appcc.turno,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getIconTurno(widget.appcc.turno),
                          color: _getColorTurno(widget.appcc.turno),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Turno ${widget.appcc.turno.toUpperCase()}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat.format(widget.appcc.fecha),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 16,
                              ),
                            ),
                            if (widget.appcc.nombreUsuario != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Por ${widget.appcc.nombreUsuario}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (widget.appcc.completado) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.albaranEntrada),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Registro completado',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (widget.appcc.observaciones != null &&
                      widget.appcc.observaciones!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Observaciones Generales',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.appcc.observaciones!,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            _buildSection(
              context,
              'Control de Limpieza',
              Icons.cleaning_services_outlined,
              AppTheme.albaranSalida,
              'Incluye limpieza de congeladores, cámaras, mesas, paredes y suelo.',
              _limpieza?.camposCompletados ?? 0,
              _limpieza?.totalCampos ?? 10,
              onTap: () => _mostrarDetalleLimpieza(context),
            ),

            _buildSection(
              context,
              'Control de Temperatura',
              Icons.thermostat_outlined,
              AppTheme.albaranMerma,
              'Temperaturas registradas de todos los equipos de conservación.',
              _temperatura?.camposCompletados ?? 0,
              _temperatura?.totalCampos ?? 8,
              onTap: () => _mostrarDetalleTemperatura(context),
            ),

            _buildSection(
              context,
              'Control de Productos',
              Icons.inventory_2_outlined,
              AppTheme.albaranEntrada,
              'Estado y temperatura de productos almacenados en cada ubicación.',
              _producto?.camposCompletados ?? 0,
              _producto?.totalCampos ?? 16,
              onTap: () => _mostrarDetalleProducto(context),
            ),

            _buildSection(
              context,
              'Control de Freidoras',
              Icons.restaurant_outlined,
              Colors.red,
              'Temperatura y TPM de las freidoras del establecimiento.',
              _freidora?.camposCompletados ?? 0,
              _freidora?.totalCampos ?? 4,
              onTap: () => _mostrarDetalleFreidora(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String description,
    int completados,
    int total, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final porcentaje = total > 0 ? (completados / total * 100).round() : 0;
    final bool estaCompleto = completados == total;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          estaCompleto
                              ? Icons.check_circle
                              : Icons.pending_outlined,
                          color: estaCompleto
                              ? Colors.green.shade600
                              : Colors.orange.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$completados/$total campos',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: estaCompleto
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '($porcentaje%)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalleLimpieza(BuildContext context) {
    if (_limpieza == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                children: [
                  Icon(Icons.cleaning_services_outlined, color: AppTheme.albaranSalida, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Control de Limpieza',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildCheckItem('Congelador 1', _limpieza!.congelador1),
              _buildCheckItem('Congelador 2', _limpieza!.congelador2),
              _buildCheckItem('Congelador 3', _limpieza!.congelador3),
              _buildCheckItem('Cámara 1', _limpieza!.camara1),
              _buildCheckItem('Cámara 2', _limpieza!.camara2),
              _buildCheckItem('Mesa 1', _limpieza!.mesa1),
              _buildCheckItem('Mesa 2', _limpieza!.mesa2),
              _buildCheckItem('Mesa 3', _limpieza!.mesa3),
              _buildCheckItem('Paredes', _limpieza!.paredes),
              _buildCheckItem('Suelo', _limpieza!.suelo),
              if (_limpieza!.observaciones != null && _limpieza!.observaciones!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text('Observaciones:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(_limpieza!.observaciones!, style: const TextStyle(fontSize: 14)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalleTemperatura(BuildContext context) {
    if (_temperatura == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                children: [
                  Icon(Icons.thermostat_outlined, color: AppTheme.albaranMerma, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Control de Temperatura',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTempItem('Congelador 1', _temperatura!.congelador1),
              _buildTempItem('Congelador 2', _temperatura!.congelador2),
              _buildTempItem('Congelador 3', _temperatura!.congelador3),
              _buildTempItem('Cámara 1', _temperatura!.camara1),
              _buildTempItem('Cámara 2', _temperatura!.camara2),
              _buildTempItem('Mesa 1', _temperatura!.mesa1),
              _buildTempItem('Mesa 2', _temperatura!.mesa2),
              _buildTempItem('Mesa 3', _temperatura!.mesa3),
              if (_temperatura!.observaciones != null && _temperatura!.observaciones!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text('Observaciones:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(_temperatura!.observaciones!, style: const TextStyle(fontSize: 14)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalleProducto(BuildContext context) {
    if (_producto == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: AppTheme.albaranEntrada, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Control de Productos',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildProductoItem('Congelador 1', _producto!.estadoProductoCongelador1, _producto!.temperaturaProductoCongelador1),
              _buildProductoItem('Congelador 2', _producto!.estadoProductoCongelador2, _producto!.temperaturaProductoCongelador2),
              _buildProductoItem('Congelador 3', _producto!.estadoProductoCongelador3, _producto!.temperaturaProductoCongelador3),
              _buildProductoItem('Cámara 1', _producto!.estadoProductoCamara1, _producto!.temperaturaProductoCamara1),
              _buildProductoItem('Cámara 2', _producto!.estadoProductoCamara2, _producto!.temperaturaProductoCamara2),
              _buildProductoItem('Mesa 1', _producto!.estadoProductoMesa1, _producto!.temperaturaProductoMesa1),
              _buildProductoItem('Mesa 2', _producto!.estadoProductoMesa2, _producto!.temperaturaProductoMesa2),
              _buildProductoItem('Mesa 3', _producto!.estadoProductoMesa3, _producto!.temperaturaProductoMesa3),
              if (_producto!.observaciones != null && _producto!.observaciones!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text('Observaciones:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(_producto!.observaciones!, style: const TextStyle(fontSize: 14)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalleFreidora(BuildContext context) {
    if (_freidora == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                children: [
                  const Icon(Icons.restaurant_outlined, color: Colors.red, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Control de Freidoras',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildFreidoraItem('Freidora 1', _freidora!.temperaturaFreidora1, _freidora!.tpmFreidora1),
              const SizedBox(height: 16),
              _buildFreidoraItem('Freidora 2', _freidora!.temperaturaFreidora2, _freidora!.tpmFreidora2),
              if (_freidora!.observaciones != null && _freidora!.observaciones!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text('Observaciones:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(_freidora!.observaciones!, style: const TextStyle(fontSize: 14)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem(String label, bool? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            value == true ? Icons.check_circle : value == false ? Icons.cancel : Icons.help_outline,
            color: value == true ? Colors.green : value == false ? Colors.red : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value == true ? 'Limpio' : value == false ? 'Sucio' : 'Sin datos',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: value == true ? Colors.green : value == false ? Colors.red : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTempItem(String label, double? temp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.albaranMerma.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              temp != null ? '${temp.toStringAsFixed(1)}°C' : 'Sin datos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: temp != null ? AppTheme.albaranMerma : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductoItem(String label, String? estado, double? temp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estado:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      estado ?? 'Sin datos',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Temperatura:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.albaranMerma.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      temp != null ? '${temp.toStringAsFixed(1)}°C' : 'N/A',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: temp != null ? AppTheme.albaranMerma : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildFreidoraItem(String label, double? temperatura, double? tpm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Temperatura:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      temperatura != null ? '${temperatura.toStringAsFixed(1)}°C' : 'Sin datos',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('TPM:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    tpm != null ? tpm.toStringAsFixed(0) : 'Sin datos',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
