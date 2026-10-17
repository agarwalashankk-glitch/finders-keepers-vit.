# Finders Keepers?
*Campus Lost-and-Found Mobile Application with Verified Ownership Handover*  
**CodeChef-VIT Promotional Cycle 2026–27 | App Development Task**

---

## 1. Overview
**Finders Keepers?** is a production-grade campus lost-and-found mobile application built for universities, starting with Vellore Institute of Technology (VIT Vellore). It directly solves the problem of chaotic, unorganized lost-item recovery across college campuses by providing an organized digital board, approximate location privacy, rule-based potential matching between lost and found items, and an ownership verification workflow before physical item handover.

---

## 2. Problem Statement
Every semester, university students lose essential items across vast campus grounds—student IDs, wallets, keys, calculators, wireless earphones, backpacks, and electronic accessories. Currently, students rely on scattered WhatsApp groups, Telegram channels, or Instagram stories. This creates three critical failures:
1. **Low Discovery & High Noise**: Messages are quickly buried under unrelated chat volume.
2. **Fraudulent Ownership Claims**: Anyone can message a well-meaning finder claiming "that's my AirPods" without providing proof.
3. **Severe Privacy Leaks**: Students post personal phone numbers, photos of government/student IDs with full details, and exact dorm room locations publicly.

**Finders Keepers?** resolves all three challenges by providing structured reports, approximate location zones, private verification questionnaires, cryptographic in-person handover codes, and role-based moderation.

---

## 3. Features
- **Dual Reporting**: Report both `LOST` (item missing) and `FOUND` (item discovered) with rich metadata.
- **Privacy-First Approximate Locations**: Campus landmarks and centroids (TT, SJT, Library, Foodys) with randomized ~65m blur circles. Private dorm addresses or classroom desk coordinates are never exposed publicly.
- **Genuine Ownership Verification Workflow**: When claiming a found item, claimants must provide private proof (distinguishing marks, internal contents, serial/card numbers, loss timeframe) that is **hidden from the public listing** and visible only to the finder.
- **Cryptographic In-Person Handover Codes**: Verification generates a 6-digit one-time code on the claimant's phone. When meeting on campus, the finder enters this code to complete the handover and transition the item into `RETURNED`.
- **Item State Machine**: Formal states (`LOST`, `FOUND`, `CLAIMED`, `VERIFIED`, `RETURNED`, `CLOSED`) with state transition validation and immutable audit event logging.
- **Rule-Based Potential Matching**: Heuristic engine scoring complementary Lost/Found items across category, keyword overlap, zone proximity, and incident date without pretending to be artificial intelligence.
- **Interactive Campus Map**: OpenStreetMap (`flutter_map`) integration rendering approximate campus zones without requiring paid API keys or credit cards.
- **Offline-First Resilience**: Automatic local draft saving (`DraftRepository`) restores incomplete reports if network drops or the app is killed. Submission idempotency (`submissionId`) prevents duplicate submissions.
- **Admin & Moderation Panel**: Real-time stats, flagged post review queue, and one-tap removal of spam or malicious listings.
- **Evaluator Testing Tools**: In-app role switcher (User $\leftrightarrow$ Admin) and one-tap demo campus data seeder to test all features immediately.

---

## 4. Technology Stack
- **Framework**: Flutter 3.16+ / Dart 3.2+
- **State Management**: Riverpod (`flutter_riverpod` 2.5+)
- **Backend & Database**: Cloud Firestore (with unlimited offline persistence enabled)
- **Authentication**: Firebase Authentication (Email/Password + campus registration numbers)
- **Cloud Storage**: Firebase Storage (with client-side image compression: 1200x1200px, 80% quality)
- **Mapping**: OpenStreetMap via `flutter_map` 7.0+ & `latlong2`
- **Local Persistence**: `shared_preferences` for offline report drafts and session cache

---

