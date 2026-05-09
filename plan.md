# Career Navigator — Step-by-step Implementation Plan (Plan.md)

This plan is designed to implement **Career Navigator** (web + backend) using:
- **NestJS (TypeScript)** + **Prisma** + **PostgreSQL**
- **Docker + Kubernetes** for containerization/orchestration
- **Swagger** for API documentation
- **OpenSearch** + **pgvector** for search/recommendations
- **Redis + BullMQ** for caching/async jobs
- **MinIO** for object storage (CV/resume uploads)
- **Self-hosted Ollama** for AI features (CV parsing, job + course recommendations, mock interviews)
- **Agora Web SDK** for video calling
- **Socket.IO** for real-time chat (typing/online status)

UI reference & branding:
- Logo: `logo/logo.png`
- UI reference screenshots (dashboard style):
  - `9ea55807-657c-46de-8781-01b652b1b020.jpeg`
  - `89ae2ce6-25b7-4619-a21c-c14d4829a2f0.jpeg`

---

## 1) Milestones (high-level roadmap) — status tracked in `plan.md`

> Status markers:
> - Not started: `[ ]`
> - In progress: `[/]`
> - Completed: `[x]`

### Milestone 0 — Project setup & foundations
- [x] 0.1 Create repo structure (frontend + backend + infra)
- [x] 0.2 Establish shared conventions (lint/format/typecheck)
- [x] 0.3 Add environment variable strategy (`.env.example`)
- [x] 0.4 Set up Swagger in NestJS and verify `/api-docs` renders

### Milestone 1 — Core auth + profile (required security)
- [/] 1.1 Implement registration + OTP email verification (scaffolded routes/controllers; OTP logic + persistence pending)
- [ ] 1.2 Implement JWT login (access + refresh) + refresh rotation
- [ ] 1.3 Implement password reset flow (expiring reset token)
- [ ] 1.4 Soft delete account (deactivation)
- [ ] 1.5 Implement theme preference (persisted: dark/light)

### Milestone 2 — Profile CRUD + resume builder/scanning
- [ ] 2.1 Implement profile CRUD (personal info, education, work experience)
- [ ] 2.2 Implement resume/CV upload (MinIO)
- [ ] 2.3 Add resume builder (structured templates)
- [ ] 2.4 Enqueue CV scan jobs to BullMQ
- [ ] 2.5 Extract structured CV info via AI (Ollama) and persist to DB

### Milestone 3 — Jobs system + mentor matching
- [ ] 3.1 Implement job listing (filters + search + pagination)
- [ ] 3.2 Implement job apply (cover letters)
- [ ] 3.3 Implement mentor search (name/skills/expertise)
- [ ] 3.4 Implement job demand ingestion pipeline (normalize into OpenSearch)
- [ ] 3.5 Implement recommendation ranking (AI + vector retrieval)
- [ ] 3.6 Trigger real-time notifications on matching jobs/certifications

### Milestone 4 — Real-time chat + notifications
- [ ] 4.1 Implement REST fallback for conversations + message history
- [ ] 4.2 Implement Socket.IO events (auth, send_message, new_message, typing, online/offline)
- [ ] 4.3 Implement notifications CRUD + mark read
- [ ] 4.4 Integrate worker events -> notification fanout

### Milestone 5 — AI features (career path only assistant)
- [ ] 5.1 Enforce AI policy boundaries (career-path only)
- [ ] 5.2 Implement AI endpoints (`/ai/chat`, `/ai/mock-interview`, course recommendations)
- [ ] 5.3 Store AI outputs with explanations for transparency

### Milestone 6 — Video calling (Agora)
- [ ] 6.1 Implement video session creation/join (auth checks + Agora token minting)
- [ ] 6.2 Store session history metadata (optional)
- [ ] 6.3 Integrate Agora client UI in the dashboard style

### Milestone 7 — Admin + analytics
- [ ] 7.1 Admin endpoints (user management, feedback moderation)
- [ ] 7.2 Analytics aggregation (engagement metrics/events summary)
- [ ] 7.3 Add RBAC middleware/guards

### Milestone 8 — Kubernetes + performance hardening
- [ ] 8.1 Containerize all services
- [ ] 8.2 Deploy on Kubernetes (HPA for API + realtime gateway, StatefulSets for Postgres/OpenSearch/MinIO)
- [ ] 8.3 Ensure WebSocket scaling across pods (Socket.IO adapter)
- [ ] 8.4 Verify rate limiting + request validation in production mode

---

## 2) Step-by-step implementation plan (detailed)

