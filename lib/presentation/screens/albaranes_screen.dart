import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/albaran_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'albaran_create_screen.dart';
import 'albaran_detail_screen.dart';

class AlbaranesScreen extends StatefulWidget {
  const AlbaranesScreen({super.key});

  @override
  State<AlbaranesScreen> createState() => _AlbaranesScreenState();
}

class _AlbaranesScreenState extends State<AlbaranesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<AlbaranViewModel>(context, listen: false);
      viewModel.limpiarFiltros(); // Limpiar filtros al entrar al módulo
      viewModel.loadAlbaranes();
    });
  }

  Future<void> _seleccionarFecha(BuildContext context, bool esDesde) async {
    final albaranViewModel = Provider.of<AlbaranViewModel>(
      context,
      listen: false,
    );
    final fechaInicial = esDesde
        ? albaranViewModel.fechaDesde ?? DateTime.now()
        : albaranViewModel.fechaHasta ?? DateTime.now();

    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'ES'),
      helpText: esDesde ? 'Fecha desde' : 'Fecha hasta',
      cancelText: 'Cancelar',
      confirmText: 'Seleccionar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryOrange,
                backgroundColor: AppTheme.backgroundLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(
                    color: AppTheme.primaryOrangeLight,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha != null) {
      if (esDesde) {
        albaranViewModel.setFechaDesde(fecha);
      } else {
        albaranViewModel.setFechaHasta(fecha);
      }
    }
  }

  void _mostrarFiltros() {
    final theme = Theme.of(context);
    final albaranViewModel = Provider.of<AlbaranViewModel>(
      context,
      listen: false,
    );

    String? tipoTemp = albaranViewModel.tipoFiltro;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra superior
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Filtrar albaranes',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              Consumer<AlbaranViewModel>(
                builder: (context, albaranViewModel, child) {
                  final dateFormat = DateFormat('dd/MM/yyyy');
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rango de fechas',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _seleccionarFecha(context, true),
                              icon: const Icon(Icons.calendar_today, size: 18),
                              label: Text(
                                albaranViewModel.fechaDesde != null
                                    ? dateFormat.format(
                                        albaranViewModel.fechaDesde!,
                                      )
                                    : 'Desde',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _seleccionarFecha(context, false),
                              icon: const Icon(Icons.calendar_today, size: 18),
                              label: Text(
                                albaranViewModel.fechaHasta != null
                                    ? dateFormat.format(
                                        albaranViewModel.fechaHasta!,
                                      )
                                    : 'Hasta',
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (albaranViewModel.fechaDesde != null ||
                          albaranViewModel.fechaHasta != null) ...[
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              albaranViewModel.clearFiltrosFecha();
                            },
                            icon: const Icon(Icons.clear, size: 18),
                            label: const Text('Limpiar fechas'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        'Tipo de albarán',
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('Todos'),
                            selected: tipoTemp == null,
                            onSelected: (_) {
                              setModalState(() => tipoTemp = null);
                              albaranViewModel.setTipoFiltro(null);
                            },
                            side: tipoTemp == null
                                ? const BorderSide(
                                    color: AppTheme.filterBorderSelected,
                                    width: 2.5,
                                  )
                                : null,
                          ),
                          FilterChip(
                            label: const Text('Entradas'),
                            avatar: const Icon(Icons.arrow_downward, size: 18),
                            selected: tipoTemp == 'entrada',
                            onSelected: (_) {
                              setModalState(() => tipoTemp = 'entrada');
                              albaranViewModel.setTipoFiltro('entrada');
                            },
                            backgroundColor: Colors.green.withValues(
                              alpha: 0.1,
                            ),
                            selectedColor: Colors.green.withValues(alpha: 0.3),
                            side: tipoTemp == 'entrada'
                                ? const BorderSide(
                                    color: AppTheme.filterBorderSelected,
                                    width: 2.5,
                                  )
                                : null,
                          ),
                          FilterChip(
                            label: const Text('Salidas'),
                            avatar: const Icon(Icons.arrow_upward, size: 18),
                            selected: tipoTemp == 'salida',
                            onSelected: (_) {
                              setModalState(() => tipoTemp = 'salida');
                              albaranViewModel.setTipoFiltro('salida');
                            },
                            backgroundColor: Colors.blue.withValues(alpha: 0.1),
                            selectedColor: Colors.blue.withValues(alpha: 0.3),
                            side: tipoTemp == 'salida'
                                ? const BorderSide(
                                    color: AppTheme.filterBorderSelected,
                                    width: 2.5,
                                  )
                                : null,
                          ),
                          FilterChip(
                            label: const Text('Mermas'),
                            avatar: const Icon(
                              Icons.warning_outlined,
                              size: 18,
                            ),
                            selected: tipoTemp == 'merma',
                            onSelected: (_) {
                              setModalState(() => tipoTemp = 'merma');
                              albaranViewModel.setTipoFiltro('merma');
                            },
                            backgroundColor: Colors.orange.withValues(
                              alpha: 0.1,
                            ),
                            selectedColor: Colors.orange.withValues(alpha: 0.3),
                            side: tipoTemp == 'merma'
                                ? const BorderSide(
                                    color: AppTheme.filterBorderSelected,
                                    width: 2.5,
                                  )
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                albaranViewModel.setTipoFiltro(null);
                                albaranViewModel.clearFiltrosFecha();
                                setModalState(() {
                                  tipoTemp = null;
                                });
                              },
                              child: const Text(
                                'Limpiar todo',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Cerrar',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Albaranes',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer<AlbaranViewModel>(
            builder: (context, albaranViewModel, child) {
              final hayFiltros =
                  albaranViewModel.tipoFiltro != null ||
                  albaranViewModel.fechaDesde != null ||
                  albaranViewModel.fechaHasta != null;

              return IconButton(
                onPressed: _mostrarFiltros,
                icon: Badge(
                  isLabelVisible: hayFiltros,
                  child: const Icon(Icons.filter_list_outlined),
                ),
                tooltip: 'Filtros',
              );
            },
          ),
        ],
      ),
      body: Consumer<AlbaranViewModel>(
        builder: (context, albaranViewModel, child) {
          if (albaranViewModel.isLoading &&
              albaranViewModel.albaranes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              if (albaranViewModel.tipoFiltro != null ||
                  albaranViewModel.fechaDesde != null ||
                  albaranViewModel.fechaHasta != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  width: double.infinity,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (albaranViewModel.tipoFiltro != null)
                        Chip(
                          avatar: const Icon(Icons.filter_alt, size: 18),
                          label: Text('Tipo: ${albaranViewModel.tipoFiltro}'),
                          onDeleted: () => albaranViewModel.setTipoFiltro(null),
                          deleteIcon: const Icon(Icons.close, size: 18),
                        ),
                      if (albaranViewModel.fechaDesde != null)
                        Chip(
                          avatar: const Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            'Desde: ${DateFormat('dd/MM/yy').format(albaranViewModel.fechaDesde!)}',
                          ),
                          onDeleted: () => albaranViewModel.setFechaDesde(null),
                          deleteIcon: const Icon(Icons.close, size: 18),
                        ),
                      if (albaranViewModel.fechaHasta != null)
                        Chip(
                          avatar: const Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            'Hasta: ${DateFormat('dd/MM/yy').format(albaranViewModel.fechaHasta!)}',
                          ),
                          onDeleted: () => albaranViewModel.setFechaHasta(null),
                          deleteIcon: const Icon(Icons.close, size: 18),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: albaranViewModel.albaranes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay albaranes',
                              style: theme.textTheme.titleMedium,
                            ),
                            if (albaranViewModel.tipoFiltro != null ||
                                albaranViewModel.fechaDesde != null ||
                                albaranViewModel.fechaHasta != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Prueba con otros filtros',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => albaranViewModel.loadAlbaranes(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: albaranViewModel.albaranes.length,
                          itemBuilder: (context, index) {
                            final albaran = albaranViewModel.albaranes[index];
                            final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

                            Color tipoColor;
                            IconData tipoIcon;
                            switch (albaran.tipo.toLowerCase()) {
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

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AlbaranDetailScreen(albaran: albaran),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: tipoColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        child: Icon(
                                          tipoIcon,
                                          color: tipoColor,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              albaran.tipoFormateado,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              dateFormat.format(
                                                albaran.fechaHora,
                                              ),
                                              style: theme.textTheme.bodyLarge,
                                            ),
                                            if (albaran.nombreUsuario !=
                                                null) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                'Por ${albaran.nombreUsuario}',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                      fontSize: 13,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                              ),
                                            ],
                                            if (albaran.motivoMerma !=
                                                null) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                'Motivo: ${albaran.motivoMerma}',
                                                style: TextStyle(
                                                  color:
                                                      theme.colorScheme.error,
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Consumer<AuthViewModel>(
                                        builder: (context, authViewModel, child) {
                                          final isAdmin =
                                              authViewModel
                                                  .currentUser
                                                  ?.isAdmin ??
                                              false;
                                          if (!isAdmin) {
                                            return Icon(
                                              Icons.chevron_right,
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            );
                                          }

                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete_outline,
                                                  color:
                                                      theme.colorScheme.error,
                                                ),
                                                onPressed: () async {
                                                  final confirm = await showDialog<bool>(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: const Text(
                                                        'Confirmar eliminación',
                                                      ),
                                                      content: Text(
                                                        '¿Estás seguro de eliminar este albarán de ${albaran.tipoFormateado}?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                                false,
                                                              ),
                                                          child: const Text(
                                                            'Cancelar',
                                                          ),
                                                        ),
                                                        FilledButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                                true,
                                                              ),
                                                          style:
                                                              FilledButton.styleFrom(
                                                                backgroundColor:
                                                                    AppTheme
                                                                        .error,
                                                              ),
                                                          child: const Text(
                                                            'Eliminar',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );

                                                  if (confirm == true &&
                                                      context.mounted) {
                                                    await albaranViewModel
                                                        .deleteAlbaran(
                                                          albaran.idAlbaran,
                                                        );
                                                  }
                                                },
                                              ),
                                              Icon(
                                                Icons.chevron_right,
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AlbaranCreateScreen()),
          );
          if (result == true) {
            if (!context.mounted) return;
            Provider.of<AlbaranViewModel>(
              context,
              listen: false,
            ).loadAlbaranes();
          }
        },
        tooltip: 'Nuevo albarán',
        child: const Icon(Icons.add, size: 36),
      ),
    );
  }
}
