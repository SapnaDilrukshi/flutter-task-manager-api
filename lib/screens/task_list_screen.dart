import 'package:flutter/material.dart';
import 'package:taskmamger/screens/add_task_screen.dart';
import 'package:taskmamger/screens/edit_task_screen.dart';
import 'package:taskmamger/utils/colors.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';



class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with TickerProviderStateMixin {
  final ApiService apiService = ApiService();
  late Future<List<Task>> futureTasks;
  late AnimationController _headerAnim;

  @override
  void initState() {
    super.initState();
    futureTasks = apiService.fetchTasks();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  void _refresh() => setState(() => futureTasks = apiService.fetchTasks());

  PageRoute _fadeRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            FadeTransition(
              opacity: CurvedAnimation(
                  parent: _headerAnim, curve: Curves.easeOut),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                                letterSpacing: -0.5,
                              ),
                              children: [
                                TextSpan(text: 'My '),
                                TextSpan(
                                  text: 'Tasks',
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Stay focused · Get things done 🚀',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMid,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _HeaderAvatar(onTap: () async {
                      final result = await Navigator.push(
                          context, _fadeRoute(const AddTaskScreen()));
                      if (result == true) _refresh();
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Body ─────────────────────────────────────────────────
            Expanded(
              child: FutureBuilder<List<Task>>(
                future: futureTasks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoading();
                  }
                  if (snapshot.hasError) return _buildError(snapshot.error);

                  final tasks = snapshot.data!.take(20).toList();
                  final done = tasks.where((t) => t.completed).length;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _StatsPanel(
                            total: tasks.length, completed: done),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(24, 0, 24, 100),
                          itemCount: tasks.length,
                          itemBuilder: (context, i) => _TaskCard(
                            task: tasks[i],
                            index: i,
                            onTap: () async {
                              final result = await Navigator.push(
                                  context,
                                  _fadeRoute(
                                      EditTaskScreen(task: tasks[i])));
                              if (result == true) _refresh();
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFAB(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                  context, _fadeRoute(const AddTaskScreen()));
              if (result == true) _refresh();
            },
            icon: const Icon(Icons.add_rounded, size: 22),
            label: const Text(
              'Add New Task',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ),
      );

  Widget _buildLoading() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text('Loading tasks...',
              style: TextStyle(
                  color: AppColors.textMid, fontSize: 14)),
        ]),
      );

  Widget _buildError(Object? error) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDE6),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: AppColors.primary, size: 34),
            ),
            const SizedBox(height: 16),
            const Text('Could not load tasks',
                style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('$error',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textMid, fontSize: 13)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Try Again'),
            ),
          ]),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Header avatar / add button
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderAvatar extends StatelessWidget {
  final VoidCallback onTap;
  const _HeaderAvatar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Panel
// ─────────────────────────────────────────────────────────────────────────────
class _StatsPanel extends StatelessWidget {
  final int total;
  final int completed;
  const _StatsPanel({required this.total, required this.completed});

  @override
  Widget build(BuildContext context) {
    final pending = total - completed;
    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _StatTile(
                  value: '$total',
                  label: 'Total',
                  color: AppColors.primary,
                  bg: const Color(0xFFFFEDE6)),
              const SizedBox(width: 10),
              _StatTile(
                  value: '$completed',
                  label: 'Done',
                  color: AppColors.success,
                  bg: const Color(0xFFDCFCE7)),
              const SizedBox(width: 10),
              _StatTile(
                  value: '$pending',
                  label: 'Pending',
                  color: AppColors.warning,
                  bg: const Color(0xFFFEF3C7)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.border,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.success),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color bg;
  const _StatTile(
      {required this.value,
      required this.label,
      required this.color,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: color.withOpacity(0.65),
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task Card
// ─────────────────────────────────────────────────────────────────────────────
class _TaskCard extends StatefulWidget {
  final Task task;
  final int index;
  final VoidCallback onTap;
  const _TaskCard(
      {required this.task, required this.index, required this.onTap});

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds: 350 + (widget.index * 55).clamp(0, 550)),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  // Pick a motivational icon based on task index
  IconData _taskIcon(int index) {
    const icons = [
      Icons.bolt_rounded,
      Icons.local_fire_department_rounded,
      Icons.star_rounded,
      Icons.rocket_launch_rounded,
      Icons.emoji_events_rounded,
      Icons.favorite_rounded,
      Icons.auto_awesome_rounded,
      Icons.flash_on_rounded,
    ];
    return icons[index % icons.length];
  }

  @override
  Widget build(BuildContext context) {
    final done = widget.task.completed;
    final accent = done ? AppColors.success : AppColors.primary;
    final cardBg = done ? AppColors.doneTint : AppColors.pendingTint;
    final cardBorder = done ? AppColors.doneBorder : AppColors.pendingBorder;
    final iconBg =
        done ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDE6);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cardBorder),
              ),
              child: Row(
                children: [
                  // Left accent stripe
                  Container(
                    width: 4,
                    height: 76,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                      ),
                    ),
                  ),

                  // Icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        done
                            ? Icons.check_circle_rounded
                            : _taskIcon(widget.index),
                        color: accent,
                        size: 22,
                      ),
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: done
                                  ? AppColors.textMid
                                  : AppColors.textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: done
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: AppColors.textMid,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                '#${widget.task.id}',
                                style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 12),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: done
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFFFEDE6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  done ? '✓ Done' : '⚡ In Progress',
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Icon(Icons.chevron_right_rounded,
                        color: AppColors.textLight, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}