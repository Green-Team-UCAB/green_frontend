import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/group.dart';
import '../bloc/groups_bloc.dart';
import 'group_detail_page.dart'; // Importante para la navegación

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
          // Intentamos recargar si hubo un error crítico
          context.read<GroupsBloc>().add(LoadGroupsEvent());
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50], // Fondo limpio estilo Kahoot
        appBar: AppBar(
          title: const Text(
            'Mis Grupos de Estudio',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: BlocBuilder<GroupsBloc, GroupsState>(
          builder: (context, state) {
            if (state is GroupsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is GroupsLoaded) {
              // ✅ PULL TO REFRESH INTEGRADO
              return RefreshIndicator(
                color: Colors.deepPurple,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  context.read<GroupsBloc>().add(LoadGroupsEvent());
                  await Future.delayed(const Duration(seconds: 1)); // UX
                },
                child: state.groups.isEmpty
                    ? _buildEmptyStateScrollable() // Scrollable para permitir refresh
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: state.groups.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _GroupCard(group: state.groups[index]);
                        },
                      ),
              );
            }
            return const Center(child: Text("Cargando..."));
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showOptionsModal(context),
          label: const Text("Nuevo", style: TextStyle(color: Colors.white)),
          icon: const Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.deepPurple,
        ),
      ),
    );
  }

  // Widget vacío que permite scroll para el refresh
  Widget _buildEmptyStateScrollable() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 200), // Espacio para centrar visualmente
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_off_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "No perteneces a ningún grupo aún.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                "Desliza hacia abajo para actualizar",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.deepPurple),
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
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final bloc = context.read<GroupsBloc>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Crear Nuevo Grupo",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nombre del Grupo",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Descripción",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
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
        title: const Text(
          "Unirse a Grupo",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: tokenController,
          decoration: const InputDecoration(
            labelText: "Código de Invitación",
            hintText: "Ej: abc-123",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
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
    final bool isAdmin = group.isAdmin;
    final Color roleColor = isAdmin ? Colors.deepPurple : Colors.teal;

    return GestureDetector(
      onTap: () async {
        // ✅ NAVEGACIÓN INTELIGENTE: Esperamos resultado
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GroupDetailPage(group: group)),
        );

        // Si devuelve true (significa que se borró o modificó drásticamente), recargamos
        if (result == true) {
          if (context.mounted) {
            context.read<GroupsBloc>().add(LoadGroupsEvent());
          }
        }
      },
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: roleColor, width: 6)),
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
                          color: Colors.black87,
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
                          color: roleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "ADMIN",
                          style: TextStyle(
                            color: roleColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (group.description != null && group.description!.isNotEmpty)
                  Text(
                    group.description!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.people, size: 18, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(
                      "${group.memberCount} Miembros",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
