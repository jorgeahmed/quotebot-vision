import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/workflow_state.dart';

class CreateActivityDialog extends StatefulWidget {
  final String projectId;
  final WorkflowStage initialStage;
  final Activity? activityToEdit;

  const CreateActivityDialog({
    super.key,
    required this.projectId,
    this.initialStage = WorkflowStage.planning,
    this.activityToEdit,
  });

  @override
  State<CreateActivityDialog> createState() => _CreateActivityDialogState();
}

class _CreateActivityDialogState extends State<CreateActivityDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _costController;
  late WorkflowStage _selectedStage;
  late ActivityPriority _selectedPriority;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.activityToEdit?.title ?? '');
    _descController =
        TextEditingController(text: widget.activityToEdit?.description ?? '');
    _costController = TextEditingController(
        text: widget.activityToEdit?.estimatedCost.toString() ?? '0.0');
    _selectedStage = widget.activityToEdit?.stage ?? widget.initialStage;
    _selectedPriority =
        widget.activityToEdit?.priority ?? ActivityPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.activityToEdit == null
          ? 'Nueva Actividad'
          : 'Editar Actividad'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Costo Estimado',
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<WorkflowStage>(
                value: _selectedStage,
                decoration: const InputDecoration(labelText: 'Etapa'),
                items: WorkflowStage.values.map((stage) {
                  return DropdownMenuItem(
                    value: stage,
                    child: Text(stage.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedStage = value);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ActivityPriority>(
                value: _selectedPriority,
                decoration: const InputDecoration(labelText: 'Prioridad'),
                items: ActivityPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedPriority = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final activity = Activity(
        id: widget.activityToEdit?.id ?? const Uuid().v4(),
        projectId: widget.projectId,
        title: _titleController.text,
        description: _descController.text,
        estimatedCost: double.tryParse(_costController.text) ?? 0.0,
        stage: _selectedStage,
        priority: _selectedPriority,
        startDate: widget.activityToEdit?.startDate ?? DateTime.now(),
        status: widget.activityToEdit?.status ?? ActivityStatus.pending,
      );
      Navigator.pop(context, activity);
    }
  }
}
