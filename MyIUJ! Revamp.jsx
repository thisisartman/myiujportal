import React, { useState, useMemo, useEffect } from 'react';
import {
  Search, Menu, Home, Book, MapPin, Trash2,
  Snowflake, Calendar, Edit3, ShieldAlert,
  User, CheckCircle, X, ChevronRight, ChevronLeft, FileText,
  CalendarDays, CreditCard, GraduationCap, Building,
  Wallet, BookOpen, Smartphone, BellRing,
  CalendarCheck, Clock, Map, Info, Library, LayoutDashboard,
  Filter, Plus, Users, Link as LinkIcon, Copy,
  ExternalLink, Phone, Mail, BookText, Contact, FilePlus
} from 'lucide-react';

const FACILITIES = [
  { id: 'f1', name: 'Classroom G.30', type: 'Academic', authority: 'OAA', image: 'bg-blue-100 text-blue-600' },
  { id: 'f2', name: 'CNP Snack Lounge', type: 'Social', authority: 'OGA', image: 'bg-orange-100 text-orange-600' },
  { id: 'f3', name: 'Main Gymnasium', type: 'Sports', authority: 'OSS', image: 'bg-green-100 text-green-600' },
  { id: 'f4', name: 'MLIC Study Room A', type: 'Library', authority: 'Library Admin', image: 'bg-purple-100 text-purple-600' }
];

const MOCK_SLOTS = [
  { time: '09:00 AM - 10:30 AM', status: 'unavailable' },
  { time: '10:40 AM - 12:10 PM', status: 'available' },
  { time: '13:15 PM - 14:45 PM', status: 'available' },
  { time: '14:55 PM - 16:25 PM', status: 'unavailable' },
  { time: '16:30 PM - 18:00 PM', status: 'available' },
  { time: '18:15 PM - 19:45 PM', status: 'available' },
];

const CATEGORIES = [
  { id: 'courses', name: 'Courses', icon: <BookOpen className="w-4 h-4" />, subcategories: [
    {id: 'finance', name: 'Finance'},
    {id: 'general-management', name: 'General Management'},
    {id: 'it-operations', name: 'IT & Operations'}
  ]},
  { id: 'residential-life', name: 'Residential Life', icon: <Home className="w-4 h-4" /> },
  { id: 'academics', name: 'Academics', icon: <Book className="w-4 h-4" /> },
  { id: 'gso', name: 'GSO', icon: <User className="w-4 h-4" /> },
  { id: 'administration', name: 'Administration', icon: <ShieldAlert className="w-4 h-4" /> }
];

const INITIAL_CALENDAR_EVENTS = [
  { id: 1, type: 'class', date: 1, time: '09:00', title: 'Ethics and Decision-making', detail: 'Maurice THEVENET | MGTP-31205 | G.30' },
  { id: 2, type: 'class', date: 1, time: '13:15', title: 'Launch your startup', detail: 'Anne Sophie DE GABRIAC | MGTE-31363 | P.109' },
  { id: 3, type: 'assignment', date: 1, time: '15:00', title: 'Finance Assignment Due', detail: 'Submit via Moodle Portal' },
  { id: 4, type: 'class', date: 4, time: '16:30', title: 'Entrepreneurship', detail: 'Yann CRAMER | MGTE-31361 | P.103' },
  { id: 5, type: 'event', date: 6, time: '18:30', title: 'Culture Night Prep Meeting', detail: 'Matsushita Hall | GSO Event' },
  { id: 6, type: 'class', date: 10, time: '09:00', title: 'Data-Driven Organization', detail: 'Zaw Zaw Aung | ITC1080 | P.109' },
  { id: 7, type: 'assignment', date: 13, time: '23:59', title: 'Startup Pitch Deck Due', detail: 'Upload to Google Classroom' },
  { id: 8, type: 'event', date: 20, time: '12:00', title: 'Career Fair Registration', detail: 'Main Cafeteria' },
  { id: 9, type: 'class', date: 24, time: '14:40', title: 'Operations Management', detail: 'Wenkai Li | OPR1010 | G.21' },
  { id: 10, type: 'event', date: 27, time: '17:00', title: 'GSO Monthly Assembly', detail: 'Matsushita Hall' },
];

const ENROLLED_COURSES = ['None (General Event)', 'Ethics (MGTP-31205)', 'Startup (MGTE-31363)', 'Entrepreneurship (MGTE-31361)'];

const MOCK_DIRECTORY = [
  { id: 1, name: 'Office of Academic Affairs (OAA)', type: 'Department', email: 'oaa@iuj.ac.jp', phone: 'Ext. 4110' },
  { id: 2, name: 'Prof. Maurice Thevenet', type: 'Faculty - GSIM', email: 'mthevenet@iuj.ac.jp', phone: 'Ext. 3020' },
  { id: 3, name: 'Prof. Anne Sophie De Gabriac', type: 'Faculty - GSIM', email: 'adegabriac@iuj.ac.jp', phone: 'Ext. 3025' },
  { id: 4, name: 'IT Helpdesk', type: 'Support', email: 'helpdesk@iuj.ac.jp', phone: 'Ext. 4222' },
  { id: 5, name: 'Matsushita Library (MLIC) Front Desk', type: 'Facility', email: 'library@iuj.ac.jp', phone: 'Ext. 4333' }
];

