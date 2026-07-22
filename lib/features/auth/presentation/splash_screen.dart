import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_state.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../l10n/app_localizations.dart';
import 'login_screen.dart';
import '../../../app_shell.dart';
import '../../admin/presentation/admin_shell.dart';
import '../../coach/presentation/coach_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _scale, _glow;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _fade  = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.7, curve: Curves.elasticOut)));
    _glow  = CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 1.0, curve: Curves.easeInOut));
    _ctrl.forward();
    _navTimer = Timer(const Duration(milliseconds: 2400), _navigate);
  }

  void _navigate() async {
    if (!mounted) return;
    final state = context.read<AppState>();
    final fbUser = FirebaseAuthService.instance.currentUser;
    if (fbUser != null && !state.isLoggedIn) {
      await state.loginWithFirebaseUser(fbUser.email ?? '');
    }
    if (!mounted) return;
    // IMPROVEMENT #7: coaches route to CoachShell, not AdminShell
    Widget dest;
    if (!state.isLoggedIn)   { dest = const LoginScreen();  }
    else if (state.isAdmin)  { dest = const AdminShell();   }
    else if (state.isCoach)  { dest = const CoachShell();   }
    else                     { dest = const AppShell();     }

    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, a, __) => dest,
      transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      transitionDuration: const Duration(milliseconds: 500),
    ));
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: DarkColors.bg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Stack(children: [
            // Background glow blobs
            Positioned(
              top: -60, left: -60,
              child: Opacity(
                opacity: 0.18 * _glow.value,
                child: Container(
                  width: 260, height: 260,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: DarkColors.primary,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80, right: -80,
              child: Opacity(
                opacity: 0.12 * _glow.value,
                child: Container(
                  width: 300, height: 300,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: DarkColors.secondary,
                  ),
                ),
              ),
            ),

            // Main content
            FadeTransition(
              opacity: _fade,
              child: Column(
                children: [
                  // ── Top spacer (adaptive) ──────────────────────────────
                  SizedBox(height: size.height * 0.18),

                  // ── Logo ──────────────────────────────────────────────
                  Center(
                    child: Stack(alignment: Alignment.center, children: [
                      // Outer glow ring
                      Container(
                        width: 128, height: 128,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: DarkColors.secondary.withValues(alpha: 0.30 * _glow.value),
                              blurRadius: 70 * _glow.value,
                              spreadRadius: 20 * _glow.value,
                            ),
                            BoxShadow(
                              color: DarkColors.primary.withValues(alpha: 0.18 * _glow.value),
                              blurRadius: 110 * _glow.value,
                              spreadRadius: 10 * _glow.value,
                            ),
                          ],
                        ),
                      ),
                      // Subtle ring border
                      Container(
                        width: 108, height: 108,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: DarkColors.primary.withValues(alpha: 0.20 * _glow.value),
                            width: 1.5,
                          ),
                        ),
                      ),
                      // Icon tile
                      ScaleTransition(
                        scale: _scale,
                        child: Container(
                          width: 88, height: 88,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [DarkColors.primary, Color(0xFF006880)],
                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: DarkColors.primary.withValues(alpha: 0.5),
                                blurRadius: 28, spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Center(child: Icon(Icons.stadium_rounded, color: Colors.white, size: 44)),
                        ),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 32),

                  // ── App name ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: ShaderMask(
                        shaderCallback: (b) => const LinearGradient(
                          colors: [DarkColors.primary, DarkColors.secondary],
                        ).createShader(b),
                        child: Text(
                          l?.appTitle ?? 'MUSTER',
                          maxLines: 1,
                          style: AppTextStyles.display(44, color: Colors.white, letterSpacing: 6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l?.appSubtitle ?? 'SPORT MANAGEMENT PLATFORM',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.label(color: DarkColors.muted)
                        .copyWith(fontSize: 11, letterSpacing: 3),
                  ),

                  const Spacer(),

                  // ── Loading bar ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Column(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _glow.value,
                          minHeight: 3,
                          backgroundColor: DarkColors.primary.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color.lerp(DarkColors.primary, DarkColors.secondary, _glow.value)!,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Loading...',
                        style: AppTextStyles.label(color: DarkColors.muted)
                            .copyWith(fontSize: 12, letterSpacing: 2),
                      ),
                    ]),
                  ),

                  SizedBox(height: size.height * 0.07),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
