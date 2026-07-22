// lib/core/constants/app_constants.dart

class AppStrings {
  static const String appName = 'MUST Activities';
  static const String appNameAr = 'أنشطة MUST';
  static const String universityName = 'Misr University for Science & Technology';
  static const String universityNameAr = 'جامعة مصر للعلوم والتكنولوجيا';
}

class AppSizes {
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  static const double radiusS = 8.0;
  static const double radiusM = 16.0;
  static const double radiusL = 24.0;
  static const double radiusXL = 32.0;
  static const double radiusCircle = 100.0;

  static const double iconS = 18.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  static const double buttonHeight = 56.0;
  static const double cardElevation = 8.0;
}

class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 800);
  static const Duration splash = Duration(milliseconds: 3000);
  static const Duration pageTransition = Duration(milliseconds: 500);
}

class UserRoles {
  static const String student = 'student';
  static const String admin = 'admin';
  static const String coach = 'coach';
}

class ActivityTypes {
  static const String sports = 'sports';
  static const String arts = 'arts';
}

class SportsList {
  static const List<Map<String, dynamic>> sports = [
    {'name': 'Football', 'nameAr': 'كرة القدم', 'icon': '⚽'},
    {'name': 'Basketball', 'nameAr': 'كرة السلة', 'icon': '🏀'},
    {'name': 'Swimming', 'nameAr': 'السباحة', 'icon': '🏊'},
    {'name': 'Tennis', 'nameAr': 'التنس', 'icon': '🎾'},
    {'name': 'Volleyball', 'nameAr': 'الكرة الطائرة', 'icon': '🏐'},
    {'name': 'Athletics', 'nameAr': 'ألعاب القوى', 'icon': '🏃'},
    {'name': 'Rowing', 'nameAr': 'التجديف', 'icon': '🚣'},
    {'name': 'Martial Arts', 'nameAr': 'الفنون القتالية', 'icon': '🥋'},
  ];
}

class ArtsList {
  static const List<Map<String, dynamic>> arts = [
    {'name': 'Opera & Theater', 'nameAr': 'الأوبرا والمسرح', 'icon': '🎭'},
    {'name': 'Music', 'nameAr': 'الموسيقى', 'icon': '🎵'},
    {'name': 'Painting', 'nameAr': 'الرسم', 'icon': '🎨'},
    {'name': 'Photography', 'nameAr': 'التصوير', 'icon': '📷'},
    {'name': 'Dance', 'nameAr': 'الرقص', 'icon': '💃'},
    {'name': 'Creative Writing', 'nameAr': 'الكتابة الإبداعية', 'icon': '✍️'},
    {'name': 'Film Making', 'nameAr': 'صناعة الأفلام', 'icon': '🎬'},
    {'name': 'Fashion Design', 'nameAr': 'تصميم الأزياء', 'icon': '👗'},
  ];
}

class FirestoreCollections {
  static const String users = 'users';
  static const String activities = 'activities';
  static const String enrollments = 'enrollments';
  static const String sessions = 'sessions';
  static const String notifications = 'notifications';
  static const String achievements = 'achievements';
  static const String announcements = 'announcements';
  static const String coaches = 'coaches';
}

class AssetLinks {
  // These are links the user needs for assets
  static const Map<String, String> freeAssets = {
    'Lottie Sports Animation': 'https://lottiefiles.com/animations/sports-activity',
    'Lottie Arts Animation': 'https://lottiefiles.com/animations/art-creativity',
    'Lottie Success': 'https://lottiefiles.com/animations/success-check',
    'Lottie Loading': 'https://lottiefiles.com/animations/loading',
    'Football Icon Pack (SVG)': 'https://www.svgrepo.com/collection/sports-icons',
    'University Illustrations': 'https://undraw.co/illustrations (search: education)',
    'Background Patterns': 'https://www.heropatterns.com/',
    'MUST Logo SVG': 'https://must.edu.eg/app/uploads/2025/02/1740307452_295_53683_logo.svg',
    'Cairo Font (Arabic)': 'https://fonts.google.com/specimen/Cairo',
    'Poppins Font (English)': 'https://fonts.google.com/specimen/Poppins',
    'Rive Animation Editor': 'https://rive.app/ (create custom mascot animation)',
    'Figma Design System': 'https://www.figma.com/community/file/1035203688168086460 (University UI Kit)',
    'Sport Icons Figma': 'https://www.figma.com/community/file/1069994235088927521 (Sport Icons)',
    'Confetti Package': 'Already in pubspec - pub.dev/packages/confetti',
  };
}

class AppHints {
  static const Map<String, String> auth = {
    'email': 'Use your university email (@must.edu.eg)',
    'password': 'At least 6 characters with numbers',
    'name': 'Enter your full name as in ID',
    'studentId': 'Found on your student card (10 digits)',
  };

  static const Map<String, String> activity = {
    'create': 'Fill all fields to launch a new student activity',
    'enroll': 'You can join up to 3 activities per semester',
    'full': 'This activity is currently full. Check back for new sessions!',
  };

  static const Map<String, String> coach = {
    'session': 'Schedule your weekly sessions here',
    'attendance': 'Mark attendance within 15 mins of session start',
  };

  static const Map<String, String> admin = {
    'notification': 'Broadcast messages reach all active students instantly',
    'management': 'Suspend inactive users or moderate activity content',
  };

  static const Map<String, String> search = {
    'activities': 'Search by name, category or coach...',
    'users': 'Search by name or email address...',
  };
}
