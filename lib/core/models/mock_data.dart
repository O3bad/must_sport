import 'package:flutter/material.dart';
import 'models.dart';

class MockData {
  MockData._();

  // Fallback user (used before login)
  static const user = UserModel(
    uid: 'u-001',
    role: UserRole.student,
    name: 'Mohamed Salah',
    studentId: 'MUST-2024-0088',
    email: 'student@must.edu.eg',
    faculty: 'IT Faculty',
    semester: 'Spring 2026',
    points: 1240,
    rank: 12,
    cgpa: 3.43,
    creditHours: '87/140',
    targetEvents: 5,
    stats: UserStats(eventsJoined: 12, bookingsMade: 34, wins: 7),
    achievements: [
      Achievement(id:'mvp',       icon:'🏆', label:'MVP Football 2025', color:Color(0xFFFFD700)),
      Achievement(id:'padel',     icon:'🥇', label:'Padel Champion',    color:Color(0xFFFFD700)),
      Achievement(id:'sportsday', icon:'⭐', label:'Sports Day Winner', color:Color(0xFF00E5FF)),
      Achievement(id:'captain',   icon:'🎖️', label:'Team Captain',      color:Color(0xFFA8FF3E)),
    ],
  );

  static final facilities = [
    const Facility(id:'f1', name:'Football Field A', category:SportCategory.football,   isAvailable:true),
    const Facility(id:'f2', name:'Football Field B', category:SportCategory.football,   isAvailable:false),
    const Facility(id:'f3', name:'Padel Court 1',    category:SportCategory.padel,      isAvailable:true),
    const Facility(id:'f4', name:'Padel Court 2',    category:SportCategory.padel,      isAvailable:true),
    const Facility(id:'f5', name:'Basketball Court', category:SportCategory.basketball, isAvailable:true),
    const Facility(id:'f6', name:'Volleyball Court', category:SportCategory.volleyball, isAvailable:false),
  ];

  static final events = [
    SportEvent(id:'e1', title:'Inter-Faculty Football Cup', emoji:'⚽',
      sportType:SportCategory.football, startDate:DateTime(2026,3,15),
      endDate:DateTime(2026,4,2), participants:128, maxParticipants:150,
      status:EventStatus.open, location:'Main Court'),
    SportEvent(id:'e2', title:'MUST Padel Championship', emoji:'🎾',
      sportType:SportCategory.padel, startDate:DateTime(2026,3,22),
      participants:32, maxParticipants:40,
      status:EventStatus.open, location:'Padel Court 1'),
    SportEvent(id:'e3', title:'Basketball 3v3 Tournament', emoji:'🏀',
      sportType:SportCategory.basketball, startDate:DateTime(2026,4,5),
      participants:48, maxParticipants:64,
      status:EventStatus.soon, location:'Gym B'),
    SportEvent(id:'e4', title:'Annual Sports Day', emoji:'🏅',
      sportType:SportCategory.all, startDate:DateTime(2026,4,20),
      participants:200, maxParticipants:300,
      status:EventStatus.soon, location:'Main Stadium'),
    SportEvent(id:'e5', title:'Volleyball Mixed Cup', emoji:'🏐',
      sportType:SportCategory.volleyball, startDate:DateTime(2026,4,12),
      participants:24, maxParticipants:24,
      status:EventStatus.full, location:'Volleyball Court'),
  ];

  static const leaderboard = [
    LeaderboardEntry(rank:1,  name:'Ahmed Hassan',  faculty:'Engineering', points:2140, initials:'AH'),
    LeaderboardEntry(rank:2,  name:'Sara Mahmoud',  faculty:'Medicine',    points:1980, initials:'SM'),
    LeaderboardEntry(rank:3,  name:'Omar Khalil',   faculty:'IT',          points:1760, initials:'OK'),
    LeaderboardEntry(rank:4,  name:'Nour Adel',     faculty:'Pharmacy',    points:1540, initials:'NA'),
    LeaderboardEntry(rank:11, name:'Mohamed Salah', faculty:'IT',          points:1240, initials:'MS', isMe:true),
    LeaderboardEntry(rank:12, name:'Layla Ibrahim', faculty:'Engineering', points:1190, initials:'LI'),
    LeaderboardEntry(rank:13, name:'Youssef Tarek', faculty:'Business',    points:1140, initials:'YT'),
  ];

  static const timeSlots = [
    '8:00 AM','10:00 AM','12:00 PM',
    '2:00 PM','4:00 PM','6:00 PM','8:00 PM',
  ];
}
