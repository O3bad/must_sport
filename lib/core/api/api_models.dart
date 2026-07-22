
// ── Generic paginated response wrapper ───────────────────────────
class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int perPage;
  final int lastPage;

  const PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.perPage,
    required this.lastPage,
  });

  bool get hasMore => page < lastPage;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      data:     (json['data'] as List<dynamic>).map(fromJsonT).toList(),
      total:    (json['total'] as num?)?.toInt()    ?? 0,
      page:     (json['page']  as num?)?.toInt()    ?? 1,
      perPage:  (json['per_page'] as num?)?.toInt() ?? 20,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) => {
    'data':      data.map(toJsonT).toList(),
    'total':     total,
    'page':      page,
    'per_page':  perPage,
    'last_page': lastPage,
  };
}

// ── Activity DTO ─────────────────────────────────────────────────
class ActivityDto {
  final String  id;
  final String  name;
  final String  nameAr;
  final String  type;
  final String  category;
  final String  description;
  final String  descriptionAr;
  final String  coachId;
  final String  coachName;
  final String? imageUrl;
  final int     maxParticipants;
  final int     currentParticipants;
  final String  schedule;
  final String  location;
  final String  locationAr;
  final bool    isActive;
  final double? rating;
  final int     ratingCount;
  final String  createdAt;

  const ActivityDto({
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
    required this.currentParticipants,
    required this.schedule,
    required this.location,
    required this.locationAr,
    required this.isActive,
    this.rating,
    required this.ratingCount,
    required this.createdAt,
  });

  factory ActivityDto.fromJson(Map<String, dynamic> j) => ActivityDto(
    id:                  j['id']                   as String? ?? '',
    name:                j['name']                 as String? ?? '',
    nameAr:              j['name_ar']              as String? ?? '',
    type:                j['type']                 as String? ?? '',
    category:            j['category']             as String? ?? '',
    description:         j['description']          as String? ?? '',
    descriptionAr:       j['description_ar']       as String? ?? '',
    coachId:             j['coach_id']             as String? ?? '',
    coachName:           j['coach_name']           as String? ?? '',
    imageUrl:            j['image_url']            as String?,
    maxParticipants:     (j['max_participants']    as num?)?.toInt() ?? 0,
    currentParticipants: (j['current_participants'] as num?)?.toInt() ?? 0,
    schedule:            j['schedule']             as String? ?? '',
    location:            j['location']             as String? ?? '',
    locationAr:          j['location_ar']          as String? ?? '',
    isActive:            j['is_active']            as bool?   ?? true,
    rating:              (j['rating']              as num?)?.toDouble(),
    ratingCount:         (j['rating_count']        as num?)?.toInt() ?? 0,
    createdAt:           j['created_at']           as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id':                  id,
    'name':                name,
    'name_ar':             nameAr,
    'type':                type,
    'category':            category,
    'description':         description,
    'description_ar':      descriptionAr,
    'coach_id':            coachId,
    'coach_name':          coachName,
    'image_url':           imageUrl,
    'max_participants':    maxParticipants,
    'current_participants':currentParticipants,
    'schedule':            schedule,
    'location':            location,
    'location_ar':         locationAr,
    'is_active':           isActive,
    'rating':              rating,
    'rating_count':        ratingCount,
    'created_at':          createdAt,
  };
}

// ── Session DTO ──────────────────────────────────────────────────
class SessionDto {
  final String       id;
  final String       activityId;
  final String       activityName;
  final String       coachId;
  final String       dateTime;
  final int          durationMinutes;
  final String       notes;
  final String       location;
  final List<String> attendeeIds;
  final bool         isCancelled;

  const SessionDto({
    required this.id,
    required this.activityId,
    required this.activityName,
    required this.coachId,
    required this.dateTime,
    required this.durationMinutes,
    required this.notes,
    required this.location,
    required this.attendeeIds,
    required this.isCancelled,
  });

  factory SessionDto.fromJson(Map<String, dynamic> j) => SessionDto(
    id:              j['id']               as String? ?? '',
    activityId:      j['activity_id']      as String? ?? '',
    activityName:    j['activity_name']    as String? ?? '',
    coachId:         j['coach_id']         as String? ?? '',
    dateTime:        j['date_time']        as String? ?? '',
    durationMinutes: (j['duration_minutes'] as num?)?.toInt() ?? 90,
    notes:           j['notes']            as String? ?? '',
    location:        j['location']         as String? ?? '',
    attendeeIds:     List<String>.from(j['attendee_ids'] ?? []),
    isCancelled:     j['is_cancelled']     as bool?   ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id':               id,
    'activity_id':      activityId,
    'activity_name':    activityName,
    'coach_id':         coachId,
    'date_time':        dateTime,
    'duration_minutes': durationMinutes,
    'notes':            notes,
    'location':         location,
    'attendee_ids':     attendeeIds,
    'is_cancelled':     isCancelled,
  };
}

// ── User DTO ─────────────────────────────────────────────────────
class UserDto {
  final String       uid;
  final String       email;
  final String       name;
  final String       nameAr;
  final String       role;
  final String?      photoUrl;
  final String?      phone;
  final String?      department;
  final String?      studentId;
  final List<String> enrolledActivities;
  final bool         isActive;
  final String       createdAt;

