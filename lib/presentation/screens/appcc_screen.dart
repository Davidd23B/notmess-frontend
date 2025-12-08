import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/appcc_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'appcc_form_screen.dart';
import 'appcc_detail_screen.dart';

class AppccScreen extends StatefulWidget {
  const AppccScreen({super.key});

  @override
  State<AppccScreen> createState() => _AppccScreenState();
}

class _AppccScreenState extends State<AppccScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<AppccViewModel>(context, listen: false);
      viewModel.limpiarFiltros();
      viewModel.loadAppccList();
    });
  }

  bool _esMismoDia(DateTime fecha1, DateTime fecha2) {
    return fecha1.year == fecha2.year &&
        fecha1.month == fecha2.month &&
        fecha1.day == fecha2.day;
  }

  Color _getColorTurno(String turno) {
    switch (turno) {
      case 'mañana':
        return AppTheme.albaranMerma;
      case 'tarde':
        return AppTheme.albaranSalida;
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
      default:
        return Icons.access_time;
    }
  }

  Future<void> _seleccionarFecha(BuildContext context, bool esDesde) async {
    final appccViewModel = Provider.of<AppccViewModel>(context, listen: false);
    final fechaInicial = esDesde
        ? appccViewModel.fechaDesde ?? DateTime.now()
        : appccViewModel.fechaHasta ?? DateTime.now();

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
        appccViewModel.setFechaDesde(fecha);
      } else {
        appccViewModel.setFechaHasta(fecha);
      }
    }
  }

  void _mostrarFiltros() {
    final theme = Theme.of(context);
    final appccViewModel = Provider.of<AppccViewModel>(context, listen: false);

    String? turnoTemp = appccViewModel.turnoFiltro;

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
                'Filtrar registros APPCC',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              Consumer<AppccViewModel>(
                builder: (context, appccViewModel, child) {
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
                                appccViewModel.fechaDesde != null
                                    ? dateFormat.format(
                                        appccViewModel.fechaDesde!,
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
                                appccViewModel.fechaHasta != null
                                    ? dateFormat.format(
                                        appccViewModel.fechaHasta!,
                                      )
                                    : 'Hasta',
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (appccViewModel.fechaDesde != null ||
                          appccViewModel.fechaHasta != null) ...[
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              appccViewModel.clearFiltrosFecha();
                            },
                            icon: const Icon(Icons.clear, size: 18),
                            label: const Text('Limpiar fechas'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text('Turno', style: theme.textTheme.labelLarge),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('Todos'),
                            selected: turnoTemp == null,
                            showCheckmark: false,
                            onSelected: (_) {
                              setModalState(() => turnoTemp = null);
                              appccViewModel.filtrarPorTurno(null);
                            },
                            side: turnoTemp == null
                                ? const BorderSide(
                                    color: AppTheme.filterBorderSelected,
                                    width: 2.5,
                                  )
                                : null,
                          ),
                          FilterChip(
                            label: const Text('Mañana'),
                            avatar: const Icon(
                              Icons.wb_sunny_outlined,
                              size: 18,
                            ),
                            selected: turnoTemp == 'mañana',
                            showCheckmark: false,
                            onSelected: (_) {
                              setModalState(() => turnoTemp = 'mañana');
                              appccViewModel.filtrarPorTurno('mañana');
                            },
                            backgroundColor: Colors.orange.withValues(
                              alpha: 0.1,
                            ),
                            selectedColor: Colors.orange.withValues(alpha: 0.3),
                            side: turnoTemp == 'mañana'
                                ? const BorderSide(
                                    color: AppTheme.filterBorderSelected,
                                    width: 2.5,
                                  )
                                : null,
                          ),
                          FilterChip(
                            label: const Text('Tarde'),
                            avatar: const Icon(
                              Icons.wb_twilight_outlined,
                              size: 18,
                            ),
                            selected: turnoTemp == 'tarde',
                            showCheckmark: false,
                            onSelected: (_) {
                              setModalState(() => turnoTemp = 'tarde');
                              appccViewModel.filtrarPorTurno('tarde');
                            },
                            backgroundColor: Colors.blue.withValues(alpha: 0.1),
                            selectedColor: Colors.blue.withValues(alpha: 0.3),
                            side: turnoTemp == 'tarde'
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
                                appccViewModel.filtrarPorTurno(null);
                                appccViewModel.clearFiltrosFecha();
                                setModalState(() {
                                  turnoTemp = null;
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
    final appccViewModel = Provider.of<AppccViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Control APPCC',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer<AppccViewModel>(
            builder: (context, appccViewModel, child) {
              final hayFiltros =
                  appccViewModel.turnoFiltro != null ||
                  appccViewModel.fechaDesde != null ||
                  appccViewModel.fechaHasta != null;

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
      body: RefreshIndicator(
        onRefresh: () => appccViewModel.loadAppccList(),
        child: appccViewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (appccViewModel.turnoFiltro != null ||
                      appccViewModel.fechaDesde != null ||
                      appccViewModel.fechaHasta != null)
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
                          if (appccViewModel.turnoFiltro != null)
                            Chip(
                              avatar: const Icon(Icons.filter_alt, size: 18),
                              label: Text(
                                'Turno: ${appccViewModel.turnoFiltro}',
                              ),
                              onDeleted: () =>
                                  appccViewModel.filtrarPorTurno(null),
                              deleteIcon: const Icon(Icons.close, size: 18),
                            ),
                          if (appccViewModel.fechaDesde != null)
                            Chip(
                              avatar: const Icon(
                                Icons.calendar_today,
                                size: 18,
                              ),
                              label: Text(
                                'Desde: ${DateFormat('dd/MM/yy').format(appccViewModel.fechaDesde!)}',
                              ),
                              onDeleted: () =>
                                  appccViewModel.setFechaDesde(null),
                              deleteIcon: const Icon(Icons.close, size: 18),
                            ),
                          if (appccViewModel.fechaHasta != null)
                            Chip(
                              avatar: const Icon(
                                Icons.calendar_today,
                                size: 18,
                              ),
                              label: Text(
                                'Hasta: ${DateFormat('dd/MM/yy').format(appccViewModel.fechaHasta!)}',
                              ),
                              onDeleted: () =>
                                  appccViewModel.setFechaHasta(null),
                              deleteIcon: const Icon(Icons.close, size: 18),
                            ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: appccViewModel.appccList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 64,
                                  color: theme.colorScheme.outline,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay registros APPCC',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (appccViewModel.turnoFiltro != null ||
                                    appccViewModel.fechaDesde != null ||
                                    appccViewModel.fechaHasta != null)
                                  Text(
                                    'Prueba con otros filtros',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.outline,
                                    ),
                                  )
                                else
                                  Text(
                                    'Crea el primer registro',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: appccViewModel.appccList.length,
                            itemBuilder: (context, index) {
                              final appcc = appccViewModel.appccList[index];
                              final colorTurno = _getColorTurno(appcc.turno);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AppccDetailScreen(appcc: appcc),
                                      ),
                                    );
                                    if (context.mounted) {
                                      Provider.of<AppccViewModel>(
                                        context,
                                        listen: false,
                                      ).loadAppccList();
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: colorTurno.withValues(
                                                  alpha: 0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                _getIconTurno(appcc.turno),
                                                color: colorTurno,
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
                                                    'Turno ${appcc.turno.toUpperCase()}',
                                                    style: theme
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    dateFormat.format(
                                                      appcc.fecha,
                                                    ),
                                                    style: theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color: theme
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                          fontSize: 14,
                                                        ),
                                                  ),
                                                  if (appcc.nombreUsuario !=
                                                      null) ...[
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'Por ${appcc.nombreUsuario}',
                                                      style: theme
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: theme
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                            fontSize: 13,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: appcc.completado
                                                    ? Colors.green.withValues(
                                                        alpha: 0.1,
                                                      )
                                                    : Colors.orange.withValues(
                                                        alpha: 0.1,
                                                      ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: appcc.completado
                                                      ? AppTheme.albaranEntrada
                                                      : AppTheme.albaranMerma,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    appcc.completado
                                                        ? Icons
                                                              .check_circle_outline
                                                        : Icons.hourglass_empty,
                                                    size: 16,
                                                    color: appcc.completado
                                                        ? Colors.green.shade700
                                                        : Colors
                                                              .orange
                                                              .shade700,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    appcc.completado
                                                        ? 'Completado'
                                                        : 'Pendiente',
                                                    style: TextStyle(
                                                      color: appcc.completado
                                                          ? Colors
                                                                .green
                                                                .shade700
                                                          : Colors
                                                                .orange
                                                                .shade700,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            if (_esMismoDia(
                                              appcc.fecha,
                                              DateTime.now(),
                                            ))
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  onPressed: () async {
                                                    final result =
                                                        await Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (_) =>
                                                                AppccFormScreen(
                                                                  appcc: appcc,
                                                                ),
                                                          ),
                                                        );
                                                    if (result == true) {
                                                      appccViewModel
                                                          .loadAppccList();
                                                    }
                                                  },
                                                  icon: const Icon(
                                                    Icons.edit_outlined,
                                                    size: 18,
                                                  ),
                                                  label: const Text('Editar'),
                                                ),
                                              ),
                                            if (_esMismoDia(
                                              appcc.fecha,
                                              DateTime.now(),
                                            ))
                                              const SizedBox(width: 8)
                                            else
                                              const Spacer(),
                                            if (authViewModel.isAdmin)
                                              IconButton(
                                                onPressed: () async {
                                                  final confirm = await showDialog<bool>(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: const Text(
                                                        'Eliminar registro',
                                                      ),
                                                      content: const Text(
                                                        '\u00bfEst\u00e1s seguro de eliminar este registro APPCC?',
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
                                                          style: FilledButton.styleFrom(
                                                            backgroundColor:
                                                                theme
                                                                    .colorScheme
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
                                                    await appccViewModel
                                                        .deleteAppcc(
                                                          appcc.idAppcc,
                                                        );
                                                  }
                                                },
                                                icon: Icon(
                                                  Icons.delete_outline,
                                                  color:
                                                      theme.colorScheme.error,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: Consumer<AppccViewModel>(
        builder: (context, appccViewModel, child) {
          final hoy = DateTime.now();
          final appccHoy = appccViewModel.appccList.where((appcc) {
            return _esMismoDia(appcc.fecha, hoy);
          }).length;

          if (appccHoy >= 2) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AppccFormScreen()),
              );
              if (result == true) {
                appccViewModel.loadAppccList();
              }
            },
            tooltip: 'Nuevo APPCC',
            child: const Icon(Icons.add, size: 36),
          );
        },
      ),
    );
  }
}