## 5. Architecture
The codebase strictly follows a clean layered architecture with separation of concerns:
```
lib/
├── core/         # Constants, campus coordinates, themes, typed exceptions, validators, fuzzy location
├── models/       # Immutable data models, state machines, audit events, verification claims
├── repositories/ # Abstracted data access layers (Auth, Items, Claims, Drafts, Notifications)
├── services/     # Firebase wrappers, image compression, heuristic matching, connectivity, mock seeder
├── providers/    # Riverpod state providers, filter notifiers, stream providers
├── features/     # Feature modules (Auth, Home, Items, Map, Claims, Profile, Notifications, Admin)
├── widgets/      # Reusable UI components (buttons, text fields, badges, dialogs, empty views)
└── routing/      # Centralized route generation and authentication guards
```

---

## 6. Database Structure

### Cloud Firestore Collections
1. **`users/{userId}`**:
   - `uid` (string): User identifier
   - `email` (string): Student campus email
   - `displayName` (string): Full name
   - `role` (string): `user` | `moderator` | `admin`
   - `campusRegistrationNumber` (string): Student ID (e.g. `23BCE1042`)
   - `reputationScore` (int): User trust score
   - `createdAt` (timestamp)
2. **`items/{itemId}`**:
   - `id` (string): Item identifier
   - `reportType` (string): `lost` | `found`
   - `status` (string): `lost` | `found` | `claimed` | `verified` | `returned` | `closed`
   - `title` (string): Short item name
   - `category` (string): e.g. `Electronics & Gadgets`, `Wallets & Purses`, `Student ID & Cards`
   - `description` (string): Visible physical description
   - `imageUrls` (array<string>): Firebase Storage URLs
   - `approximateLocation` (map): `zoneId`, `zoneName`, `approxLatitude`, `approxLongitude`, `approxRadiusMeters`, `areaDetail`
   - `incidentDateTime` (timestamp): Date/time item was lost or found
   - `reporterId` (string): User ID of reporter
   - `reporterName` (string): Display name of reporter
   - `activeClaimCount` (int): Count of pending claims
   - `verifiedClaimId` (string, optional): ID of winning verified claim
   - `isFlagged` (bool): True if flagged for moderator review
   - `flagReason` (string, optional): Student reporting reason
   - `submissionId` (string): Client-side UUID for idempotency
   - `createdAt`, `updatedAt` (timestamp)
3. **`items/{itemId}/events/{eventId}`** (Subcollection):
   - `id`, `itemId`, `eventType`, `previousStatus`, `newStatus`, `triggeredByUserId`, `triggeredByUserName`, `notes`, `timestamp`
4. **`claims/{claimId}`**:
   - `id` (string): Claim identifier
   - `itemId` (string): Related item ID
   - `itemReporterId` (string): Finder's user ID
   - `claimantId` (string): Claimant's user ID
   - `claimantName`, `claimantEmail` (string)
   - `status` (string): `pending` | `under_review` | `verified` | `rejected` | `cancelled`
   - **Private Verification Fields** (Protected by security rules):
     - `distinguishingFeatures` (string): Private marks, scratches, stickers
     - `hiddenContents` (string): Internal contents, card numbers, lock screen wallpapers
     - `serialOrIdentifier` (string): Partial serial or ID code
     - `lossCircumstance` (string): Where and when claimant lost it
     - `proofImageUrls` (array<string>): Receipts, older photos
   - `reviewedAt` (timestamp), `reviewerNotes` (string)
   - `handoverVerificationCode` (string, 6 digits): Generated upon verification
5. **`notifications/{notificationId}`**:
   - `id`, `userId`, `title`, `body`, `type`, `relatedItemId`, `relatedClaimId`, `isRead`, `createdAt`

---

## 7. Authentication Flow
- New users register with their campus email, password, full name, and student registration number.
- `AuthRepository` registers credentials with Firebase Auth and persists the extended student profile in Firestore `users/{uid}`.
- `AuthWrapper` continuously observes `authStateChangesProvider`:
  - Authenticated $\rightarrow$ Renders `MainNavigationScreen` (Home, Browse, Map, Claims, Profile).
  - Unauthenticated $\rightarrow$ Renders `LoginScreen`.
