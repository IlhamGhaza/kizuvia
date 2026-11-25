import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kizuvia/features/auth/presentation/login_screen.dart';
import 'package:kizuvia/features/dev/gallery_screen.dart';
import 'package:kizuvia/features/education/presentation/education_screen.dart';
import 'package:kizuvia/features/family/presentation/family_screen.dart';
import 'package:kizuvia/features/family/presentation/join_family_screen.dart';
import 'package:kizuvia/features/history/presentation/history_screen.dart';
import 'package:kizuvia/features/home/not_found_screen.dart';
import 'package:kizuvia/features/home/presentation/app_shell.dart';
import 'package:kizuvia/features/home/presentation/dose_detail_screen.dart';
import 'package:kizuvia/features/home/presentation/today_screen.dart';
import 'package:kizuvia/features/medications/presentation/medication_detail_screen.dart';
import 'package:kizuvia/features/medications/presentation/medication_form_screen.dart';
import 'package:kizuvia/features/onboarding/presentation/onboarding_screen.dart';
import 'package:kizuvia/features/patients/presentation/patient_detail_screen.dart';
import 'package:kizuvia/features/patients/presentation/patient_form_screen.dart';
import 'package:kizuvia/features/patients/presentation/patients_screen.dart';
import 'package:kizuvia/features/settings/data/settings_repository.dart';
import 'package:kizuvia/features/settings/presentation/alarm_test_screen.dart';
import 'package:kizuvia/features/settings/presentation/settings_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const patients = '/patients';
  static const history = '/history';
  static const family = '/family';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const settings = '/settings';
  static const alarmHelp = '/settings/alarm-help';
  static const alarmTest = '/settings/alarm-test';
  static const devGallery = '/dev/gallery';
}

/// Redirects to onboarding until it is completed. Auth/family redirects are
/// added in Phase 2 (docs/02-ARCHITECTURE.md §6).
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final onboardingDone = ref.watch(
    settingsControllerProvider.select((s) => s.onboardingDone),
  );
  return GoRouter(
    initialLocation: AppRoutes.home,
    errorBuilder: (context, state) => const NotFoundScreen(),
    redirect: (context, state) {
      // kizuvia://invite/ABC123 (docs/02 §6): the host is "invite".
      final uri = state.uri;
      // Email sign-in link: supabase_flutter reads it; just land on Keluarga.
      if (uri.scheme == 'kizuvia' && uri.host == 'login-callback') {
        return AppRoutes.family;
      }
      if (uri.scheme == 'kizuvia' && uri.host == 'invite') {
        final code = uri.pathSegments.isEmpty ? '' : uri.pathSegments.first;
        return '/invite/$code';
      }
      final atOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (!onboardingDone && !atOnboarding) return AppRoutes.onboarding;
      if (onboardingDone && atOnboarding) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.patients,
                builder: (context, state) => const PatientsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.family,
                builder: (context, state) => const FamilyScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/family/create',
        builder: (context, state) => const JoinFamilyScreen(createMode: true),
      ),
      GoRoute(
        path: '/family/join',
        builder: (context, state) => const JoinFamilyScreen(),
      ),
      GoRoute(
        path: '/invite/:code',
        builder: (context, state) =>
            JoinFamilyScreen(code: state.pathParameters['code']),
      ),
      GoRoute(
        path: '/patients/new',
        builder: (context, state) => const PatientFormScreen(),
      ),
      GoRoute(
        path: '/patients/:id',
        builder: (context, state) =>
            PatientDetailScreen(patientId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/patients/:id/education',
        builder: (context, state) =>
            EducationScreen(patientId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/patients/:id/edit',
        builder: (context, state) =>
            PatientFormScreen(patientId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/patients/:id/meds/new',
        builder: (context, state) =>
            MedicationFormScreen(patientId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/meds/:id',
        builder: (context, state) =>
            MedicationDetailScreen(medicationId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/meds/:id/edit',
        builder: (context, state) =>
            MedicationFormScreen(medicationId: state.pathParameters['id']),
      ),
      // Tap on a notification: /dose/{scheduleId}?at={iso} (docs/02 §6).
      GoRoute(
        path: '/dose/:scheduleId',
        builder: (context, state) => DoseDetailScreen(
          scheduleId: state.pathParameters['scheduleId']!,
          at: DateTime.tryParse(state.uri.queryParameters['at'] ?? '')?.toUtc(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.alarmHelp,
        builder: (context, state) => const AlarmHelpScreen(),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.alarmTest,
          builder: (context, state) => const AlarmTestScreen(),
        ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.devGallery,
          builder: (context, state) => const GalleryScreen(),
        ),
    ],
  );
}
