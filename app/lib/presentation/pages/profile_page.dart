import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_event.dart';
import '../blocs/profile/profile_state.dart';
import '../../../domain/entities/user_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _companyController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _companyController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _populateControllers(UserProfile profile) {
    if (!_isEditing) {
      // Only update if not editing to avoid overwriting user input
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone ?? '';
      _addressController.text = profile.address ?? '';
      _companyController.text = profile.companyName ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Perfil actualizado correctamente')),
            );
            setState(() => _isEditing = false);
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileLoaded ||
              state is RoleSwitching ||
              state is ProfileUpdating) {
            UserProfile profile;
            if (state is ProfileLoaded) {
              profile = state.profile;
            } else if (state is RoleSwitching) {
              profile = state.currentProfile;
            } else {
              profile = (state as ProfileUpdating).currentProfile;
            }

            _populateControllers(profile);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar & Role Switcher
                    _buildHeader(context, profile, state is RoleSwitching),
                    const SizedBox(height: 32),

                    // Access Level/Role verification
                    if (state is! RoleSwitching)
                      _buildRoleBadge(profile.activeRole),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),

                    // Personal Info
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nombre Completo',
                      icon: Icons.person,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Correo Electrónico',
                      icon: Icons.email,
                      enabled: _isEditing,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Teléfono',
                      icon: Icons.phone,
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Dirección / Ubicación Base',
                      icon: Icons.location_on,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _companyController,
                      label: 'Compañía (Opcional)',
                      icon: Icons.business,
                      enabled: _isEditing,
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('No se pudo cargar el perfil'));
        },
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, UserProfile profile, bool isSwitching) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.indigo.shade100,
              backgroundImage: profile.avatarUrl != null
                  ? NetworkImage(profile.avatarUrl!)
                  : null,
              child: profile.avatarUrl == null
                  ? Text(
                      profile.name.isNotEmpty
                          ? profile.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                          fontSize: 40, color: Colors.indigo.shade800),
                    )
                  : null,
            ),
            if (_isEditing)
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, size: 18),
                  onPressed: () {
                    // TODO: Implement avatar upload
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Subida de avatar próximamente')),
                    );
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (isSwitching)
          const CircularProgressIndicator()
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Rol Actual: ',
                style: TextStyle(color: Colors.grey[600]),
              ),
              DropdownButton<UserRole>(
                value: profile.activeRole,
                onChanged: (UserRole? newRole) {
                  if (newRole != null && newRole != profile.activeRole) {
                    if (profile.hasRole(newRole)) {
                      context.read<ProfileBloc>().add(SwitchRole(newRole));
                    } else {
                      // Request to add role? or show error
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('No tienes habilitado este rol')),
                      );
                    }
                  }
                },
                items: UserRole.values.map((role) {
                  return DropdownMenuItem<UserRole>(
                    value: role,
                    child: Text(
                      role == UserRole.client ? 'Cliente' : 'Contratista',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    final isContractor = role == UserRole.contractor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isContractor
            ? Colors.orange.withOpacity(0.1)
            : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isContractor ? Colors.orange : Colors.blue,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isContractor ? Icons.engineering : Icons.person,
            size: 16,
            color: isContractor ? Colors.orange : Colors.blue,
          ),
          const SizedBox(width: 8),
          Text(
            isContractor
                ? 'Vista de Contratista (Herramientas completas)'
                : 'Vista de Cliente (Solo lectura/Aprobación)',
            style: TextStyle(
              color: isContractor ? Colors.orange[800] : Colors.blue[800],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[100],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          if (label.contains('(Opcional)')) return null;
          return 'Este campo es requerido';
        }
        return null;
      },
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
            UpdateProfile(
              name: _nameController.text,
              email: _emailController.text,
              phone: _phoneController.text,
              address: _addressController.text,
              companyName: _companyController.text,
            ),
          );
    }
  }
}