- Includes a secure password reset flow (`sendPasswordResetEmail`).

---

## 8. Lost/Found Workflow
1. User taps **I Lost an Item** (Red) or **I Found an Item** (Green) on Home.
2. Selects category and provides title and description.
3. Attaches up to 3 compressed photos from Camera or Gallery.
4. Selects campus landmark zone (e.g., *Technology Tower*, *SJT*, *Central Library*).
5. Chooses incident date and time.
6. The app automatically creates a local draft (`DraftRepository`) so data is never lost if the connection drops.
7. User taps **Publish Report to Campus Board**.
8. On success, the local draft is cleared, the item is committed to Firestore with an idempotency UUID, and an initial audit event is logged in `items/{itemId}/events`.

---

## 9. Ownership Verification Mechanism
This is the core anti-fraud pillar of **Finders Keepers?**. Traditional lost-and-found apps fail because anyone can click "Claim" and walk away with an item.

### The Problem Solved
If a student reports finding a black wallet at SJT, public viewers see only the exterior photo and general zone. They do not know:
- Which credit/debit cards are inside.
- The names on library receipts inside.
- Exact cash denominations.
- Faint interior engravings or scratches.

### The Verification Workflow
1. **Private Questionnaire**: The claimant must answer private questions:
   - *Distinguishing Marks*: e.g., "Cartoon astronaut sticker on rear bottom right."
   - *Hidden Contents*: e.g., "SBI Global card ending in 4108 and a 2024 Metro pass."
   - *Serial / Passcode Hint*: e.g., "Lockscreen wallpaper is a golden retriever; serial ends in 91EX."
   - *Loss Circumstance*: e.g., "Left on 2nd floor lab bench 214 after 11 AM CS class."
2. **Claim Privacy**: Cloud Firestore security rules strictly block other users from reading `claims/{claimId}`. Only the item finder and system admins can view the claimant's answers.
3. **Finder Review**: The finder opens **Review Submitted Claims** and compares the answers directly against the physical item in their possession.
4. **Single-Winner Approval Guard**: Only one claim can be verified. Simultaneous conflicting claims are locked out.
5. **In-Person Handover Security Code**:
   - Approving the claim generates a random 6-digit code (e.g. `482915`) displayed **only on the verified owner's screen**.
   - When meeting on campus, the owner presents this code to the finder.
   - The finder enters the code into the app.
   - The app confirms the match, marks the item as `RETURNED`, logs the audit event, and archives the listing.

---

## 10. Item State Machine
State transitions are strictly enforced in `ItemStateMachine` and Firestore security rules:
```
  LOST ──────────────────────┐
   │                         │
   ▼                         ▼
 FOUND ──► CLAIMED ──► VERIFIED ──► RETURNED (Terminal)
   │          │          ▲
   │          ▼          │
   └───────► CLOSED ◄────┘ (Terminal)
```
- **`lost`**: Reported as missing by original owner.
- **`found`**: Reported as discovered by a campus finder.
- **`claimed`**: An ownership claim has been submitted and is under review.
- **`verified`**: Finder reviewed private proof, approved claim, and generated handover code.
- **`returned`**: Physical handover verified via 6-digit code. Terminal state.
- **`closed`**: Withdrawn or archived by reporter or administrator.

---

## 11. Privacy & Security

### Approximate Location Privacy
- **No Precise GPS Tracking**: Storing raw GPS coordinates exposes student movements, classroom schedules, and dorm rooms.
- **Zone Blur Circles**: The system maps locations to named campus zones (10 predefined landmarks at VIT) with an intentional ~65m fuzzy offset circle.
- **Documentation**: Exact home addresses or dorm room numbers are strictly disallowed in public fields.

