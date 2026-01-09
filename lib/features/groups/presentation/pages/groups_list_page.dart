import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/group.dart';
import '../bloc/groups_bloc.dart';

class GroupsListPage extends StatelessWidget {
  const GroupsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GroupsBloc>()..add(LoadGroupsEvent()),
      child: const GroupsListView(),
    );
  }
}

class GroupsListView extends StatelessWidget {
  const GroupsListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Escucha para mostrar Snackbars de éxito o error
    return BlocListener<GroupsBloc, GroupsState>(
      listener: (context, state) {
        if (state is GroupOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is GroupsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
          // Si falla, intentamos recargar la lista para no quedar en pantalla de carga eterna
          context.read<GroupsBloc>().add(LoadGroupsEvent());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mis Grupos de Estudio',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: BlocBuilder<GroupsBloc, GroupsState>(
          builder: (context, state) {
            if (state is GroupsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is GroupsLoaded) {
              if (state.groups.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.groups.length,
                itemBuilder: (context, index) {
                  return _GroupCard(group: state.groups[index]);
                },
              );
            }
            return const Center(child: Text("Cargando..."));
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showOptionsModal(context),
          label: const Text("Nuevo"),
          icon: const Icon(Icons.add),
          backgroundColor: Colors.indigo,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.group_off_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No perteneces a ningún grupo aún.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.indigo),
              title: const Text('Crear Grupo'),
              subtitle: const Text('Conviértete en administrador'),
              onTap: () {
                Navigator.pop(context);
                _showCreateGroupDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.input, color: Colors.green),
              title: const Text('Unirse a un Grupo'),
              subtitle: const Text('Usar código de invitación'),
              onTap: () {
                Navigator.pop(context);
                _showJoinGroupDialog(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    // Capturamos el bloc antes de abrir el diálogo
    final bloc = context.read<GroupsBloc>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Crear Nuevo Grupo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nombre del Grupo"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Descripción"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                bloc.add(
                  CreateGroupEvent(
                    name: nameController.text,
                    description: descController.text,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Crear"),
          ),
        ],
      ),
    );
  }

  void _showJoinGroupDialog(BuildContext context) {
    final tokenController = TextEditingController();
    final bloc = context.read<GroupsBloc>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Unirse a Grupo"),
        content: TextField(
          controller: tokenController,
          decoration: const InputDecoration(
            labelText: "Código de Invitación",
            hintText: "Ej: abc-123",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (tokenController.text.isNotEmpty) {
                bloc.add(JoinGroupEvent(token: tokenController.text));
                Navigator.pop(context);
              }
            },
            child: const Text("Unirse"),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final Group group;

  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    // Color según rol: Admin (Indigo) vs Member (Verde azulado)
    final bool isAdmin = group.isAdmin;
    final Color accentColor = isAdmin ? Colors.indigo : Colors.teal;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: accentColor, width: 6)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "ADMIN",
                        style: TextStyle(
                          color: Colors.indigo,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (group.description != null)
                Text(
                  group.description!,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.people, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text("${group.memberCount} Miembros"),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
