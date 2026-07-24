# bEDesh — Study Abroad Guide & Community App

<!-- <div style="display:flex; column-gap:2em; width:50%;height:auto;"> -->
<table>
  <tr>
    <td>
      <img src="https://raw.githubusercontent.com/deadshoot333/bEDesh/refs/heads/main/screenshots/landing_page.png" alt="Landing Page" width=30% height=30%>
    </td>
    <td>
      <img src="https://raw.githubusercontent.com/deadshoot333/bEDesh/refs/heads/main/screenshots/home_page.png" alt="Home Page" width=30% height=30%>
    </td>
  </tr>
</table>
<!-- </div> -->


**bEDesh** is a cross-platform mobile application that helps Bangladeshi students navigate the entire study-abroad journey — from discovering universities, courses, and scholarships, to finding verified accommodation and connecting with peers heading to the same city or campus.

Built as a final-year Software Development Project (CSE 464) at the Military Institute of Science and Technology (MIST).

> Existing platforms (CollegeDunia, Yocket, IDP Live, Edvoy, Common App) are largely single-country-centric and fragmented — they cover *either* university search *or* counselling *or* peer support, never all of it in one place, and none of them address verified accommodation or local payment/cultural context for Bangladeshi students. bEDesh combines all of these into a single, integrated platform.

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [System Architecture](#system-architecture)
- [Database Schema](#database-schema)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Mobile App Setup](#mobile-app-setup)
  - [Backend Setup](#backend-setup)
- [Environment Variables](#environment-variables)
- [Usage](#usage)
- [Testing](#testing)
- [Ethical & Privacy Considerations](#ethical--privacy-considerations)
- [Team](#team)
- [License](#license)
- [Acknowledgements](#acknowledgements)

---

## Features

- **University & Program Search** — Filter universities by country, program, global ranking, tuition fee, and eligibility; view detailed profiles and jump straight to official university sites.
- **Scholarship & Course Discovery** — Browse scholarships by country, university, and type (full/partial funding, merit-based); set deadline reminders.
- **Accommodation Helper** — Browse verified, student-friendly housing abroad with pricing, amenities, photos, and landlord contact info; post and manage your own accommodation/roommate listings.
- **Peer Connect** — Find and connect with students headed to the same university or city; send/accept connection requests and message directly.
- **Community Feed** — Post questions, tips, and experiences; comment on and like other students' posts, organized into University and City groups.
- **Guided Onboarding & FAQs** — Country-specific FAQ sections addressing common concerns (funding, PR pathways, language requirements, work rights, etc.).

## Tech Stack

| Layer | Technology | Notes |
|---|---|---|
| Mobile Frontend | **Flutter** (Dart, SDK ^3.7.2) | Single codebase for Android/iOS/desktop/web |
| Backend | **Node.js + Express.js** | REST API, `server/` directory |
| Database | **Supabase** (PostgreSQL) | Auth, Row Level Security, realtime, file storage |
| Key Flutter packages | `http`, `shared_preferences`, `image_picker`, `share_plus`, `url_launcher`, `intl_phone_field`, `cupertino_icons` | See `pubspec.yaml` |
| Tooling | Git/GitHub, Postman, VS Code | Version control, API testing, IDE |

## System Architecture

The mobile app (client) communicates with the bEDesh backend server over REST APIs. The server exposes an API Gateway and application logic layer, which reads from and writes to the Supabase-backed database (user data, university/scholarship/course data, accommodation listings, and community posts).

```
Flutter Mobile App  ──HTTP/REST──>  Express API Gateway ──>  Application Logic ──>  Supabase (PostgreSQL)
       (client)                          (server/)                                    (bEDesh Database)
```

## Database Schema

Core entities and relationships:

- `users` — primary entity; each user has `id`, `email`, `password`, `mobile_number`, `university`, `city`, `image`, etc.
- `users` → `messages`: one-to-many
- `users` → `posts`: one-to-many
- `users` → `peer_connections`: many-to-many (via requester/receiver)
- `users` → `accommodations`: one-to-many
- `users` → `rf_tokens`: one-to-one (refresh tokens)
- `accommodations` → `accommodation_facilities`: one-to-many
- `facilities` → `accommodation_facilities`: many-to-many
- `countries` → `universities`: one-to-many
- `universities` → `courses`, `scholarships`: many-to-many

See the full Entity-Relationship Diagram and use-case diagram in the [SDP report](./SDP_report%20(1).pdf).

## Project Structure

```
bEDesh/
├── android/               # Android platform code
├── ios/                   # iOS platform code
├── linux/, macos/, windows/  # Desktop platform code (Flutter multi-platform)
├── web/                   # Web platform code
├── assets/                # Images used across the app (university/country photos, flags, etc.)
├── lib/                   # Flutter application source (screens, widgets, services, models)
├── server/                # Node.js/Express backend (REST API, Supabase integration)
├── test/                  # Flutter widget/unit tests
├── pubspec.yaml           # Flutter dependencies & asset manifest
├── package.json           # Root Node.js dependencies (backend tooling)
└── SDP_report (1).pdf     # Full academic project report
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK `^3.7.2` or higher)
- [Node.js](https://nodejs.org/) (LTS recommended) and npm
- A [Supabase](https://supabase.com/) project (URL + API keys)
- Android Studio / Xcode (for emulators) or a physical device
- Git

### Mobile App Setup

```bash
# Clone the repository
git clone https://github.com/deadshoot333/bEDesh.git
cd bEDesh

# Install Flutter dependencies
flutter pub get

# Run the app (with a device/emulator connected)
flutter run
```

To build a release APK:

```bash
flutter build apk --release
```

### Backend Setup

```bash
cd server

# Install dependencies
npm install

# Configure environment variables (see below)
cp .env.example .env   # then fill in your values

# Start the development server
npm run dev

# Or start in production mode
npm start
```

## Environment Variables

Create a `.env` file inside `server/` with the following (adjust names to match your actual code):

```env
PORT=5000
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
JWT_SECRET=your_jwt_secret
```

On the Flutter side, point the app's API base URL (typically in a config/service file under `lib/`) to your running backend, e.g. `http://<your-local-ip>:5000/api`.

> **Note:** Never commit real credentials. Keep `.env` in `.gitignore`.

## Usage

1. Launch the backend server (`server/`) so the API is reachable.
2. Launch the Flutter app on an emulator or device.
3. Sign up / log in as a student.
4. Explore destinations, search and filter universities, browse scholarships, post or search accommodation listings, and connect with peers via Peer Connect and the Community Feed.

## Testing

- Widget/unit tests for the Flutter app live in `test/` — run with:
  ```bash
  flutter test
  ```
- The project underwent usability evaluation using Nielsen's 10 usability heuristics, plus task-completion-time testing across three core flows (university search & filter, peer connect, community post view/share), averaging ~10 seconds per task across evaluators. See the SDP report for the full System Usability Scale (SUS) results.

## Ethical & Privacy Considerations

- No personal image or biometric data is collected via device cameras.
- The app does not request microphone or location permissions.
- No sensitive personal data collection requiring explicit consent is performed beyond standard account fields.

<!-- ## Roadmap

- [ ] AI chatbot for 24/7 study-abroad, visa, and admissions queries
- [ ] Financial planning calculator and automated scholarship matching
- [ ] Video calling and virtual/VR campus tours
- [ ] Parent portal for tracking application progress
- [ ] Alumni network and mentorship matching
- [ ] Bengali language support (multi-language UI)
- [ ] Embassy/government data integration for visa processing status
- [ ] Post-arrival support (part-time jobs, local laws, staying connected home)
-->
## Team

**Group A8 — MIST, CSE 464 (Software Development Project-II)**

| Name | Student ID |
|---|---|
| Anika Tasnim | 202214008 |
| Arqam Bin Almas | 202214011 |
| Maisha Nanjeeba | 202214033 |
| Md. Nahul Rahman | 202214049 |

## License

This project was developed for academic purposes as part of the CSE 464 course at the Military Institute of Science and Technology. No license has been specified yet — add one (e.g. MIT) if you intend to open-source this project.

## Acknowledgements

- Course faculty at MIST for guidance and design feedback throughout the project.
- Reviewed platforms (CollegeDunia, Yocket, IDP Live, Edvoy, Common App) for informing the competitive analysis and research gap identified in this project.