### Firebase Security Rules
- Unauthenticated access is completely blocked for mutating operations.
- `items`: Anyone can read public listings, but only the original reporter or admin can delete or edit them.
- `claims`: Only the claimant, finder, and admin can read private proof fields.
- `events`: Append-only audit trail; existing records cannot be edited or deleted.

---

## 12. Offline / Network Failure Handling
- **Firestore Offline Persistence**: Unlimited cache enabled (`Settings.CACHE_SIZE_UNLIMITED`). Users can browse previously loaded listings even in campus basements or elevators with zero connectivity.
- **Draft Auto-Preservation**: Form inputs and selected image paths are auto-saved to device storage on every keystroke. If the app closes or the network drops during report creation, returning to the report screen prompts "Unfinished draft restored from local storage."
- **Submission Idempotency**: Each submission generates a client UUID `submissionId`. If an interrupted request retries, Firestore checks `where('submissionId', isEqualTo: id)` to prevent duplicate posts.
- **Connectivity Monitor**: Real-time banner warns: *"Offline Mode — Viewing cached reports. New drafts will save locally."*

---

## 13. Search & Matching Logic
- **Search & Filters**: Debounced keyword search across title and description, combined with multi-criteria filters (Report Type, Category, Status, Campus Zone).
- **Rule-Based Potential Match Engine (`MatchingService`)**:
  - Compares complementary reports (`LOST` $\leftrightarrow$ `FOUND`).
  - **Category (40%)**: Identical category check.
  - **Keywords (30%)**: Tokenized text overlap excluding common stop words.
  - **Location (20%)**: Identical campus zone or Haversine distance < 500m.
  - **Time (10%)**: Incident dates within 24 hours to 7 days.
  - **Output**: Items with score $\ge 45\%$ show a **Potential Match** badge with an explicit score percentage and transparent breakdown of matching factors.

---

## 14. Notifications
- Real-time in-app Notification Center (`notifications/{id}`) tracking:
  - New ownership claims received on your found item.
  - Claim approvals, rejections, and handover code generation.
  - Potential match detections between lost and found items.
  - Handover completions.

---

## 15. Admin / Moderation
- Users with role `admin` or `moderator` have access to the **Admin Moderation Panel**:
  - Live campus metrics: Total reports, lost count, found count, flagged count.
  - Flagged items queue: Review student reports regarding spam, offensive pictures, or fraudulent claims.
  - Take-down actions: Permanently remove violating posts from the campus board.
- **Evaluator Switcher**: On the Profile screen, evaluators can tap **Enable Admin Role** to test the moderation panel immediately without backend configuration.

---

## 16. Firebase Setup Guide
1. Create a project in [Firebase Console](https://console.firebase.google.com/).
2. Enable **Authentication** (Email/Password).
3. Create a **Cloud Firestore** database and deploy `firestore.rules`.
4. Create a **Firebase Storage** bucket and deploy `storage.rules`.
5. Add Android app (`com.codechefvit.finderskeepers`) and download `google-services.json` into `android/app/`.
6. Add iOS app and download `GoogleService-Info.plist` into `ios/Runner/`.

---

## 17. Running Locally
```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run unit and integration tests
flutter test

# 3. Launch application
flutter run
```
*Note*: If Firebase is not yet configured, the app automatically runs in **Demo Mode**, pre-populated with realistic VIT campus items, functional verification flows, and offline draft handling.

---

## 18. Building the Release APK
```bash
flutter build apk --release
```
The output binary will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 19. Known Limitations
- **Camera on Emulators**: Requires a physical device or virtual scene configuration in Android Studio to capture camera photos.
- **FCM Push Credentials**: In-app notifications are fully operational; background OS-level APNs/FCM pushes require platform developer keys.

---

## 20. Future Improvements
- RFID / NFC integration for student ID cards.
- Automated WhatsApp notifications via Twilio for students without the app installed.
- Multi-campus federation across other university chapters.
