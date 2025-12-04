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
            ),

            _buildSection(
              context,
              'Control de Temperatura',
              Icons.thermostat_outlined,
              AppTheme.albaranMerma,
              'Temperaturas registradas de todos los equipos de conservación.',
              _temperatura?.camposCompletados ?? 0,
              _temperatura?.totalCampos ?? 8,
            ),

            _buildSection(
              context,
              'Control de Productos',
              Icons.inventory_2_outlined,
              AppTheme.albaranEntrada,
              'Estado y temperatura de productos almacenados en cada ubicación.',
              _producto?.camposCompletados ?? 0,
              _producto?.totalCampos ?? 16,
            ),

            _buildSection(
              context,
              'Control de Freidoras',
              Icons.restaurant_outlined,
              Colors.red,
              'Temperatura y TPM de las freidoras del establecimiento.',
              _freidora?.camposCompletados ?? 0,
              _freidora?.totalCampos ?? 4,
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
    int total,
  ) {
    final theme = Theme.of(context);
    final porcentaje = total > 0 ? (completados / total * 100).round() : 0;
    final bool estaCompleto = completados == total;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
          ],
        ),
      ),
    );
  }
}
