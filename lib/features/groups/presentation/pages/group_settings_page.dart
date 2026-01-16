import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/group_member.dart';
import '../bloc/group_settings_bloc.dart';

class GroupSettingsPage extends StatelessWidget {
  final Group group;

  const GroupSettingsPage({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GroupSettingsBloc>()
        ..add(LoadGroupMembersEvent(groupId: group.id)),
      child: _GroupSettingsView(group: group),
    );
  }
}

class _GroupSettingsView extends StatefulWidget {
  final Group group;

  const _GroupSettingsView({required this.group});

  @override
  State<_GroupSettingsView> createState() => _GroupSettingsViewState();
}

class _GroupSettingsViewState extends State<_GroupSettingsView> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  List<GroupMember> _currentMembers = [];
  bool _isLoadingMembers = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group.name);
    _descController = TextEditingController(text: widget.group.description);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupSettingsBloc, GroupSettingsState>(
      listener: (context, state) {
        if (state is GroupInfoUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Información actualizada"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else if (state is MemberKicked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.orange,
            ),
          );
        } else if (state is GroupDeleted) {
          Navigator.pop(context, {'action': 'delete'});
        } else if (state is GroupSettingsError) {
          setState(() {
            _isLoadingMembers = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is GroupMembersLoaded) {
          setState(() {
            _currentMembers = state.members;
            _isLoadingMembers = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            "Configuración",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Información General"),
              _buildInfoForm(context),
              const SizedBox(height: 24),
              _buildSectionTitle(
                "Administrar Miembros (${_currentMembers.length})",
              ),
              _buildMembersList(context),
              const SizedBox(height: 32),
              _buildDangerZone(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoForm(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nombre del Grupo",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.group),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: "Descripción",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  context.read<GroupSettingsBloc>().add(
                        UpdateGroupInfoEvent(
                          groupId: widget.group.id,
                          name: _nameController.text,
                          description: _descController.text,
                        ),
                      );
                },
                icon: const Icon(Icons.save),
                label: const Text("Guardar Cambios"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersList(BuildContext context) {
    if (_isLoadingMembers) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_currentMembers.isEmpty) {
      return const Center(child: Text("No hay miembros (solo tú)"));
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _currentMembers.length,
        separatorBuilder: (c, i) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final member = _currentMembers[index];

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
              child: Text(
                member.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              member.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: member.email.isNotEmpty ? Text(member.email) : null,
            trailing: IconButton(
              icon: const Icon(Icons.person_remove, color: Colors.redAccent),
              tooltip: "Expulsar miembro",
              onPressed: () {
                _showKickDialog(context, member.id, member.name, index);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Zona de Peligro",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Eliminar este grupo borrará todos los datos asociados y expulsará a todos los miembros. Esta acción no se puede deshacer.",
            style: TextStyle(color: Colors.redAccent, fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _showDeleteGroupDialog(context),
              icon: const Icon(Icons.delete_forever),
              label: const Text("ELIMINAR GRUPO"),
            ),
          ),
        ],
      ),
    );
  }

  void _showKickDialog(
    BuildContext context,
    String userId,
    String name,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("¿Expulsar miembro?"),
        content: Text("¿Estás seguro de que quieres sacar a $name del grupo?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<GroupSettingsBloc>().add(
                    KickMemberEvent(groupId: widget.group.id, memberId: userId),
                  );
              setState(() {
                _currentMembers.removeAt(index);
              });
              Navigator.pop(dialogContext);
            },
            child: const Text(
              "Expulsar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          "¿Eliminar Grupo?",
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          "Esta acción es irreversible. ¿Confirmas que quieres eliminar este grupo permanentemente?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<GroupSettingsBloc>().add(
                    DeleteGroupEvent(groupId: widget.group.id),
                  );
              Navigator.pop(dialogContext);
            },
            child: const Text(
              "SÍ, ELIMINAR",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
