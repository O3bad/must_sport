import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/activity_state.dart';
import '../../../core/models/activity_models.dart';
import '../../../core/models/models.dart';
import '../../../l10n/app_localizations.dart';

// ─── CHAT MESSAGE MODEL ───────────────────────────────────────────────────────
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  ChatMessage({required this.text, required this.isUser}) : time = DateTime.now();
}

// ─── CHATBOT LOGIC ────────────────────────────────────────────────────────────
String chatbotReply({
  required BuildContext context,
  required String message,
  required UserRole role,
  required List<ActivityRegistration> registrations,
  required String userEmail,
}) {
  final l10n = AppLocalizations.of(context)!;
  final m = message.toLowerCase();

  // Greetings
  if (['hello','hi','hey','good morning','good afternoon','مرحبا','سلام','هاي','اهلا'].any(m.contains)) {
    return role == UserRole.admin || role == UserRole.coach
        ? l10n.chatbotReplyGreetingAdmin
        : l10n.chatbotReplyGreetingStudent;
  }

  // Activities
  if (['activities','sports','join','available','what sports','what can i do','الأنشطة','النشاطات','arts','sing','act','music','opera','poetry','dance','رياضة','فنون'].any(m.contains)) {
    const sports = '⚽ Football  🎾 Padel  🏀 Basketball  🏐 Volleyball\n🏋️ Gym  🥋 Martial Arts  🏊 Swimming  🎱 Table Tennis\n🏸 Badminton  🤸 Gymnastics & Yoga  🏃 Athletics  ♟️ Chess';
    const arts   = '🎭 Acting & Theatre  🎤 Vocal Singing  🎹 Piano\n🎻 Strings  🥁 Percussion  🎷 Wind & Brass  🎸 Guitar & Oud\n📜 Poetry & Spoken Word  💃 Dance  🎬 Opera & Musical Theatre\n🖼️ Creative Writing  🎙️ Public Speaking & Debate';
    return l10n.chatbotReplyActivities(sports, arts);
  }

  // Register
  if (['register','sign up','enroll','how to join','application','apply','سجل','تسجيل','اشتراك'].any(m.contains)) {
    return role == UserRole.admin || role == UserRole.coach
        ? l10n.chatbotReplyRegisterAdmin
        : l10n.chatbotReplyRegisterStudent;
  }

  // Events
  if (['events','tournament','competition','upcoming','cup','championship','بطولة','فعالية','مسابقة'].any(m.contains)) {
    return l10n.chatbotReplyEvents;
  }

  // Status check
  if (['status','pending','approved','rejected','my registration','check','application','طلبي','حالة','مقبول','مرفوض'].any(m.contains)) {
    if (role == UserRole.student) {
      final myRegs = registrations.where((r) => r.studentEmail == userEmail).toList();
      if (myRegs.isEmpty) return l10n.chatbotReplyNoRegistrations;
      
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      final lines = myRegs.map((r) {
        String statusLabel;
        if (isArabic) {
          statusLabel = switch(r.status) {
            RegistrationStatus.pending => 'قيد الانتظار',
            RegistrationStatus.approved => 'مقبول',
            RegistrationStatus.rejected => 'مرفوض',
          };
        } else {
          statusLabel = r.status.label;
        }
        return '${r.activity.emoji} ${r.activity.name}: ${r.status.emoji} $statusLabel';
      }).join('\n');
      
      return l10n.chatbotReplyMyRegistrations(lines);
    }
    
    final pendingCount = registrations.where((r) => r.status == RegistrationStatus.pending).length;
    final approvedCount = registrations.where((r) => r.status == RegistrationStatus.approved).length;
    final rejectedCount = registrations.where((r) => r.status == RegistrationStatus.rejected).length;
    
    return l10n.chatbotReplyAdminSummary(pendingCount, approvedCount, rejectedCount);
  }

  // Admin-specific
  if (['admin','approve','reject','manage','dashboard','إداري','مسؤول','لوحة'].any(m.contains)) {
    if (role == UserRole.admin || role == UserRole.coach) {
      final pending = registrations.where((r) => r.status == RegistrationStatus.pending).length;
      return l10n.chatbotReplyAdminQuickSummary(pending);
    }
  }

  // Points & leaderboard
  if (['points','score','rank','leaderboard','نقاط','ترتيب','ترتيبي','الابطال'].any(m.contains)) {
    return l10n.chatbotReplyPoints;
  }

  // Facilities / booking
  if (['book','facility','field','court','reserve','حجز','ملعب'].any(m.contains)) {
    return l10n.chatbotReplyBooking;
  }

  // Help
  if (['help','guide','how','what can','support','مساعدة','كيف'].any(m.contains)) {
    return role == UserRole.admin || role == UserRole.coach
        ? l10n.chatbotReplyHelpAdmin
        : l10n.chatbotReplyHelpStudent;
  }

  return l10n.chatbotReplyFallback;
}

