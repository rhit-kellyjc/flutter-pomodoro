import 'package:flutter/material.dart';
import '../managers/auth_manager.dart';
import '../pages/sign_in_page.dart';
import '../models/background_option.dart';
import '../components/stats_modal.dart';
import '../managers/stats_manager.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:cloud_firestore/cloud_firestore.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback onThemePressed;
  final AuthManager authManager;
  final BackgroundOption currentBackground;

  const AppHeader({
    super.key,
    required this.onThemePressed,
    required this.authManager,
    required this.currentBackground,
  });

  Stream<DocumentSnapshot> _getUserStatsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();
  }

  Future<void> _showStatsModal(BuildContext context, String userId) async {
    final statsManager = StatsManager(userId: userId);
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StreamBuilder<DocumentSnapshot>(
        stream: _getUserStatsStream(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return FutureBuilder(
            future: statsManager.getUserStats(),
            builder: (context, statsSnapshot) {
              if (!statsSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              return StatsModal(stats: statsSnapshot.data!);
            },
          );
        },
      ),
    );
  }

  Widget _buildAuthButton(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authManager.authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isAnonymous = user?.isAnonymous ?? true;

        if (isAnonymous) {
          return TextButton.icon(
            onPressed: () => _showSignInPage(context),
            icon: const Icon(Icons.login, color: Colors.white),
            label: const Text(
              'Sign In',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        return PopupMenuButton(
          icon: const Icon(
            Icons.person,
            color: Colors.white,
          ),
          offset: const Offset(0, 40),
          color: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.white),
                title: Text(
                  snapshot.data?.isAnonymous == true
                      ? 'Anonymous User'
                      : snapshot.data?.email ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const PopupMenuItem(
              height: 1,
              padding: EdgeInsets.zero,
              child: Divider(color: Colors.white24),
            ),
            if (!snapshot.data!.isAnonymous) ...[
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await authManager.signOut();
                  },
                ),
              ),
            ],
            if (snapshot.data!.isAnonymous) ...[
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.login, color: Colors.white),
                  title: const Text(
                    'Sign In',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showSignInPage(context);
                  },
                ),
              ),
            ],
            PopupMenuItem(
              child: ListTile(
                leading: const Icon(Icons.bar_chart, color: Colors.white),
                title: const Text(
                  'Statistics',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (snapshot.data?.uid != null) {
                    _showStatsModal(context, snapshot.data!.uid);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Flutter Pomodoro',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.palette,
                  color: Colors.white,
                ),
                onPressed: onThemePressed,
              ),
              const SizedBox(width: 8),
              _buildAuthButton(context),
            ],
          ),
        ],
      ),
    );
  }

  void _showSignInPage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SignInPage(
          background: currentBackground,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slideAnimation = Tween(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
          );

          final fadeAnimation = Tween(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
