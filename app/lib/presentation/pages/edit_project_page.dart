import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/workflow_state.dart';
import '../blocs/project_bloc.dart';

class EditProjectPage extends StatefulWidget {
  final Project project;

  const EditProjectPage({super.key, required this.project});

  @override
  State<EditProjectPage> createState() => _EditProjectPageState();
}

class _EditProjectPageState extends State<EditProjectPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late WorkflowStage _currentStage;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name);
    _descriptionController =
        TextEditingController(text: widget.project.description);
    _locationController = TextEditingController(text: widget.project.location);
    _currentStage =
        widget.project.workflowState?.mainStage ?? WorkflowStage.planning;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Proyecto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Nombre del Proyecto',
                icon: Icons.work,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Descripción',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _locationController,
                label: 'Ubicación',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 24),
              const Text(
                'Etapa del Workflow (Manual)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildStageDropdown(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _isSaving ? null : _saveProject,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Guardar Cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Campo requerido' : null,
    );
  }

  Widget _buildStageDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<WorkflowStage>(
          value: _currentStage,
          isExpanded: true,
          onChanged: (WorkflowStage? newValue) {
            if (newValue != null) {
              setState(() => _currentStage = newValue);
            }
          },
          items: WorkflowStage.values.map((WorkflowStage stage) {
            return DropdownMenuItem<WorkflowStage>(
              value: stage,
              child: Text(stage.name.toUpperCase()),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updatedProject = widget.project.copyWith(
      name: _nameController.text,
      description: _descriptionController.text,
      location: _locationController.text,
      workflowState:
          widget.project.workflowState?.copyWith(mainStage: _currentStage) ??
              WorkflowState(
                  mainStage: _currentStage,
                  subState: 'draft',
                  lastUpdated: DateTime.now()),
    );

    context.read<ProjectBloc>().add(UpdateProject(updatedProject));

    // Simulate delay for feedback mechanism (Bloc doesn't emit distinct success state easily consumable here without listener)
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proyecto actualizado')),
      );
      Navigator.pop(context);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Proyecto'),
        content: const Text(
            '¿Estás seguro de que quieres eliminar este proyecto? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProjectBloc>().add(DeleteProject(widget.project.id));
              Navigator.pop(ctx); // Close Dialog
              Navigator.pop(context); // Close Edit Page
              Navigator.pop(
                  context); // Close Details Page (Back to Dashboard optimally)
              // Note: This multiple pop depends on navigation stack.
              // Ideally we navigate until Dashboard logic resets.
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