// ─── CHATBOT SCREEN ───────────────────────────────────────────────────────────
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});
  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _ctrl    = TextEditingController();
  final _scroll  = ScrollController();
  final _messages = <ChatMessage>[];
  bool _typing   = false;

  List<String> _getSuggestions(BuildContext context, UserRole role) {
    final l10n = AppLocalizations.of(context)!;
    if (role == UserRole.admin || role == UserRole.coach) {
      return [l10n.suggPendingRegs, l10n.suggHowToApprove, l10n.suggDashboard, l10n.suggEvents];
    }
    return [l10n.suggSports, l10n.suggArts, l10n.suggHowToRegister, l10n.suggMyStatus, l10n.suggPoints];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context)!;
      final role = context.read<AppState>().user.role;
      final name = context.read<AppState>().user.name.split(' ').first;
      final greeting = role == UserRole.student
          ? l10n.chatbotGreetingStudent(name)
          : l10n.chatbotGreetingAdmin(name);
      setState(() {
        _messages.add(ChatMessage(text: greeting, isUser: false));
      });
    });
  }

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _ctrl.clear();
    setState(() {
      _messages.add(ChatMessage(text: text.trim(), isUser: true));
      _typing = true;
    });
    _scrollToBottom();

    // Capture state before async gap
    final user = context.read<AppState>().user;
    final regs = context.read<ActivityRegistrationState>().all;

    await Future.delayed(Duration(milliseconds: 600 + (text.length * 8).clamp(0, 800)));
    if (!mounted) return;

    final reply = chatbotReply(
      context: context,
      message: text,
      role: user.role,
      registrations: regs,
      userEmail: user.email,
    );
    setState(() {
      _messages.add(ChatMessage(text: reply, isUser: false));
      _typing = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;
    final second  = context.secondaryColor;
    final txt     = context.textColor;
    final border  = context.borderColor;
    final surf    = context.surfaceColor;
    final bg      = context.bgColor;
    final muted   = context.mutedColor;
    final hPad    = context.hPadding;
    final role    = context.read<AppState>().user.role;
    final suggs   = _getSuggestions(context, role);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        title: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primary, const Color(0xFF0097A7)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: Icon(Icons.smart_toy_rounded, size: 18, color: Colors.white)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppLocalizations.of(context)!.aiGuideTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.heading(16, context: context, color: txt)),
                Row(children: [
                  Container(
                      width: 7,
                      height: 7,
                      decoration:
                          BoxDecoration(color: second, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(AppLocalizations.of(context)!.online,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(11, context: context, color: second)),
                  ),
                ]),
              ],
            ),
          ),
        ]),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: muted),
            tooltip: AppLocalizations.of(context)!.clearChat,
            onPressed: () => setState(() {
              _messages.clear();
              final l10n = AppLocalizations.of(context)!;
              final name = context.read<AppState>().user.name.split(' ').first;
              _messages.add(ChatMessage(
                  text: '👋 ${l10n.chatCleared}, $name.\n\n${l10n.askMeAnything}',
                  isUser: false));
            }),
          ),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: border)),
      ),
      body: Column(children: [
        // ── Messages ────────────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 8),
            itemCount: _messages.length + (_typing ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (i == _messages.length) return _TypingBubble();
              final msg = _messages[i];
              return _ChatBubble(message: msg);
            },
          ),
        ),

        // ── Suggestions ─────────────────────────────────────────────────
        Container(
          height: context.isSmallPhone ? 44 : 40,
          color: bg,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: hPad - 4),
            itemCount: suggs.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _send(suggs[i]),
              child: Container(
                margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: surf,
                  border: Border.all(color: border),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(suggs[i],
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(12, context: context, color: muted, weight: FontWeight.w600)),
              ),
            ),
          ),
        ),
        Divider(height: 1, color: border),

        // ── Input ────────────────────────────────────────────────────────
        Container(
          color: bg,
          padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 10 + MediaQuery.of(context).viewInsets.bottom),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                style: AppTextStyles.body(14, context: context, color: txt),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.askMeAnything,
                  hintStyle: AppTextStyles.body(14, context: context, color: muted),
                  filled: true,
                  fillColor: surf,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: primary, width: 1.5)),
                ),
                onSubmitted: _send,
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _send(_ctrl.text),
              child: Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [second, const Color(0xFF7ACC2A)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: second.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Icon(Icons.arrow_upward_rounded, color: bg, size: 22),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ─── CHAT BUBBLE ─────────────────────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;
    final border  = context.borderColor;
    final surf    = context.surfaceColor;
    final isUser  = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primary, const Color(0xFF0097A7)]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Icon(Icons.smart_toy_rounded, size: 14, color: Colors.white)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? primary.withValues(alpha: 0.15) : surf,
                border: Border.all(color: isUser
                    ? primary.withValues(alpha: 0.4) : border),
                borderRadius: BorderRadiusDirectional.only(
                  topStart:    const Radius.circular(16),
                  topEnd:      const Radius.circular(16),
                  bottomStart: Radius.circular(isUser ? 16 : 4),
                  bottomEnd:   Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(message.text,
                  style: AppTextStyles.body(13.5, context: context, color: context.textColor)),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final surf   = context.surfaceColor;
    final border = context.borderColor;
    final primary = context.primaryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primary, const Color(0xFF0097A7)]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(child: Icon(Icons.smart_toy_rounded, size: 14, color: Colors.white)),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: surf, border: Border.all(color: border),
            borderRadius: const BorderRadiusDirectional.only(
              topStart: Radius.circular(16), topEnd: Radius.circular(16),
              bottomStart: Radius.circular(4), bottomEnd: Radius.circular(16),
            ),
          ),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            _Dot(delay: 0), _Dot(delay: 200), _Dot(delay: 400),
          ]),
        ),
      ]),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Container(
      width: 7, height: 7,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: context.mutedColor.withValues(alpha: _anim.value),
        shape: BoxShape.circle,
      ),
    ),
  );
}
