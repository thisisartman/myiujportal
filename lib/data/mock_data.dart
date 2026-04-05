import '../models/alert_item.dart';
import '../models/calendar_event.dart';
import '../models/facility.dart';
import '../models/wiki_page.dart';
import 'package:flutter/material.dart';

final List<Facility> kFacilities = [
  const Facility(
    id: 'f1',
    name: 'Classroom G.30',
    type: 'Academic',
    authority: 'OAA',
    bgColor: Color(0xFFDBEAFE),
    iconColor: Color(0xFF2563EB),
  ),
  const Facility(
    id: 'f2',
    name: 'CNP Snack Lounge',
    type: 'Social',
    authority: 'OGA',
    bgColor: Color(0xFFFFEDD5),
    iconColor: Color(0xFFEA580C),
  ),
  const Facility(
    id: 'f3',
    name: 'Main Gymnasium',
    type: 'Sports',
    authority: 'OSS',
    bgColor: Color(0xFFDCFCE7),
    iconColor: Color(0xFF16A34A),
  ),
  const Facility(
    id: 'f4',
    name: 'MLIC Study Room A',
    type: 'Library',
    authority: 'Library Admin',
    bgColor: Color(0xFFF3E8FF),
    iconColor: Color(0xFF9333EA),
  ),
];

final List<TimeSlot> kMockSlots = [
  const TimeSlot(time: '09:00 AM - 10:30 AM', available: false),
  const TimeSlot(time: '10:40 AM - 12:10 PM', available: true),
  const TimeSlot(time: '13:15 PM - 14:45 PM', available: true),
  const TimeSlot(time: '14:55 PM - 16:25 PM', available: false),
  const TimeSlot(time: '16:30 PM - 18:00 PM', available: true),
  const TimeSlot(time: '18:15 PM - 19:45 PM', available: true),
];

final List<CalendarEvent> kInitialCalendarEvents = [
  const CalendarEvent(id: 1, type: CalendarEventType.class_, date: 1, time: '09:00', title: 'Ethics and Decision-making', detail: 'Maurice THEVENET | MGTP-31205 | G.30'),
  const CalendarEvent(id: 2, type: CalendarEventType.class_, date: 1, time: '13:15', title: 'Launch your startup', detail: 'Anne Sophie DE GABRIAC | MGTE-31363 | P.109'),
  const CalendarEvent(id: 3, type: CalendarEventType.assignment, date: 1, time: '15:00', title: 'Finance Assignment Due', detail: 'Submit via Moodle Portal'),
  const CalendarEvent(id: 4, type: CalendarEventType.class_, date: 4, time: '16:30', title: 'Entrepreneurship', detail: 'Yann CRAMER | MGTE-31361 | P.103'),
  const CalendarEvent(id: 5, type: CalendarEventType.event, date: 6, time: '18:30', title: 'Culture Night Prep Meeting', detail: 'Matsushita Hall | GSO Event'),
  const CalendarEvent(id: 6, type: CalendarEventType.class_, date: 10, time: '09:00', title: 'Data-Driven Organization', detail: 'Zaw Zaw Aung | ITC1080 | P.109'),
  const CalendarEvent(id: 7, type: CalendarEventType.assignment, date: 13, time: '23:59', title: 'Startup Pitch Deck Due', detail: 'Upload to Google Classroom'),
  const CalendarEvent(id: 8, type: CalendarEventType.event, date: 20, time: '12:00', title: 'Career Fair Registration', detail: 'Main Cafeteria'),
  const CalendarEvent(id: 9, type: CalendarEventType.class_, date: 24, time: '14:40', title: 'Operations Management', detail: 'Wenkai Li | OPR1010 | G.21'),
  const CalendarEvent(id: 10, type: CalendarEventType.event, date: 27, time: '17:00', title: 'GSO Monthly Assembly', detail: 'Matsushita Hall'),
];

const List<String> kEnrolledCourses = [
  'None (General Event)',
  'Ethics (MGTP-31205)',
  'Startup (MGTE-31363)',
  'Entrepreneurship (MGTE-31361)',
];