export default function App() {
  const [currentPage, setCurrentPage] = useState('home');
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const [isDesktopSidebarCollapsed, setIsDesktopSidebarCollapsed] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');

  // Modals
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [isCreateTopicModalOpen, setIsCreateTopicModalOpen] = useState(false);
  const [editRequestSent, setEditRequestSent] = useState(false);
  const [toastMessage, setToastMessage] = useState(null);

  // Booking specific state
  const [selectedFacility, setSelectedFacility] = useState(null);
  const [selectedSlot, setSelectedSlot] = useState(null);
  const [bookingReason, setBookingReason] = useState('');

  // Wiki Accordion State
  const [isWikiExpanded, setIsWikiExpanded] = useState(false);
  const [expandedCategories, setExpandedCategories] = useState(CATEGORIES.map(c => c.name));
  const [expandedSubcategories, setExpandedSubcategories] = useState(['Finance', 'General Management', 'IT & Operations']);

  // Calendar specific state
  const [calendarEvents, setCalendarEvents] = useState(INITIAL_CALENDAR_EVENTS);
  const [calendarFilter, setCalendarFilter] = useState('all');
  const [selectedDate, setSelectedDate] = useState(1);
  const [isAddEventModalOpen, setIsAddEventModalOpen] = useState(false);
  const [isEditEventModalOpen, setIsEditEventModalOpen] = useState(false);
  const [editingEvent, setEditingEvent] = useState(null);
  const [isGroupMeetingModalOpen, setIsGroupMeetingModalOpen] = useState(false);
  const [generatedLink, setGeneratedLink] = useState(null);
  const [calendarView, setCalendarView] = useState('month');
  const [currentViewDate, setCurrentViewDate] = useState(new Date(2026, 3, 1)); // April 2026

  // New Meeting Poll State
  const [meetingTitle, setMeetingTitle] = useState('');
  const [isMeetingPollModalOpen, setIsMeetingPollModalOpen] = useState(false);
  const [selectedPollSlots, setSelectedPollSlots] = useState([]);

  // Moving WIKI_PAGES inside the component to allow navigation within content
  const WIKI_PAGES = useMemo(() => ({
    // --- LANDING PAGES ---
    'wiki-home': {
      title: 'Wiki Knowledge Base',
      category: 'Wiki',
      icon: <Library className="w-5 h-5" />,
      isLandingPage: true,
      lastUpdated: 'Today',
      content: (
        <div className="space-y-6 text-gray-800">
          <p className="text-lg">Welcome to the official, community-driven MyIUJ! Wiki. Find procedures, guides, course syllabi, and student-curated knowledge all in one place.</p>

          <div className="flex flex-col sm:flex-row gap-4 pt-2">
            <button onClick={() => setIsCreateTopicModalOpen(true)} className="flex-1 flex items-center justify-center gap-2 bg-indigo-600 text-white p-4 rounded-xl shadow-sm hover:bg-indigo-700 transition-colors font-bold">
              <FilePlus className="w-5 h-5"/> Create New Topic
            </button>
            <button onClick={() => setIsEditModalOpen(true)} className="flex-1 flex items-center justify-center gap-2 bg-white border border-gray-300 text-gray-700 p-4 rounded-xl shadow-sm hover:border-indigo-400 hover:bg-indigo-50 transition-colors font-bold">
              <Edit3 className="w-5 h-5 text-indigo-500"/> Edit Existing Topic
            </button>
          </div>

          <h3 className="text-xl font-bold text-gray-900 border-b border-gray-200 pb-2 mt-6">Explore Categories</h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <button onClick={() => setCurrentPage('category-courses')} className="text-left p-5 border border-gray-200 rounded-xl hover:shadow-md hover:border-indigo-300 transition-all bg-white group flex items-center gap-4">
              <div className="p-3 bg-blue-50 text-blue-600 rounded-lg group-hover:scale-110 transition-transform"><BookOpen className="w-6 h-6"/></div>
              <div><h4 className="font-bold text-gray-900">Courses</h4><p className="text-xs text-gray-500">Syllabi & Materials</p></div>
            </button>
            <button onClick={() => setCurrentPage('category-residential-life')} className="text-left p-5 border border-gray-200 rounded-xl hover:shadow-md hover:border-indigo-300 transition-all bg-white group flex items-center gap-4">
              <div className="p-3 bg-green-50 text-green-600 rounded-lg group-hover:scale-110 transition-transform"><Home className="w-6 h-6"/></div>
              <div><h4 className="font-bold text-gray-900">Residential Life</h4><p className="text-xs text-gray-500">Dorms & Local Guides</p></div>
            </button>
            <button onClick={() => setCurrentPage('category-academics')} className="text-left p-5 border border-gray-200 rounded-xl hover:shadow-md hover:border-indigo-300 transition-all bg-white group flex items-center gap-4">
              <div className="p-3 bg-purple-50 text-purple-600 rounded-lg group-hover:scale-110 transition-transform"><GraduationCap className="w-6 h-6"/></div>
              <div><h4 className="font-bold text-gray-900">Academics</h4><p className="text-xs text-gray-500">Procedures & Registration</p></div>
            </button>
            <button onClick={() => setCurrentPage('category-gso')} className="text-left p-5 border border-gray-200 rounded-xl hover:shadow-md hover:border-indigo-300 transition-all bg-white group flex items-center gap-4">
              <div className="p-3 bg-orange-50 text-orange-600 rounded-lg group-hover:scale-110 transition-transform"><User className="w-6 h-6"/></div>
              <div><h4 className="font-bold text-gray-900">GSO</h4><p className="text-xs text-gray-500">Events & Organizations</p></div>
            </button>
          </div>
        </div>
      )
    },
    'category-courses': {
      title: 'Course Syllabi Hub',
      category: 'Courses',
      icon: <BookOpen className="w-5 h-5" />,
      isLandingPage: true,
      parentPage: 'wiki-home',
      lastUpdated: 'Today',
      content: (
        <div className="space-y-6 text-gray-800">
          <p>Access official syllabi, learning objectives, and materials for courses offered at the Graduate School of International Management (GSIM) and Graduate School of International Relations (GSIR).</p>

          <div className="bg-amber-50 border border-amber-200 p-4 rounded-xl flex items-start gap-3 mt-4">
            <ShieldAlert className="text-amber-600 w-6 h-6 shrink-0 mt-0.5"/>
            <div>
              <p className="text-sm text-amber-900 font-bold mb-1">Role-Based Access Restriction</p>
              <p className="text-sm text-amber-800">Directly adding or publishing new course entries is strictly limited to <strong>Professors and OAA Administrators</strong>. Students are limited to using the "Suggest Edit" feature to propose updates to existing syllabus pages.</p>
            </div>
          </div>

          <h3 className="text-xl font-bold text-gray-900 border-b border-gray-200 pb-2 mt-8">Select Specialization</h3>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <button onClick={() => setCurrentPage('subcategory-finance')} className="bg-white p-5 border border-gray-200 rounded-xl hover:border-indigo-400 hover:shadow-md transition-all text-center group">
              <div className="w-12 h-12 mx-auto bg-indigo-50 text-indigo-600 rounded-full flex items-center justify-center mb-3 group-hover:scale-110 transition-transform"><BookOpen className="w-5 h-5"/></div>
              <h4 className="font-bold text-gray-900">Finance</h4>
            </button>
            <button onClick={() => setCurrentPage('subcategory-it-operations')} className="bg-white p-5 border border-gray-200 rounded-xl hover:border-indigo-400 hover:shadow-md transition-all text-center group">
              <div className="w-12 h-12 mx-auto bg-blue-50 text-blue-600 rounded-full flex items-center justify-center mb-3 group-hover:scale-110 transition-transform"><BookOpen className="w-5 h-5"/></div>
              <h4 className="font-bold text-gray-900">IT & Operations</h4>
            </button>
            <button onClick={() => setCurrentPage('subcategory-general-management')} className="bg-white p-5 border border-gray-200 rounded-xl hover:border-indigo-400 hover:shadow-md transition-all text-center group">
              <div className="w-12 h-12 mx-auto bg-emerald-50 text-emerald-600 rounded-full flex items-center justify-center mb-3 group-hover:scale-110 transition-transform"><BookOpen className="w-5 h-5"/></div>
              <h4 className="font-bold text-gray-900">General Management</h4>
            </button>
          </div>
        </div>
      )
    },
    'subcategory-finance': {
      title: 'Finance Specialization',
      category: 'Courses',
      subcategory: 'Finance',
      icon: <BookOpen className="w-5 h-5" />,
      isLandingPage: true,
      parentPage: 'category-courses',
      lastUpdated: 'Winter 2026',
      content: (
        <div className="space-y-4 text-gray-800">
          <p>The Finance specialization equips students with analytical tools to navigate global markets, sustainable investing, and emerging fintech applications.</p>
          <div className="grid grid-cols-1 gap-3 mt-6">
            <button onClick={() => setCurrentPage('course-fin2090')} className="flex items-center justify-between p-4 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors text-left">
              <span className="font-bold text-indigo-900">FIN2090: Behavioral Finance</span>
              <ChevronRight className="w-5 h-5 text-gray-400"/>
            </button>
            <button onClick={() => setCurrentPage('course-fin2080')} className="flex items-center justify-between p-4 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors text-left">
              <span className="font-bold text-indigo-900">FIN2080: Sustainable Finance & Investment</span>
              <ChevronRight className="w-5 h-5 text-gray-400"/>
            </button>
            <button onClick={() => setCurrentPage('course-fin3020')} className="flex items-center justify-between p-4 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors text-left">
              <span className="font-bold text-indigo-900">FIN3020: Finance and Technology</span>
              <ChevronRight className="w-5 h-5 text-gray-400"/>
            </button>
          </div>
        </div>
      )
    },
    'subcategory-it-operations': {
      title: 'IT & Operations Specialization',
      category: 'Courses',
      subcategory: 'IT & Operations',
      icon: <BookOpen className="w-5 h-5" />,
      isLandingPage: true,
      parentPage: 'category-courses',
      lastUpdated: 'Winter 2026',
      content: (
        <div className="space-y-4 text-gray-800">
          <p>Explore syllabi covering data science, digital transformation (DX), and the management of organizational processes.</p>
          <div className="grid grid-cols-1 gap-3 mt-6">
            <button onClick={() => setCurrentPage('course-itc1080')} className="flex items-center justify-between p-4 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors text-left">
              <span className="font-bold text-blue-900">ITC1080: Data-Driven Organization</span>
              <ChevronRight className="w-5 h-5 text-gray-400"/>
            </button>
            <button onClick={() => setCurrentPage('course-itc2080')} className="flex items-center justify-between p-4 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors text-left">
              <span className="font-bold text-blue-900">ITC2080: Management for Digital Transformation</span>
              <ChevronRight className="w-5 h-5 text-gray-400"/>
            </button>
            <button onClick={() => setCurrentPage('course-itc2020')} className="flex items-center justify-between p-4 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors text-left">
              <span className="font-bold text-blue-900">ITC2020: Big Data Analytics</span>
              <ChevronRight className="w-5 h-5 text-gray-400"/>
            </button>
            <button onClick={() => setCurrentPage('course-opr1010')} className="flex items-center justify-between p-4 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors text-left">
              <span className="font-bold text-blue-900">OPR1010: Operations Management</span>
              <ChevronRight className="w-5 h-5 text-gray-400"/>
            </button>
          </div>
        </div>
      )
    },
    'subcategory-general-management': {
      title: 'General Management Specialization',
      category: 'Courses',
      subcategory: 'General Management',
      icon: <BookOpen className="w-5 h-5" />,
      isLandingPage: true,
      parentPage: 'category-courses',
      lastUpdated: 'Winter 2026',
      content: (
        <div className="space-y-4 text-gray-800">
          <p>Core management topics covering international strategy, entrepreneurship, and organizational control.</p>
          <div className="grid grid-cols-1 gap-3 mt-6">
            <button onClick={() => setCurrentPage('course-mgt1130')} className="flex items-center justify-between p-4 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors text-left">
              <span className="font-bold text-emerald-900">MGT1130: International Management</span>
              <ChevronRight className="w-5 h-5 text-gray-400"/>
            </button>
            <button onClick={() => setCurrentPage('course-mgt1140')} className="flex items-center justify-between p-4 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors text-left">
              <span className="font-bold text-emerald-900">MGT1140: Business Decision-Making and Control</span>
              <ChevronRight className="w-5 h-5 text-gray-400"/>
            </button>
            <button onClick={() => setCurrentPage('course-mgt2120')} className="flex items-center justify-between p-4 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors text-left">
              <span className="font-bold text-emerald-900">MGT2120: Entrepreneurship & Small Business Dev.</span>
              <ChevronRight className="w-5 h-5 text-gray-400"/>
            </button>
          </div>
        </div>
      )
    },
    'category-residential-life': {
      title: 'Residential Life Hub',
      category: 'Residential Life',
      icon: <Home className="w-5 h-5" />,
      isLandingPage: true,
      parentPage: 'wiki-home',
      lastUpdated: 'Today',
      content: (
        <div className="space-y-4 text-gray-800">
          <p>Everything you need to know about living on campus, maintaining dorm rules, and surviving the Niigata climate.</p>
          <div className="grid grid-cols-1 gap-3 mt-4">
            <button onClick={() => setCurrentPage('winter-survival')} className="flex items-center gap-3 p-4 bg-white border border-gray-200 rounded-xl hover:shadow-md transition-shadow text-left">
               <div className="bg-blue-50 p-2 rounded"><Snowflake className="w-5 h-5 text-blue-600"/></div>
               <span className="font-bold flex-1">Winter Survival Guide</span>
            </button>
            <button onClick={() => setCurrentPage('trash-mastery')} className="flex items-center gap-3 p-4 bg-white border border-gray-200 rounded-xl hover:shadow-md transition-shadow text-left">
               <div className="bg-emerald-50 p-2 rounded"><Trash2 className="w-5 h-5 text-emerald-600"/></div>
               <span className="font-bold flex-1">Trash Separation Mastery</span>
            </button>
            <button onClick={() => setCurrentPage('urasa-station')} className="flex items-center gap-3 p-4 bg-white border border-gray-200 rounded-xl hover:shadow-md transition-shadow text-left">
               <div className="bg-indigo-50 p-2 rounded"><MapPin className="w-5 h-5 text-indigo-600"/></div>
               <span className="font-bold flex-1">Urasa Station Transit Guide</span>
            </button>
          </div>
        </div>
      )
    },
    'category-academics': {
      title: 'Academics Hub',
      category: 'Academics',
      icon: <Book className="w-5 h-5" />,
      isLandingPage: true,
      parentPage: 'wiki-home',
      lastUpdated: 'Today',
      content: (
        <div className="space-y-4 text-gray-800">
          <p>Guides on academic procedures, calendar synchronization, and cross-registration.</p>
          <div className="grid grid-cols-1 gap-3 mt-4">
            <button onClick={() => setCurrentPage('device-calendar')} className="flex items-center gap-3 p-4 bg-white border border-gray-200 rounded-xl hover:shadow-md transition-shadow text-left">
               <div className="bg-indigo-50 p-2 rounded"><Calendar className="w-5 h-5 text-indigo-600"/></div>
               <span className="font-bold flex-1">Syncing Timetable & Reminders</span>
            </button>
          </div>
        </div>
      )
    },
    'category-gso': {
      title: 'GSO Hub',
      category: 'GSO',
      icon: <User className="w-5 h-5" />,
      isLandingPage: true,
      parentPage: 'wiki-home',
      lastUpdated: 'Today',
      content: (
        <div className="space-y-4 text-gray-800 text-center py-8">
          <User className="w-12 h-12 text-gray-300 mx-auto mb-2" />
          <p>GSO Guidelines, Event Planning, and Budget Processes will be published here.</p>
        </div>
      )
    },
    'category-administration': {
      title: 'Administration Hub',
      category: 'Administration',
      icon: <ShieldAlert className="w-5 h-5" />,
      isLandingPage: true,
      parentPage: 'wiki-home',
      lastUpdated: 'Today',
      content: (
        <div className="space-y-4 text-gray-800 text-center py-8">
          <ShieldAlert className="w-12 h-12 text-gray-300 mx-auto mb-2" />
          <p>Official Visa Procedures, Emergency Contacts, and IT Helpdesk FAQs will be published here.</p>
        </div>
      )
    },

    // --- ARTICLES & SYLLABI ---
    'winter-survival': {
      title: 'Winter Survival Guide',
      category: 'Residential Life',
      icon: <Snowflake className="w-5 h-5" />,
      parentPage: 'category-residential-life',
      lastUpdated: 'Oct 24, 2025',
      content: (
        <div className="space-y-4 text-gray-800">
          <p>Minamiuonuma is located in "Snow Country" (Yukiguni). Winters here are exceptionally beautiful but require serious preparation. Snow can exceed 2-3 meters at its peak.</p>

          <h3 className="text-xl font-semibold mt-6 border-b pb-2">1. Essential Clothing</h3>
          <ul className="list-disc pl-5 space-y-2">
            <li><strong>Snow Boots:</strong> Do not rely on regular sneakers. Buy tall, waterproof snow boots with deep treads. You can purchase these at the local Aeon or online.</li>
            <li><strong>Layering:</strong> Heattech (from Uniqlo) is highly recommended. Always wear a thermal base layer.</li>
            <li><strong>Outerwear:</strong> A waterproof, windproof jacket is mandatory.</li>
          </ul>

          <h3 className="text-xl font-semibold mt-6 border-b pb-2">2. Dorm Heating & Utilities</h3>
          <p>Your room's AC unit functions as a heater. To save on electricity while keeping pipes from freezing, use the timer function to turn on the heat 30 minutes before you wake up and 30 minutes before you return from classes.</p>

          <div className="bg-yellow-50 border-l-4 border-yellow-400 p-4 mt-4">
            <p className="text-sm text-yellow-800 font-semibold">⚠️ Emergency Tip: Keep a physical shovel in your room or car. You may need to dig your way out of the parking lot after heavy overnight snowfall!</p>
          </div>
        </div>
      )
    },
    'trash-mastery': {
      title: 'Trash Separation Mastery',
      category: 'Residential Life',
      icon: <Trash2 className="w-5 h-5" />,
      parentPage: 'category-residential-life',
      lastUpdated: 'Sep 10, 2025',
      content: (
        <div className="space-y-4 text-gray-800">
          <p>Japan has strict garbage sorting rules, and Minamiuonuma is no exception. Proper separation in the dormitories (like SD1) is mandatory.</p>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mt-4">
            <div className="border border-red-200 rounded-lg p-4 bg-red-50">
              <h4 className="font-bold text-red-700 mb-2">Burnable (Moeru Gomi)</h4>
              <p className="text-sm">Use the designated RED local bags. Includes food waste, paper that can't be recycled, and small plastics.</p>
            </div>
            <div className="border border-blue-200 rounded-lg p-4 bg-blue-50">
              <h4 className="font-bold text-blue-700 mb-2">Non-Burnable (Moenai Gomi)</h4>
              <p className="text-sm">Use the designated BLUE local bags. Includes ceramics, glass, metals, and hard plastics.</p>
            </div>
          </div>

          <h3 className="text-xl font-semibold mt-6 border-b pb-2">PET Bottles & Cans</h3>
          <p>Caps and labels must be removed from PET bottles. Rinse all cans and bottles before placing them in the designated dorm bins.</p>
        </div>
      )
    },
    'urasa-station': {
      title: 'Urasa Station Transit Guide',
      category: 'Residential Life',
      icon: <MapPin className="w-5 h-5" />,
      parentPage: 'category-residential-life',
      lastUpdated: 'Nov 01, 2025',
      content: (
        <div className="space-y-4 text-gray-800">
          <p>Urasa Station is our primary gateway to Tokyo (via the Joetsu Shinkansen) and neighboring towns.</p>

          <h3 className="text-xl font-semibold mt-6 border-b pb-2">Shuttle Bus Schedule</h3>
          <p>The IUJ shuttle runs daily between campus and Urasa Station. The ride takes approximately 10-15 minutes.</p>
          <ul className="list-disc pl-5 space-y-2 mt-2">
            <li><strong>Morning Peak:</strong> 07:30, 08:15, 08:50</li>
            <li><strong>Afternoon:</strong> 12:30, 14:00, 16:30</li>
            <li><strong>Evening:</strong> 18:15, 20:00 (Last bus)</li>
          </ul>
          <p className="text-sm text-gray-500 italic mt-2">* Schedules are subject to change during holidays and heavy snow days.</p>
        </div>
      )
    },
    'device-calendar': {
      title: 'Syncing Timetable & Reminders',
      category: 'Academics',
      icon: <Calendar className="w-5 h-5" />,
      parentPage: 'category-academics',
      lastUpdated: 'Just Now',
      content: (
        <div className="space-y-4 text-gray-800">
          <p>Missing classes or assignment deadlines is easy if your schedule isn't synced directly to your personal device. This guide covers the official MyIUJ! sync method.</p>

          <h3 className="text-xl font-semibold mt-6 border-b pb-2">Device Calendar Integration</h3>
          <p>For all students, we highly recommend integrating your IUJ schedule directly into your native <strong>Device Calendar</strong> (Apple Calendar, Google Calendar, etc.) for the most reliable notifications.</p>

          <div className="bg-indigo-50 border border-indigo-200 p-4 rounded-xl my-4">
            <h4 className="font-bold text-indigo-800 flex items-center gap-2 mb-2">
              <CheckCircle className="w-5 h-5" /> The "10-30-60" Rule
            </h4>
            <p className="text-sm text-indigo-900">
              When syncing via the MyIUJ! app to your device, the system is programmed to automatically generate three cascading reminders for every class or exam:
            </p>
            <ul className="list-disc pl-5 mt-2 text-sm text-indigo-900 font-medium">
              <li>1 Hour before (Get ready / Review notes)</li>
              <li>30 Minutes before (Leave dorm / Walk to main building)</li>
              <li>10 Minutes before (Find your seat)</li>
            </ul>
          </div>

          <h3 className="text-xl font-semibold mt-6 border-b pb-2">How it Works</h3>
          <p>Because MyIUJ! uses your Google Workspace SSO, your timetable is <strong>automatically synced</strong> to your device's primary calendar. No manual setup is required.</p>
          <p className="mt-2">Just ensure you are logged into your device with your IUJ Google account, and the 10m/30m/1h alerts will be applied automatically to all classes!</p>
        </div>
      )
    },
    'course-fin2090': {
      title: 'FIN2090: Behavioral Finance',
      category: 'Courses',
      subcategory: 'Finance',
      icon: <BookOpen className="w-5 h-5" />,
      parentPage: 'subcategory-finance',
      lastUpdated: 'Winter 2026',
      content: (
        <div className="space-y-6 text-gray-800">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Instructor</p>
              <p className="font-semibold text-indigo-900">Yanghua Shi</p>
            </div>
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Schedule</p>
              <p className="font-semibold text-indigo-900">Fri 10:30-12:00, 13:00-14:30</p>
            </div>
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Credits</p>
              <p className="font-semibold text-indigo-900">2 Credits</p>
            </div>
          </div>
          <h3 className="text-xl font-semibold border-b border-gray-200 pb-2">Course Description</h3>
          <p>This course will give you an overview of how psychological biases and cognitive limitations shape financial decisions, market behavior, and investment outcomes, with a focus on real-world applications in business and finance.</p>
          <h3 className="text-xl font-semibold border-b border-gray-200 pb-2 mt-6">Learning Objectives</h3>
          <p>In today's complex financial landscape, understanding how people actually make decisions is critical for designing effective business strategies and financial products. The objective is to provide an overview of key concepts in behavioral finance, including how cognitive biases, emotions, and social influences affect financial decision-making.</p>
        </div>
      )
    },
    'course-fin2080': {
      title: 'FIN2080: Sustainable Finance & Investment',
      category: 'Courses',
      subcategory: 'Finance',
      icon: <BookOpen className="w-5 h-5" />,
      parentPage: 'subcategory-finance',
      lastUpdated: 'Winter 2026',
      content: (
        <div className="space-y-6 text-gray-800">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Instructor</p>
              <p className="font-semibold text-indigo-900">Chow, Yuen Leng</p>
            </div>
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Schedule</p>
              <p className="font-semibold text-indigo-900">Tue 2nd & 3rd Period</p>
            </div>
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Credits</p>
              <p className="font-semibold text-indigo-900">2 Credits</p>
            </div>
          </div>
          <h3 className="text-xl font-semibold border-b border-gray-200 pb-2">Course Description</h3>
          <p>Students will be given an overview of the financial markets and the new investment trends of sustainable finance. This course focuses on three core components: environment, social, and governance (ESG).</p>
          <h3 className="text-xl font-semibold border-b border-gray-200 pb-2 mt-6">Learning Objectives</h3>
          <p>This course aims to provide students with an understanding of the linkages between global capital markets and funding environment, social and governance (ESG) related projects. Sustainable finance plays a key role in mobilizing capital towards a greener agenda.</p>
        </div>
      )
    },
    'course-fin3020': {
      title: 'FIN3020: Finance and Technology',
      category: 'Courses',
      subcategory: 'Finance',
      icon: <BookOpen className="w-5 h-5" />,
      parentPage: 'subcategory-finance',
      lastUpdated: 'Winter 2026',
      content: (
        <div className="space-y-6 text-gray-800">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Instructor</p>
              <p className="font-semibold text-indigo-900">Chow, Yuen Leng</p>
            </div>
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Schedule</p>
              <p className="font-semibold text-indigo-900">Mon 2nd & 3rd Period</p>
            </div>
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Credits</p>
              <p className="font-semibold text-indigo-900">2 Credits</p>
            </div>
          </div>
          <h3 className="text-xl font-semibold border-b border-gray-200 pb-2">Course Description</h3>
          <p>In this course, you will be given an overview of finance and technology (fintech). What is fintech, when did it originate, what are the major trends going forward. The course will also provide an introduction to digital currencies and blockchain.</p>
          <h3 className="text-xl font-semibold border-b border-gray-200 pb-2 mt-6">Career Relevance</h3>
          <p>Fintech is increasingly changing the way for payments and investing. You will gain an understanding of the complex structure of payment methods and financial regulations, and employ strategies in developing a fintech strategy for your business.</p>
        </div>
      )
    },
    'course-itc1080': {
      title: 'ITC1080: Data-Driven Organization',
      category: 'Courses',
      subcategory: 'IT & Operations',
      icon: <BookOpen className="w-5 h-5" />,
      parentPage: 'subcategory-it-operations',
      lastUpdated: 'Winter 2026',
      content: (
        <div className="space-y-6 text-gray-800">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Instructor</p>
              <p className="font-semibold text-indigo-900">Zaw Zaw Aung</p>
            </div>
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Schedule</p>
              <p className="font-semibold text-indigo-900">Monday 4th & 5th Period</p>
            </div>
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Credits</p>
              <p className="font-semibold text-indigo-900">2 Credits</p>
            </div>
          </div>
          <h3 className="text-xl font-semibold border-b border-gray-200 pb-2">Course Description</h3>
          <p>Companies are embracing Digital Transformation (DX) as their main agenda. Yet being more "digital" or collecting more data won't get the companies very far if there aren't methods and tools to better the management process. This course teaches how to adapt operating models and organization strategy.</p>
          <h3 className="text-xl font-semibold border-b border-gray-200 pb-2 mt-6">Core Topics</h3>
          <ul className="list-disc pl-5 space-y-1">
            <li>Creating Data-Driven Organization Culture</li>
            <li>Alignment of Data Strategy with Business Strategy</li>
            <li>Data Engineering, Self-service Data Platform and Data Mesh</li>
            <li>Data Quality, Data Literacy, Data Governance</li>
          </ul>
        </div>
      )
    },
    'course-itc2080': {
      title: 'ITC2080: Management for Digital Transformation',
      category: 'Courses',
      subcategory: 'IT & Operations',
      icon: <BookOpen className="w-5 h-5" />,
      parentPage: 'subcategory-it-operations',
      lastUpdated: 'Winter 2026',
      content: (
        <div className="space-y-6 text-gray-800">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Instructor</p>
              <p className="font-semibold text-indigo-900">Sakurai, Mihoko</p>
            </div>
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Schedule</p>
              <p className="font-semibold text-indigo-900">Wed 14:40-16:10, 16:20-17:50</p>
            </div>
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Credits</p>
              <p className="font-semibold text-indigo-900">2 Credits</p>
            </div>
          </div>
          <h3 className="text-xl font-semibold border-b border-gray-200 pb-2">Course Description</h3>
          <p>This course provides essential frameworks and associated keywords that help to understand digital transformation (DX). The course aims to investigate three core topics: DX process, DX structure, and DX culture within an organization.</p>
          <p className="mt-2">Discussions around these themes are based on the notion of "sociotechnical system" which regards a work system as correlative interacting systems of the social system and the technical system.</p>
        </div>
      )
    },
    'course-mgt1130': {
      title: 'MGT1130: International Management',
      category: 'Courses',
      subcategory: 'General Management',
      icon: <BookOpen className="w-5 h-5" />,
      parentPage: 'subcategory-general-management',
      lastUpdated: 'Winter 2026',
      content: (
        <div className="space-y-6 text-gray-800">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Instructor</p>
              <p className="font-semibold text-indigo-900">Yingying Zhang Zhang</p>
            </div>
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Schedule</p>
              <p className="font-semibold text-indigo-900">Wed Per 4-5 OR Thu Per 2-3</p>
            </div>
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Credits</p>
              <p className="font-semibold text-indigo-900">2 Credits</p>
            </div>
          </div>
          <h3 className="text-xl font-semibold border-b border-gray-200 pb-2">Course Description</h3>
          <p>This course of international management is designed to equip students with essential knowledge and skills for effective management within the global business landscape. As our world continues to evolve into a highly interconnected arena, the ability to navigate international contexts has become imperative.</p>
          <h3 className="text-xl font-semibold border-b border-gray-200 pb-2 mt-6">Course Content</h3>
          <ul className="list-disc pl-5 space-y-1">
            <li>Foundations of Global Business</li>
            <li>Analytical Tools for Internationalization</li>
            <li>Navigating International Competitive Environments</li>
            <li>Global Strategic Management</li>
          </ul>
        </div>
      )
    },
    'course-mgt1140': {
      title: 'MGT1140: Business Decision-Making and Control',
      category: 'Courses',
      subcategory: 'General Management',
      icon: <BookOpen className="w-5 h-5" />,
      parentPage: 'subcategory-general-management',
      lastUpdated: 'Winter 2026',
      content: (
        <div className="space-y-6 text-gray-800">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Instructor</p>
              <p className="font-semibold text-indigo-900">Lee, Hyunkoo</p>
            </div>
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Schedule</p>
              <p className="font-semibold text-indigo-900">Wed 10:30 AM & 1:00 PM</p>
            </div>
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Credits</p>
              <p className="font-semibold text-indigo-900">2 Credits</p>
            </div>
          </div>
          <h3 className="text-xl font-semibold border-b border-gray-200 pb-2">Course Description</h3>
          <p>This course introduces students to the evolving role of managerial accounting in modern business environments. The course highlights the informational needs of managers in planning, controlling, and decision making, and shows how to take advantage of accounting data in various situations.</p>
          <p className="mt-2">Topics include cost estimation, cost analysis, activity-based costing, cost-volume-profits analysis, budgets and standards, responsibility accounting, and transfer pricing.</p>
        </div>
      )
    },
    'course-mgt2120': {
      title: 'MGT2120: Entrepreneurship & Small Business Dev.',
      category: 'Courses',
      subcategory: 'General Management',
      icon: <BookOpen className="w-5 h-5" />,
      parentPage: 'subcategory-general-management',
      lastUpdated: 'Winter 2026',
      content: (
        <div className="space-y-6 text-gray-800">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Instructor</p>
              <p className="font-semibold text-indigo-900">Remy Magnier-Watanabe</p>
            </div>
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Schedule</p>
              <p className="font-semibold text-indigo-900">Thu 14:40 - 17:50</p>
            </div>
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Credits</p>
              <p className="font-semibold text-indigo-900">2 Credits</p>
            </div>
          </div>
          <h3 className="text-xl font-semibold border-b border-gray-200 pb-2">Course Description</h3>
          <p>This course is particularly useful for students who are interested in starting their own business and want to learn different aspects of business management. This course is also suited to those involved in corporate entrepreneurship or in improving competitive positioning.</p>
          <h3 className="text-xl font-semibold border-b border-gray-200 pb-2 mt-6">Learning Objectives</h3>
          <p>Evaluate qualities of the successful entrepreneurial profile; determine the steps necessary to open and operate a small business enterprise; identify marketing and financial competencies; and ultimately develop and present a Business Plan.</p>
        </div>
      )
    },
    'course-opr1010': {
      title: 'OPR1010: Operations Management',
      category: 'Courses',
      subcategory: 'IT & Operations',
      icon: <BookOpen className="w-5 h-5" />,
      parentPage: 'subcategory-it-operations',
      lastUpdated: 'Winter 2026',
      content: (
        <div className="space-y-6 text-gray-800">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Instructor</p>
              <p className="font-semibold text-indigo-900">Wenkai Li</p>
            </div>
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Schedule</p>
              <p className="font-semibold text-indigo-900">Mon/Tue 14:40 - 17:50</p>
            </div>
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Credits</p>
              <p className="font-semibold text-indigo-900">2 Credits</p>
            </div>
          </div>
          <h3 className="text-xl font-semibold border-b border-gray-200 pb-2">Course Description</h3>
          <p>Operations is one of three basic functions/pillars in any business organization. Operations Management (OM) is the management of systems or processes that create goods and/or provide services, within an organization. Operations is the engine for a company that creates values in a firm's value chain.</p>
          <p className="mt-2">Students will familiarize with basic knowledge of production and processes, including a strategic view of operations management, process thinking, lean thinking, quality management, and inventory management. Japanese way of operations will also be introduced.</p>
        </div>
      )
    },
    'course-itc2020': {
      title: 'ITC2020: Big Data Analytics',
      category: 'Courses',
      subcategory: 'IT & Operations',
      icon: <BookOpen className="w-5 h-5" />,
      parentPage: 'subcategory-it-operations',
      lastUpdated: 'Winter 2026',
      content: (
        <div className="space-y-6 text-gray-800">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Instructor</p>
              <p className="font-semibold text-indigo-900">Zaw Zaw Aung</p>
            </div>
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Schedule</p>
              <p className="font-semibold text-indigo-900">Fri 2nd & 3rd Period</p>
            </div>
            <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-xl">
              <p className="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Credits</p>
              <p className="font-semibold text-indigo-900">2 Credits</p>
            </div>
          </div>
          <h3 className="text-xl font-semibold border-b border-gray-200 pb-2">Course Description</h3>
          <p>This course is for those new to data science and interested in understanding why the Big Data Era has come to be. This course introduces you data-analytic thinking. You will be able to describe the reasons behind the evolving plethora of new big data platforms from the perspective of big data management systems.</p>
          <h3 className="text-xl font-semibold border-b border-gray-200 pb-2 mt-6">Learning Objectives</h3>
          <p>Recognize different data elements in your own work, explain why your team needs to design a Big Data Infrastructure Plan, select a data model, retrieve data, process patterns, and design an approach leveraging machine learning processes.</p>
        </div>
      )
    }
  }), []);

  useEffect(() => {
    if (!['home', 'calendar', 'student-id', 'booking', 'facilities', 'library', 'directory'].includes(currentPage)) {
      setIsWikiExpanded(true);

      // Auto-expand the specific level-2 category if a page is selected via search
      const activePage = WIKI_PAGES[currentPage];
      if (activePage && activePage.category) {
        setExpandedCategories(prev =>
          prev.includes(activePage.category) ? prev : [...prev, activePage.category]
        );
      }
      if (activePage && activePage.subcategory) {
        setExpandedSubcategories(prev =>
          prev.includes(activePage.subcategory) ? prev : [...prev, activePage.subcategory]
        );
      }
    }
  }, [currentPage, WIKI_PAGES]);

  const toggleCategory = (categoryName) => {
    setExpandedCategories(prev =>
      prev.includes(categoryName)
        ? prev.filter(c => c !== categoryName)
        : [...prev, categoryName]
    );
  };

  const toggleSubcategory = (subName) => {
    setExpandedSubcategories(prev =>
      prev.includes(subName)
        ? prev.filter(c => c !== subName)
        : [...prev, subName]
    );
  };

  const searchResults = useMemo(() => {
    if (!searchQuery) return null;
    return Object.entries(WIKI_PAGES).filter(([key, page]) =>
      !page.isLandingPage && (
        page.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
        page.category.toLowerCase().includes(searchQuery.toLowerCase())
      )
    );
  }, [searchQuery, WIKI_PAGES]);

  const activePageData = WIKI_PAGES[currentPage] || {};

  const handleEditSubmit = (e) => {
    e.preventDefault();
    setEditRequestSent(true);
    setTimeout(() => {
      setIsEditModalOpen(false);
      setIsCreateTopicModalOpen(false);
      setEditRequestSent(false);
    }, 2000);
  };

  const showToast = (msg) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 4000);
  };

  const copyToClipboard = (text) => {
    navigator.clipboard.writeText(text);
    showToast("Meeting link copied to clipboard!");
  };

  const filteredEvents = useMemo(() => {
    let dayEvents = calendarEvents.filter(e => e.date === selectedDate);
    if (calendarFilter !== 'all') {
      dayEvents = dayEvents.filter(e => e.type === calendarFilter);
    }
    return dayEvents.sort((a, b) => a.time.localeCompare(b.time));
  }, [calendarFilter, selectedDate, calendarEvents]);

  const togglePollSlot = (slotId) => {
    if (selectedPollSlots.includes(slotId)) {
      setSelectedPollSlots(selectedPollSlots.filter(id => id !== slotId));
    } else {
      setSelectedPollSlots([...selectedPollSlots, slotId]);
    }
  };

  const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

  const nextMonth = () => {
    setCurrentViewDate(new Date(currentViewDate.getFullYear(), currentViewDate.getMonth() + 1, 1));
  };

  const prevMonth = () => {
    setCurrentViewDate(new Date(currentViewDate.getFullYear(), currentViewDate.getMonth() - 1, 1));
  };

  const goToToday = () => {
    setCurrentViewDate(new Date(2026, 3, 1));
    setSelectedDate(1);
    setCalendarView('month');
  };

  const daysInMonth = new Date(currentViewDate.getFullYear(), currentViewDate.getMonth() + 1, 0).getDate();
  let firstDay = new Date(currentViewDate.getFullYear(), currentViewDate.getMonth(), 1).getDay();
  firstDay = firstDay === 0 ? 6 : firstDay - 1; // Make Monday = 0
  const isMockMonth = currentViewDate.getMonth() === 3 && currentViewDate.getFullYear() === 2026;

  const MOCK_POLL_DATES = [
    {
      date: 'Thursday, April 2',
      slots: [
        { id: 'thu-1', time: '09:00 AM', status: 'busy', label: 'Ethics Class' },
        { id: 'thu-2', time: '11:00 AM', status: 'free' },
        { id: 'thu-3', time: '13:15 PM', status: 'busy', label: 'Startup Class' },
        { id: 'thu-4', time: '15:00 PM', status: 'free' }
      ]
    },
    {
      date: 'Friday, April 3',
      slots: [
        { id: 'fri-1', time: '10:00 AM', status: 'free' },
        { id: 'fri-2', time: '12:00 PM', status: 'free' },
        { id: 'fri-3', time: '14:00 PM', status: 'busy', label: 'Finance Assignment' },
        { id: 'fri-4', time: '16:00 PM', status: 'free' }
      ]
    }
  ];

  return (
    <div className="min-h-screen bg-gray-50 font-sans flex flex-col md:flex-row">

      {/* --- SIDEBAR NAVIGATION --- */}
      {isSidebarOpen && (
        <div
          className="fixed inset-0 bg-black/50 z-40 md:hidden"
          onClick={() => setIsSidebarOpen(false)}
        />
      )}
      <aside className={`
        fixed md:sticky top-0 left-0 h-screen bg-white z-50
        transition-all duration-300 ease-in-out shrink-0 overflow-hidden
        ${isSidebarOpen ? 'translate-x-0 shadow-2xl md:shadow-none' : '-translate-x-full'}
        ${isDesktopSidebarCollapsed ? 'md:w-0 md:-translate-x-full md:border-r-0' : 'md:w-64 md:translate-x-0 border-r border-gray-200'}
        w-64
      `}>
        <div className="w-64 h-full flex flex-col">
          <div className="p-4 border-b border-gray-100 flex items-center justify-between">
            <div className="flex items-center gap-2 text-indigo-700 font-bold text-xl tracking-tight">
              <Book className="w-6 h-6" />
              MyIUJ!
            </div>
            <button onClick={() => setIsSidebarOpen(false)} className="md:hidden text-gray-500">
              <X className="w-5 h-5" />
            </button>
          </div>

          <div className="flex-1 overflow-y-auto py-4">
            <div className="px-4 mb-2 text-xs font-semibold text-gray-400 uppercase tracking-wider">Main</div>

            <button
              onClick={() => { setCurrentPage('home'); setIsSidebarOpen(false); }}
              className={`w-full text-left px-4 py-2 flex items-center gap-3 text-sm font-medium transition-colors
                ${currentPage === 'home' ? 'bg-indigo-50 text-indigo-700 border-r-4 border-indigo-600' : 'text-gray-600 hover:bg-gray-50'}`}
            >
              <LayoutDashboard className="w-4 h-4" /> Dashboard
            </button>

            <button
              onClick={() => { setCurrentPage('calendar'); setIsSidebarOpen(false); }}
              className={`w-full text-left px-4 py-2 flex items-center gap-3 text-sm font-medium transition-colors
                ${currentPage === 'calendar' ? 'bg-indigo-50 text-indigo-700 border-r-4 border-indigo-600' : 'text-gray-600 hover:bg-gray-50'}`}
            >
              <CalendarDays className="w-4 h-4" /> Calendar
            </button>

            <button
              onClick={() => { setCurrentPage('facilities'); setIsSidebarOpen(false); }}
              className={`w-full text-left px-4 py-2 flex items-center gap-3 text-sm font-medium transition-colors
                ${['facilities', 'booking', 'library', 'directory'].includes(currentPage) ? 'bg-indigo-50 text-indigo-700 border-r-4 border-indigo-600' : 'text-gray-600 hover:bg-gray-50'}`}
            >
              <Building className="w-4 h-4" /> Facilities
            </button>

            <button
              onClick={() => {
                setCurrentPage('wiki-home');
                setIsWikiExpanded(true);
                setIsSidebarOpen(false);
              }}
              className={`w-full text-left px-4 py-2 flex items-center justify-between text-sm font-medium transition-colors mt-2
                ${(!['home', 'calendar', 'student-id', 'booking', 'facilities', 'library', 'directory'].includes(currentPage)) ? 'bg-indigo-50 text-indigo-700 border-r-4 border-indigo-600' : 'text-gray-600 hover:bg-gray-50'}`}
            >
              <div className="flex items-center gap-3">
                <Library className="w-4 h-4" /> Wiki
              </div>
              <ChevronRight
                onClick={(e) => {
                  e.stopPropagation(); // prevent navigating if just clicking the arrow
                  setIsWikiExpanded(!isWikiExpanded);
                }}
                className={`w-4 h-4 transition-transform duration-200 hover:bg-indigo-100 rounded ${isWikiExpanded ? 'rotate-90' : ''}`}
              />
            </button>

            <div className={`overflow-hidden transition-all duration-300 ease-in-out origin-top ${isWikiExpanded ? 'max-h-[2000px] opacity-100 scale-y-100' : 'max-h-0 opacity-0 scale-y-95'}`}>
              <div className="bg-gray-50/50 py-2 border-y border-gray-100 mt-1 pl-2 border-l-2 border-l-indigo-200 ml-4 mr-2 rounded-r-lg">
                {CATEGORIES.map(category => {
                  const isExpanded = expandedCategories.includes(category.name);
                  return (
                  <div key={category.name} className="mt-4 first:mt-2">
                    <button
                      onClick={() => {
                        setCurrentPage(`category-${category.id}`);
                        if (!isExpanded) toggleCategory(category.name);
                        setIsSidebarOpen(false);
                      }}
                      className={`w-full px-4 mb-2 text-xs font-semibold uppercase tracking-wider flex items-center justify-between transition-colors
                        ${currentPage === `category-${category.id}` ? 'text-indigo-700' : 'text-gray-400 hover:text-gray-600'}`}
                    >
                      <div className="flex items-center gap-2">
                        {category.icon} {category.name}
                      </div>
                      <ChevronRight
                        onClick={(e) => {
                          e.stopPropagation();
                          toggleCategory(category.name);
                        }}
                        className={`w-3 h-3 transition-transform duration-200 hover:bg-gray-200 rounded ${isExpanded ? 'rotate-90' : ''}`}
                      />
                    </button>
                    <div className={`overflow-hidden transition-all duration-300 ease-in-out ${isExpanded ? 'max-h-[1000px] opacity-100' : 'max-h-0 opacity-0'}`}>
                      {category.subcategories ? (
                        <div className="pl-2 mt-1 space-y-2">
                          {category.subcategories.map(sub => {
                            const isSubExpanded = expandedSubcategories.includes(sub.name);
                            return (
                              <div key={sub.id}>
                                <button
                                  onClick={() => {
                                    setCurrentPage(`subcategory-${sub.id}`);
                                    if (!isSubExpanded) toggleSubcategory(sub.name);
                                    setIsSidebarOpen(false);
                                  }}
                                  className={`w-full px-4 mb-1 text-[11px] font-bold uppercase tracking-wider flex items-center justify-between transition-colors
                                    ${currentPage === `subcategory-${sub.id}` ? 'text-indigo-600' : 'text-indigo-400/80 hover:text-indigo-600'}`}
                                >
                                  {sub.name}
                                  <ChevronRight
                                    onClick={(e) => {
                                      e.stopPropagation();
                                      toggleSubcategory(sub.name);
                                    }}
                                    className={`w-3 h-3 transition-transform duration-200 hover:bg-indigo-100 rounded ${isSubExpanded ? 'rotate-90' : ''}`}
                                  />
                                </button>
                                <ul className={`space-y-1 overflow-hidden transition-all duration-300 ${isSubExpanded ? 'max-h-[500px] opacity-100' : 'max-h-0 opacity-0'}`}>
                                  {Object.entries(WIKI_PAGES)
                                    .filter(([_, page]) => page.category === category.name && page.subcategory === sub.name && !page.isLandingPage)
                                    .map(([key, page]) => (
                                      <li key={key}>
                                        <button
                                          onClick={() => { setCurrentPage(key); setIsSidebarOpen(false); }}
                                          className={`w-full text-left px-4 py-2 pl-8 text-sm transition-colors
                                            ${currentPage === key ? 'bg-indigo-50 text-indigo-700 font-semibold border-r-4 border-indigo-600' : 'text-gray-600 hover:bg-gray-50'}`}
                                        >
                                          {page.title}
                                        </button>
                                      </li>
                                    ))}
                                </ul>
                              </div>
                            );
                          })}
                        </div>
                      ) : (
                        <ul className="space-y-1">
                          {Object.entries(WIKI_PAGES)
                            .filter(([_, page]) => page.category === category.name && !page.isLandingPage)
                            .map(([key, page]) => (
                              <li key={key}>
                                <button
                                  onClick={() => { setCurrentPage(key); setIsSidebarOpen(false); }}
                                  className={`w-full text-left px-4 py-2 pl-10 text-sm transition-colors
                                    ${currentPage === key ? 'bg-indigo-50 text-indigo-700 font-semibold border-r-4 border-indigo-600' : 'text-gray-600 hover:bg-gray-50'}`}
                                >
                                  {page.title}
                                </button>
                              </li>
                            ))}
                        </ul>
                      )}
                    </div>
                  </div>
                )})}
              </div>
            </div>
          </div>

          <button
            onClick={() => { setCurrentPage('student-id'); setIsSidebarOpen(false); }}
            className={`w-full text-left p-4 border-t border-gray-100 flex items-center justify-between transition-all group
              ${currentPage === 'student-id' ? 'bg-indigo-50 border-l-4 border-l-indigo-600' : 'bg-gray-50 hover:bg-gray-100 border-l-4 border-l-transparent'}`}
          >
            <div className="flex items-center gap-3">
              <div className={`w-8 h-8 rounded-full flex items-center justify-center font-bold transition-colors
                ${currentPage === 'student-id' ? 'bg-indigo-200 text-indigo-800' : 'bg-indigo-100 text-indigo-700 group-hover:bg-indigo-200'}`}>
                AT
              </div>
              <div>
                <p className={`text-sm font-semibold ${currentPage === 'student-id' ? 'text-indigo-900' : 'text-gray-800'}`}>
                  Apoorv Terwadkar
                </p>
                <p className="text-xs text-gray-500">Digital ID & Vaults</p>
              </div>
            </div>
            <CreditCard className={`w-5 h-5 transition-transform ${currentPage === 'student-id' ? 'text-indigo-600' : 'text-gray-400 group-hover:scale-110 group-hover:text-indigo-500'}`} />
          </button>
        </div>
      </aside>

      {/* --- MAIN CONTENT AREA --- */}
      <main className="flex-1 flex flex-col min-w-0 h-screen overflow-hidden">

        {/* HEADER & SEARCH */}
        <header className="bg-white border-b border-gray-200 px-4 py-3 sticky top-0 z-30 flex items-center gap-4">
          <button
            onClick={() => {
              setIsSidebarOpen(true);
              setIsDesktopSidebarCollapsed(!isDesktopSidebarCollapsed);
            }}
            className="text-gray-600 hover:bg-gray-100 p-2 rounded-lg transition-colors"
          >
            <Menu className="w-6 h-6" />
          </button>

          <div className="flex-1 max-w-2xl relative">
            <div className="relative">
              <Search className="w-5 h-5 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
              <input
                type="text"
                placeholder="Search Wiki, Courses, Library..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full bg-gray-100 border-transparent focus:bg-white focus:border-indigo-500 focus:ring-2 focus:ring-indigo-200 rounded-full py-2 pl-10 pr-4 text-sm transition-all shadow-inner"
              />
            </div>

            {/* Mock Search Results Dropdown */}
            {searchResults && searchQuery && (
              <div className="absolute top-full left-0 right-0 mt-2 bg-white rounded-xl shadow-xl border border-gray-100 overflow-hidden z-50 max-h-96 overflow-y-auto">
                {searchResults.length > 0 ? (
                  <ul>
                    {searchResults.map(([key, page]) => (
                      <li key={key}>
                        <button
                          onClick={() => { setCurrentPage(key); setSearchQuery(''); }}
                          className="w-full text-left px-4 py-3 hover:bg-gray-50 border-b border-gray-50 flex items-center gap-3"
                        >
                          <div className="p-2 bg-gray-100 rounded-lg text-gray-500">
                            {page.icon}
                          </div>
                          <div>
                            <p className="font-semibold text-sm text-gray-800">{page.title}</p>
                            <p className="text-xs text-gray-400">{page.category}</p>
                          </div>
                        </button>
                      </li>
                    ))}
                  </ul>
                ) : (
                  <div className="p-4 text-center text-sm text-gray-500">No results found for "{searchQuery}"</div>
                )}
              </div>
            )}
          </div>
        </header>

        {/* PAGE CONTENT */}
        <div className="flex-1 overflow-y-auto p-4 md:p-8 bg-gray-50/50 relative">

          {/* Toast Notification */}
          {toastMessage && (
            <div className="absolute top-4 right-4 bg-gray-900 text-white px-4 py-3 rounded-lg shadow-xl flex items-center gap-3 z-50 animate-in slide-in-from-top-2">
              <BellRing className="w-5 h-5 text-green-400" />
              <p className="text-sm font-medium">{toastMessage}</p>
              <button onClick={() => setToastMessage(null)}><X className="w-4 h-4 text-gray-400 hover:text-white" /></button>
            </div>
          )}

          {currentPage === 'home' ? (
            <div className="max-w-6xl mx-auto space-y-6 animate-in fade-in duration-300">
              {/* Dashboard Header */}
              <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200 flex flex-col sm:flex-row sm:justify-between sm:items-center gap-4">
                <div>
                  <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-2">
                    <LayoutDashboard className="w-6 h-6 text-indigo-600"/> Dashboard
                  </h1>
                  <p className="text-sm text-gray-500 mt-1">Welcome back, Apoorv. Here is your daily overview.</p>
                </div>
                <button
                  onClick={() => setCurrentPage('calendar')}
                  className="text-left sm:text-right p-3 -m-3 sm:-mr-3 rounded-xl hover:bg-indigo-50 transition-colors cursor-pointer group"
                  title="Open Master Calendar"
                >
                  <p className="text-sm font-bold text-indigo-600 group-hover:text-indigo-800 transition-colors flex items-center sm:justify-end gap-1.5">
                    April 1, 2026 <CalendarDays className="w-4 h-4 opacity-0 group-hover:opacity-100 transition-opacity hidden sm:block" />
                  </p>
                  <p className="text-xs text-gray-500 font-medium">Wednesday</p>
                </button>
              </div>

              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Up Next Widget */}
                <div className="lg:col-span-2 bg-white p-6 rounded-2xl shadow-sm border border-gray-200 flex flex-col">
                  <div className="flex justify-between items-center mb-4">
                    <h2 className="text-lg font-bold text-gray-800 flex items-center gap-2">
                      <CalendarDays className="w-5 h-5 text-indigo-500"/> Up Next
                    </h2>
                    <button onClick={() => setCurrentPage('calendar')} className="text-sm font-semibold text-indigo-600 hover:text-indigo-800">
                      View Calendar &rarr;
                    </button>
                  </div>

                  <div className="bg-indigo-50 border border-indigo-100 p-5 rounded-xl flex flex-col sm:flex-row justify-between sm:items-center gap-4 flex-1 hover:shadow-md transition-shadow cursor-pointer" onClick={() => setCurrentPage('calendar')}>
                    <div>
                      <div className="flex items-center gap-3 mb-2">
                        <span className="bg-indigo-600 text-white text-xs font-bold px-2 py-1 rounded shadow-sm">13:15 PM</span>
                        <span className="text-xs font-semibold text-indigo-800 bg-indigo-100 px-2 py-1 rounded border border-indigo-200 flex items-center gap-1">
                          <BellRing className="w-3 h-3"/> Reminders synced to device
                        </span>
                      </div>
                      <h3 className="text-xl font-bold text-indigo-900 mb-1">Launch your startup</h3>
                      <p className="text-sm font-medium text-indigo-700 flex items-center gap-2">
                        <MapPin className="w-4 h-4"/> Classroom: P.109 <span className="text-indigo-300">|</span> Anne Sophie DE GABRIAC
                      </p>
                    </div>
                    <div className="shrink-0 hidden sm:block">
                      <div className="w-12 h-12 bg-white rounded-full flex items-center justify-center shadow-sm border border-indigo-100">
                        <Clock className="w-6 h-6 text-indigo-400" />
                      </div>
                    </div>
                  </div>
                </div>

                {/* Quick Access */}
                <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
                  <h2 className="text-lg font-bold text-gray-800 mb-4">Quick Access</h2>
                  <div className="space-y-3">
                    <button onClick={() => setCurrentPage('student-id')} className="w-full flex items-center justify-between p-4 rounded-xl border border-gray-100 hover:border-indigo-300 hover:bg-gray-50 transition-all group shadow-sm hover:shadow">
                      <div className="flex items-center gap-3">
                        <div className="p-2 bg-orange-100 rounded-lg group-hover:scale-110 transition-transform">
                          <CreditCard className="w-5 h-5 text-orange-600"/>
                        </div>
                        <div className="text-left">
                          <span className="block font-bold text-gray-800">Digital ID</span>
                          <span className="block text-xs text-gray-500">Access Vaults</span>
                        </div>
                      </div>
                      <ChevronRight className="w-5 h-5 text-gray-300 group-hover:text-indigo-500 group-hover:translate-x-1 transition-all"/>
                    </button>

                    <button onClick={() => setCurrentPage('facilities')} className="w-full flex items-center justify-between p-4 rounded-xl border border-gray-100 hover:border-indigo-300 hover:bg-gray-50 transition-all group shadow-sm hover:shadow">
                      <div className="flex items-center gap-3">
                        <div className="p-2 bg-green-100 rounded-lg group-hover:scale-110 transition-transform">
                          <Building className="w-5 h-5 text-green-600"/>
                        </div>
                        <div className="text-left">
                          <span className="block font-bold text-gray-800">Campus Facilities</span>
                          <span className="block text-xs text-gray-500">Directory & Bookings</span>
                        </div>
                      </div>
                      <ChevronRight className="w-5 h-5 text-gray-300 group-hover:text-indigo-500 group-hover:translate-x-1 transition-all"/>
                    </button>
                  </div>
                </div>
              </div>

              {/* Trending Wiki Items */}
              <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
                <div className="flex justify-between items-center mb-4">
                  <h2 className="text-lg font-bold text-gray-800 flex items-center gap-2">
                    <Library className="w-5 h-5 text-blue-500"/> Trending from Wiki
                  </h2>
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <button onClick={() => setCurrentPage('winter-survival')} className="bg-blue-50 border border-blue-100 p-4 rounded-xl text-left hover:shadow-md transition-shadow group">
                    <h3 className="font-bold text-blue-900 flex items-center gap-2 mb-2">
                      <Snowflake className="w-5 h-5 text-blue-600" /> Winter is Coming
                    </h3>
                    <p className="text-sm text-blue-800 mb-3">Get ready for the Minamiuonuma snow season. Check out the definitive survival guide.</p>
                    <span className="text-sm font-bold text-blue-600 group-hover:text-blue-800 flex items-center gap-1 group-hover:translate-x-1 transition-transform">
                      Read Guide <ChevronRight className="w-4 h-4" />
                    </span>
                  </button>

                  <button onClick={() => setCurrentPage('trash-mastery')} className="bg-emerald-50 border border-emerald-100 p-4 rounded-xl text-left hover:shadow-md transition-shadow group">
                    <h3 className="font-bold text-emerald-900 flex items-center gap-2 mb-2">
                      <Trash2 className="w-5 h-5 text-emerald-600" /> Trash Separation Rules
                    </h3>
                    <p className="text-sm text-emerald-800 mb-3">Avoid fines and keep the dorms clean. Master the local recycling rules and schedules.</p>
                    <span className="text-sm font-bold text-emerald-600 group-hover:text-emerald-800 flex items-center gap-1 group-hover:translate-x-1 transition-transform">
                      Read Guide <ChevronRight className="w-4 h-4" />
                    </span>
                  </button>
                </div>
              </div>
            </div>
          ) : currentPage === 'facilities' ? (
            <div className="max-w-6xl mx-auto space-y-6 animate-in fade-in duration-300">
              <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
                <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-2"><Map className="w-6 h-6 text-indigo-600"/> Campus Facilities & Services</h1>
                <p className="text-sm text-gray-500 mt-1">Access library resources, search campus directories, and manage room bookings.</p>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                 {/* Room Booking */}
                 <button onClick={() => setCurrentPage('booking')} className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200 hover:border-indigo-400 hover:shadow-md transition-all text-left group flex flex-col h-full">
                    <div className="w-14 h-14 rounded-xl bg-blue-100 text-blue-600 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                      <CalendarCheck className="w-7 h-7" />
                    </div>
                    <h3 className="font-bold text-gray-900 text-lg mb-2">Room & Area Booking</h3>
                    <p className="text-sm text-gray-500 mb-4 flex-1">Reserve classrooms, study rooms, sports facilities, and social lounges. Automatically routes requests to OAA, OGA, or OSS.</p>
                    <span className="text-sm font-bold text-indigo-600 flex items-center gap-1 group-hover:translate-x-1 transition-transform">
                      Open Bookings <ChevronRight className="w-4 h-4" />
                    </span>
                 </button>

                 {/* Library */}
                 <button onClick={() => setCurrentPage('library')} className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200 hover:border-indigo-400 hover:shadow-md transition-all text-left group flex flex-col h-full">
                    <div className="w-14 h-14 rounded-xl bg-purple-100 text-purple-600 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                      <BookText className="w-7 h-7" />
                    </div>
                    <h3 className="font-bold text-gray-900 text-lg mb-2">MLIC Library Services</h3>
                    <p className="text-sm text-gray-500 mb-4 flex-1">Search the external OPAC catalog, reserve physical books, access e-journals, and view your current loans.</p>
                    <span className="text-sm font-bold text-indigo-600 flex items-center gap-1 group-hover:translate-x-1 transition-transform">
                      Access Library <ChevronRight className="w-4 h-4" />
                    </span>
                 </button>

                 {/* Directory */}
                 <button onClick={() => setCurrentPage('directory')} className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200 hover:border-indigo-400 hover:shadow-md transition-all text-left group flex flex-col h-full">
                    <div className="w-14 h-14 rounded-xl bg-green-100 text-green-600 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                      <Contact className="w-7 h-7" />
                    </div>
                    <h3 className="font-bold text-gray-900 text-lg mb-2">Campus Directory</h3>
                    <p className="text-sm text-gray-500 mb-4 flex-1">Quickly search for contact details of university staff, faculty members, and student organizations.</p>
                    <span className="text-sm font-bold text-indigo-600 flex items-center gap-1 group-hover:translate-x-1 transition-transform">
                      Search Directory <ChevronRight className="w-4 h-4" />
                    </span>
                 </button>
              </div>
            </div>
          ) : currentPage === 'library' ? (
            <div className="max-w-5xl mx-auto space-y-6 animate-in fade-in duration-300">
              <button
                onClick={() => setCurrentPage('facilities')}
                className="text-sm font-semibold text-indigo-600 hover:text-indigo-800 flex items-center gap-1"
              >
                <ChevronLeft className="w-4 h-4" /> Back to Facilities Hub
              </button>

              <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                <div>
                  <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-2"><BookText className="w-6 h-6 text-indigo-600"/> Matsushita Library (MLIC)</h1>
                  <p className="text-sm text-gray-500 mt-1">Your gateway to academic resources and library services.</p>
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="md:col-span-2 bg-white p-8 rounded-2xl shadow-sm border border-gray-200 text-center flex flex-col justify-center items-center">
                  <div className="w-16 h-16 bg-gray-50 rounded-full flex items-center justify-center mb-4 border border-gray-100">
                    <Search className="w-8 h-8 text-indigo-400" />
                  </div>
                  <h2 className="text-xl font-bold text-gray-900 mb-2">Search Library Catalog</h2>
                  <p className="text-sm text-gray-500 mb-6 max-w-md">Search for physical books, research papers, and digital journals through the external OPAC system.</p>

                  <div className="w-full max-w-md relative mb-4">
                    <input type="text" placeholder="Search by title, author, or keyword..." className="w-full border border-gray-300 rounded-full py-3 pl-5 pr-12 focus:ring-2 focus:ring-indigo-500 outline-none text-sm shadow-inner" />
                    <button
                      onClick={() => showToast("Redirecting to external MLIC OPAC website...")}
                      className="absolute right-1.5 top-1/2 -translate-y-1/2 bg-indigo-600 text-white p-2 rounded-full hover:bg-indigo-700 transition-colors shadow-sm"
                    >
                      <Search className="w-4 h-4" />
                    </button>
                  </div>
                  <p className="text-xs text-gray-400 flex items-center justify-center gap-1"><ExternalLink className="w-3 h-3" /> Opens in a new tab</p>
                </div>

                <div className="space-y-4">
                  <button onClick={() => showToast("Opening your borrowed items...")} className="w-full bg-white p-5 rounded-2xl shadow-sm border border-gray-200 hover:border-indigo-400 transition-all text-left flex items-center gap-4 group">
                    <div className="p-3 bg-blue-50 text-blue-600 rounded-xl group-hover:scale-110 transition-transform"><BookOpen className="w-6 h-6" /></div>
                    <div>
                      <h4 className="font-bold text-gray-900">My Loans</h4>
                      <p className="text-xs text-gray-500 mt-0.5">2 books borrowed</p>
                    </div>
                  </button>

                  <button onClick={() => { setCurrentPage('booking'); setSelectedFacility(FACILITIES.find(f => f.id === 'f4')); }} className="w-full bg-white p-5 rounded-2xl shadow-sm border border-gray-200 hover:border-indigo-400 transition-all text-left flex items-center gap-4 group">
                    <div className="p-3 bg-purple-50 text-purple-600 rounded-xl group-hover:scale-110 transition-transform"><Map className="w-6 h-6" /></div>
                    <div>
                      <h4 className="font-bold text-gray-900">Study Rooms</h4>
                      <p className="text-xs text-gray-500 mt-0.5">Reserve MLIC Area A</p>
                    </div>
                  </button>

                  <button onClick={() => showToast("Redirecting to external E-Journals database...")} className="w-full bg-white p-5 rounded-2xl shadow-sm border border-gray-200 hover:border-indigo-400 transition-all text-left flex items-center gap-4 group">
                    <div className="p-3 bg-green-50 text-green-600 rounded-xl group-hover:scale-110 transition-transform"><FileText className="w-6 h-6" /></div>
                    <div>
                      <h4 className="font-bold text-gray-900">E-Journals</h4>
                      <p className="text-xs text-gray-500 mt-0.5">EBSCOhost & more</p>
                    </div>
                  </button>
                </div>
              </div>
            </div>
          ) : currentPage === 'directory' ? (
            <div className="max-w-5xl mx-auto space-y-6 animate-in fade-in duration-300">
              <button
                onClick={() => setCurrentPage('facilities')}
                className="text-sm font-semibold text-indigo-600 hover:text-indigo-800 flex items-center gap-1"
              >
                <ChevronLeft className="w-4 h-4" /> Back to Facilities Hub
              </button>

              <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
                <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-2"><Contact className="w-6 h-6 text-indigo-600"/> Campus Directory</h1>
                <p className="text-sm text-gray-500 mt-1">Find contact information for university staff, faculty members, and departments.</p>

                <div className="mt-6 relative max-w-2xl">
                  <Search className="w-5 h-5 text-gray-400 absolute left-4 top-1/2 -translate-y-1/2" />
                  <input
                    type="text"
                    placeholder="Search by name, department, or role..."
                    className="w-full bg-gray-50 border border-gray-200 rounded-xl py-3 pl-12 pr-4 text-sm focus:ring-2 focus:ring-indigo-500 focus:bg-white outline-none transition-all"
                  />
                </div>
              </div>

              <div className="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden">
                <div className="grid grid-cols-1 divide-y divide-gray-100">
                  {MOCK_DIRECTORY.map(contact => (
                    <div key={contact.id} className="p-5 flex flex-col sm:flex-row sm:items-center justify-between gap-4 hover:bg-gray-50 transition-colors">
                      <div className="flex items-center gap-4">
                        <div className="w-12 h-12 bg-indigo-50 text-indigo-600 rounded-full flex items-center justify-center font-bold text-lg border border-indigo-100 shrink-0">
                          {contact.name.charAt(0)}
                        </div>
                        <div>
                          <h3 className="font-bold text-gray-900">{contact.name}</h3>
                          <p className="text-xs font-semibold text-indigo-600 uppercase tracking-wider mt-0.5">{contact.type}</p>
                        </div>
                      </div>

                      <div className="flex flex-col sm:items-end gap-2 shrink-0">
                        <a href={`mailto:${contact.email}`} className="text-sm text-gray-600 hover:text-indigo-600 flex items-center gap-2">
                          <Mail className="w-4 h-4 text-gray-400" /> {contact.email}
                        </a>
                        <div className="text-sm text-gray-600 flex items-center gap-2">
                          <Phone className="w-4 h-4 text-gray-400" /> {contact.phone}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          ) : currentPage === 'booking' ? (
            <div className="max-w-5xl mx-auto space-y-6 animate-in fade-in duration-300">
              <button
                onClick={() => setCurrentPage('facilities')}
                className="text-sm font-semibold text-indigo-600 hover:text-indigo-800 flex items-center gap-1"
              >
                <ChevronLeft className="w-4 h-4" /> Back to Facilities Directory
              </button>

              <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
                <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-2"><CalendarCheck className="w-6 h-6 text-indigo-600"/> Campus Area Bookings</h1>
                <p className="text-sm text-gray-500 mt-1">Reserve classrooms, lounges, and sports facilities. Requests are automatically routed to the relevant authority (OAA, OGA, OSS, etc.).</p>
              </div>

              {!selectedFacility ? (
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                  {FACILITIES.map(facility => (
                    <button
                      key={facility.id}
                      onClick={() => setSelectedFacility(facility)}
                      className="bg-white p-5 rounded-xl shadow-sm border border-gray-200 hover:border-indigo-400 hover:shadow-md transition-all text-left group"
                    >
                      <div className={`w-12 h-12 rounded-lg ${facility.image} flex items-center justify-center mb-4 group-hover:scale-110 transition-transform`}>
                        <Map className="w-6 h-6" />
                      </div>
                      <h3 className="font-bold text-gray-900">{facility.name}</h3>
                      <p className="text-xs text-gray-500 mt-1 flex items-center gap-1"><ShieldAlert className="w-3 h-3"/> Managed by {facility.authority}</p>
                    </button>
                  ))}
                </div>
              ) : (
                <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
                  <button
                    onClick={() => setSelectedFacility(null)}
                    className="text-sm font-semibold text-indigo-600 hover:text-indigo-800 flex items-center gap-1 mb-6"
                  >
                    <ChevronLeft className="w-4 h-4" /> Back to Facilities
                  </button>

                  <div className="flex justify-between items-end border-b border-gray-100 pb-4 mb-6">
                    <div>
                      <h2 className="text-2xl font-bold text-gray-900">{selectedFacility.name}</h2>
                      <p className="text-sm text-gray-500 mt-1">Select an available time slot below to request a booking.</p>
                    </div>
                    <div className="bg-gray-100 text-gray-600 px-3 py-1 rounded-full text-xs font-semibold flex items-center gap-2">
                      <Calendar className="w-4 h-4"/> Today, April 1
                    </div>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    {MOCK_SLOTS.map((slot, index) => (
                      <button
                        key={index}
                        onClick={() => {
                          if (slot.status === 'unavailable') {
                            showToast(`Date unavailable: ${slot.time} is already booked.`);
                          } else {
                            setSelectedSlot(slot);
                          }
                        }}
                        className={`p-4 rounded-xl border text-left transition-all relative overflow-hidden
                          ${slot.status === 'unavailable'
                            ? 'bg-gray-50 border-gray-200 cursor-not-allowed opacity-75'
                            : 'bg-white border-green-200 hover:border-green-400 hover:shadow-md cursor-pointer group'}`}
                      >
                        <div className="flex justify-between items-start mb-2">
                          <span className="font-semibold text-gray-800 text-sm flex items-center gap-2">
                            <Clock className="w-4 h-4 text-gray-400" /> {slot.time}
                          </span>
                        </div>
                        <span className={`text-xs font-bold px-2 py-1 rounded-full inline-block
                          ${slot.status === 'unavailable' ? 'bg-gray-200 text-gray-600' : 'bg-green-100 text-green-700 group-hover:bg-green-200'}
                        `}>
                          {slot.status === 'unavailable' ? 'Booked' : 'Available'}
                        </span>
                      </button>
                    ))}
                  </div>
                </div>
              )}
            </div>
          ) : currentPage === 'calendar' ? (
            <div className="max-w-6xl mx-auto space-y-6 animate-in fade-in duration-300">

              {/* Calendar Header with Action Buttons */}
              <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
                <div>
                  <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-2"><CalendarDays className="w-6 h-6 text-indigo-600"/> Master Calendar</h1>
                  <div className="flex items-center gap-2 mt-2">
                    <span className="px-3 py-1 bg-green-50 text-green-700 rounded-full text-xs font-semibold border border-green-100 flex items-center gap-1">
                      <CheckCircle className="w-3 h-3" /> Auto-synced via Google SSO
                    </span>
                  </div>
                </div>

                <div className="flex flex-wrap items-center gap-3">
                  <button
                    onClick={() => setIsAddEventModalOpen(true)}
                    className="flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2.5 rounded-xl text-sm font-semibold transition-all shadow-sm"
                  >
                    <Plus className="w-4 h-4" /> Add Event
                  </button>
                  <button
                    onClick={() => setIsGroupMeetingModalOpen(true)}
                    className="flex items-center gap-2 bg-white border border-gray-300 hover:border-indigo-400 hover:bg-indigo-50 text-gray-700 px-4 py-2.5 rounded-xl text-sm font-semibold transition-all shadow-sm"
                  >
                    <Users className="w-4 h-4 text-indigo-500" /> Group Meeting
                  </button>
                </div>
              </div>

              <div className="flex flex-col lg:flex-row gap-6">
                {/* Left: Monthly View */}
                <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200 lg:w-1/2 flex flex-col">

                  {/* Calendar Controls */}
                  <div className="flex justify-between items-center mb-6">
                    <div className="flex items-center gap-1 bg-gray-100 p-1 rounded-lg">
                      <button onClick={() => setCalendarView('month')} className={`px-3 py-1.5 text-xs font-bold rounded-md transition-all ${calendarView === 'month' ? 'bg-white text-indigo-700 shadow-sm' : 'text-gray-500 hover:text-gray-800'}`}>Month</button>
                      <button onClick={() => setCalendarView('week')} className={`px-3 py-1.5 text-xs font-bold rounded-md transition-all ${calendarView === 'week' ? 'bg-white text-indigo-700 shadow-sm' : 'text-gray-500 hover:text-gray-800'}`}>Week</button>
                    </div>
                    <button onClick={goToToday} className="text-xs font-bold text-indigo-600 hover:text-indigo-800 bg-indigo-50 hover:bg-indigo-100 px-3 py-1.5 rounded-lg transition-colors">
                      Today
                    </button>
                  </div>

                  <div className="flex justify-between items-center mb-6">
                    <button onClick={prevMonth} className="p-2 text-gray-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-full transition-colors"><ChevronLeft className="w-5 h-5"/></button>
                    <h2 className="text-lg font-bold text-indigo-900">
                      {monthNames[currentViewDate.getMonth()]} {currentViewDate.getFullYear()}
                    </h2>
                    <button onClick={nextMonth} className="p-2 text-gray-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-full transition-colors"><ChevronRight className="w-5 h-5"/></button>
                  </div>

                  <div className="grid grid-cols-7 gap-y-4 text-center">
                    {['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'].map(day => (
                      <div key={day} className="text-xs font-semibold text-gray-400 uppercase">{day}</div>
                    ))}

                    {calendarView === 'month' ? (
                      <>
                        {Array.from({ length: firstDay }).map((_, i) => (
                          <div key={`empty-${i}`} className="p-2"></div>
                        ))}
                        {Array.from({ length: daysInMonth }, (_, i) => i + 1).map(date => {
                          const hasEvent = isMockMonth && calendarEvents.some(e => e.date === date);
                          const isSelected = isMockMonth && date === selectedDate;
                          return (
                          <div key={date} className="relative flex justify-center items-center">
                            <button
                              onClick={() => { if (isMockMonth) setSelectedDate(date); }}
                              className={`w-8 h-8 flex items-center justify-center rounded-full text-sm font-medium transition-colors outline-none
                              ${isSelected ? 'bg-indigo-600 text-white shadow-md' : isMockMonth ? 'text-gray-700 hover:bg-gray-100 cursor-pointer' : 'text-gray-400 cursor-default'}
                            `}>
                              {date}
                            </button>
                            {/* Event dots */}
                            {hasEvent && (
                              <span className="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full border border-white pointer-events-none"></span>
                            )}
                          </div>
                        )})}
                      </>
                    ) : (
                      <div className="col-span-7 py-12 text-sm text-gray-400 font-medium flex flex-col items-center gap-2">
                        <CalendarDays className="w-8 h-8 text-gray-300" />
                        Week view under construction
                      </div>
                    )}
                  </div>
                </div>

                {/* Right: Detailed Filtered Event List */}
                <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200 lg:w-1/2 flex flex-col">

                  {/* Filter Pills */}
                  <div className="flex items-center gap-2 mb-6 overflow-x-auto pb-2 scrollbar-hide">
                    <Filter className="w-4 h-4 text-gray-400 shrink-0 mr-1" />
                    {['all', 'class', 'assignment', 'event'].map(filterType => (
                      <button
                        key={filterType}
                        onClick={() => setCalendarFilter(filterType)}
                        className={`px-3 py-1.5 rounded-full text-xs font-bold whitespace-nowrap capitalize transition-colors
                          ${calendarFilter === filterType
                            ? 'bg-gray-800 text-white shadow-sm'
                            : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}
                      >
                        {filterType === 'all' ? 'All' : filterType === 'class' ? 'Classes' : filterType === 'assignment' ? 'Assignments' : 'Events'}
                      </button>
                    ))}
                  </div>

                  <h3 className="text-sm font-bold text-gray-800 mb-4 border-b border-gray-100 pb-2 flex justify-between items-center">
                    <span>Events for {monthNames[currentViewDate.getMonth()]} {isMockMonth ? selectedDate : currentViewDate.getFullYear()}</span>
                    <span className="text-xs text-gray-400 font-normal">{isMockMonth ? filteredEvents.length : 0} items</span>
                  </h3>

                  <div className="space-y-4 flex-1 overflow-y-auto">
                    {isMockMonth && filteredEvents.length > 0 ? (
                      filteredEvents.map(event => (
                        <div
                          key={event.id}
                          onClick={() => { setEditingEvent(event); setIsEditEventModalOpen(true); }}
                          className="flex gap-4 p-4 border border-gray-100 rounded-xl hover:shadow-md hover:border-indigo-300 transition-all bg-gray-50/50 cursor-pointer group relative"
                        >
                          <div className="absolute top-4 right-4 opacity-0 group-hover:opacity-100 transition-opacity bg-white p-1.5 rounded-lg shadow-sm border border-gray-200">
                            <Edit3 className="w-4 h-4 text-indigo-500" />
                          </div>
                          <div className="shrink-0 mt-1">
                            {event.type === 'class' ? <BookOpen className="w-5 h-5 text-indigo-400" /> :
                             event.type === 'assignment' ? <ShieldAlert className="w-5 h-5 text-red-400" /> :
                             <Users className="w-5 h-5 text-green-400" />}
                          </div>
                          <div>
                            <div className="flex flex-wrap items-center gap-2 mb-1">
                              <span className={`text-white text-xs font-bold px-2 py-0.5 rounded
                                ${event.type === 'class' ? 'bg-indigo-600' :
                                  event.type === 'assignment' ? 'bg-red-500' : 'bg-green-600'}
                              `}>{event.time}</span>
                              <h4 className="font-bold text-gray-900 text-sm group-hover:text-indigo-700 transition-colors">{event.title}</h4>
                            </div>
                            <p className="text-xs text-gray-500 mt-1 leading-relaxed">{event.detail}</p>
                          </div>
                        </div>
                      ))
                    ) : (
                      <div className="text-center text-gray-500 text-sm py-8">
                        No {calendarFilter !== 'all' ? calendarFilter : ''} events scheduled for this day.
                      </div>
                    )}
                  </div>
                </div>
              </div>
            </div>
          ) : currentPage === 'student-id' ? (
            <div className="max-w-5xl mx-auto animate-in fade-in duration-300">
              <div className="flex flex-col lg:flex-row gap-6 items-start">

                {/* Column 1: The Digital ID Card */}
                <div className="w-full lg:w-5/12 bg-white rounded-3xl shadow-lg border border-gray-200 overflow-hidden shrink-0">
                  <div className="bg-orange-500 h-28 relative flex justify-center">
                    <div className="absolute top-4 right-4 text-white/80 hover:text-white cursor-pointer transition-colors">
                      <ShieldAlert className="w-6 h-6" />
                    </div>
                  </div>
                  <div className="px-6 pb-8 relative">
                    <div className="bg-white p-6 rounded-2xl shadow-xl border border-gray-100 -mt-16 text-center">
                      {/* Realistic SVG Barcode */}
                      <div className="h-16 w-full flex justify-center pb-4 border-b border-gray-100 mb-4">
                        <svg className="h-full w-full max-w-[260px] opacity-90" viewBox="0 0 200 40" preserveAspectRatio="none">
                          <g fill="#111827">
                            <rect x="0" y="0" width="4" height="40" />
                            <rect x="6" y="0" width="2" height="40" />
                            <rect x="10" y="0" width="6" height="40" />
                            <rect x="18" y="0" width="2" height="40" />
                            <rect x="22" y="0" width="2" height="40" />
                            <rect x="28" y="0" width="8" height="40" />
                            <rect x="38" y="0" width="4" height="40" />
                            <rect x="44" y="0" width="2" height="40" />
                            <rect x="50" y="0" width="6" height="40" />
                            <rect x="58" y="0" width="4" height="40" />
                            <rect x="64" y="0" width="2" height="40" />
                            <rect x="70" y="0" width="2" height="40" />
                            <rect x="74" y="0" width="6" height="40" />
                            <rect x="82" y="0" width="4" height="40" />
                            <rect x="88" y="0" width="2" height="40" />
                            <rect x="94" y="0" width="8" height="40" />
                            <rect x="104" y="0" width="2" height="40" />
                            <rect x="108" y="0" width="4" height="40" />
                            <rect x="114" y="0" width="4" height="40" />
                            <rect x="120" y="0" width="2" height="40" />
                            <rect x="124" y="0" width="6" height="40" />
                            <rect x="134" y="0" width="2" height="40" />
                            <rect x="138" y="0" width="4" height="40" />
                            <rect x="144" y="0" width="2" height="40" />
                            <rect x="150" y="0" width="6" height="40" />
                            <rect x="158" y="0" width="4" height="40" />
                            <rect x="164" y="0" width="2" height="40" />
                            <rect x="170" y="0" width="2" height="40" />
                            <rect x="174" y="0" width="8" height="40" />
                            <rect x="184" y="0" width="4" height="40" />
                            <rect x="190" y="0" width="2" height="40" />
                            <rect x="196" y="0" width="4" height="40" />
                          </g>
                        </svg>
                      </div>
                      <h2 className="text-2xl font-bold text-indigo-900">Apoorv Terwadkar</h2>
                      <p className="text-sm font-semibold text-gray-500 mt-2">GSIM <span className="mx-3 text-gray-300">|</span> ID: 2C5059</p>
                    </div>
                  </div>
                </div>

                {/* Column 2: The Vaults */}
                <div className="w-full lg:w-7/12 space-y-6">

                  {/* Academic Vault */}
                  <div className="bg-white rounded-3xl shadow-lg border border-gray-200 overflow-hidden">
                    <div className="flex justify-between items-center bg-blue-50/80 p-5 border-b border-blue-100">
                      <h3 className="text-lg font-bold text-blue-900 flex items-center gap-2"><GraduationCap className="w-5 h-5"/> Academic Vault</h3>
                      <ChevronRight className="w-5 h-5 text-blue-400" />
                    </div>
                    <div className="grid grid-cols-2 divide-x divide-gray-100 bg-white">
                      <div className="p-6 text-center hover:bg-gray-50 transition-colors">
                        <p className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-2">Credits Scored</p>
                        <p className="text-4xl font-extrabold text-gray-800">10</p>
                      </div>
                      <div className="p-6 text-center hover:bg-gray-50 transition-colors">
                        <p className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-2">CGPA</p>
                        <p className="text-4xl font-extrabold text-indigo-600">3.375</p>
                      </div>
                    </div>
                  </div>

                  {/* Admin Vault */}
                  <div className="bg-white rounded-3xl shadow-lg border border-gray-200 overflow-hidden">
                    <div className="flex justify-between items-center bg-gray-50 p-5 border-b border-gray-200">
                      <h3 className="text-lg font-bold text-gray-800 flex items-center gap-2"><BookOpen className="w-5 h-5"/> Admin Vault</h3>
                      <ChevronRight className="w-5 h-5 text-gray-400" />
                    </div>
                    <div className="grid grid-cols-2 sm:grid-cols-4 divide-x divide-y sm:divide-y-0 divide-gray-100 bg-white">
                      <button className="p-6 flex flex-col items-center justify-center gap-3 hover:bg-orange-50/50 transition-colors group">
                        <div className="w-12 h-12 rounded-full bg-orange-100 flex items-center justify-center group-hover:scale-110 transition-transform">
                          <Building className="w-6 h-6 text-orange-600" />
                        </div>
                        <span className="text-sm font-semibold text-gray-700">Dorm</span>
                      </button>
                      <button className="p-6 flex flex-col items-center justify-center gap-3 hover:bg-green-50/50 transition-colors group text-center">
                        <div className="w-12 h-12 rounded-full bg-green-100 flex items-center justify-center group-hover:scale-110 transition-transform">
                          <Wallet className="w-6 h-6 text-green-600" />
                        </div>
                        <span className="text-sm font-semibold text-gray-700">Financial<br/>Statement</span>
                      </button>
                      <button className="p-6 flex flex-col items-center justify-center gap-3 hover:bg-blue-50/50 transition-colors group">
                        <div className="w-12 h-12 rounded-full bg-blue-100 flex items-center justify-center group-hover:scale-110 transition-transform">
                          <Book className="w-6 h-6 text-blue-600" />
                        </div>
                        <span className="text-sm font-semibold text-gray-700">Textbooks</span>
                      </button>
                      <button className="p-6 flex flex-col items-center justify-center gap-3 hover:bg-purple-50/50 transition-colors group">
                        <div className="w-12 h-12 rounded-full bg-purple-100 flex items-center justify-center group-hover:scale-110 transition-transform">
                          <FileText className="w-6 h-6 text-purple-600" />
                        </div>
                        <span className="text-sm font-semibold text-gray-700">Records</span>
                      </button>
                    </div>
                  </div>

                </div>
              </div>
            </div>
          ) : (
            <div className="max-w-4xl mx-auto bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden animate-in fade-in duration-300">

              {/* Page Header */}
              <div className="border-b border-gray-100 p-6 md:p-8 bg-gradient-to-br from-white to-gray-50 relative">

                {/* Dynamic Breadcrumb / Backlink */}
                {activePageData.parentPage && (
                  <button
                    onClick={() => setCurrentPage(activePageData.parentPage)}
                    className="text-sm font-semibold text-indigo-600 hover:text-indigo-800 flex items-center gap-1 mb-6 transition-colors"
                  >
                    <ChevronLeft className="w-4 h-4" /> Back to {WIKI_PAGES[activePageData.parentPage].title}
                  </button>
                )}

                <div className="flex items-center gap-2 text-xs font-semibold text-indigo-600 mb-3 uppercase tracking-wider">
                  {activePageData.category} {activePageData.subcategory && <><ChevronRight className="w-3 h-3 mx-1 inline"/> {activePageData.subcategory}</>}
                </div>
                <div className="flex flex-col md:flex-row md:items-start justify-between gap-4">
                  <h1 className="text-3xl md:text-4xl font-extrabold text-gray-900 tracking-tight flex items-center gap-3">
                    {activePageData.icon} {activePageData.title}
                  </h1>

                  {/* Moderated Workflow Button (Hidden on Landing Pages) */}
                  {!activePageData.isLandingPage && (
                    <button
                      onClick={() => setIsEditModalOpen(true)}
                      className="shrink-0 flex items-center gap-2 bg-white border border-gray-200 hover:border-indigo-300 hover:bg-indigo-50 text-gray-700 px-4 py-2 rounded-lg text-sm font-semibold transition-all shadow-sm"
                    >
                      <Edit3 className="w-4 h-4 text-indigo-600" /> Suggest Edit
                    </button>
                  )}
                </div>

                {!activePageData.isLandingPage && activePageData.lastUpdated && (
                  <div className="mt-4 text-sm text-gray-500 flex items-center gap-4">
                    <span>Last updated: {activePageData.lastUpdated}</span>
                    <span className="flex items-center gap-1 text-green-600 bg-green-50 px-2 py-0.5 rounded-full text-xs font-medium border border-green-200">
                      <CheckCircle className="w-3 h-3" /> GSO Verified
                    </span>
                  </div>
                )}
              </div>

              {/* Page Body */}
              <div className="p-6 md:p-8">
                {activePageData.content}
              </div>

            </div>
          )}
        </div>
      </main>

      {/* --- ADD EVENT MODAL --- */}
      {isAddEventModalOpen && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-gray-900/40 backdrop-blur-sm" onClick={() => setIsAddEventModalOpen(false)}></div>
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md relative z-10 overflow-hidden flex flex-col">
            <div className="p-5 border-b border-gray-100 flex items-center justify-between bg-gray-50">
              <h3 className="font-bold text-gray-900 flex items-center gap-2">
                <Plus className="w-5 h-5 text-indigo-600" /> Quick Add Event
              </h3>
              <button onClick={() => setIsAddEventModalOpen(false)} className="text-gray-400 hover:text-gray-600">
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={(e) => {
              e.preventDefault();
              const dateParts = e.target.date.value.split('-');
              const dateVal = dateParts.length === 3 ? parseInt(dateParts[2], 10) : selectedDate;
              const newEvent = {
                id: Date.now(),
                type: e.target.course.value === 'None (General Event)' ? 'event' : 'class',
                date: dateVal,
                time: e.target.time.value,
                title: e.target.title.value,
                detail: e.target.course.value
              };
              setCalendarEvents([...calendarEvents, newEvent]);
              setIsAddEventModalOpen(false);
              showToast("Event saved! Reminders synced to your device calendar.");
            }} className="p-5 space-y-4">

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-1">Event Title</label>
                <input name="title" type="text" placeholder="e.g., Study group, Dentist appt..." required className="w-full border border-gray-300 rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none" />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-1">Related Course / Category</label>
                <select name="course" className="w-full border border-gray-300 rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none bg-white">
                  {ENROLLED_COURSES.map(course => <option key={course} value={course}>{course}</option>)}
                </select>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-1">Date</label>
                  <input name="date" type="date" required className="w-full border border-gray-300 rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none" />
                </div>
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-1">Time</label>
                  <input name="time" type="time" required className="w-full border border-gray-300 rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none" />
                </div>
              </div>

              <div className="bg-indigo-50 text-indigo-800 text-xs p-3 rounded-lg flex items-start gap-2 border border-indigo-100 mt-2">
                <Smartphone className="w-4 h-4 shrink-0 mt-0.5" />
                <p>This event will automatically sync with your <strong>device's calendar</strong> and configure 10m, 30m, and 1h reminders.</p>
              </div>

              <div className="flex justify-end gap-3 pt-4 border-t border-gray-100 mt-2">
                <button type="button" onClick={() => setIsAddEventModalOpen(false)} className="px-4 py-2 text-sm font-semibold text-gray-600 hover:bg-gray-100 rounded-lg transition-colors">
                  Cancel
                </button>
                <button type="submit" className="px-5 py-2 text-sm font-semibold text-white bg-indigo-600 hover:bg-indigo-700 rounded-lg shadow-md transition-colors">
                  Save Event
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* --- EDIT EVENT MODAL --- */}
      {isEditEventModalOpen && editingEvent && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-gray-900/40 backdrop-blur-sm" onClick={() => setIsEditEventModalOpen(false)}></div>
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md relative z-10 overflow-hidden flex flex-col">
            <div className="p-5 border-b border-gray-100 flex items-center justify-between bg-gray-50">
              <h3 className="font-bold text-gray-900 flex items-center gap-2">
                <Edit3 className="w-5 h-5 text-indigo-600" /> Edit Event
              </h3>
              <button onClick={() => setIsEditEventModalOpen(false)} className="text-gray-400 hover:text-gray-600">
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={(e) => {
              e.preventDefault();
              const updatedEvent = {
                ...editingEvent,
                title: e.target.title.value,
                time: e.target.time.value,
                type: e.target.type.value,
                detail: e.target.detail.value
              };
              setCalendarEvents(calendarEvents.map(ev => ev.id === editingEvent.id ? updatedEvent : ev));
              setIsEditEventModalOpen(false);
              showToast("Event updated! Reminders automatically re-synced.");
            }} className="p-5 space-y-4">

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-1">Event Title</label>
                <input name="title" defaultValue={editingEvent.title} type="text" required className="w-full border border-gray-300 rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none" />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-1">Event Type</label>
                <select name="type" defaultValue={editingEvent.type} className="w-full border border-gray-300 rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-indigo-500 outline-none bg-white">
                  <option value="class">Class</option>
                  <option value="assignment">Assignment</option>
                  <option value="event">Event</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-1">Time</label>
                <input name="time" defaultValue={editingEvent.time} type="time" required className="w-full border border-gray-300 rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-indigo-500 outline-none" />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-1">Details / Location</label>
                <input name="detail" defaultValue={editingEvent.detail} type="text" required className="w-full border border-gray-300 rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-indigo-500 outline-none" />
              </div>

              <div className="bg-indigo-50 text-indigo-800 text-xs p-3 rounded-lg flex items-start gap-2 border border-indigo-100 mt-2">
                <Smartphone className="w-4 h-4 shrink-0 mt-0.5" />
                <p>Changes will automatically sync to your <strong>device's calendar</strong> to update your 10m, 30m, and 1h alerts.</p>
              </div>

              <div className="flex justify-between items-center pt-4 border-t border-gray-100 mt-2">
                <button
                  type="button"
                  onClick={() => {
                    setCalendarEvents(calendarEvents.filter(ev => ev.id !== editingEvent.id));
                    setIsEditEventModalOpen(false);
                    showToast("Event deleted from your calendar.");
                  }}
                  className="px-4 py-2 text-sm font-semibold text-red-600 hover:bg-red-50 rounded-lg transition-colors flex items-center gap-1"
                >
                  <Trash2 className="w-4 h-4"/> Delete
                </button>
                <div className="flex gap-2">
                  <button type="button" onClick={() => setIsEditEventModalOpen(false)} className="px-4 py-2 text-sm font-semibold text-gray-600 hover:bg-gray-100 rounded-lg transition-colors">
                    Cancel
                  </button>
                  <button type="submit" className="px-5 py-2 text-sm font-semibold text-white bg-indigo-600 hover:bg-indigo-700 rounded-lg shadow-md transition-colors">
                    Save Changes
                  </button>
                </div>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* --- GROUP MEETING MODAL --- */}
      {isGroupMeetingModalOpen && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-gray-900/40 backdrop-blur-sm" onClick={() => {setIsGroupMeetingModalOpen(false); setGeneratedLink(null);}}></div>
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md relative z-10 overflow-hidden flex flex-col">
            <div className="p-5 border-b border-gray-100 flex items-center justify-between bg-gray-50">
              <h3 className="font-bold text-gray-900 flex items-center gap-2">
                <Users className="w-5 h-5 text-indigo-600" /> Schedule Group Meeting
              </h3>
              <button onClick={() => {setIsGroupMeetingModalOpen(false); setGeneratedLink(null);}} className="text-gray-400 hover:text-gray-600">
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="p-5 space-y-4">
              {!generatedLink ? (
                <>
                  <p className="text-sm text-gray-600 mb-2">Create a link for your group to vote on their free times, similar to Doodle or Calendly.</p>

                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-1">Meeting Title</label>
                    <input type="text" value={meetingTitle} onChange={(e) => setMeetingTitle(e.target.value)} placeholder="e.g., Marketing Project Phase 2..." className="w-full border border-gray-300 rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none" />
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-1">Proposed Dates Range</label>
                    <div className="flex items-center gap-2">
                      <input type="date" className="flex-1 border border-gray-300 rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-indigo-500 outline-none" />
                      <span className="text-gray-400 font-bold">to</span>
                      <input type="date" className="flex-1 border border-gray-300 rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-indigo-500 outline-none" />
                    </div>
                  </div>

                  <div className="flex justify-end gap-3 pt-4 border-t border-gray-100 mt-4">
                    <button onClick={() => setIsGroupMeetingModalOpen(false)} className="px-4 py-2 text-sm font-semibold text-gray-600 hover:bg-gray-100 rounded-lg transition-colors">
                      Cancel
                    </button>
                    <button
                      onClick={() => setGeneratedLink('https://myiuj.ac.jp/meet/a7b9x2')}
                      className="px-5 py-2 text-sm font-semibold text-white bg-indigo-600 hover:bg-indigo-700 rounded-lg shadow-md transition-colors flex items-center gap-2"
                    >
                      <LinkIcon className="w-4 h-4" /> Generate Link
                    </button>
                  </div>
                </>
              ) : (
                <div className="py-4 text-center animate-in zoom-in-95 duration-200">
                  <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4 text-green-600">
                    <CheckCircle className="w-8 h-8" />
                  </div>
                  <h3 className="text-xl font-bold text-gray-900 mb-2">Link Generated!</h3>
                  <p className="text-sm text-gray-600 mb-6">Share this link with your peers. They will be able to mark their available times.</p>

                  <div className="flex items-center gap-2 bg-gray-100 p-2 rounded-xl border border-gray-200">
                    <input type="text" readOnly value={generatedLink} className="bg-transparent border-none focus:ring-0 text-sm font-medium text-gray-800 flex-1 px-2 outline-none" />
                    <button
                      onClick={() => copyToClipboard(generatedLink)}
                      className="bg-white border border-gray-300 hover:bg-gray-50 text-gray-700 px-3 py-1.5 rounded-lg text-sm font-semibold transition-all flex items-center gap-2 shadow-sm"
                    >
                      <Copy className="w-4 h-4" /> Copy
                    </button>
                    <button
                      onClick={() => {
                        setIsGroupMeetingModalOpen(false);
                        setCurrentPage('calendar');
                        setIsMeetingPollModalOpen(true);
                      }}
                      className="bg-indigo-100 border border-indigo-200 hover:bg-indigo-200 text-indigo-700 px-3 py-1.5 rounded-lg text-sm font-semibold transition-all flex items-center gap-2 shadow-sm"
                      title="Simulate opening the link as a recipient"
                    >
                      <LinkIcon className="w-4 h-4" /> Open
                    </button>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {/* --- MEETING POLL / AVAILABILITY MODAL (Recipient View) --- */}
      {isMeetingPollModalOpen && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-gray-900/40 backdrop-blur-sm" onClick={() => setIsMeetingPollModalOpen(false)}></div>
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl relative z-10 overflow-hidden flex flex-col max-h-[90vh]">
            <div className="p-5 border-b border-gray-100 flex items-center justify-between bg-gray-50 shrink-0">
              <h3 className="font-bold text-gray-900 flex items-center gap-2">
                <CalendarDays className="w-5 h-5 text-indigo-600" />
                Availability Poll: {meetingTitle || 'Marketing Project Phase 2'}
              </h3>
              <button onClick={() => setIsMeetingPollModalOpen(false)} className="text-gray-400 hover:text-gray-600">
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="p-5 overflow-y-auto">
              <div className="bg-blue-50 text-blue-800 text-sm p-4 rounded-xl flex items-start gap-3 border border-blue-100 mb-6">
                <Info className="w-5 h-5 shrink-0 mt-0.5" />
                <div>
                  <p>We've synced with your <strong>Google Workspace Calendar</strong>. Slots conflicting with your schedule are automatically grayed out.</p>
                  <p className="mt-1 opacity-80 text-xs">Note: Once the final time is chosen, it will automatically sync to your device's calendar with 10m, 30m, and 1h reminders.</p>
                </div>
              </div>

              <div className="space-y-6">
                {MOCK_POLL_DATES.map((dayData, index) => (
                  <div key={index}>
                    <h4 className="font-bold text-gray-800 mb-3 border-b border-gray-100 pb-2">{dayData.date}</h4>
                    <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                      {dayData.slots.map(slot => {
                        const isSelected = selectedPollSlots.includes(slot.id);
                        if (slot.status === 'busy') {
                          return (
                            <div key={slot.id} className="p-3 rounded-xl border border-gray-200 bg-gray-100 opacity-60 text-center cursor-not-allowed">
                              <p className="text-sm font-bold text-gray-500">{slot.time}</p>
                              <p className="text-xs text-gray-400 mt-1 flex items-center justify-center gap-1">
                                <ShieldAlert className="w-3 h-3" /> {slot.label}
                              </p>
                            </div>
                          );
                        }

                        return (
                          <button
                            key={slot.id}
                            onClick={() => togglePollSlot(slot.id)}
                            className={`p-3 rounded-xl border text-center transition-all ${
                              isSelected
                                ? 'bg-indigo-600 border-indigo-600 text-white shadow-md scale-[1.02]'
                                : 'bg-white border-gray-300 text-gray-700 hover:border-indigo-400 hover:shadow-sm'
                            }`}
                          >
                            <p className="text-sm font-bold">{slot.time}</p>
                            <p className={`text-xs mt-1 font-medium ${isSelected ? 'text-indigo-100' : 'text-green-600'}`}>
                              {isSelected ? 'Selected' : 'Free - Click to Select'}
                            </p>
                          </button>
                        );
                      })}
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <div className="p-5 border-t border-gray-100 bg-gray-50 flex justify-end gap-3 shrink-0">
               <button onClick={() => setIsMeetingPollModalOpen(false)} className="px-4 py-2 text-sm font-semibold text-gray-600 hover:bg-gray-200 rounded-lg transition-colors">
                  Cancel
                </button>
                <button onClick={() => {
                  setIsMeetingPollModalOpen(false);
                  setSelectedPollSlots([]);
                  showToast("Availability submitted! The organizer will be notified.");
                }} className="px-5 py-2 text-sm font-semibold text-white bg-indigo-600 hover:bg-indigo-700 rounded-lg shadow-md transition-colors">
                  Submit Availability
                </button>
            </div>
          </div>
        </div>
      )}

      {/* --- CREATE TOPIC MODAL (Moderated Workflow Demo) --- */}
      {isCreateTopicModalOpen && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-gray-900/40 backdrop-blur-sm" onClick={() => setIsCreateTopicModalOpen(false)}></div>
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg relative z-10 overflow-hidden flex flex-col">

            {editRequestSent ? (
              <div className="p-8 text-center space-y-4">
                <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4 text-green-600">
                  <CheckCircle className="w-8 h-8" />
                </div>
                <h3 className="text-xl font-bold text-gray-900">Topic Submitted!</h3>
                <p className="text-gray-600">Your new topic has been sent to the GSO moderation queue. It will be reviewed shortly before publication.</p>
              </div>
            ) : (
              <>
                <div className="p-5 border-b border-gray-100 flex items-center justify-between bg-gray-50">
                  <h3 className="font-bold text-gray-900 flex items-center gap-2">
                    <FilePlus className="w-5 h-5 text-indigo-600" /> Create New Topic
                  </h3>
                  <button onClick={() => setIsCreateTopicModalOpen(false)} className="text-gray-400 hover:text-gray-600">
                    <X className="w-5 h-5" />
                  </button>
                </div>

                <form onSubmit={handleEditSubmit} className="p-5 space-y-4">
                  <div className="bg-blue-50 text-blue-800 text-xs p-3 rounded-lg flex items-start gap-2 border border-blue-100">
                    <ShieldAlert className="w-4 h-4 shrink-0 mt-0.5" />
                    <p><strong>Moderated Workflow:</strong> Your new topic will not go live immediately. A GSO officer will review it to ensure accuracy and relevance.</p>
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-1">Topic Title</label>
                    <input type="text" placeholder="e.g., Local Supermarkets Guide" required className="w-full border border-gray-300 rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none" />
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-1">Select Category</label>
                    <select className="w-full border border-gray-300 rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-indigo-500 outline-none bg-white">
                      <option>Residential Life</option>
                      <option>Academics</option>
                      <option>GSO</option>
                      <option>Administration</option>
                    </select>
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-1">Initial Content</label>
                    <textarea
                      required
                      rows={4}
                      placeholder="Start writing the guide here..."
                      className="w-full border border-gray-300 rounded-lg p-3 text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none resize-none"
                    ></textarea>
                  </div>

                  <div className="flex justify-end gap-3 pt-4 border-t border-gray-100">
                    <button type="button" onClick={() => setIsCreateTopicModalOpen(false)} className="px-4 py-2 text-sm font-semibold text-gray-600 hover:bg-gray-100 rounded-lg transition-colors">
                      Cancel
                    </button>
                    <button type="submit" className="px-5 py-2 text-sm font-semibold text-white bg-indigo-600 hover:bg-indigo-700 rounded-lg shadow-md transition-colors">
                      Submit for Moderation
                    </button>
                  </div>
                </form>
              </>
            )}
          </div>
        </div>
      )}

      {/* --- EDIT SUGGESTION MODAL (Moderated Workflow Demo) --- */}
      {isEditModalOpen && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-gray-900/40 backdrop-blur-sm" onClick={() => setIsEditModalOpen(false)}></div>
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg relative z-10 overflow-hidden flex flex-col">

            {editRequestSent ? (
              <div className="p-8 text-center space-y-4">
                <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4 text-green-600">
                  <CheckCircle className="w-8 h-8" />
                </div>
                <h3 className="text-xl font-bold text-gray-900">Suggestion Submitted!</h3>
                <p className="text-gray-600">Your edit has been sent to the GSO moderation queue. It will be reviewed shortly.</p>
              </div>
            ) : (
              <>
                <div className="p-5 border-b border-gray-100 flex items-center justify-between bg-gray-50">
                  <h3 className="font-bold text-gray-900 flex items-center gap-2">
                    <Edit3 className="w-5 h-5 text-indigo-600" /> Propose an Edit
                  </h3>
                  <button onClick={() => setIsEditModalOpen(false)} className="text-gray-400 hover:text-gray-600">
                    <X className="w-5 h-5" />
                  </button>
                </div>

                <form onSubmit={handleEditSubmit} className="p-5 space-y-4">
                  <div className="bg-blue-50 text-blue-800 text-xs p-3 rounded-lg flex items-start gap-2 border border-blue-100">
                    <ShieldAlert className="w-4 h-4 shrink-0 mt-0.5" />
                    <p><strong>Moderated Workflow:</strong> Your changes will not go live immediately. A GSO officer will review your suggestion to ensure accuracy before publishing.</p>
                  </div>

                  {activePageData.isLandingPage && (
                    <div>
                      <label className="block text-sm font-semibold text-gray-700 mb-1">Which article are you editing?</label>
                      <input type="text" placeholder="e.g., Winter Survival Guide" required className="w-full border border-gray-300 rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none" />
                    </div>
                  )}

                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-1">What are you adding/fixing?</label>
                    <input type="text" placeholder="e.g., Updated bus schedule for Winter term" required className="w-full border border-gray-300 rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none" />
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-1">Proposed Content</label>
                    <textarea
                      required
                      rows={5}
                      placeholder="Write your updated information here..."
                      className="w-full border border-gray-300 rounded-lg p-3 text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none resize-none"
                    ></textarea>
                  </div>

                  <div className="flex justify-end gap-3 pt-4 border-t border-gray-100">
                    <button type="button" onClick={() => setIsEditModalOpen(false)} className="px-4 py-2 text-sm font-semibold text-gray-600 hover:bg-gray-100 rounded-lg transition-colors">
                      Cancel
                    </button>
                    <button type="submit" className="px-5 py-2 text-sm font-semibold text-white bg-indigo-600 hover:bg-indigo-700 rounded-lg shadow-md transition-colors">
                      Submit to GSO
                    </button>
                  </div>
                </form>
              </>
            )}
          </div>
        </div>
      )}

      {/* --- BOOKING REQUEST MODAL --- */}
      {selectedSlot && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-gray-900/40 backdrop-blur-sm" onClick={() => setSelectedSlot(null)}></div>
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg relative z-10 overflow-hidden flex flex-col">
            <div className="p-5 border-b border-gray-100 flex items-center justify-between bg-gray-50">
              <h3 className="font-bold text-gray-900 flex items-center gap-2">
                <CalendarCheck className="w-5 h-5 text-indigo-600" /> Confirm Booking Request
              </h3>
              <button onClick={() => setSelectedSlot(null)} className="text-gray-400 hover:text-gray-600">
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="p-5 space-y-4">
              <div className="bg-blue-50 border border-blue-100 rounded-lg p-4">
                <p className="text-sm font-semibold text-blue-900">{selectedFacility?.name}</p>
                <p className="text-sm text-blue-700 mt-1 flex items-center gap-2">
                  <Clock className="w-4 h-4"/> {selectedSlot.time}
                </p>
              </div>

              <div className="bg-amber-50 text-amber-800 text-xs p-3 rounded-lg flex items-start gap-2 border border-amber-100">
                <Info className="w-4 h-4 shrink-0 mt-0.5" />
                <p>This request will be automatically routed to <strong>{selectedFacility?.authority}</strong> for approval. You do not need to contact them separately.</p>
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-1">Reason for Booking</label>
                <textarea
                  value={bookingReason}
                  onChange={(e) => setBookingReason(e.target.value)}
                  rows={3}
                  placeholder="e.g., Study group session, Club meeting..."
                  className="w-full border border-gray-300 rounded-lg p-3 text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none resize-none"
                ></textarea>
              </div>

              <div className="flex justify-end gap-3 pt-4 border-t border-gray-100">
                <button onClick={() => setSelectedSlot(null)} className="px-4 py-2 text-sm font-semibold text-gray-600 hover:bg-gray-100 rounded-lg transition-colors">
                  Cancel
                </button>
                <button
                  onClick={() => {
                    showToast(`Booking request submitted! ${selectedFacility?.authority} will review it shortly.`);
                    setSelectedSlot(null);
                    setBookingReason('');
                  }}
                  className="px-5 py-2 text-sm font-semibold text-white bg-indigo-600 hover:bg-indigo-700 rounded-lg shadow-md transition-colors"
                >
                  Send Request
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

    </div>
  );
}
