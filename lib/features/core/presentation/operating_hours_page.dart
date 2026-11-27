import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_page_header.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_time_picker_sheet.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_toast.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/manage_operating_hours.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';

/// Owner/Manager configuration screen for weekly operating hours and
/// holiday/special-date exceptions (`operating-hours.md`).
class OperatingHoursPage extends StatefulWidget {
  final String branchId;
  final String? workshopId;
  final ManageOperatingHoursUseCase? manageOperatingHours;

  const OperatingHoursPage({
    super.key,
    required this.branchId,
    this.workshopId,
    this.manageOperatingHours,
  });

  @override
  State<OperatingHoursPage> createState() => _OperatingHoursPageState();
}

class _OperatingHoursPageState extends State<OperatingHoursPage> {
  late final ManageOperatingHoursUseCase? _useCase;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _workshopScope = false;

  List<OperatingHoursDay> _days = const [];
  List<OperatingHoursException> _exceptions = const [];

  static const Map<String, String> _dayLabels = {
    'MONDAY': 'Lunes',
    'TUESDAY': 'Martes',
    'WEDNESDAY': 'Miércoles',
    'THURSDAY': 'Jueves',
    'FRIDAY': 'Viernes',
    'SATURDAY': 'Sábado',
    'SUNDAY': 'Domingo',
  };