final List<DirectoryEntry> kMockDirectory = [
  // Offices
  const DirectoryEntry(id: 1, name: 'Office of Academic Affairs (OAA)', type: 'Department', email: 'oaa@iuj.ac.jp', phone: 'Ext. 4110'),
  const DirectoryEntry(id: 2, name: 'Office of Student Services (OSS)', type: 'Department', email: 'oss@iuj.ac.jp', phone: 'Ext. 4120'),
  const DirectoryEntry(id: 3, name: 'Office of General Affairs (OGA)', type: 'Department', email: 'oga@iuj.ac.jp', phone: 'Ext. 4130'),
  const DirectoryEntry(id: 4, name: 'Admissions Office', type: 'Department', email: 'admissions@iuj.ac.jp', phone: 'Ext. 4100'),
  const DirectoryEntry(id: 5, name: 'Career Development Center', type: 'Department', email: 'career@iuj.ac.jp', phone: 'Ext. 4140'),
  // Faculty - GSIM
  const DirectoryEntry(id: 6, name: 'Prof. Maurice Thevenet', type: 'Faculty - GSIM', email: 'mthevenet@iuj.ac.jp', phone: 'Ext. 3020'),
  const DirectoryEntry(id: 7, name: 'Prof. Anne Sophie De Gabriac', type: 'Faculty - GSIM', email: 'adegabriac@iuj.ac.jp', phone: 'Ext. 3025'),
  const DirectoryEntry(id: 8, name: 'Prof. Remy Magnier-Watanabe', type: 'Faculty - GSIM', email: 'rmagnier@iuj.ac.jp', phone: 'Ext. 3030'),
  const DirectoryEntry(id: 9, name: 'Prof. Zaw Zaw Aung', type: 'Faculty - GSIM', email: 'zaung@iuj.ac.jp', phone: 'Ext. 3035'),
  const DirectoryEntry(id: 10, name: 'Prof. Wenkai Li', type: 'Faculty - GSIM', email: 'wli@iuj.ac.jp', phone: 'Ext. 3040'),
  // Support
  const DirectoryEntry(id: 11, name: 'IT Helpdesk', type: 'Support', email: 'helpdesk@iuj.ac.jp', phone: 'Ext. 4222'),
  const DirectoryEntry(id: 12, name: 'Matsushita Library (MLIC) Front Desk', type: 'Facility', email: 'library@iuj.ac.jp', phone: 'Ext. 4333'),
  const DirectoryEntry(id: 13, name: 'Health Center', type: 'Support', email: 'health@iuj.ac.jp', phone: 'Ext. 4200'),
  const DirectoryEntry(id: 14, name: 'Tokyo Liaison Office (Roppongi)', type: 'Satellite Office', email: 'tokyo@iuj.ac.jp', phone: '+81-3-XXXX-XXXX'),
];

final List<WikiCategory> kWikiCategories = [
  WikiCategory(
    id: 'courses',
    name: 'Courses',
    subcategories: [
      // GSIM
      const WikiSubcategory(id: 'finance', name: 'Finance (GSIM)'),
      const WikiSubcategory(id: 'general-management', name: 'General Management (GSIM)'),
      const WikiSubcategory(id: 'it-operations', name: 'IT & Operations (GSIM)'),
      // GSIR
      const WikiSubcategory(id: 'intl-relations', name: 'International Relations (GSIR)'),
      const WikiSubcategory(id: 'intl-development', name: 'International Development (GSIR)'),
      const WikiSubcategory(id: 'public-management', name: 'Public Management (GSIR)'),
    ],
  ),
  const WikiCategory(id: 'residential-life', name: 'Residential Life'),
  const WikiCategory(id: 'academics', name: 'Academics'),
  const WikiCategory(id: 'gso', name: 'GSO'),
  const WikiCategory(id: 'administration', name: 'Administration'),
];

