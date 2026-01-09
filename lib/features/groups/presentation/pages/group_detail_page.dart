import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/group.dart';
import '../bloc/detail/group_detail_bloc.dart';
import 'group_settings_page.dart'; // Import de la página de ajustes

class GroupDetailPage extends StatelessWidget {
  final Group group;

  const GroupDetailPage({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<GroupDetailBloc>()..add(LoadGroupDetailsEvent(group.id)),
      child: _GroupDetailView(group: group),
    );
  }
}

class _GroupDetailView extends StatelessWidget {
  final Group group;

  const _GroupDetailView({required this.group});

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupDetailBloc, GroupDetailState>(
      listener: (context, state) {
        if (state is InvitationGenerated) {
          _showInvitationDialog(context, state.link);
        } else if (state is GroupDetailError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              group.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              // 1. Invitar (Solo Admin)
              if (group.isAdmin)
                IconButton(
                  icon: const Icon(Icons.person_add),
                  tooltip: 'Invitar miembros',
                  onPressed: () {
                    context.read<GroupDetailBloc>().add(
                      GenerateInviteEvent(group.id),
                    );
                  },
                ),

              // 2. Ajustes (Solo Admin) - ✅ Lógica de retorno integrada
              if (group.isAdmin)
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Configuración del Grupo',
                  onPressed: () async {
                    // Obtenemos miembros para pasarlos a la pantalla de edición
                    final state = context.read<GroupDetailBloc>().state;
                    List<dynamic> currentMembers = [];
                    if (state is GroupDetailLoaded) {
                      currentMembers = state.leaderboard;
                    } else if (state is InvitationGenerated) {
                      currentMembers = state.leaderboard;
                    }

                    // Navegamos y esperamos resultado
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupSettingsPage(
                          group: group,
                          members: currentMembers,
                        ),
                      ),
                    );

                    // Si se eliminó el grupo (result map con action: delete)
                    if (result != null &&
                        result is Map &&
                        result['action'] == 'delete') {
                      if (context.mounted) {
                        Navigator.pop(
                          context,
                          true,
                        ); // Cerramos detalle y avisamos a lista
                      }
                    } else if (result == true) {
                      // Si hubo cambios menores (nombre/descripción), recargamos
                      if (context.mounted) {
                        context.read<GroupDetailBloc>().add(
                          LoadGroupDetailsEvent(group.id),
                        );
                      }
                    }
                  },
                ),
            ],
            bottom: const TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(text: "Actividades", icon: Icon(Icons.assignment_outlined)),
                Tab(text: "Ranking", icon: Icon(Icons.emoji_events_outlined)),
              ],
            ),
          ),
          body: BlocBuilder<GroupDetailBloc, GroupDetailState>(
            builder: (context, state) {
              if (state is GroupDetailLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is GroupDetailLoaded ||
                  state is InvitationGenerated) {
                final quizzes = (state is GroupDetailLoaded)
                    ? state.quizzes
                    : (state as InvitationGenerated).quizzes;

                final leaderboard = (state is GroupDetailLoaded)
                    ? state.leaderboard
                    : (state as InvitationGenerated).leaderboard;

                return TabBarView(
                  children: [
                    _QuizzesTab(quizzes: quizzes),
                    _LeaderboardTab(leaderboard: leaderboard),
                  ],
                );
              } else if (state is GroupDetailError) {
                return Center(child: Text("Error: ${state.message}"));
              }
              return const Center(child: Text("Cargando detalles..."));
            },
          ),
        ),
      ),
    );
  }

  void _showInvitationDialog(BuildContext context, String link) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Invitación Generada",
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Comparte este enlace/token para que otros se unan:"),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
              ),
              child: SelectableText(
                link,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy, color: Colors.deepPurple),
            label: const Text(
              "Copiar",
              style: TextStyle(color: Colors.deepPurple),
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: link));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Enlace copiado al portapapeles"),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Listo"),
          ),
        ],
      ),
    );
  }
}

// --- TAB 1: ACTIVIDADES (QUIZZES) ---
class _QuizzesTab extends StatelessWidget {
  final List<dynamic> quizzes;

  const _QuizzesTab({required this.quizzes});

  @override
  Widget build(BuildContext context) {
    if (quizzes.isEmpty) {
      return const _EmptyState(
        icon: Icons.assignment_outlined,
        message: "No hay actividades asignadas aún.",
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: quizzes.length,
      separatorBuilder: (c, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        final title = quiz['title'] ?? 'Sin título';
        final status = quiz['status'] ?? 'PENDING';
        final isCompleted = status == 'COMPLETED';
        final score = quiz['userResult'] != null
            ? quiz['userResult']['score']
            : 0;
        final date = quiz['availableUntil'] ?? '';

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Navegar al juego (Próximamente)"),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isCompleted ? "COMPLETADO" : "PENDIENTE",
                          style: TextStyle(
                            color: isCompleted
                                ? Colors.green[700]
                                : Colors.orange[800],
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        _formatDate(date),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (isCompleted) ...[
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "$score pts",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ] else ...[
                        const Icon(
                          Icons.timer_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Disponible",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.deepPurple,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final date = DateTime.parse(isoDate);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return '';
    }
  }
}

// --- TAB 2: RANKING (LEADERBOARD) ---
class _LeaderboardTab extends StatelessWidget {
  final List<dynamic> leaderboard;

  const _LeaderboardTab({required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    if (leaderboard.isEmpty) {
      return const _EmptyState(
        icon: Icons.emoji_events_outlined,
        message: "Aún no hay ranking disponible.",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final user = leaderboard[index];
        final name = user['name'] ?? 'Usuario';
        final points = user['totalPoints'] ?? 0;
        final position = index + 1;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: _getRankColor(position),
              foregroundColor: position <= 3 ? Colors.white : Colors.black54,
              child: Text(
                "$position",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            trailing: Text(
              "$points pts",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getRankColor(int position) {
    if (position == 1) return const Color(0xFFFFD700);
    if (position == 2) return const Color(0xFFC0C0C0);
    if (position == 3) return const Color(0xFFCD7F32);
    return Colors.grey[200]!;
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 50, color: Colors.deepPurple),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