  bool get _hasWorkshop =>
      widget.workshopId != null && widget.workshopId!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _useCase = widget.manageOperatingHours ??
        (getIt.isRegistered<ManageOperatingHoursUseCase>()
            ? getIt<ManageOperatingHoursUseCase>()
            : null);
    _load();
  }

  Future<void> _load() async {
    if (_useCase == null) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final daysFuture = (_workshopScope && _hasWorkshop)
          ? _useCase.getWorkshopOperatingHours(widget.workshopId!)
          : _useCase.getBranchOperatingHours(widget.branchId);
      final excFuture = (_workshopScope && _hasWorkshop)
          ? _useCase.getWorkshopExceptions(widget.workshopId!)
          : _useCase.getBranchExceptions(widget.branchId);
      final results = await Future.wait([daysFuture, excFuture]);
      final fetchedDays = results[0] as List<OperatingHoursDay>;
      if (!mounted) return;
      setState(() {
        _days = fetchedDays.isNotEmpty
            ? fetchedDays
            : BranchOperatingSchedule.weekdayKeys
                .map(
                  (d) => OperatingHoursDay(
                    dayOfWeek: d,
                    open: d != 'SUNDAY',
                    openTime: d != 'SUNDAY' ? '08:30' : null,
                    closeTime: d != 'SUNDAY' ? '18:00' : null,
                  ),
                )
                .toList();
        _exceptions = results[1] as List<OperatingHoursException>;
      });
    } catch (e) {
      if (mounted) {
        ShiftIQToast.show(
          context,
          message: 'No se pudo cargar los horarios: $e',
          type: ShiftIQToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSchedule() async {
    if (_useCase == null) return;
    setState(() => _isSaving = true);
    try {
      final updated = (_workshopScope && _hasWorkshop)
          ? await _useCase.updateWorkshopOperatingHours(
              widget.workshopId!,
              _days,
            )
          : await _useCase.updateBranchOperatingHours(
              widget.branchId,
              _days,
            );
      if (!mounted) return;
      setState(() => _days = updated);
      ShiftIQToast.show(
        context,
        message: 'Horarios guardados correctamente',
        type: ShiftIQToastType.success,
      );
    } catch (e) {
      if (mounted) {
        ShiftIQToast.show(
          context,
          message: 'Error al guardar horarios: $e',
          type: ShiftIQToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _resetBranchToWorkshop() async {
    if (_useCase == null) return;
    setState(() => _isSaving = true);
    try {
      await _useCase.deleteBranchOperatingHours(widget.branchId);
      await _load();
      if (!mounted) return;
      ShiftIQToast.show(
        context,
        message: 'Se restauró la herencia del horario global del taller',
        type: ShiftIQToastType.success,
      );
    } catch (e) {
      if (mounted) {
        ShiftIQToast.show(
          context,
          message: 'No se pudo restaurar: $e',
          type: ShiftIQToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDayTime(int index, {required bool isOpenTime}) async {
    final day = _days[index];
    final current = EffectiveOperatingHours.parseTimeOfDay(
          isOpenTime ? day.openTime : day.closeTime,
        ) ??
        TimeOfDay(hour: isOpenTime ? 8 : 18, minute: isOpenTime ? 30 : 0);

    final picked = await showShiftIQTimePickerSheet(
      context,
      initialTime: current,
      title: isOpenTime ? 'Hora de apertura' : 'Hora de cierre',
    );
    if (picked == null || !mounted) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

    setState(() {
      final copy = [..._days];
      copy[index] = isOpenTime
          ? day.copyWith(openTime: formatted)
          : day.copyWith(closeTime: formatted);
      _days = copy;
    });
  }

  Future<void> _openAddExceptionDialog() async {
    if (_useCase == null) return;
    var selectedDate = DateTime.now().add(const Duration(days: 1));
    var isOpen = false;
    var openTime = const TimeOfDay(hour: 9, minute: 0);
    var closeTime = const TimeOfDay(hour: 13, minute: 0);
    final reasonCtrl = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (dlgCtx, setDlgState) {
          final isoDate =
              '${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
          return AlertDialog(
            title: const Text('Nueva excepción / feriado'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today_rounded),
                    title: const Text('Fecha'),
                    subtitle: Text(isoDate),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: dlgCtx,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (d != null) setDlgState(() => selectedDate = d);
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Atiende en horario especial'),
                    value: isOpen,
                    onChanged: (v) => setDlgState(() => isOpen = v),
                  ),
                  if (isOpen) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final t = await showShiftIQTimePickerSheet(
                                dlgCtx,
                                initialTime: openTime,
                                title: 'Apertura',
                              );
                              if (t != null) setDlgState(() => openTime = t);
                            },
                            child: Text(
                              '${openTime.hour.toString().padLeft(2, '0')}:${openTime.minute.toString().padLeft(2, '0')}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final t = await showShiftIQTimePickerSheet(
                                dlgCtx,
                                initialTime: closeTime,
                                title: 'Cierre',
                              );
                              if (t != null) setDlgState(() => closeTime = t);
                            },
                            child: Text(
                              '${closeTime.hour.toString().padLeft(2, '0')}:${closeTime.minute.toString().padLeft(2, '0')}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextField(
                    controller: reasonCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Motivo (ej. Fiestas Patrias)',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dlgCtx).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dlgCtx).pop(true),
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );

    if (created != true || !mounted) {
      reasonCtrl.dispose();
      return;
    }

    final isoDate =
        '${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    final openStr =
        '${openTime.hour.toString().padLeft(2, '0')}:${openTime.minute.toString().padLeft(2, '0')}';
    final closeStr =
        '${closeTime.hour.toString().padLeft(2, '0')}:${closeTime.minute.toString().padLeft(2, '0')}';

    try {
      if (_workshopScope && _hasWorkshop) {
        await _useCase.createWorkshopException(
          workshopId: widget.workshopId!,
          date: isoDate,
          open: isOpen,
          openTime: isOpen ? openStr : null,
          closeTime: isOpen ? closeStr : null,
          reason: reasonCtrl.text,
        );
      } else {
        await _useCase.createBranchException(
          branchId: widget.branchId,
          date: isoDate,
          open: isOpen,
          openTime: isOpen ? openStr : null,
          closeTime: isOpen ? closeStr : null,
          reason: reasonCtrl.text,
        );
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ShiftIQToast.show(
          context,
          message: 'No se pudo registrar la excepción: $e',
          type: ShiftIQToastType.error,
        );
      }
    } finally {
      reasonCtrl.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiftIQColors.warmNeutral,
      body: ShiftIQCollapsibleHeaderBody(
        header: const ShiftIQPageHeader(
          title: 'Horarios y Feriados',
          subtitle: 'Configura la atención semanal y días especiales',
          showBackButton: true,
        ),
        body: _isLoading
            ? const ShiftIQSkeletonCardList(itemCount: 4)
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  if (_hasWorkshop) ...[
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('Esta sede')),
                        ButtonSegment(
                          value: true,
                          label: Text('Global taller'),
                        ),
                      ],
                      selected: {_workshopScope},
                      onSelectionChanged: (s) {
                        setState(() => _workshopScope = s.first);
                        _load();
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: ShiftIQColors.borderSlate),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HORARIO SEMANAL',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (var i = 0; i < _days.length; i++) ...[
                          _DayHoursRow(
                            label: _dayLabels[_days[i].dayOfWeek] ??
                                _days[i].dayOfWeek,
                            day: _days[i],
                            onToggle: (open) {
                              setState(() {
                                final copy = [..._days];
                                copy[i] = _days[i].copyWith(
                                  open: open,
                                  openTime: open
                                      ? (_days[i].openTime ?? '08:30')
                                      : null,
                                  closeTime: open
                                      ? (_days[i].closeTime ?? '18:00')
                                      : null,
                                );
                                _days = copy;
                              });
                            },
                            onPickOpen: () => _pickDayTime(i, isOpenTime: true),
                            onPickClose: () =>
                                _pickDayTime(i, isOpenTime: false),
                          ),
                          if (i < _days.length - 1)
                            const Divider(height: 14, color: Color(0xFFF1F5F9)),
                        ],
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: _isSaving ? null : _saveSchedule,
                                style: FilledButton.styleFrom(
                                  backgroundColor: ShiftIQColors.primaryBlue,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  _isSaving ? 'Guardando...' : 'Guardar horario',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            if (!_workshopScope) ...[
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed:
                                    _isSaving ? null : _resetBranchToWorkshop,
                                child: const Text('Heredar'),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: ShiftIQColors.borderSlate),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'FERIADOS Y EXCEPCIONES',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.6,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _openAddExceptionDialog,
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Agregar'),
                            ),
                          ],
                        ),
                        if (_exceptions.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Sin feriados o excepciones registradas.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          )
                        else
                          ..._exceptions.map(
                            (ex) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                ex.open
                                    ? Icons.schedule_rounded
                                    : Icons.event_busy_rounded,
                                color: ex.open
                                    ? ShiftIQColors.primaryBlue
                                    : ShiftIQColors.severityCrimson,
                              ),
                              title: Text(
                                ex.reason?.isNotEmpty == true
                                    ? '${ex.date} · ${ex.reason}'
                                    : ex.date,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                ex.open
                                    ? '${ex.openTime ?? ''} - ${ex.closeTime ?? ''}'
                                    : 'Cerrado',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline_rounded),
                                onPressed: () async {
                                  if (_useCase == null) return;
                                  if (_workshopScope && _hasWorkshop) {
                                    await _useCase.deleteWorkshopException(
                                      widget.workshopId!,
                                      ex.id,
                                    );
                                  } else {
                                    await _useCase.deleteBranchException(
                                      widget.branchId,
                                      ex.id,
                                    );
                                  }
                                  _load();
                                },
                              ),
                            ),
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

class _DayHoursRow extends StatelessWidget {
  final String label;
  final OperatingHoursDay day;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickOpen;
  final VoidCallback onPickClose;

  const _DayHoursRow({
    required this.label,
    required this.day,
    required this.onToggle,
    required this.onPickOpen,
    required this.onPickClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: ShiftIQColors.graphiteText,
            ),
          ),
        ),
        Switch.adaptive(value: day.open, onChanged: onToggle),
        const Spacer(),
        if (day.open) ...[
          OutlinedButton(
            onPressed: onPickOpen,
            style: OutlinedButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: Text(day.openTime ?? '08:30'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('-'),
          ),
          OutlinedButton(
            onPressed: onPickClose,
            style: OutlinedButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: Text(day.closeTime ?? '18:00'),
          ),
        ] else
          const Text(
            'Cerrado',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
            ),
          ),
      ],
    );
  }
}
