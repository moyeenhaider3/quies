# Roadmap: Quies

## Overview

Quies is built in 5 phases, progressing from core infrastructure through interactive features to final polish. Phase 1 (Foundation) and Phase 2 (Quote Feed) are complete. The next agent picks up at Phase 3 (Interactions & Mood), which adds bookmarking, like toggling, mood-based content matching, and completes the core user loop. Phase 4 adds settings and customization. Phase 5 adds behavioral design touches and comprehensive testing.

## Phases

- [x] **Phase 1: Foundation & Onboarding** - Core infrastructure, DI, routing, theme, and complete onboarding flow
- [x] **Phase 2: Quote Feed** - Quote data layer, feed bloc, swipeable card UI, share integration
- [x] **Phase 3: Interactions & Mood** - Bookmarking, like toggling, mood check-in, content matching algorithm
- [x] **Phase 4: Settings & Customization** - Settings screen, theme switching, font/size options, notifications, preference reset
- [ ] **Phase 5: Polish & Behavioral Design** - Breathing prompts, session awareness, test coverage, animation refinement

## Phase Details

<details>
<summary>✅ Phase 1: Foundation & Onboarding (COMPLETE)</summary>

### Phase 1: Foundation & Onboarding

**Goal**: Establish project structure, local storage, DI, routing, theme, and complete onboarding flow
**Depends on**: Nothing (first phase)
**Requirements**: ONBRD-01, ONBRD-02, ONBRD-03, ONBRD-04, TECH-01, TECH-02, TECH-03, TECH-04, TECH-05
**Success Criteria** (what must be TRUE):

1. App launches with onboarding on first run
2. User can complete or skip the onboarding quiz
3. Preferences persist — subsequent launches skip onboarding
4. go_router redirect guard works correctly
5. DI container resolves all registered dependencies
   **Plans**: 1 plan

Plans:

- [x] 01-01: Project setup, theming, local storage, onboarding UI & logic

</details>

<details>
<summary>✅ Phase 2: Quote Feed (COMPLETE)</summary>

### Phase 2: Quote Feed

**Goal**: Deliver swipeable full-screen quote cards from local JSON data with share functionality
**Depends on**: Phase 1
**Requirements**: FEED-01, FEED-02, FEED-03, FEED-04, DATA-01, SHAR-01
**Success Criteria** (what must be TRUE):

1. User sees beautiful full-screen quote cards after onboarding
2. Quotes load from local JSON asset
3. Cards display quote text, author, and category badge
4. User can share a quote via system share sheet
5. Vertical PageView with smooth swiping
   **Plans**: 1 plan

Plans:

- [x] 02-01: Quote data layer (entity, model, datasource, repository), FeedBloc, QuoteFeedScreen, QuoteCard, share integration

</details>

### Phase 3: Interactions & Mood

**Goal**: Add bookmark/like toggling with state persistence, mood check-in UI, and content matching algorithm that personalizes the feed
**Depends on**: Phase 2
**Requirements**: ONBRD-05, FEED-05, BOOK-01, BOOK-02, BOOK-03, BOOK-04, BOOK-05, MOOD-01, MOOD-02, MOOD-03, DATA-02, DATA-03, DATA-04
**Success Criteria** (what must be TRUE):

1. User can tap heart icon to like a quote — icon toggles filled/outline
2. User can tap bookmark icon to save a quote — icon toggles filled/outline
3. Bookmarked quotes persist across app restarts (Hive)
4. User can view a saved/bookmarked quotes collection
5. Mood check-in allows user to set current mood
6. Feed ordering reflects mood + time-of-day + onboarding preferences
   **Plans**: TBD (estimated 3 plans)

Plans:

- [x] 03-01: Like & bookmark state management (FeedBloc events, Hive persistence, QuoteCard toggle UI)
- [x] 03-02: Bookmarks collection screen (saved quotes list, remove bookmark, navigation)
- [x] 03-03: Mood check-in UI, content matching algorithm, time-of-day awareness, preference integration

### Phase 4: Settings & Customization

**Goal**: Full settings screen with theme switching, font selection, text sizing, notification scheduling, and preference management
**Depends on**: Phase 3
**Requirements**: SETT-01, SETT-02, SETT-03, SETT-04, SETT-05, SETT-06, SETT-07, SETT-08
**Success Criteria** (what must be TRUE):

1. Settings screen accessible from feed
2. User can toggle dark/light theme and see immediate change
3. User can select quote display font from preset options
4. User can adjust quote text size
5. User can enable daily reminder notifications
6. User can re-take onboarding quiz
7. Settings persist via Hive across restarts
   **Plans**: TBD (estimated 2 plans)

Plans:

- [x] 04-01: Settings screen UI, theme switching (ThemeCubit), font/size options, Hive persistence
- [x] 04-02: Daily reminder notifications (flutter_local_notifications, time picker, permission handling)

### Phase 5: Polish & Behavioral Design

**Goal**: Add mindful behavioral design patterns (breathing prompts, session awareness), refine animations, and achieve comprehensive test coverage
**Depends on**: Phase 4
**Requirements**: FEED-06, TECH-06, BEHV-01, BEHV-02, BEHV-03, BEHV-04
**Success Criteria** (what must be TRUE):

1. Breathing prompts appear every 5-7 swipes in the feed
2. App shows gentle "welcome back" on resume after inactivity
3. No gamification elements exist (verified audit)
4. All blocs/cubits have unit tests
5. Key screens have widget tests
6. Animations feel smooth and premium
   **Plans**: TBD (estimated 2 plans)

Plans:

- [x] 05-01: Breathing prompt widget, feed insertion logic, session awareness, gentle progress indicators
- [ ] 05-02: Comprehensive test suite (deferred — partially covered by Phase 6 Plan 04)

