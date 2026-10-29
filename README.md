<p align="center">
  <img src="Kanvacol%20logo%20(square%2C%20LinkedIn%20size)%401x.png" alt="KanvaCol logo" width="120">
</p>
<h1 align="center">KanvaCol</h1>
<p align="center"><b>Where ideas are drawn, protected and taken further, together.</b></p>

KanvaCol is a collaborative canvas where people solve real-world problems by drawing. Sketch a workflow, a system design or a fix for an everyday problem, get feedback from AI and from the community, and build on each other's work, with every contributor credited.

> **Status:** Early development. The features below describe what we are building toward; not all of them work yet.

---

## Why KanvaCol

Most good ideas start as a rough sketch, and most problems are easier to solve when you can see them. KanvaCol gives people a shared place to:

- **Draw the problem and the solution.** No diagramming skills or special syntax needed.
- **Get AI feedback.** AI reviews your drawing, points out gaps and unnecessary complexity, and suggests alternatives.
- **Build on each other's work.** Clone someone's canvas, improve it, and send your version back to the owner. The owner always decides what happens to their original.
- **Learn from a growing library.** Every published solution joins a public gallery that others can learn from and improve.

## Features

| Area | What it does |
| --- | --- |
| Canvas | Create, edit and save drawings. Every save is kept as a version you can go back to. |
| Gallery | Browse published canvases. Each one shows its owner's chosen version. |
| Contributions | Clone a canvas, edit your copy, and request a review from the owner. The owner compares both versions side by side and accepts or rejects the change. |
| AI review | Ask AI to review a canvas before or after saving and get recommendations you can apply. |
| Community | Comment on drawings, vote on published work, and follow other problem solvers. |
| Credit | Everyone whose work is accepted is named in the canvas's history. |

## How ownership works

- The person who creates a canvas is its **owner**. Only the owner can change the published version.
- Anyone else is a **contributor**. Contributors work on their own copy and can suggest changes, but never edit the original directly.
- Accepted contributions are credited by name, and older versions are never deleted.

## Tech stack

| Layer | Technology |
| --- | --- |
| Backend | Java 21, Spring Boot |
| Canvas data | MongoDB |
| Users and relationships | PostgreSQL |
| Authentication | Spring Security, JWT, multi-factor authentication |
| AI | LLM-based review service (provider to be decided) |

The backend is built as a modular monolith (separate auth, canvas, gallery and AI modules) so it can be split into services later. See  https://github.com/Moham2791/KanvaCol/blob/main/KanvaCol-v1-Architecture.png for the architecture.

## Getting started

### Prerequisites

- Java 21
- Docker (to run the databases locally)

### Run locally

```bash
# 1. Clone the repository
git clone https://github.com/Moham2791/KanvaCol.git
cd KanvaCol

# 2. Start MongoDB
docker run -d --name kanvacol-mongo -p 27017:27017 mongo:7

# 3. Run the backend
cd backend
./mvnw spring-boot:run
```

Configuration lives in `backend/src/main/resources/application.properties`. Put secrets (database passwords, API keys) in environment variables, never in committed files.

## Roadmap

- [ ] Canvas create, edit, save and version history
- [ ] Sign up, log in and multi-factor authentication
- [ ] AI review of a canvas
- [ ] Public gallery and share links
- [ ] Clone, suggest changes and owner review with side-by-side comparison
- [ ] Comments, votes and profiles
- [ ] Real-time co-editing
- [ ] Timed challenges with community voting

## Contributing

Contributions are welcome. To keep `main` stable:

1. Create a branch from `main` named `feature/<short-description>` or `fix/<short-description>`.
2. Write clear commit messages that say what changed, for example `Add canvas save endpoint`.
3. Open a pull request. At least one review is required before merging.
4. Keep pull requests small and focused on one change.

Please open an issue before starting large changes so we can agree on the approach first.

## Community guidelines

KanvaCol only works if people feel safe sharing unfinished ideas. Everyone taking part in this repository or on the platform is expected to:

- **Be respectful.** Critique the idea, never the person.
- **Give useful feedback.** Say what could be better and why.
- **Credit others.** Don't present someone else's work as your own.
- **Keep it appropriate.** No harassment, hate speech, spam or explicit content.

Violations can lead to removed content or a ban from the project and the platform. Report problems by opening an issue or contacting the maintainers.

## Security

Please **do not** open a public issue for security vulnerabilities. Report them privately through GitHub's [private vulnerability reporting](https://github.com/Moham2791/KanvaCol/security/advisories/new) so they can be fixed before being disclosed.

## Privacy and user content

- Users own the drawings they create on KanvaCol.
- Drafts stay private until the owner publishes them.
- Published canvases are visible to everyone and can be cloned by other users, with credit to the original owner.
- Users can delete their account and personal data.

The platform's full Terms of Service and Privacy Policy will be published before public launch.

## License

Copyright (c) 2026 Muhammad T Khaliq. All rights reserved.

This source code is made available for viewing only. No permission is
granted to copy, modify, distribute, or use this code, in whole or in
part, without prior written permission from the copyright holder.

## Maintainers

- **Muhammad T Khaliq** ([@Moham2791](https://github.com/Moham2791)), founder