  const UserDto({
    required this.uid,
    required this.email,
    required this.name,
    required this.nameAr,
    required this.role,
    this.photoUrl,
    this.phone,
    this.department,
    this.studentId,
    required this.enrolledActivities,
    required this.isActive,
    required this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> j) => UserDto(
    uid:                j['uid']          as String? ?? '',
    email:              j['email']        as String? ?? '',
    name:               j['name']         as String? ?? '',
    nameAr:             j['name_ar']      as String? ?? '',
    role:               j['role']         as String? ?? 'student',
    photoUrl:           j['photo_url']    as String?,
    phone:              j['phone']        as String?,
    department:         j['department']   as String?,
    studentId:          j['student_id']   as String?,
    enrolledActivities: List<String>.from(j['enrolled_activities'] ?? []),
    isActive:           j['is_active']    as bool?   ?? true,
    createdAt:          j['created_at']   as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'uid':                 uid,
    'email':               email,
    'name':                name,
    'name_ar':             nameAr,
    'role':                role,
    'photo_url':           photoUrl,
    'phone':               phone,
    'department':          department,
    'student_id':          studentId,
    'enrolled_activities': enrolledActivities,
    'is_active':           isActive,
    'created_at':          createdAt,
  };
}

// ── Notification DTO ─────────────────────────────────────────────
class NotificationDto {
  final String  id;
  final String  title;
  final String  titleAr;
  final String  body;
  final String  bodyAr;
  final String  type;
  final String? targetRole;
  final bool    isRead;
  final String  createdAt;

  const NotificationDto({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.body,
    required this.bodyAr,
    required this.type,
    this.targetRole,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> j) => NotificationDto(
    id:         j['id']          as String? ?? '',
    title:      j['title']       as String? ?? '',
    titleAr:    j['title_ar']    as String? ?? '',
    body:       j['body']        as String? ?? '',
    bodyAr:     j['body_ar']     as String? ?? '',
    type:       j['type']        as String? ?? 'general',
    targetRole: j['target_role'] as String?,
    isRead:     j['is_read']     as bool?   ?? false,
    createdAt:  j['created_at']  as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id':          id,
    'title':       title,
    'title_ar':    titleAr,
    'body':        body,
    'body_ar':     bodyAr,
    'type':        type,
    'target_role': targetRole,
    'is_read':     isRead,
    'created_at':  createdAt,
  };
}

// ── Enrollment request ───────────────────────────────────────────
class EnrollmentRequest {
  final String activityId;
  final String studentId;

  const EnrollmentRequest({
    required this.activityId,
    required this.studentId,
  });

  factory EnrollmentRequest.fromJson(Map<String, dynamic> j) =>
      EnrollmentRequest(
        activityId: j['activity_id'] as String? ?? '',
        studentId:  j['student_id']  as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
    'activity_id': activityId,
    'student_id':  studentId,
  };
}

// ── Auth response ────────────────────────────────────────────────
class AuthResponse {
  final String  token;
  final String  refreshToken;
  final int     expiresIn;
  final UserDto user;

  const AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> j) => AuthResponse(
    token:        j['token']         as String? ?? '',
    refreshToken: j['refresh_token'] as String? ?? '',
    expiresIn:    (j['expires_in']   as num?)?.toInt() ?? 3600,
    user:         UserDto.fromJson(j['user'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'token':         token,
    'refresh_token': refreshToken,
    'expires_in':    expiresIn,
    'user':          user.toJson(),
  };
}

// ── Create activity request ──────────────────────────────────────
class CreateActivityRequest {
  final String name;
  final String nameAr;
  final String type;
  final String category;
  final String description;
  final String descriptionAr;
  final String coachId;
  final int    maxParticipants;
  final String schedule;
  final String location;
  final String locationAr;

  const CreateActivityRequest({
    required this.name,
    required this.nameAr,
    required this.type,
    required this.category,
    required this.description,
    required this.descriptionAr,
    required this.coachId,
    required this.maxParticipants,
    required this.schedule,
    required this.location,
    required this.locationAr,
  });

  factory CreateActivityRequest.fromJson(Map<String, dynamic> j) =>
      CreateActivityRequest(
        name:            j['name']             as String? ?? '',
        nameAr:          j['name_ar']          as String? ?? '',
        type:            j['type']             as String? ?? '',
        category:        j['category']         as String? ?? '',
        description:     j['description']      as String? ?? '',
        descriptionAr:   j['description_ar']   as String? ?? '',
        coachId:         j['coach_id']         as String? ?? '',
        maxParticipants: (j['max_participants'] as num?)?.toInt() ?? 30,
        schedule:        j['schedule']         as String? ?? '',
        location:        j['location']         as String? ?? '',
        locationAr:      j['location_ar']      as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
    'name':             name,
    'name_ar':          nameAr,
    'type':             type,
    'category':         category,
    'description':      description,
    'description_ar':   descriptionAr,
    'coach_id':         coachId,
    'max_participants': maxParticipants,
    'schedule':         schedule,
    'location':         location,
    'location_ar':      locationAr,
  };
}
