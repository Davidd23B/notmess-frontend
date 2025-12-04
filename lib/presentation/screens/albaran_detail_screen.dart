import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/albaran.dart';
import '../../core/constants/api_constants.dart';
import '../viewmodels/albaran_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class AlbaranDetailScreen extends StatefulWidget {
  final Albaran albaran;

  const AlbaranDetailScreen({super.key, required this.albaran});

  @override
  State<AlbaranDetailScreen> createState() => _AlbaranDetailScreenState();
}

class _AlbaranDetailScreenState extends State<AlbaranDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AlbaranViewModel>(
        context,
        listen: false,
      ).loadLineasAlbaran(widget.albaran.idAlbaran);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    Color tipoColor;
    IconData tipoIcon;
    switch (widget.albaran.tipo.toLowerCase()) {
      case 'entrada':
        tipoColor = AppTheme.albaranEntrada;
        tipoIcon = Icons.arrow_downward;
        break;
      case 'salida':
        tipoColor = AppTheme.albaranSalida;
        tipoIcon = Icons.arrow_upward;
        break;
      case 'merma':
        tipoColor = AppTheme.albaranMerma;
        tipoIcon = Icons.warning_outlined;
        break;
      default:
        tipoColor = Colors.grey;
        tipoIcon = Icons.receipt_outlined;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle del Albarán',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              final isAdmin = authViewModel.currentUser?.isAdmin ?? false;
              if (!isAdmin) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirmar eliminación'),
                      content: Text(
                        '¿Estás seguro de eliminar este albarán de ${widget.albaran.tipoFormateado}?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.error,
                          ),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    final albaranViewModel = Provider.of<AlbaranViewModel>(
                      context,
                      listen: false,
                    );
                    await albaranViewModel.deleteAlbaran(
                      widget.albaran.idAlbaran,
                    );

                    if (context.mounted) {
                      Navigator.pop(context, true);
                    }
                  }
                },
                tooltip: 'Eliminar albarán',
              );
            },
          ),
        ],
      ),
      body: Consumer<AlbaranViewModel>(
        builder: (context, albaranViewModel, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: tipoColor.withValues(alpha: 0.1),
                            child: Icon(tipoIcon, color: tipoColor),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.albaran.tipoFormateado,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateFormat.format(widget.albaran.fechaHora),
                                  style: theme.textTheme.bodyMedium,
                                ),
                                if (widget.albaran.nombreUsuario != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Por ${widget.albaran.nombreUsuario}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (widget.albaran.motivoMerma != null) ...[
                        const Divider(height: 24),
                        Text(
                          'Motivo de merma',
                          style: theme.textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.albaran.motivoMerma!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                      if (widget.albaran.observaciones != null &&
                          widget.albaran.observaciones!.isNotEmpty) ...[
                        const Divider(height: 24),
                        Text(
                          'Observaciones',
                          style: theme.textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.albaran.observaciones!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Líneas del albarán',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              if (albaranViewModel.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (albaranViewModel.lineasActuales.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No hay líneas en este albarán',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                ...albaranViewModel.lineasActuales.map((linea) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading:
                          linea.imagenProducto != null &&
                              linea.imagenProducto!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                '${ApiConstants.baseUrl}/imagenes/${linea.imagenProducto}',
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: theme
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.inventory_2_outlined,
                                      color: theme.colorScheme.primary,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.inventory_2_outlined,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                      title: Text(
                        linea.nombreProducto ?? 'Producto desconocido',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Cantidad: ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${linea.cantidad}',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
