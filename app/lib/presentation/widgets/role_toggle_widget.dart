import 'package:flutter/material.dart';
import '../../domain/entities/user_profile.dart';

class RoleToggleWidget extends StatelessWidget {
  final UserProfile profile;
  final Function(UserRole) onRoleChanged;
  final bool isLoading;

  const RoleToggleWidget({
    super.key,
    required this.profile,
    required this.onRoleChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRoleButton(
            context,
            role: UserRole.client,
            label: 'Cliente',
            icon: Icons.person,
          ),
          const SizedBox(width: 4),
          _buildRoleButton(
            context,
            role: UserRole.contractor,
            label: 'Contratista',
            icon: Icons.construction,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context, {
    required UserRole role,
    required String label,
    required IconData icon,
  }) {
    final isActive = profile.activeRole == role;
    final hasRole = profile.hasRole(role);
    final canSwitch = profile.canSwitchTo(role);

    if (!hasRole) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: isActive ? const Color(0xFF6200EE) : Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: isLoading || !canSwitch ? null : () => onRoleChanged(role),
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.white : Colors.grey.shade700,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey.shade700,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                if (isLoading && isActive)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isActive ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