// All wiki page metadata (content is in the page widgets)
final Map<String, WikiPage> kWikiPages = {
  'wiki-home': const WikiPage(id: 'wiki-home', title: 'Wiki Knowledge Base', category: 'Wiki', isLandingPage: true, lastUpdated: 'Today'),
  'category-courses': const WikiPage(id: 'category-courses', title: 'Course Syllabi Hub', category: 'Courses', isLandingPage: true, parentPage: 'wiki-home', lastUpdated: 'Today'),
  'subcategory-finance': const WikiPage(id: 'subcategory-finance', title: 'Finance Specialization', category: 'Courses', subcategory: 'Finance', isLandingPage: true, parentPage: 'category-courses', lastUpdated: 'Winter 2026'),
  'subcategory-it-operations': const WikiPage(id: 'subcategory-it-operations', title: 'IT & Operations Specialization', category: 'Courses', subcategory: 'IT & Operations', isLandingPage: true, parentPage: 'category-courses', lastUpdated: 'Winter 2026'),
  'subcategory-general-management': const WikiPage(id: 'subcategory-general-management', title: 'General Management Specialization', category: 'Courses', subcategory: 'General Management', isLandingPage: true, parentPage: 'category-courses', lastUpdated: 'Winter 2026'),
  'category-residential-life': const WikiPage(id: 'category-residential-life', title: 'Residential Life Hub', category: 'Residential Life', isLandingPage: true, parentPage: 'wiki-home', lastUpdated: 'Today'),
  'category-academics': const WikiPage(id: 'category-academics', title: 'Academics Hub', category: 'Academics', isLandingPage: true, parentPage: 'wiki-home', lastUpdated: 'Today'),
  'category-gso': const WikiPage(id: 'category-gso', title: 'GSO Hub', category: 'GSO', isLandingPage: true, parentPage: 'wiki-home', lastUpdated: 'Today'),
  'category-administration': const WikiPage(id: 'category-administration', title: 'Administration Hub', category: 'Administration', isLandingPage: true, parentPage: 'wiki-home', lastUpdated: 'Today'),
  'winter-survival': const WikiPage(id: 'winter-survival', title: 'Winter Survival Guide', category: 'Residential Life', parentPage: 'category-residential-life', lastUpdated: 'Oct 24, 2025'),
  'trash-mastery': const WikiPage(id: 'trash-mastery', title: 'Trash Separation Mastery', category: 'Residential Life', parentPage: 'category-residential-life', lastUpdated: 'Sep 10, 2025'),
  'urasa-station': const WikiPage(id: 'urasa-station', title: 'Urasa Station Transit Guide', category: 'Residential Life', parentPage: 'category-residential-life', lastUpdated: 'Nov 01, 2025'),
  'device-calendar': const WikiPage(id: 'device-calendar', title: 'Syncing Timetable & Reminders', category: 'Academics', parentPage: 'category-academics', lastUpdated: 'Just Now'),
  'course-fin2090': const WikiPage(id: 'course-fin2090', title: 'FIN2090: Behavioral Finance', category: 'Courses', subcategory: 'Finance', parentPage: 'subcategory-finance', lastUpdated: 'Winter 2026'),
  'course-fin2080': const WikiPage(id: 'course-fin2080', title: 'FIN2080: Sustainable Finance & Investment', category: 'Courses', subcategory: 'Finance', parentPage: 'subcategory-finance', lastUpdated: 'Winter 2026'),
  'course-fin3020': const WikiPage(id: 'course-fin3020', title: 'FIN3020: Finance and Technology', category: 'Courses', subcategory: 'Finance', parentPage: 'subcategory-finance', lastUpdated: 'Winter 2026'),
  'course-itc1080': const WikiPage(id: 'course-itc1080', title: 'ITC1080: Data-Driven Organization', category: 'Courses', subcategory: 'IT & Operations', parentPage: 'subcategory-it-operations', lastUpdated: 'Winter 2026'),
  'course-itc2080': const WikiPage(id: 'course-itc2080', title: 'ITC2080: Management for Digital Transformation', category: 'Courses', subcategory: 'IT & Operations', parentPage: 'subcategory-it-operations', lastUpdated: 'Winter 2026'),
  'course-itc2020': const WikiPage(id: 'course-itc2020', title: 'ITC2020: Big Data Analytics', category: 'Courses', subcategory: 'IT & Operations', parentPage: 'subcategory-it-operations', lastUpdated: 'Winter 2026'),
  'course-opr1010': const WikiPage(id: 'course-opr1010', title: 'OPR1010: Operations Management', category: 'Courses', subcategory: 'IT & Operations', parentPage: 'subcategory-it-operations', lastUpdated: 'Winter 2026'),
  'course-mgt1130': const WikiPage(id: 'course-mgt1130', title: 'MGT1130: International Management', category: 'Courses', subcategory: 'General Management', parentPage: 'subcategory-general-management', lastUpdated: 'Winter 2026'),
  'course-mgt1140': const WikiPage(id: 'course-mgt1140', title: 'MGT1140: Business Decision-Making and Control', category: 'Courses', subcategory: 'General Management', parentPage: 'subcategory-general-management', lastUpdated: 'Winter 2026'),
  'course-mgt2120': const WikiPage(id: 'course-mgt2120', title: 'MGT2120: Entrepreneurship & Small Business Dev.', category: 'Courses', subcategory: 'General Management', parentPage: 'subcategory-general-management', lastUpdated: 'Winter 2026'),

  // GSIR subcategory landing pages
  'subcategory-intl-relations': const WikiPage(id: 'subcategory-intl-relations', title: 'International Relations (IRP)', category: 'Courses', subcategory: 'International Relations (GSIR)', isLandingPage: true, parentPage: 'category-courses', lastUpdated: 'Apr 2026'),
  'subcategory-intl-development': const WikiPage(id: 'subcategory-intl-development', title: 'International Development (IDP)', category: 'Courses', subcategory: 'International Development (GSIR)', isLandingPage: true, parentPage: 'category-courses', lastUpdated: 'Apr 2026'),
  'subcategory-public-management': const WikiPage(id: 'subcategory-public-management', title: 'Public Management & Policy (PMPP)', category: 'Courses', subcategory: 'Public Management (GSIR)', isLandingPage: true, parentPage: 'category-courses', lastUpdated: 'Apr 2026'),

  // Administration pages
  'about-iuj': const WikiPage(id: 'about-iuj', title: 'About IUJ', category: 'Administration', parentPage: 'category-administration', lastUpdated: 'Apr 2026'),
  'access-transport': const WikiPage(id: 'access-transport', title: 'Getting to Campus', category: 'Administration', parentPage: 'category-administration', lastUpdated: 'Apr 2026'),
  'admissions-overview': const WikiPage(id: 'admissions-overview', title: 'Admissions Overview', category: 'Administration', parentPage: 'category-administration', lastUpdated: 'Apr 2026'),
  'research-centers': const WikiPage(id: 'research-centers', title: 'Research Centers & Institutes', category: 'Administration', parentPage: 'category-administration', lastUpdated: 'Apr 2026'),
};

