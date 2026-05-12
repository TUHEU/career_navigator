# Career Navigator — Project Reset Plan (from beginning)

## References
- UI reference: `Dashboard for students.jpeg`, `Skillset Dashboard.jpeg`
- Logo: `logo/logo.png`
- Source context: `project description.pdf`

## Target Tech Stack (Web + Scalable Backend)
- **Frontend (Web):** Next.js (React) + TypeScript
  - UI/branding: Tailwind-style design system (dashboard layout from screenshots)
  - Animations: **Framer Motion**
  - 3D accents: **Three.js** (via React Three Fiber), lazy-loaded
  - Realtime: Socket.IO client
  - Video: Agora Web SDK
- **Backend:** NestJS (TypeScript) + Prisma + PostgreSQL
  - API docs: **Swagger** (`/api-docs`)
  - Auth: JWT + refresh token rotation + OTP email verification
  - Search: OpenSearch + pgvector (recommendation embeddings)
  - Cache + async jobs: Redis + BullMQ
  - Object storage: MinIO (CV/resume/profile media)
  - AI runtime: self-hosted **Ollama**
- **Infra:** Docker + Kubernetes
  - Ingress + TLS (cert-manager)
  - HPA for API + realtime gateway
  - StatefulSets for Postgres/OpenSearch/MinIO, Redis deployments

---

## Milestone Status System (for tracking)
- Not started: `[ ]`
- In progress: `[/]`
- Completed: `[x]`

---

## Milestones (fresh start)
### Milestone 0 — Foundations & repo setup
- [x] 0.1 Create repo structure (web + backend + infra)
- [/] 0.2 Add tooling (lint/format/typecheck) and base TS config (added tsconfig + prettier/editorconfig + eslint config + infra skeleton)
- [x] 0.3 Add `.env.example` templates
- [ ] 0.4 Initialize backend + Swagger at `/api-docs`

### Milestone 1 — Core Auth + Security
- [ ] 1.1 Registration + OTP email verification
- [ ] 1.2 JWT access + refresh rotation
- [ ] 1.3 Password reset flow (expiring tokens)
- [ ] 1.4 Soft delete / deactivation
- [ ] 1.5 Theme preference persistence (dark/light)

### Milestone 2 — Profile CRUD + Resume/CV
- [ ] 2.1 Personal info + Education CRUD
- [ ] 2.2 Work experience CRUD
- [ ] 2.3 Profile picture + CV upload to MinIO
- [ ] 2.4 Resume builder (structured templates)
- [ ] 2.5 CV scan orchestration (BullMQ + Ollama extraction)

### Milestone 3 — Jobs system + Mentor matching + Recommendations
- [ ] 3.1 Job browse with filters + search + pagination
- [ ] 3.2 Apply with cover letters
- [ ] 3.3 Mentor search by skills/expertise
- [ ] 3.4 Ingest job demand into OpenSearch index
- [ ] 3.5 AI reranking + explanations + notifications fanout

### Milestone 4 — Realtime Chat + Notifications
- [ ] 4.1 REST fallback for conversations + message history
- [ ] 4.2 Socket.IO events (typing, online/offline, new messages)
- [ ] 4.3 Notifications CRUD + mark read
- [ ] 4.4 Worker-driven notification updates

### Milestone 5 — Career-path restricted AI Chat + Interview prep
- [ ] 5.1 Enforce “career-path-only” policy
- [ ] 5.2 AI chat endpoint (`/ai/chat`)
- [ ] 5.3 Mock interview endpoint (`/ai/mock-interview`)
- [ ] 5.4 Course recommendations mapping (Coursera/Simplilearn/edX/Udemy/Alison)

### Milestone 6 — Video calling (Agora)
- [ ] 6.1 Start/join/end video sessions (token minting)
- [ ] 6.2 Store session metadata (optional)
- [ ] 6.3 UI integration in dashboard style

### Milestone 7 — Admin + Analytics
- [ ] 7.1 Admin user management + feedback moderation
- [ ] 7.2 Analytics endpoints for engagement metrics
- [ ] 7.3 RBAC guard enforcement

### Milestone 8 — Docker + Kubernetes + Performance hardening
- [ ] 8.1 Containerize services
- [ ] 8.2 Kubernetes deployments + services + ingress/TLS
- [ ] 8.3 WebSocket scaling strategy (Socket.IO + adapter)
- [ ] 8.4 Rate limiting + production hardening validation

---

## Implementation Checklist (major steps)
- [ ] Create directories: `/apps/web`, `/apps/api`, `/infra/docker`, `/infra/k8s`
- [ ] Initialize backend with NestJS + Swagger
- [ ] Add Prisma schema + migrations strategy
- [ ] Implement auth flows (OTP → activate → JWT login → refresh rotation)
- [ ] Implement profile CRUD + resume upload + CV scan pipeline
- [ ] Implement job/mentor search + OpenSearch indexing
- [ ] Implement AI recommendations and AI chat policy constraints
- [ ] Implement Socket.IO chat + notifications
- [ ] Implement Agora video calling token service
- [ ] Add admin + analytics endpoints
- [ ] Add Dockerfiles + Kubernetes manifests
- [ ] Run lint/test/build and smoke test end-to-end

---

## UI/Theming Notes (from screenshots)
Use these references as style guide:
- Layout: left sidebar + top bar + card-based dashboards
- Provide dark/light mode toggle (persisted user preference)
- Apply Framer Motion for page transitions and micro-interactions
- Add light Three.js accents only where it won’t block performance (lazy-load)

Logo usage:
- Brand header/sidebar: `logo/logo.png`
- Authentication screens header/footer: `logo/logo.png`
