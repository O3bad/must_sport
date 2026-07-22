import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MUSTER'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'University activities Management'**
  String get appSubtitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInToAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInToAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@must.edu.eg'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @demoCredentials.
  ///
  /// In en, this message translates to:
  /// **'Demo Credentials'**
  String get demoCredentials;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @coach.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get coach;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidCredentials;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginFailed;

  /// No description provided for @orSignInWith.
  ///
  /// In en, this message translates to:
  /// **'Or sign in with'**
  String get orSignInWith;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @firebaseError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error. Please try again.'**
  String get firebaseError;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @athletes.
  ///
  /// In en, this message translates to:
  /// **'Athletes'**
  String get athletes;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @awaitingReview.
  ///
  /// In en, this message translates to:
  /// **'awaiting review'**
  String get awaitingReview;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @coachDashboard.
  ///
  /// In en, this message translates to:
  /// **'Coach Dashboard'**
  String get coachDashboard;

  /// No description provided for @myAthletes.
  ///
  /// In en, this message translates to:
  /// **'My Athletes'**
  String get myAthletes;

  /// No description provided for @searchAthletes.
  ///
  /// In en, this message translates to:
  /// **'Search by name, activity, faculty…'**
  String get searchAthletes;

  /// No description provided for @noAthletes.
  ///
  /// In en, this message translates to:
  /// **'No approved athletes yet.'**
  String get noAthletes;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activities;

  /// No description provided for @booking.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get booking;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @myApps.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get myApps;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @aiGuide.
  ///
  /// In en, this message translates to:
  /// **'Chatbot'**
  String get aiGuide;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info.'**
  String get personalInfo;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @studentId.
  ///
  /// In en, this message translates to:
  /// **'Student ID'**
  String get studentId;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @faculty.
  ///
  /// In en, this message translates to:
  /// **'Faculty'**
  String get faculty;

  /// No description provided for @semester.
  ///
  /// In en, this message translates to:
  /// **'Semester'**
  String get semester;

  /// No description provided for @bioOptional.
  ///
  /// In en, this message translates to:
  /// **'Bio (Optional)'**
  String get bioOptional;

  /// No description provided for @bioHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself...'**
  String get bioHint;

  /// No description provided for @academicInfo.
  ///
  /// In en, this message translates to:
  /// **'Academic Info'**
  String get academicInfo;

  /// No description provided for @notificationPrefs.
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notificationPrefs;

  /// No description provided for @reservationReminders.
  ///
  /// In en, this message translates to:
  /// **'Reservation Reminders'**
  String get reservationReminders;

  /// No description provided for @reservationRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Get reminded before your bookings'**
  String get reservationRemindersDesc;

  /// No description provided for @registrationUpdates.
  ///
  /// In en, this message translates to:
  /// **'Registration Updates'**
  String get registrationUpdates;

  /// No description provided for @registrationUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Approvals and rejections'**
  String get registrationUpdatesDesc;

  /// No description provided for @upcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get upcomingEvents;

  /// No description provided for @upcomingEventsDesc.
  ///
  /// In en, this message translates to:
  /// **'Events starting soon'**
  String get upcomingEventsDesc;

  /// No description provided for @requiredForms.
  ///
  /// In en, this message translates to:
  /// **'Required Forms'**
  String get requiredForms;

  /// No description provided for @requiredFormsDesc.
  ///
  /// In en, this message translates to:
  /// **'Forms needed for registration'**
  String get requiredFormsDesc;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @showMyProfile.
  ///
  /// In en, this message translates to:
  /// **'Show my profile'**
  String get showMyProfile;

  /// No description provided for @showMyProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Visible to other students'**
  String get showMyProfileDesc;

  /// No description provided for @showMyStats.
  ///
  /// In en, this message translates to:
  /// **'Show my stats'**
  String get showMyStats;

  /// No description provided for @showMyStatsDesc.
  ///
  /// In en, this message translates to:
  /// **'Visible on leaderboard'**
  String get showMyStatsDesc;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @tapToSwitch.
  ///
  /// In en, this message translates to:
  /// **'Tap to switch'**
  String get tapToSwitch;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @nameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get nameCannotBeEmpty;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully ✓'**
  String get profileUpdated;

  /// No description provided for @tapToChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to change photo'**
  String get tapToChangePhoto;

  /// No description provided for @chooseAvatarColor.
  ///
  /// In en, this message translates to:
  /// **'Choose Avatar Color'**
  String get chooseAvatarColor;

  /// No description provided for @uploadComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Profile picture upload coming soon'**
  String get uploadComingSoon;

  /// No description provided for @uploadFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Upload from Gallery (Coming Soon)'**
  String get uploadFromGallery;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @cgpa.
  ///
  /// In en, this message translates to:
  /// **'CGPA'**
  String get cgpa;

  /// No description provided for @creditHours.
  ///
  /// In en, this message translates to:
  /// **'Credit Hours'**
  String get creditHours;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome,'**
  String get welcome;

  /// No description provided for @enrolled.
  ///
  /// In en, this message translates to:
  /// **'Enrolled'**
  String get enrolled;

  /// No description provided for @overall.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get overall;

  /// No description provided for @wins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get wins;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// No description provided for @eventsLabel.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get eventsLabel;

  /// No description provided for @quickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get quickAccess;

  /// No description provided for @bookAField.
  ///
  /// In en, this message translates to:
  /// **'Book a Field'**
  String get bookAField;

  /// No description provided for @joinAnEvent.
  ///
  /// In en, this message translates to:
  /// **'Join an Event'**
  String get joinAnEvent;

  /// No description provided for @myApplications.
  ///
  /// In en, this message translates to:
  /// **'My Applications'**
  String get myApplications;

  /// No description provided for @allActivities.
  ///
  /// In en, this message translates to:
  /// **'All Activities'**
  String get allActivities;

  /// No description provided for @upcomingTournament.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Tournament'**
  String get upcomingTournament;

  /// No description provided for @registerNow.
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get registerNow;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @eventsAndTournaments.
  ///
  /// In en, this message translates to:
  /// **'Events & Tournaments'**
  String get eventsAndTournaments;

  /// No description provided for @competeWinRepresent.
  ///
  /// In en, this message translates to:
  /// **'Compete, win, and represent'**
  String get competeWinRepresent;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @registrationOpen.
  ///
  /// In en, this message translates to:
  /// **'Registration Open'**
  String get registrationOpen;

  /// No description provided for @eventFull.
  ///
  /// In en, this message translates to:
  /// **'Event Full'**
  String get eventFull;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @registered.
  ///
  /// In en, this message translates to:
  /// **'✓ Registered'**
  String get registered;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register →'**
  String get register;

  /// No description provided for @noEventsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No events in this category'**
  String get noEventsInCategory;

  /// No description provided for @clearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear Filter'**
  String get clearFilter;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'d left'**
  String get daysLeft;

  /// No description provided for @bookAFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Book a Field'**
  String get bookAFieldTitle;

  /// No description provided for @selectDateVenueTime.
  ///
  /// In en, this message translates to:
  /// **'Select date, venue, and time slot'**
  String get selectDateVenueTime;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'📅  Select Date'**
  String get selectDate;

  /// No description provided for @selectField.
  ///
  /// In en, this message translates to:
  /// **'📍  Select Field'**
  String get selectField;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'🕐  Select Time'**
  String get selectTime;

  /// No description provided for @full.
  ///
  /// In en, this message translates to:
  /// **'FULL'**
  String get full;

  /// No description provided for @slotAlreadyBooked.
  ///
  /// In en, this message translates to:
  /// **'Slot Already Booked'**
  String get slotAlreadyBooked;

  /// No description provided for @alreadyBookedMsg.
  ///
  /// In en, this message translates to:
  /// **'is already booked for'**
  String get alreadyBookedMsg;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get on;

  /// No description provided for @chooseDifferent.
  ///
  /// In en, this message translates to:
  /// **'Please choose a different time or date.'**
  String get chooseDifferent;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed!'**
  String get bookingConfirmed;

  /// No description provided for @bookAnother.
  ///
  /// In en, this message translates to:
  /// **'Book Another'**
  String get bookAnother;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm:'**
  String get confirmBooking;

  /// No description provided for @activitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activitiesTitle;

  /// No description provided for @activitiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'24 activities — Sports & Performing Arts'**
  String get activitiesSubtitle;

  /// No description provided for @sports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get sports;

  /// No description provided for @arts.
  ///
  /// In en, this message translates to:
  /// **'Arts'**
  String get arts;

  /// No description provided for @all24.
  ///
  /// In en, this message translates to:
  /// **'All 24'**
  String get all24;

  /// No description provided for @searchActivities.
  ///
  /// In en, this message translates to:
  /// **'🔍  Search activities...'**
  String get searchActivities;

  /// No description provided for @noActivitiesFound.
  ///
  /// In en, this message translates to:
  /// **'No activities found'**
  String get noActivitiesFound;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @registerNowBtn.
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get registerNowBtn;

  /// No description provided for @spots.
  ///
  /// In en, this message translates to:
  /// **'spots'**
  String get spots;

  /// No description provided for @enrolledTag.
  ///
  /// In en, this message translates to:
  /// **'✓ Enrolled'**
  String get enrolledTag;

  /// No description provided for @myApplicationsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Applications'**
  String get myApplicationsTitle;

  /// No description provided for @allTab.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allTab;

  /// No description provided for @pendingTab.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingTab;

  /// No description provided for @approvedTab.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approvedTab;

  /// No description provided for @rejectedTab.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejectedTab;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @noApplicationsYet.
  ///
  /// In en, this message translates to:
  /// **'No applications here yet'**
  String get noApplicationsYet;

  /// No description provided for @goToActivities.
  ///
  /// In en, this message translates to:
  /// **'Go to Activities to register'**
  String get goToActivities;

  /// No description provided for @applied.
  ///
  /// In en, this message translates to:
  /// **'Applied:'**
  String get applied;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level:'**
  String get level;

  /// No description provided for @congratsApproved.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You\'ve been approved. Check your university email for further instructions.'**
  String get congratsApproved;

  /// No description provided for @rejectedMsg.
  ///
  /// In en, this message translates to:
  /// **'Your application was not accepted this time. You may reapply next semester.'**
  String get rejectedMsg;

  /// No description provided for @underReview.
  ///
  /// In en, this message translates to:
  /// **'Your application is under review. The admin will respond shortly.'**
  String get underReview;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @semesterGoal.
  ///
  /// In en, this message translates to:
  /// **'🎯 Semester Goal'**
  String get semesterGoal;

  /// No description provided for @goalAchieved.
  ///
  /// In en, this message translates to:
  /// **'🎉 Goal achieved this semester!'**
  String get goalAchieved;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @achievementsBadges.
  ///
  /// In en, this message translates to:
  /// **'Achievements & Badges'**
  String get achievementsBadges;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @myReservations.
  ///
  /// In en, this message translates to:
  /// **'My Reservations'**
  String get myReservations;

  /// No description provided for @participationHistory.
  ///
  /// In en, this message translates to:
  /// **'Participation History'**
  String get participationHistory;

  /// No description provided for @updateProfilePrefs.
  ///
  /// In en, this message translates to:
  /// **'Update profile & preferences'**
  String get updateProfilePrefs;

  /// No description provided for @viewManageBookings.
  ///
  /// In en, this message translates to:
  /// **'View & manage bookings'**
  String get viewManageBookings;

  /// No description provided for @activitiesEventsBookings.
  ///
  /// In en, this message translates to:
  /// **'Activities, events & bookings'**
  String get activitiesEventsBookings;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @aiGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Guide'**
  String get aiGuideTitle;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear chat'**
  String get clearChat;

  /// No description provided for @askMeAnything.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything...'**
  String get askMeAnything;

  /// No description provided for @chatCleared.
  ///
  /// In en, this message translates to:
  /// **'Chat cleared! Hello again'**
  String get chatCleared;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'champs'**
  String get leaderboard;

  /// No description provided for @topPerformers.
  ///
  /// In en, this message translates to:
  /// **'Top performers this semester'**
  String get topPerformers;

  /// No description provided for @noStudentsYet.
  ///
  /// In en, this message translates to:
  /// **'No students yet'**
  String get noStudentsYet;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'unread'**
  String get unread;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get allCaughtUp;

  /// No description provided for @noNotificationsNow.
  ///
  /// In en, this message translates to:
  /// **'No notifications right now.'**
  String get noNotificationsNow;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// No description provided for @notifReservationReminder.
  ///
  /// In en, this message translates to:
  /// **'Reservation Reminder'**
  String get notifReservationReminder;

  /// No description provided for @notifRegistrationApproved.
  ///
  /// In en, this message translates to:
  /// **'Registration Approved'**
  String get notifRegistrationApproved;

  /// No description provided for @notifRegistrationRejected.
  ///
  /// In en, this message translates to:
  /// **'Registration Rejected'**
  String get notifRegistrationRejected;

  /// No description provided for @notifUpcomingEvent.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Event'**
  String get notifUpcomingEvent;

  /// No description provided for @notifFormRequired.
  ///
  /// In en, this message translates to:
  /// **'Form Required'**
  String get notifFormRequired;

  /// No description provided for @notifSystemInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get notifSystemInfo;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  /// No description provided for @myReservationsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Reservations'**
  String get myReservationsTitle;

  /// No description provided for @newBooking.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newBooking;

  /// No description provided for @upcomingSection.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcomingSection;

  /// No description provided for @pastCancelled.
  ///
  /// In en, this message translates to:
  /// **'Past & Cancelled'**
  String get pastCancelled;

  /// No description provided for @remindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind Me'**
  String get remindMe;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking?'**
  String get cancelBooking;

  /// No description provided for @cancelBookingMsg.
  ///
  /// In en, this message translates to:
  /// **'Cancel your booking for'**
  String get cancelBookingMsg;

  /// No description provided for @keepIt.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepIt;

  /// No description provided for @cancelBookingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get cancelBookingConfirm;

  /// No description provided for @reminderSet.
  ///
  /// In en, this message translates to:
  /// **'🔔 Reminder set for'**
  String get reminderSet;

  /// No description provided for @noReservationsYet.
  ///
  /// In en, this message translates to:
  /// **'No reservations yet'**
  String get noReservationsYet;

  /// No description provided for @bookFacilityToStart.
  ///
  /// In en, this message translates to:
  /// **'Book a facility to get started'**
  String get bookFacilityToStart;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now →'**
  String get bookNow;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today!'**
  String get todayLabel;

  /// No description provided for @tomorrowLabel.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrowLabel;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'✅ Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'⏳ Pending'**
  String get statusPending;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'❌ Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'✔ Completed'**
  String get statusCompleted;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetails;

  /// No description provided for @almostThere.
  ///
  /// In en, this message translates to:
  /// **'Almost there — fill in the remaining info'**
  String get almostThere;

  /// No description provided for @joinMusterSport.
  ///
  /// In en, this message translates to:
  /// **'Join MUSTER SPORT and start competing 🏟️'**
  String get joinMusterSport;

  /// No description provided for @iAmA.
  ///
  /// In en, this message translates to:
  /// **'I AM A…'**
  String get iAmA;

  /// No description provided for @roleStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get roleStudent;

  /// No description provided for @roleStudentDesc.
  ///
  /// In en, this message translates to:
  /// **'Join activities,\nbook facilities & compete'**
  String get roleStudentDesc;

  /// No description provided for @roleCoach.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get roleCoach;

  /// No description provided for @roleCoachDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage teams &\nreview registrations'**
  String get roleCoachDesc;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleAdminDesc.
  ///
  /// In en, this message translates to:
  /// **'Full access to\ndashboard & users'**
  String get roleAdminDesc;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'FULL NAME'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mohamed Ahmed'**
  String get fullNameHint;

  /// No description provided for @universityEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'UNIVERSITY EMAIL'**
  String get universityEmailLabel;

  /// No description provided for @studentIdHint.
  ///
  /// In en, this message translates to:
  /// **'MUST-2024-XXXX'**
  String get studentIdHint;

  /// No description provided for @studentIdDesc.
  ///
  /// In en, this message translates to:
  /// **'Your university-issued ID number'**
  String get studentIdDesc;

  /// No description provided for @facultyLabel.
  ///
  /// In en, this message translates to:
  /// **'FACULTY'**
  String get facultyLabel;

  /// No description provided for @selectFaculty.
  ///
  /// In en, this message translates to:
  /// **'Select faculty'**
  String get selectFaculty;

  /// No description provided for @semesterLabel.
  ///
  /// In en, this message translates to:
  /// **'SEMESTER'**
  String get semesterLabel;

  /// No description provided for @semesterHint.
  ///
  /// In en, this message translates to:
  /// **'Semester'**
  String get semesterHint;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'PHONE (OPTIONAL)'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'01xxxxxxxxx'**
  String get phoneHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get passwordLabel;

  /// No description provided for @passwordHint2.
  ///
  /// In en, this message translates to:
  /// **'Min. 6 characters'**
  String get passwordHint2;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM PASSWORD'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get confirmPasswordHint;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @joinAs.
  ///
  /// In en, this message translates to:
  /// **'Join as'**
  String get joinAs;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @errorNameShort.
  ///
  /// In en, this message translates to:
  /// **'Full name must be at least 3 characters.'**
  String get errorNameShort;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid university email.'**
  String get errorInvalidEmail;

  /// No description provided for @errorPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get errorPasswordShort;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get errorPasswordMismatch;

  /// No description provided for @errorSelectFaculty.
  ///
  /// In en, this message translates to:
  /// **'Please select your faculty.'**
  String get errorSelectFaculty;

  /// No description provided for @errorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get errorEmailInUse;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak — use at least 6 characters.'**
  String get errorWeakPassword;

  /// No description provided for @errorSignUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-up failed. Please try again.'**
  String get errorSignUpFailed;

  /// No description provided for @checkEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkEmail;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a password reset link to {email}. Check your inbox and follow the instructions.'**
  String resetLinkSent(String email);

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToSignIn;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your university email and we\'ll send you a reset link.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @errorNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account found with that email.'**
  String get errorNoAccount;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @failedToLoadLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Failed to load leaderboard'**
  String get failedToLoadLeaderboard;

  /// No description provided for @rankingsLabel.
  ///
  /// In en, this message translates to:
  /// **'RANKINGS'**
  String get rankingsLabel;

  /// No description provided for @youLabel.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youLabel;

  /// No description provided for @featuredTournamentName.
  ///
  /// In en, this message translates to:
  /// **'MUST Inter-Faculty\nFootball Cup'**
  String get featuredTournamentName;

  /// No description provided for @featuredTournamentDate.
  ///
  /// In en, this message translates to:
  /// **'March 15 – April 2, 2026'**
  String get featuredTournamentDate;

  /// No description provided for @chatbotGreetingStudent.
  ///
  /// In en, this message translates to:
  /// **'👋 Hello {name}! I\'m your MUSTER SPORT AI Guide 🏟️\n\nI can help you find activities, register, and track your applications.'**
  String chatbotGreetingStudent(String name);

  /// No description provided for @chatbotGreetingAdmin.
  ///
  /// In en, this message translates to:
  /// **'👋 Hello {name}! I\'m the MUSTER SPORT AI Admin Guide 🛡️\n\nI can help you manage registrations, navigate the dashboard, and handle student applications.\n\nHow can I help?'**
  String chatbotGreetingAdmin(String name);

  /// No description provided for @chatbotReplyGreetingAdmin.
  ///
  /// In en, this message translates to:
  /// **'👋 Hello Admin! I\'m your MUSTER SPORT AI Guide.\n\nI can help you:\n• Review pending registrations\n• Navigate the admin dashboard\n• Manage events and users\n\nWhat do you need help with?'**
  String get chatbotReplyGreetingAdmin;

  /// No description provided for @chatbotReplyGreetingStudent.
  ///
  /// In en, this message translates to:
  /// **'👋 Hello! Welcome to MUSTER SPORT 🏟️\n\nI can help you:\n• Browse all 12 activities\n• Register for an activity\n• Check your registration status\n• View upcoming events\n\nWhat would you like to do?'**
  String get chatbotReplyGreetingStudent;

  /// No description provided for @chatbotReplyActivities.
  ///
  /// In en, this message translates to:
  /// **'🎭 We offer 24 activities — Sports & Performing Arts:\n\n⚽ SPORTS (12):\n{sports}\n\n🎭 ARTS & CULTURE (12):\n{arts}\n\nGo to the Activities tab and use the Sports / Arts / All tabs to browse!'**
  String chatbotReplyActivities(String sports, String arts);

  /// No description provided for @chatbotReplyRegisterAdmin.
  ///
  /// In en, this message translates to:
  /// **'📋 To manage registrations:\n1. Go to Registrations tab\n2. Review pending applications\n3. View full student details\n4. Tap ✅ Approve or ❌ Reject\n\nYou can also reset a decision using the ↩ Reset button.'**
  String get chatbotReplyRegisterAdmin;

  /// No description provided for @chatbotReplyRegisterStudent.
  ///
  /// In en, this message translates to:
  /// **'📝 To register for an activity:\n1. Tap the Activities tab (⚽)\n2. Browse or search for your activity\n3. Tap \"Register Now\"\n4. Fill in the registration form\n5. Submit and await admin approval!\n\nTrack your status in \"My Registrations\".'**
  String get chatbotReplyRegisterStudent;

  /// No description provided for @chatbotReplyEvents.
  ///
  /// In en, this message translates to:
  /// **'🏆 Upcoming Events:\n\n⚽ Inter-Faculty Football Cup — Mar 15\n🎾 MUST Padel Championship — Mar 22\n🏀 Basketball 3v3 Tournament — Apr 5\n🏅 Annual Sports Day — Apr 20\n🏐 Volleyball Mixed Cup — Apr 12\n🏊 Swimming Gala — May 3\n\nGo to the Events tab for full details!'**
  String get chatbotReplyEvents;

  /// No description provided for @chatbotReplyNoRegistrations.
  ///
  /// In en, this message translates to:
  /// **'📭 You haven\'t registered for any activities yet.\n\nGo to the Activities tab to register!'**
  String get chatbotReplyNoRegistrations;

  /// No description provided for @chatbotReplyMyRegistrations.
  ///
  /// In en, this message translates to:
  /// **'📋 Your Registrations:\n\n{lines}\n\nCheck the \"My Registrations\" tab for full details.'**
  String chatbotReplyMyRegistrations(String lines);

  /// No description provided for @chatbotReplyAdminSummary.
  ///
  /// In en, this message translates to:
  /// **'📊 Registration Summary:\n\n⏳ Pending: {pending}\n✅ Approved: {approved}\n❌ Rejected: {rejected}\n\nGo to the Registrations tab to review.'**
  String chatbotReplyAdminSummary(int pending, int approved, int rejected);

  /// No description provided for @chatbotReplyAdminQuickSummary.
  ///
  /// In en, this message translates to:
  /// **'🛡️ Admin Quick Summary:\n\n• {pending} pending registration(s) awaiting review\n• Go to Registrations tab to act\n• Use Events tab to manage tournaments\n• Check Dashboard for full stats\n\nNeed help with anything specific?'**
  String chatbotReplyAdminQuickSummary(int pending);

  /// No description provided for @chatbotReplyPoints.
  ///
  /// In en, this message translates to:
  /// **'⭐ Points System:\n\n• Join an activity → +50 pts\n• Attend sessions → +10 pts/session\n• Win a tournament → +200 pts\n• Top 3 finish → +100 pts\n• Sports Day participation → +30 pts\n\nCheck the Leaderboard to see your rank among all students!'**
  String get chatbotReplyPoints;

  /// No description provided for @chatbotReplyBooking.
  ///
  /// In en, this message translates to:
  /// **'📅 Booking Facilities:\n\nYou can book:\n• ⚽ Football Fields A & B\n• 🎾 Padel Courts 1 & 2\n• 🏀 Basketball Court\n• 🏐 Volleyball Court\n\nGo to the Booking tab and select your facility, date, and time slot!'**
  String get chatbotReplyBooking;

  /// No description provided for @chatbotReplyHelpAdmin.
  ///
  /// In en, this message translates to:
  /// **'🛡️ Admin Help:\n\n• 🏠 Dashboard — Stats & overview\n• 📋 Registrations — Approve/reject students\n• 🏆 Events — Manage tournaments\n• 👥 Users — View all students\n\nTap any tab in the bottom nav to navigate. What do you need?'**
  String get chatbotReplyHelpAdmin;

  /// No description provided for @chatbotReplyHelpStudent.
  ///
  /// In en, this message translates to:
  /// **'🏟️ Student Help:\n\n• 🏠 Home — Your stats & quick actions\n• ⚽ Activities — Browse & register for sports\n• 📅 Booking — Reserve a facility\n• 🏆 Events — Join tournaments\n• 📋 My Registrations — Track your applications\n• 👤 Profile — Your achievements & stats\n\nAsk me anything!'**
  String get chatbotReplyHelpStudent;

  /// No description provided for @chatbotReplyFallback.
  ///
  /// In en, this message translates to:
  /// **'🤔 I\'m not sure about that. Try asking me about:\n\n• \"show activities\" — available sports\n• \"how to register\" — sign up process\n• \"my status\" — your applications\n• \"upcoming events\" — tournaments\n• \"points system\" — scoring\n• \"help\" — full guide'**
  String get chatbotReplyFallback;

  /// No description provided for @suggSports.
  ///
  /// In en, this message translates to:
  /// **'Sports activities'**
  String get suggSports;

  /// No description provided for @suggArts.
  ///
  /// In en, this message translates to:
  /// **'Arts activities'**
  String get suggArts;

  /// No description provided for @suggHowToRegister.
  ///
  /// In en, this message translates to:
  /// **'How to register'**
  String get suggHowToRegister;

  /// No description provided for @suggMyStatus.
  ///
  /// In en, this message translates to:
  /// **'My status'**
  String get suggMyStatus;

  /// No description provided for @suggPoints.
  ///
  /// In en, this message translates to:
  /// **'Points system'**
  String get suggPoints;

  /// No description provided for @suggPendingRegs.
  ///
  /// In en, this message translates to:
  /// **'Pending registrations'**
  String get suggPendingRegs;

  /// No description provided for @suggHowToApprove.
  ///
  /// In en, this message translates to:
  /// **'How to approve'**
  String get suggHowToApprove;

  /// No description provided for @suggDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard overview'**
  String get suggDashboard;

  /// No description provided for @suggEvents.
  ///
  /// In en, this message translates to:
  /// **'Events summary'**
  String get suggEvents;

  /// No description provided for @pts.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get pts;

  /// No description provided for @footballFieldA.
  ///
  /// In en, this message translates to:
  /// **'Football Field A'**
  String get footballFieldA;

  /// No description provided for @padelCourt2.
  ///
  /// In en, this message translates to:
  /// **'Padel Court 2'**
  String get padelCourt2;

  /// No description provided for @tomorrowAt.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow, {time}'**
  String tomorrowAt(String time);

  /// No description provided for @mar7At.
  ///
  /// In en, this message translates to:
  /// **'Mar 7, {time}'**
  String mar7At(String time);

  /// No description provided for @catTeamSports.
  ///
  /// In en, this message translates to:
  /// **'Team Sports'**
  String get catTeamSports;

  /// No description provided for @catRacketSports.
  ///
  /// In en, this message translates to:
  /// **'Racket Sports'**
  String get catRacketSports;

  /// No description provided for @catIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get catIndividual;

  /// No description provided for @catCombatSports.
  ///
  /// In en, this message translates to:
  /// **'Combat Sports'**
  String get catCombatSports;

  /// No description provided for @catAquatics.
  ///
  /// In en, this message translates to:
  /// **'Aquatics'**
  String get catAquatics;

  /// No description provided for @catWellness.
  ///
  /// In en, this message translates to:
  /// **'Wellness'**
  String get catWellness;

  /// No description provided for @catMindSports.
  ///
  /// In en, this message translates to:
  /// **'Mind Sports'**
  String get catMindSports;

  /// No description provided for @catPerformingArts.
  ///
  /// In en, this message translates to:
  /// **'Performing Arts'**
  String get catPerformingArts;

  /// No description provided for @catMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get catMusic;

  /// No description provided for @catLiteraryArts.
  ///
  /// In en, this message translates to:
  /// **'Literary Arts'**
  String get catLiteraryArts;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @venue.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get venue;

  /// No description provided for @coachLabel.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get coachLabel;

  /// No description provided for @activeMembers.
  ///
  /// In en, this message translates to:
  /// **'Active Members'**
  String get activeMembers;

  /// No description provided for @regFee.
  ///
  /// In en, this message translates to:
  /// **'Registration Fee'**
  String get regFee;

  /// No description provided for @studentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} students'**
  String studentsCount(int count);

  /// No description provided for @alreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'You are registered!'**
  String get alreadyRegistered;

  /// No description provided for @checkStatusInMyApps.
  ///
  /// In en, this message translates to:
  /// **'Check your status in \"My Applications\".'**
  String get checkStatusInMyApps;

  /// No description provided for @registerForActivity.
  ///
  /// In en, this message translates to:
  /// **'Register for {name} →'**
  String registerForActivity(String name);

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register – {name}'**
  String registerTitle(String name);

  /// No description provided for @coachPrefix.
  ///
  /// In en, this message translates to:
  /// **'Coach: {name}'**
  String coachPrefix(String name);

  /// No description provided for @errorPleaseAgreeTerms.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the terms and conditions'**
  String get errorPleaseAgreeTerms;

  /// No description provided for @errorActivityFull.
  ///
  /// In en, this message translates to:
  /// **'Sorry, this activity is currently full. Please check back later.'**
  String get errorActivityFull;

  /// No description provided for @personalInfoSection.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfoSection;

  /// No description provided for @fieldLabelPhone.
  ///
  /// In en, this message translates to:
  /// **'PHONE NUMBER *'**
  String get fieldLabelPhone;

  /// No description provided for @fieldLabelFaculty.
  ///
  /// In en, this message translates to:
  /// **'FACULTY *'**
  String get fieldLabelFaculty;

  /// No description provided for @fieldLabelSemester.
  ///
  /// In en, this message translates to:
  /// **'SEMESTER'**
  String get fieldLabelSemester;

  /// No description provided for @fieldLabelLevel.
  ///
  /// In en, this message translates to:
  /// **'EXPERIENCE LEVEL'**
  String get fieldLabelLevel;

  /// No description provided for @experienceBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get experienceBeginner;

  /// No description provided for @experienceIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get experienceIntermediate;

  /// No description provided for @experienceAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get experienceAdvanced;

  /// No description provided for @experienceProfessional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get experienceProfessional;

  /// No description provided for @teamMembersSection.
  ///
  /// In en, this message translates to:
  /// **'Team Members'**
  String get teamMembersSection;

  /// No description provided for @teamMembersDesc.
  ///
  /// In en, this message translates to:
  /// **'Add your team members (name, student ID, faculty)'**
  String get teamMembersDesc;

  /// No description provided for @memberNum.
  ///
  /// In en, this message translates to:
  /// **'Member {n}'**
  String memberNum(int n);

  /// No description provided for @addAnotherMember.
  ///
  /// In en, this message translates to:
  /// **'Add Another Member'**
  String get addAnotherMember;

  /// No description provided for @motivationSection.
  ///
  /// In en, this message translates to:
  /// **'Motivation'**
  String get motivationSection;

  /// No description provided for @fieldLabelStatement.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL STATEMENT'**
  String get fieldLabelStatement;

  /// No description provided for @statementHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us why you want to join and any relevant experience...'**
  String get statementHint;

  /// No description provided for @agreementsSection.
  ///
  /// In en, this message translates to:
  /// **'Agreements'**
  String get agreementsSection;

  /// No description provided for @agreementMedical.
  ///
  /// In en, this message translates to:
  /// **'I confirm I am physically fit and have no medical conditions that would prevent participation.'**
  String get agreementMedical;

  /// No description provided for @agreementTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the activity terms, code of conduct, and university sports policies. *'**
  String get agreementTerms;

  /// No description provided for @submitApplication.
  ///
  /// In en, this message translates to:
  /// **'Submit Application →'**
  String get submitApplication;

  /// No description provided for @applicationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Application Submitted!'**
  String get applicationSubmitted;

  /// No description provided for @appSubmittedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your registration for {activity} has been sent to the admin for review. You\'ll be notified once approved.'**
  String appSubmittedDesc(String activity);

  /// No description provided for @backToActivities.
  ///
  /// In en, this message translates to:
  /// **'Back to Activities'**
  String get backToActivities;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @payInstaPay.
  ///
  /// In en, this message translates to:
  /// **'InstaPay'**
  String get payInstaPay;

  /// No description provided for @payVodafoneCash.
  ///
  /// In en, this message translates to:
  /// **'Vodafone Cash'**
  String get payVodafoneCash;

  /// No description provided for @payFawry.
  ///
  /// In en, this message translates to:
  /// **'Fawry'**
  String get payFawry;

  /// No description provided for @payCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get payCard;

  /// No description provided for @payCentralBank.
  ///
  /// In en, this message translates to:
  /// **'Central Bank'**
  String get payCentralBank;

  /// No description provided for @payMobileWallet.
  ///
  /// In en, this message translates to:
  /// **'Mobile Wallet'**
  String get payMobileWallet;

  /// No description provided for @payAtOutlet.
  ///
  /// In en, this message translates to:
  /// **'Pay at outlet'**
  String get payAtOutlet;

  /// No description provided for @payVisaMastercard.
  ///
  /// In en, this message translates to:
  /// **'Visa / Mastercard'**
  String get payVisaMastercard;

  /// No description provided for @securePayment.
  ///
  /// In en, this message translates to:
  /// **'Secure Payment'**
  String get securePayment;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'MM/YY'**
  String get expiryDate;

  /// No description provided for @cvc.
  ///
  /// In en, this message translates to:
  /// **'CVC'**
  String get cvc;

  /// No description provided for @cardholderName.
  ///
  /// In en, this message translates to:
  /// **'Cardholder Name'**
  String get cardholderName;

  /// No description provided for @payInstantlyCentralBank.
  ///
  /// In en, this message translates to:
  /// **'Pay instantly via Central Bank of Egypt'**
  String get payInstantlyCentralBank;

  /// No description provided for @payViaVodafoneCash.
  ///
  /// In en, this message translates to:
  /// **'Pay via Vodafone Cash mobile wallet'**
  String get payViaVodafoneCash;

  /// No description provided for @instaPayHint.
  ///
  /// In en, this message translates to:
  /// **'InstaPay username or +20xxxxxxxxxx'**
  String get instaPayHint;

  /// No description provided for @vodafoneCashHint.
  ///
  /// In en, this message translates to:
  /// **'Vodafone Cash number (010xxxxxxxx)'**
  String get vodafoneCashHint;

  /// No description provided for @instaPayInfo.
  ///
  /// In en, this message translates to:
  /// **'A payment request will be sent to your InstaPay account.'**
  String get instaPayInfo;

  /// No description provided for @vodafoneCashInfo.
  ///
  /// In en, this message translates to:
  /// **'You will receive an OTP on your Vodafone number to confirm.'**
  String get vodafoneCashInfo;

  /// No description provided for @fawryInstruction.
  ///
  /// In en, this message translates to:
  /// **'Pay at any Fawry outlet or Fawry app'**
  String get fawryInstruction;

  /// No description provided for @referenceNumber.
  ///
  /// In en, this message translates to:
  /// **'REFERENCE NUMBER'**
  String get referenceNumber;

  /// No description provided for @fawryStep1.
  ///
  /// In en, this message translates to:
  /// **'Visit any Fawry outlet or open Fawry app'**
  String get fawryStep1;

  /// No description provided for @fawryStep2.
  ///
  /// In en, this message translates to:
  /// **'Select \"Bill Payment\" > \"Universities\"'**
  String get fawryStep2;

  /// No description provided for @fawryStep3.
  ///
  /// In en, this message translates to:
  /// **'Enter the reference number above'**
  String get fawryStep3;

  /// No description provided for @fawryStep4.
  ///
  /// In en, this message translates to:
  /// **'Complete payment within 48 hours'**
  String get fawryStep4;

  /// No description provided for @errorCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 16-digit card number'**
  String get errorCardNumber;

  /// No description provided for @errorExpiry.
  ///
  /// In en, this message translates to:
  /// **'Enter expiry as MM/YY'**
  String get errorExpiry;

  /// No description provided for @errorExpired.
  ///
  /// In en, this message translates to:
  /// **'Card has expired'**
  String get errorExpired;

  /// No description provided for @errorCVC.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid CVC (3-4 digits)'**
  String get errorCVC;

  /// No description provided for @errorCardholder.
  ///
  /// In en, this message translates to:
  /// **'Enter the cardholder name'**
  String get errorCardholder;

  /// No description provided for @errorEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter your {method}'**
  String errorEnterPhone(String method);

  /// No description provided for @errorVodafoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Vodafone Cash number starting with 010 (11 digits)'**
  String get errorVodafoneNumber;

  /// No description provided for @errorInstaPayFormat.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid InstaPay username or Egyptian mobile number'**
  String get errorInstaPayFormat;

  /// No description provided for @paidVia.
  ///
  /// In en, this message translates to:
  /// **'Paid via {method}'**
  String paidVia(String method);

  /// No description provided for @refCopied.
  ///
  /// In en, this message translates to:
  /// **'Reference number copied'**
  String get refCopied;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get december;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @eventsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get eventsAdmin;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @activeEvents.
  ///
  /// In en, this message translates to:
  /// **'Active Events'**
  String get activeEvents;

  /// No description provided for @registrations.
  ///
  /// In en, this message translates to:
  /// **'Registrations'**
  String get registrations;

  /// No description provided for @pendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get pendingReview;

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// No description provided for @recentEvents.
  ///
  /// In en, this message translates to:
  /// **'Recent Events'**
  String get recentEvents;

  /// No description provided for @manageAllEvents.
  ///
  /// In en, this message translates to:
  /// **'Manage All Events →'**
  String get manageAllEvents;

  /// No description provided for @userBreakdown.
  ///
  /// In en, this message translates to:
  /// **'User Breakdown'**
  String get userBreakdown;

  /// No description provided for @allBookings.
  ///
  /// In en, this message translates to:
  /// **'All Bookings'**
  String get allBookings;

  /// No description provided for @manageAllUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage All Users →'**
  String get manageAllUsers;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @coachActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get coachActivities;

  /// No description provided for @students.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get students;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @yourDashboard.
  ///
  /// In en, this message translates to:
  /// **'Your Dashboard'**
  String get yourDashboard;

  /// No description provided for @manageActivitiesSessions.
  ///
  /// In en, this message translates to:
  /// **'Manage your activities & sessions'**
  String get manageActivitiesSessions;

  /// No description provided for @myActivities.
  ///
  /// In en, this message translates to:
  /// **'My Activities'**
  String get myActivities;

  /// No description provided for @recentSessions.
  ///
  /// In en, this message translates to:
  /// **'Recent Sessions'**
  String get recentSessions;

  /// No description provided for @noActivitiesAssigned.
  ///
  /// In en, this message translates to:
  /// **'No activities assigned'**
  String get noActivitiesAssigned;

  /// No description provided for @myStudents.
  ///
  /// In en, this message translates to:
  /// **'My Students'**
  String get myStudents;

  /// No description provided for @acrossActivities.
  ///
  /// In en, this message translates to:
  /// **'Across {count} activities'**
  String acrossActivities(int count);

  /// No description provided for @noSessionsYet.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get noSessionsYet;

  /// No description provided for @scheduleFirstSession.
  ///
  /// In en, this message translates to:
  /// **'Schedule your first session'**
  String get scheduleFirstSession;

  /// No description provided for @scheduleSession.
  ///
  /// In en, this message translates to:
  /// **'Schedule Session'**
  String get scheduleSession;

  /// No description provided for @selectActivityToSchedule.
  ///
  /// In en, this message translates to:
  /// **'Select an activity to schedule a session.'**
  String get selectActivityToSchedule;

  /// No description provided for @manageUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get manageUsers;

  /// No description provided for @coaches.
  ///
  /// In en, this message translates to:
  /// **'Coaches'**
  String get coaches;

  /// No description provided for @admins.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get admins;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get searchUsers;

  /// No description provided for @adminList.
  ///
  /// In en, this message translates to:
  /// **'Admin list'**
  String get adminList;

  /// No description provided for @createActivity.
  ///
  /// In en, this message translates to:
  /// **'Create Activity'**
  String get createActivity;

  /// No description provided for @errorSelectCoach.
  ///
  /// In en, this message translates to:
  /// **'Please select a coach'**
  String get errorSelectCoach;

  /// No description provided for @activityNameEn.
  ///
  /// In en, this message translates to:
  /// **'Activity Name (EN) *'**
  String get activityNameEn;

  /// No description provided for @activityNameAr.
  ///
  /// In en, this message translates to:
  /// **'Activity Name (AR) *'**
  String get activityNameAr;

  /// No description provided for @activityType.
  ///
  /// In en, this message translates to:
  /// **'Activity Type'**
  String get activityType;

  /// No description provided for @activityCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get activityCategory;

  /// No description provided for @activityDescEn.
  ///
  /// In en, this message translates to:
  /// **'Description (EN)'**
  String get activityDescEn;

  /// No description provided for @activityDescAr.
  ///
  /// In en, this message translates to:
  /// **'Description (AR)'**
  String get activityDescAr;

  /// No description provided for @activityCoach.
  ///
  /// In en, this message translates to:
  /// **'Coach *'**
  String get activityCoach;

  /// No description provided for @activityMax.
  ///
  /// In en, this message translates to:
  /// **'Max Participants'**
  String get activityMax;

  /// No description provided for @activitySchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule (e.g. Mon 4PM)'**
  String get activitySchedule;

  /// No description provided for @activityLocEn.
  ///
  /// In en, this message translates to:
  /// **'Location (EN)'**
  String get activityLocEn;

  /// No description provided for @activityLocAr.
  ///
  /// In en, this message translates to:
  /// **'Location (AR)'**
  String get activityLocAr;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creating;

  /// No description provided for @sendNotification.
  ///
  /// In en, this message translates to:
  /// **'Send Notification'**
  String get sendNotification;

  /// No description provided for @notificationTitleEn.
  ///
  /// In en, this message translates to:
  /// **'Title (EN)'**
  String get notificationTitleEn;

  /// No description provided for @notificationTitleAr.
  ///
  /// In en, this message translates to:
  /// **'Title (AR)'**
  String get notificationTitleAr;

  /// No description provided for @notificationMessageEn.
  ///
  /// In en, this message translates to:
  /// **'Message (EN)'**
  String get notificationMessageEn;

  /// No description provided for @notificationMessageAr.
  ///
  /// In en, this message translates to:
  /// **'Message (AR)'**
  String get notificationMessageAr;

  /// No description provided for @targetAudience.
  ///
  /// In en, this message translates to:
  /// **'TARGET AUDIENCE'**
  String get targetAudience;

  /// No description provided for @everyone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get everyone;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @activityCreated.
  ///
  /// In en, this message translates to:
  /// **'Activity created!'**
  String get activityCreated;

  /// No description provided for @activated.
  ///
  /// In en, this message translates to:
  /// **'Activated'**
  String get activated;

  /// No description provided for @deactivated.
  ///
  /// In en, this message translates to:
  /// **'Deactivated'**
  String get deactivated;

  /// No description provided for @userActivated.
  ///
  /// In en, this message translates to:
  /// **'User activated'**
  String get userActivated;

  /// No description provided for @userDeactivated.
  ///
  /// In en, this message translates to:
  /// **'User deactivated'**
  String get userDeactivated;

  /// No description provided for @notificationSent.
  ///
  /// In en, this message translates to:
  /// **'Notification sent!'**
  String get notificationSent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