## Phase A — Repository scaffolding (Day 1)
1. Create directories:
   - `/apps/web` (frontend)
   - `/apps/api` (NestJS backend)
   - `/infra/k8s` (helm/kustomize manifests)
   - `/infra/docker` (Dockerfiles)
2. Add base tooling:
   - ESLint/Prettier (frontend and backend)
   - TypeScript strict mode
3. Create `.env.example` for each service:
   - JWT secrets
   - DB URLs
   - Redis URLs
   - OpenSearch credentials
   - MinIO credentials
   - Agora / Brevo keys

**UI theming requirements (based on screenshots):**
- Dashboard layout:
  - left sidebar + top search bar + content cards
- Light/dark mode toggle (persist user preference)
- Use the dashboard style in the screenshots as visual reference:
  - cards, rounded panels, subtle shadows, clear typography

## Phase B — Backend base (Day 2)
1. NestJS project bootstrap:
   - modules layout
   - global ValidationPipe (input validation)
   - CORS strict allowlist
2. Swagger/OpenAPI:
   - configure Swagger at `/api-docs`
   - document DTO schemas for every endpoint
3. Implement response standardization:
   - `ResponseFactory` (Factory pattern)

## Phase C — Auth + security foundation (Days 3–5)
1. Users table via Prisma schema:
   - users, roles, deleted_at, verification fields
2. Implement:
   - `POST /auth/register`
   - `POST /auth/verify-email` (OTP)
   - `POST /auth/resend-code`
   - `POST /auth/login`
   - `POST /auth/refresh` (rotation)
   - password reset:
     - `POST /auth/forgot-password`
     - `POST /auth/reset-password`
   - `POST /auth/change-password`
   - `POST /auth/logout`
   - `DELETE /auth/delete-account` (soft delete)
3. Security checklist (must be satisfied):
   - bcrypt password hashing (salt + hash)
   - JWT access tokens with expiration
   - refresh token rotation with secure storage + revoke on reuse
   - SQL injection prevention:
     - Prisma parameterized queries by default
   - rate limiting on sensitive endpoints
   - HTTPS-ready via ingress/TLS, secure cookies, HSTS
4. Add RBAC guards:
   - Job Seeker / Mentor / Admin

## Phase D — Profile CRUD + theme persistence (Days 6–8)
1. Implement `GET /profile/me`, `PUT /profile/setup`
2. Implement theme:
   - `GET /profile/theme`, `PUT /profile/theme`
   - persist preference in DB
3. Profile picture upload:
   - `PUT /profile/picture` (URL)
   - `POST /upload/picture` (file -> MinIO)

## Phase E — Education + Work Experience CRUD (Days 9–10)
1. Education CRUD:
   - `POST /profile/education`
   - `PUT /profile/education/:id`
   - `DELETE /profile/education/:id`
2. Work experience CRUD:
   - `POST /profile/work-experience`
   - `PUT /profile/work-experience/:id`
   - `DELETE /profile/work-experience/:id`

## Phase F — Resume Builder + CV Scan (Days 11–13)
1. Resume builder:
   - allow structured sections and export previews (frontend)
   - persist templates
   - backend endpoint: `POST /resume/builder`
2. Upload:
   - `POST /resume/upload` -> MinIO
3. Scan:
   - `POST /resume/scan` -> enqueue BullMQ job `cv.parse`
   - `GET /resume/status/:id`
4. AI extraction via Ollama:
   - parse resume into structured schema (skills, experience, education, targets)
   - store extracted results + confidence scores
5. After parsing:
   - trigger recommendation refresh jobs:
     - `recommend.refresh` (BullMQ)

## Phase G — Jobs + Mentors + Recommendations (Days 14–18)
1. Job listings:
   - `GET /jobs` (filters, search, pagination)
   - `GET /jobs/:id`
2. Apply:
   - `POST /jobs/:id/apply` (cover letter)
3. Job demand ingestion:
   - normalize jobs and requirements into OpenSearch index
   - update skills taxonomy
4. Recommendations:
   - `GET /recommendations/my`
   - compute ranking using:
     - vector retrieval (pgvector/OpenSearch)
     - AI reranker (Ollama)
   - store explanations for each recommended job
5. Mentors search:
   - `GET /mentors/search` (name, skills, expertise)
   - `GET /mentors/:id`
6. Mentorship requests:
   - `POST /mentor-requests`
   - `GET /mentor-requests/my`
   - accept/reject endpoints

## Phase H — Course recommendations (Days 19–20)
1. AI course mapping:
   - `GET /recommendations/my/courses`
2. Providers integration (start with curated mapping, not full scraping):
   - Coursera, Simplilearn, edX, Udemy, Alison
