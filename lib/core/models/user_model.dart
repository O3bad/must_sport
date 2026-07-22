// lib/core/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String nameAr;
  final String role; // student, admin, coach
  final String? photoUrl;
  final String? phone;
  final String? department;
  final String? studentId;
  final List<String> enrolledActivities;
  final String? fcmToken;
  final DateTime createdAt;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.nameAr,
    required this.role,
    this.photoUrl,
    this.phone,
    this.department,
    this.studentId,
    this.enrolledActivities = const [],
    this.fcmToken,
    required this.createdAt,
    this.isActive = true,
    this.metadata,
  });

  bool get isStudent => role == UserRoles.student;
  bool get isAdmin => role == UserRoles.admin;
  bool get isCoach => role == UserRoles.coach;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      nameAr: data['nameAr'] ?? '',
      role: data['role'] ?? UserRoles.student,
      photoUrl: data['photoUrl'],
      phone: data['phone'],
      department: data['department'],
      studentId: data['studentId'],
      enrolledActivities: List<String>.from(data['enrolledActivities'] ?? []),
      fcmToken: data['fcmToken'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'nameAr': nameAr,
      'role': role,
      'photoUrl': photoUrl,
      'phone': phone,
      'department': department,
      'studentId': studentId,
      'enrolledActivities': enrolledActivities,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  UserModel copyWith({
    String? name,
    String? nameAr,
    String? photoUrl,
    String? phone,
    String? department,
    List<String>? enrolledActivities,
    String? fcmToken,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      role: role,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      studentId: studentId,
      enrolledActivities: enrolledActivities ?? this.enrolledActivities,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata,
    );
  }
}

class ActivityModel {
  final String id;
  final String name;
  final String nameAr;
  final String type; // sports or arts
  final String category; // Football, Theater, etc.
  final String description;
  final String descriptionAr;
  final String coachId;
  final String coachName;
  final String? imageUrl;
  final int maxParticipants;
  final int currentParticipants;
  final String schedule; // e.g. "Mon/Wed 4-6PM"
  final String location;
  final String locationAr;
  final bool isActive;
  final DateTime createdAt;
  final List<String> enrolledStudentIds;
  final double? rating;
  final int ratingCount;

  ActivityModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.type,
    required this.category,
    required this.description,
    required this.descriptionAr,
    required this.coachId,
    required this.coachName,
    this.imageUrl,
    required this.maxParticipants,
    this.currentParticipants = 0,
    required this.schedule,
    required this.location,
    required this.locationAr,
    this.isActive = true,
    required this.createdAt,
    this.enrolledStudentIds = const [],
    this.rating,
    this.ratingCount = 0,
  });

  bool get isFull => currentParticipants >= maxParticipants;
  double get fillPercentage => currentParticipants / maxParticipants;

  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityModel(
      id: doc.id,
      name: data['name'] ?? '',
      nameAr: data['nameAr'] ?? '',
      type: data['type'] ?? ActivityTypes.sports,
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      descriptionAr: data['descriptionAr'] ?? '',
      coachId: data['coachId'] ?? '',
      coachName: data['coachName'] ?? '',
      imageUrl: data['imageUrl'],
      maxParticipants: data['maxParticipants'] ?? 30,
      currentParticipants: data['currentParticipants'] ?? 0,
      schedule: data['schedule'] ?? '',
      location: data['location'] ?? '',
      locationAr: data['locationAr'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      enrolledStudentIds: List<String>.from(data['enrolledStudentIds'] ?? []),
      rating: data['rating']?.toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nameAr': nameAr,
      'type': type,
      'category': category,
      'description': description,
      'descriptionAr': descriptionAr,
      'coachId': coachId,
      'coachName': coachName,
      'imageUrl': imageUrl,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'schedule': schedule,
      'location': location,
      'locationAr': locationAr,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'enrolledStudentIds': enrolledStudentIds,
      'rating': rating,
      'ratingCount': ratingCount,
    };
  }
}

class SessionModel {
  final String id;
  final String activityId;
  final String activityName;
  final String coachId;
  final DateTime dateTime;
  final int durationMinutes;
  final String notes;
  final String location;
  final List<String> attendeeIds;
  final bool isCancelled;

  SessionModel({
    required this.id,
    required this.activityId,
    required this.activityName,
    required this.coachId,
    required this.dateTime,
    this.durationMinutes = 90,
    this.notes = '',
    required this.location,
    this.attendeeIds = const [],
    this.isCancelled = false,
  });

  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SessionModel(
      id: doc.id,
      activityId: data['activityId'] ?? '',
      activityName: data['activityName'] ?? '',
      coachId: data['coachId'] ?? '',
      dateTime: (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationMinutes: data['durationMinutes'] ?? 90,
      notes: data['notes'] ?? '',
      location: data['location'] ?? '',
      attendeeIds: List<String>.from(data['attendeeIds'] ?? []),
      isCancelled: data['isCancelled'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'activityId': activityId,
    'activityName': activityName,
    'coachId': coachId,
    'dateTime': Timestamp.fromDate(dateTime),
    'durationMinutes': durationMinutes,
    'notes': notes,
    'location': location,
    'attendeeIds': attendeeIds,
    'isCancelled': isCancelled,
  };
}

class NotificationModel {
  final String id;
  final String title;
  final String titleAr;
  final String body;
  final String bodyAr;
  final String type;
  final String? targetUserId;
  final String? targetRole;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.body,
    required this.bodyAr,
    required this.type,
    this.targetUserId,
    this.targetRole,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      titleAr: data['titleAr'] ?? '',
      body: data['body'] ?? '',
      bodyAr: data['bodyAr'] ?? '',
      type: data['type'] ?? 'general',
      targetUserId: data['targetUserId'],
      targetRole: data['targetRole'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }
}
