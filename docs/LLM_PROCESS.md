# LLM_PROCESS.md — B2 Weather App

> Appendix D. Written by Loke and Silje — not by the AI (`SPEC.md` §1). One entry per session.

## Sessions

### 2026-11-20 — Xcode project setup (Loke)

- **Task given to the AI:** Guide me step by step through creating the Xcode project.
- **What it produced:**
  - `.gitignore`
  - Terminal checks after each step
  - Moved files to remove the extra folder level
  - Renaming
  - `.gitkeep` files so the empty folders could be pushed to GitHub
  - Commit and push
  - Update-log row
  - Added the `docs/` folder
- **What I kept / changed:**
  - I did all the Xcode set-up myself and set iOS 17.0 and `EXCLUDED_SOURCE_FILE_NAMES`.
  - I chose to remove the nesting and to name the struct `WeatherApp`, despite the module-name clash.
  - I kept `build/` in `.gitignore`.
- **Observations:**
  - It didn't know the new `project.pbxproj` format, so it inspected it before continuing.
  - It flagged the `.gitkeep` risk, and the build check confirmed it was real.
  - Checking the resolved settings caught two typos (`.gitkkep`, `gitkeep`).
