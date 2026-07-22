// lib/features/admin/manage_users_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/models/user_model.dart';
import 'bloc/admin_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});
  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.manageUsers, style: AppTextStyles.heading(18, color: Colors.white, context: context)),
        backgroundColor: DarkColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: DarkColors.accent,
          tabs: [
            Tab(text: l.students),
            Tab(text: l.coaches),
            Tab(text: l.admins),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: l.searchUsers,
                hintStyle: AppTextStyles.body(14, color: isDark ? Colors.white38 : Colors.black38, context: context),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10),
              ),
              style: AppTextStyles.body(14, color: isDark ? Colors.white : Colors.black, context: context),
            ),
          ),
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state is! AdminLoaded) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: DarkColors.primary));
                }
                return TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _UserList(
                        users: state.students,
                        search: _search,
                        isDark: isDark),
                    _UserList(
                        users: state.coaches,
                        search: _search,
                        isDark: isDark),
                    // Admins not tracked in AdminBloc — show empty for now
                    Center(child: Text(l.adminList, style: AppTextStyles.body(14, context: context))),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  final List<UserModel> users;
  final String search;
  final bool isDark;
  const _UserList(
      {required this.users, required this.search, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final filtered = search.isEmpty
        ? users
        : users.where((u) =>
            u.name.toLowerCase().contains(search) ||
            u.email.toLowerCase().contains(search)).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text('No users found',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final u = filtered[i];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 200 + i * 40),
          builder: (_, v, child) =>
              Opacity(opacity: v, child: child),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? DarkColors.surface2 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8)],
            ),
            child: Row(children: [
              CircleAvatar(
                backgroundColor: DarkColors.primary,
                child: Text(
                  u.name.isNotEmpty ? u.name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).map((p) => p[0].toUpperCase()).take(2).join() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    Text(u.email,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Switch(
                value: u.isActive,
                activeThumbColor: Colors.green,
                onChanged: (v) => context.read<AdminBloc>().add(
                  AdminUserToggled(u.uid, v, AppLocalizations.of(context)!)),
              ),
            ]),
          ),
        );
      },
    );
  }
}