### Phase 6: MVP — Quotes + Music (iTunes)

**Goal**: Add live quote fetching from Quotable API, music previews from iTunes Search API with genre-based selection, audio playback, and offline caching — for a ₹0 Play Store MVP
**Depends on**: Phase 5 Plan 01
**Requirements**: MVP-QUOTE-01, MVP-MUSIC-01, MVP-MUSIC-02, MVP-CACHE-01, MVP-BLOC-01, MVP-UI-01, MVP-UI-02, MVP-AUDIO-01, MVP-TEST-01, MVP-POLISH-01
**Success Criteria** (what must be TRUE):

1. User can select from 5 genres (inspirational, love, peace, sad, success)
2. Quote loads from Quotable API by genre tag
3. Music preview loads from iTunes Search API by mapped keyword
4. Audio preview plays for 10-15 seconds then auto-stops
5. previewUrl validation — skips tracks without preview
6. Combined result cached per genre for offline fallback
7. No API keys, no auth, no backend required
8. Error states handled (no internet, empty results, null preview)
   **Plans**: 4 plans

Plans:

- [ ] 06-01: Domain models (RemoteQuote, MusicPreview) + API services (QuoteApiService, MusicService) + genre mapping
- [ ] 06-02: CacheService (Hive) + QuoteMusicBloc (events, states, parallel fetch, cache fallback)
- [ ] 06-03: GenreSelectionScreen + QuoteMusicScreen + AudioPlayerWidget + routes
- [ ] 06-04: Error handling hardening + offline mode + UI polish + unit tests

### Phase 8: Audio Experience & Visual Refinements

**Goal**: Enable audio by default with dynamic song previews (7-15s), unique per-quote music via combined mood+tag search, word-by-word quote animation, redesign header layout with vertical icon arrangement on RIGHT side, and harmonize UI colors with quote cards
**Depends on**: Phase 7
**Requirements**: AUD-01, AUD-02, ANIM-01, UI-01, UI-02, UI-03
**Success Criteria** (what must be TRUE):

1. Audio is enabled by default on app launch
2. Each quote gets a different song, even when sharing the same tag
3. Music search uses combined mood+tag query with mood-dependent content type (vocal vs instrumental)
4. Preview duration is dynamic: 1s per 10 chars, clamped to 7-15s range
5. Audio transitions use quick fade (0.3s out, 0.2s silence, 0.3s in)
6. Quote text animates word-by-word with smooth slide-in effect
7. Gear and book icons are arranged vertically on RIGHT side of header
8. Mood selector is on LEFT side of header
9. Quote text is centered in header
10. Card design (background, colors) harmonizes with quote card theme
    **Plans**: 5 plans (3 waves)

Plans:

- [ ] 08-01: Audio Default Preference + Dynamic Duration + Fade Transitions (AUD-01)
- [ ] 08-02: Unique Song Selection + Combined Mood+Tag Keywords (AUD-02)
- [x] 08-03: Theme & Header Redesign — icons LEFT (UI-01, UI-02, UI-03) [completed, needs correction]
- [ ] 08-04: Word-by-Word Animation (ANIM-01)
- [ ] 08-05: Header Icon Position Fix — icons LEFT → RIGHT (UI-01 correction)

### Phase 9: UX Polish & Author Experience

**Goal**: Replace all loading spinners with theme-aware shimmer skeletons, add tag visibility to mood selector bottom sheet, and build an author detail modal with quote browsing
**Depends on**: Phase 8
**Requirements**: UX-SHIMMER-01, UX-TAG-01, AUTH-01, AUTH-02
**Success Criteria** (what must be TRUE):

1. No `CircularProgressIndicator` exists anywhere in the app — all loading states use shimmer
2. Shimmer mimics real quote card layout (text lines, author, tags, action buttons)
3. Shimmer adapts to dark/light theme automatically
4. Mood selector bottom sheet shows mapped tag chips under each mood
5. Tapping a mood applies all its tags (broad); tapping individual tag narrows filter
6. Author detail modal opens via: tap author name on card + author button in action row
7. Author modal shows name, description, bio, quote count + horizontal quote carousel
8. Tapping a quote in the carousel opens full-screen detail view
9. `authorSlug` is available on `Quote` entity for reliable author lookup
   **Plans**: 4 plans (2 waves)

Plans:

- [ ] 09-01: Shimmer primitives + replace all 7 CircularProgressIndicator instances
- [ ] 09-02: Mood selector — tag chips under moods, individual tag tap filtering
- [ ] 09-03: Quote entity authorSlug + RemoteQuote.toQuote() mapping fix
- [ ] 09-04: Author detail modal + author access points on QuoteCard + quote carousel

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6

| Phase                         | Plans Complete | Status      | Completed  |
| ----------------------------- | -------------- | ----------- | ---------- |
| 1. Foundation & Onboarding    | 1/1            | Complete    | 2025-01-17 |
| 2. Quote Feed                 | 1/1            | Complete    | 2025-01-19 |
| 3. Interactions & Mood        | 3/3            | Complete    | 2025-02-13 |
| 4. Settings & Customization   | 2/2            | Complete    | 2025-02-13 |
| 5. Polish & Behavioral Design | 1/2            | In Progress | -          |
| 6. MVP — Quotes + Music       | 0/4            | Planned     | -          |
| 7. API + Filters              | 0/5            | Planned     | -          |
| 8. Audio & Visual Polish      | 1/5            | In Progress | -          |
| 9. UX Polish & Author         | 0/4            | Planned     | -          |

---

_Roadmap created: 2025-01-14_
_Last updated: 2026-02-13 after Phase 6 planning_
