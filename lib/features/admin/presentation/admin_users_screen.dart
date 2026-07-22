import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/state/app_state.dart';
import '../../../core/models/models.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});
  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  UserRole? _filter;
  // FIX: search support
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    var users = state.adminAllUsers;
    if (_filter != null) users = users.where((u) => u.role == _filter).toList();
    if (_searchQuery.isNotEmpty) {
      users = users.where((u) =>
          u.name.toLowerCase().contains(_searchQuery) ||
          u.email.toLowerCase().contains(_searchQuery) ||
          u.faculty.toLowerCase().contains(_searchQuery)).toList();
    }

    final border  = context.borderColor;
    final muted   = context.mutedColor;
    final surf    = context.surfaceColor;
    final txt     = context.textColor;

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: _AdminAppBar(title: isAr ? 'إدارة المستخدمين' : 'Manage Users'),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FIX: Search bar
              TextField(
                controller: _searchCtrl,
                style: AppTextStyles.body(14, color: txt, context: context),
                decoration: InputDecoration(
                  hintText: isAr ? 'البحث بالاسم أو البريد أو الكلية...' : 'Search by name, email or faculty…',
                  hintStyle: AppTextStyles.body(15, color: muted, context: context),
                  prefixIcon: Icon(Icons.search, color: muted, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () { _searchCtrl.clear(); },
                          child: Icon(Icons.close, color: muted, size: 18))
                      : null,
                  filled: true,
                  fillColor: surf,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.primaryColor, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Role filter pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _FilterPill(label: isAr ? 'الكل' : 'All', active: _filter == null,
                      color: context.primaryColor,
                      onTap: () => setState(() => _filter = null)),
                  const SizedBox(width: 8),
                  ...UserRole.values.map((r) => Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: _FilterPill(
                      label: isAr ? _roleLabelAr(r) : r.label,
                      active: _filter == r,
                      color: _roleColor(r, context),
                      onTap: () => setState(() => _filter = r),
                    ),
                  )),
                ]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: users.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.search_rounded, size: 40, color: Color(0xFF5A7090)),
                  const SizedBox(height: 12),
                  Text(isAr ? 'لم يتم العثور على مستخدمين' : 'No users found',
                      style: AppTextStyles.body(14, color: muted, context: context)),
                ]))
              : ListView.separated(
                  padding: EdgeInsetsDirectional.only(
                    start: 20, end: 20,
                    bottom: MediaQuery.of(context).padding.bottom + 90,
                  ),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _UserCard(user: users[i]),
                ),
        ),
      ]),
    );
  }

  String _roleLabelAr(UserRole r) => switch (r) {
    UserRole.student => 'طالب',
    UserRole.admin   => 'مسؤول',
    UserRole.coach   => 'مدرب',
  };

  Color _roleColor(UserRole r, BuildContext ctx) => switch (r) {
    UserRole.student => ctx.primaryColor,
    UserRole.admin   => ctx.errorColor,
    UserRole.coach   => ctx.accentColor,
  };
}

class _AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const _AdminAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(title,
        style: AppTextStyles.body(18, color: context.textColor, weight: FontWeight.w700, context: context)),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: context.textColor, size: 20),
        onPressed: () => context.read<AppState>().setNavIndex(0),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _FilterPill({required this.label, required this.active,
    required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.14) : context.surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? color : context.borderColor),
        ),
        child: Text(label, style: AppTextStyles.body(14,
            color: active ? color : context.mutedColor,
            weight: FontWeight.w700, context: context)),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  const _UserCard({required this.user});

  Color _roleColor(BuildContext ctx) => switch (user.role) {
    UserRole.student => ctx.primaryColor,
    UserRole.admin   => ctx.errorColor,
    UserRole.coach   => ctx.accentColor,
  };

  @override
  Widget build(BuildContext context) {
    final col   = _roleColor(context);
    final txt   = context.textColor;
    final muted = context.mutedColor;
    final isAr  = Localizations.localeOf(context).languageCode == 'ar';
    // FIX: detect if this card is for the current user
    final isSelf = context.read<AppState>().currentUser?.uid == user.uid;

    return AppCard(
      glowColor: col,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 14),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [col.withValues(alpha: 0.7), col.withValues(alpha: 0.3)],
            ),
            boxShadow: [BoxShadow(color: col.withValues(alpha: 0.3), blurRadius: 10)],
          ),
          child: Center(child: Text(user.initials,
              style: AppTextStyles.display(16, color: Colors.white, context: context))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(
              child: Text(user.name,
                  maxLines: 1,
                  style: AppTextStyles.body(15, color: txt, weight: FontWeight.w600, context: context),
                  overflow: TextOverflow.ellipsis),
            ),
            // FIX: "YOU" badge so admin sees their own row clearly
            if (isSelf) ...[
              const SizedBox(width: 6),
              AppPill(label: isAr ? 'أنت' : 'YOU', color: col, fontSize: 10),
            ],
          ]),
          const SizedBox(height: 2),
          Text(user.email,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body(13, color: muted, context: context)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 4, children: [
            AppPill(label: isAr ? _roleLabelAr(user.role) : user.role.label, color: col),
            AppPill(label: user.faculty, color: context.secondaryColor),
          ]),
        ])),
        if (user.role == UserRole.student)
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('${user.points}', style: AppTextStyles.heading(15, color: col, context: context)),
            Text(isAr ? 'نقطة' : 'pts', style: AppTextStyles.label(color: muted, context: context)),
          ]),
        const SizedBox(width: 8),
        // FIX: hide delete button for own account
        if (!isSelf)
          GestureDetector(
            onTap: () => _confirmDelete(context),
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: context.errorColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.person_remove_outlined,
                  color: context.errorColor, size: 16),
            ),
          )
        else
          // Disabled placeholder to maintain layout
          const SizedBox(width: 30),
      ]),
    );
  }

  String _roleLabelAr(UserRole r) => switch (r) {
    UserRole.student => 'طالب',
    UserRole.admin   => 'مسؤول',
    UserRole.coach   => 'مدرب',
  };

  void _confirmDelete(BuildContext context) {
    final state = context.read<AppState>();
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(isAr ? 'إزالة المستخدم؟' : 'Remove User?',
            style: AppTextStyles.heading(18, color: context.textColor, context: context)),
        content: Text(isAr ? 'سيؤدي هذا إلى إزالة "${user.name}" من النظام.' : 'This will remove "${user.name}" from the system.',
            style: AppTextStyles.body(15, color: context.mutedColor, context: context)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text(isAr ? 'إلغاء' : 'Cancel', style: AppTextStyles.body(15, color: context.mutedColor, context: context))),
          TextButton(
            onPressed: () async {
              final deleted = await state.adminDeleteUser(user.uid);
              if (!context.mounted) return;
              Navigator.pop(context);
              if (!deleted) {
                // Should not happen since button is hidden for self, but extra safety
                state.showToast(isAr ? '❌ لا يمكن إزالة حسابك الخاص' : '❌ Cannot remove your own account');
              }
            },
            child: Text(isAr ? 'إزالة' : 'Remove',
                style: AppTextStyles.body(15, color: context.errorColor, weight: FontWeight.w700, context: context)),
          ),
        ],
      ),
    );
  }
}