3. Store:
   - course provider, course id/url, why it matches, prerequisites

## Phase I — Real-time chat + notifications (Days 21–24)
1. REST fallback:
   - `GET /chat/conversations`
   - `GET /chat/messages/:conversationId`
   - `POST /chat/messages`
2. Socket.IO:
   - typing indicators
   - online/offline status
   - new messages broadcast
3. Notifications:
   - `GET /notifications`
   - `POST /notifications/:id/read`
   - `POST /notifications/read-all`
4. Worker-driven notifications:
   - on recommendation changes, new matching jobs/certs

## Phase J — AI chat bot (career path constrained) (Days 25–26)
1. Endpoint:
   - `POST /ai/chat`
2. Policy:
   - enforce career-path-only responses (jobs/skills/education/mentorship)
   - avoid unrelated content
3. Input validation:
   - DTOs + rate limiting
4. Save chat sessions:
   - conversation history for user review (optional)

## Phase K — Mock interview with AI feedback (Days 27–28)
1. Endpoint:
   - `POST /ai/mock-interview`
2. Flow:
   - AI generates rubric, interviewer questions
   - user submits answers
   - AI returns feedback:
     - strengths, gaps, recommended improvements
3. Persist feedback:
   - `feedback` + analytics events

## Phase L — Video calling with Agora (Days 29–30)
1. Endpoint:
   - `POST /video/start-session`
   - `POST /video/join-session`
   - `POST /video/end-session`
2. Backend:
   - verify JWT + roles
   - return Agora token + channel details
3. Frontend:
   - integrate Agora Web SDK into the dashboard/video UI

## Phase M — Admin + analytics (Days 31–33)
1. Admin:
   - `GET /admin/users`
   - `PATCH /admin/users/:id`
   - `GET /admin/feedback`
2. Analytics dashboard backend:
   - endpoints feeding charts:
     - engagement metrics
     - conversion rates (job applications)
     - active users

## Phase N — Docker + Kubernetes (Days 34–36)
1. Create Dockerfiles for:
   - web-frontend
   - api-service
   - worker-service
   - ai-orchestrator (optional)
2. Kubernetes manifests:
   - Deployments / StatefulSets / Services
   - Ingress + TLS via cert-manager
3. HPA:
   - api-service scaling
   - realtime-gateway scaling
4. Persistence:
   - PVs for Postgres/OpenSearch/MinIO
5. WebSocket scaling:
   - Socket.IO Redis adapter configuration

## Phase O — Testing + verification (Days 37–40)
1. Backend tests:
   - unit tests: services (AuthService, RecommendationService)
   - integration tests: controller endpoints with DB test containers
2. Security tests:
   - JWT expiration + refresh rotation
   - OTP expiry
   - rate limiting behavior
   - input validation failures
3. Performance:
   - load test critical endpoints:
     - `/auth/login` (throttle)
     - `/jobs` search
     - socket handshake
4. Swagger validation:
   - ensure every endpoint appears with correct schemas
5. End-to-end smoke tests:
   - register -> OTP -> login
   - create profile -> upload resume -> CV parse -> recommendations
   - chat message -> notification
   - video token -> session join

---

## 3) Deliverables checklist (what you’ll have at the end)

- [ ] `plan.md` committed
- [ ] Working web frontend with:
  - dashboard layout matching the uploaded references
  - logo from `logo/logo.png`
  - light/dark mode toggle
  - animations using Framer Motion
  - 3D accents using Three.js (lazy-loaded)
- [ ] NestJS backend with:
  - Swagger at `/api-docs`
  - Auth (OTP, JWT, refresh rotation, reset flow, soft delete)
  - Profile CRUD + resume upload/scan
  - Jobs search/filter/apply
  - Mentors search + mentor requests
  - Recommendations (AI + vector retrieval)
  - Chat via Socket.IO + REST fallback
  - Notifications + feedback + admin endpoints
- [ ] Async worker pipeline:
  - BullMQ jobs for CV parse + ingestion + recommendations refresh
- [ ] AI runtime:
  - self-hosted Ollama orchestrated via ai-orchestrator service
- [ ] Infra:
  - Docker images
  - Kubernetes manifests and working ingress/TLS
- [ ] Validation:
  - automated tests + manual smoke tests
  - security edge-case verification

---

## 4) Notes on using the uploaded images
- Use the images as design reference for:
  - sidebar layout
  - card-based dashboard panels
  - typography scale and spacing
  - “dashboard analytics” look (second image)
  - light mode styling and component silhouettes
- The logo will be used across:
  - login/register header
  - sidebar brand area
  - top-left navbar area