final List<AlertItem> kMockAlerts = [
  const AlertItem(
    id: 'a1',
    title: 'Library Extended Hours — Finals Week',
    body: 'The Matsushita Library (MLIC) will be open until midnight from Apr 20–30. Quiet study rooms bookable via OSS.',
    date: 'Apr 6',
    mailingList: 'all-students',
    severity: AlertSeverity.info,
  ),
  const AlertItem(
    id: 'a2',
    title: 'Course Registration Opens Apr 15',
    body: 'Spring term course registration opens at 9:00 AM on April 15. Log into the Academic Portal to submit your course selections. Contact OAA (oaa@iuj.ac.jp) with any questions.',
    date: 'Apr 5',
    mailingList: 'all-students',
    severity: AlertSeverity.announcement,
  ),
  const AlertItem(
    id: 'a3',
    title: 'GSIM Career Fair — Volunteer Sign-up',
    body: 'The GSIM Career Fair is on Apr 20. Students interested in volunteering at the event should sign up via the OSS portal by Apr 12.',
    date: 'Apr 4',
    mailingList: 'gsim-only',
    severity: AlertSeverity.info,
  ),
  const AlertItem(
    id: 'a4',
    title: 'Campus Shuttle Schedule Change (Golden Week)',
    body: 'The Urasa Station shuttle will run reduced service May 3–6 (Golden Week). Check the OGA notice board for the modified timetable.',
    date: 'Apr 3',
    mailingList: 'all-students',
    severity: AlertSeverity.warning,
  ),
  const AlertItem(
    id: 'a5',
    title: 'New Wi-Fi Access Points Installed in CNP',
    body: 'IT has upgraded wireless coverage in the CNP building. If you experience connectivity issues, contact helpdesk@iuj.ac.jp or Ext. 4222.',
    date: 'Apr 1',
    mailingList: 'all-students',
    severity: AlertSeverity.info,
  ),
];
