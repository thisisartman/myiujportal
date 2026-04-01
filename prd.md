# Product Requirements Document (PRD): MyIUJ! Portal

## 1. Executive Summary
**MyIUJ!** is a modular, multipage campus portal and community-driven knowledge base built for the International University of Japan. It solves the fragmentation of university systems by consolidating daily schedules, facility bookings, administrative vaults, and a heavily structured, searchable academic Wiki into a single, highly responsive interface.

## 2. Architectural Strategy
Per explicit project requirements, the application must avoid being a monolithic single-file structure.
* **Modular & Multipage:** The architecture must utilize a router (e.g., `react-router-dom`) to manage distinct, separate page components (`Dashboard.jsx`, `CalendarView.jsx`, `FacilitiesHub.jsx`, `WikiArticle.jsx`).
* **Dynamic Routing:** The Wiki must use a single dynamic template component that fetches and renders content based on URL parameters, rather than hardcoding dozens of separate syllabus pages.
* **Layout Shell:** A persistent `<Layout />` component will wrap the application, maintaining the state of the sidebar and top navigation search bar across all page changes.

## 3. Core Modules & Feature Specifications

### 3.1. Layout & Global Navigation
* **Collapsible Sidebar:** The left navigation pane must be fully collapsible. When toggled via the header menu icon, it must smoothly disappear/slide into the left side of the screen, allowing the main content area to expand and fill the void.
* **Tighter UI Constraints:** All pop-up forms and overlays (e.g., Add Event, Edit Topic, Group Meeting) must use a strict, narrow width (`max-w-md`) to ensure a focused, uncluttered user experience.
* **Global Search:** A persistent top search bar capable of fuzzy-searching Wiki articles, course syllabi, and library resources.

### 3.2. Personalized Dashboard (`/`)
* **Quick-Access Calendar Widget:** Located in the top right of the dashboard header.
  * *Specific Formatting:* Must display the **Date on top** and the **Day of the week at the bottom**.
  * *Specific Exclusion:* Do not display the geographic location (e.g., Minamiuonuma).
  * *Interaction:* The entire widget must be clickable, routing the user directly to the Master Calendar.
* **Up Next:** Highlights the immediate next event, showing time, title, location, and instructor.
* **Quick Links:** Direct routing to the Digital ID and Campus Facilities.

### 3.3. Master Calendar (`/calendar`)
The calendar must emulate a fully functional, native scheduling application.
* **Dynamic Grid Interaction:** The monthly grid must accurately calculate padding for days of the week. Users must be able to click on any specific date to dynamically filter and view the events for that day on the right-hand panel.
* **Navigation:** Must include functional `<` and `>` arrows to switch months, a "Today" button to instantly jump to the current date, and toggles for Month/Week views.
* **Interactive Event Management:**
  * Event cards must reveal an "Edit" icon on hover.
  * Clicking an event opens a narrow modal allowing the user to edit the title, time, type, and details, or completely delete the event.
  * Changes must update the UI in real-time.
* **Strict Terminology:** Event types must strictly be categorized as **"Classes"**, **"Assignments"** (formerly deadlines), and **"Events"** (formerly university events).
* **Device Syncing:** The system must generate 10m, 30m, and 1h cascading alerts. *Explicit Instruction:* All UI copy must refer to this as syncing to the user's generic **"device calendar"** (strictly no brand-specific references like Samsung).

### 3.4. Facilities & Services Hub (`/facilities`)
A centralized landing page featuring a collection of distinct campus services:
* **Room Booking:** An interactive time-slot selector for classrooms and lounges, automatically routing requests to OAA/OGA/OSS.
* **MLIC Library Services:** A dedicated sub-page allowing users to search the external OPAC catalog, view active book loans, and access E-Journals.
* **Campus Directory:** A searchable contact list for university staff, faculty, and departments.

### 3.5. Wiki Knowledge Base & Course Hub (`/wiki/...`)
The Wiki is the core repository for institutional knowledge, featuring data extracted from official PDF syllabi and student guides.
* **Strict Nested Sidebar Structure:** The navigation pane must follow a precise, collapsible hierarchical structure without displaying the actual content in the menu:
  * `Wiki`
    * `Courses`
      * `Finance`
        * `FIN2090 Behavioral Finance`
        * `FIN2080 Sustainable Finance...`
      * `IT & Operations`
      * `General Management`
    * `Residential Life`
    * `Academics`
* **Landing Pages:** Clicking top-level categories (e.g., Courses, Finance) must open succinct, dedicated landing pages. These pages must contain brief descriptions and internal routing links to their respective sub-pages.
* **Breadcrumb Backlinks:** Every sub-page and article must feature a "Back to [Parent Page]" button at the top to allow seamless upward navigation.

### 3.6. Role-Based Access Control (RBAC) & Moderation
A core requirement for the Wiki's integrity.
* **Crucial Distinction for Courses:** Adding new course entries or officially publishing syllabus updates is **strictly limited to Professors and OAA staff**. A prominent alert must explain this on the Courses landing page. Students are limited to using the "Suggest Edit" workflow.
* **Topic Creation Workflow:** The root Wiki landing page must feature two primary actions:
  1. *Create New Topic:* Opens a modal to submit a brand new guide/article.
  2. *Edit Existing Topic:* Opens a modal to propose changes to current articles.
* **The Moderation Queue:** Both the "Create" and "Edit" actions utilized by students do not publish live immediately. They must trigger a "Submitted for Moderation" success state, indicating the content is pending review by GSO/Admin officers.

## 4. Technical Stack
* **Frontend:** React.js (Functional components, Hooks).
* **Routing:** `react-router-dom` for multipage navigation.
* **Styling:** Tailwind CSS (Utility-first CSS).
* **Icons:** Lucide-React.
