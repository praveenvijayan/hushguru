---
title: "Migrate Firebase auth flows off Dynamic Links"
priority: high
labels: [auth, firebase]
blocked_by: []
---

Firebase Dynamic Links shut down on August 25, 2025. Audit and update the app's
Firebase Authentication integration so supported sign-in and email action flows
use the current Firebase Auth path and do not depend on Firebase Dynamic Links.

## Acceptance criteria
- [ ] The app has no runtime dependency on Firebase Dynamic Links packages, APIs, `.page.link` URLs, or Dynamic Links-backed auth handlers
- [ ] Firebase Auth client packages are updated to versions that support Firebase's post-Dynamic Links auth behavior for the app's supported platforms
- [ ] Email/password sign-in, registration, sign-out, and cold-start auth persistence still work on the supported mobile targets
- [ ] Any configured email action or deep-link domains use platform-supported App Links/Universal Links or Firebase's current email action configuration rather than Firebase Dynamic Links
- [ ] A regression test or documented manual verification covers the affected authentication flow
- [ ] `flutter analyze` passes with zero issues
