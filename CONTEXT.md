# CONTEXT.md — B2 Weather App

> Course rules and external facts that don't change during the project. `SPEC.md` = what to build · `STYLE.md` = how · `CONTEXT.md` = the rules around it.

## 1. Course and submission

| | |
| - | - |
| Course / Lab | CM2023 · Lab B:2 — Native Weather App |
| Prerequisite | Lab B:1 passed |
| Format | Solved in pairs |
| Deadline | Submit ≥ 1 day before the scheduled presentation |
| What is submitted | **One document:** reflection report (~½ page) + Appendices A–D |
| Code | Not submitted — reviewed and discussed at the oral presentation |

| Appendix | File | Content |
| -------- | ---- | ------- |
| A | `docs/TEST_REPORT.md` + test files | Tested logic, test cases, results, mutation tests, ≥ 20 UX scenarios |
| B | `README.md` | How the code is structured: main files, responsibilities, how layers connect |
| C | `SPEC.md` | Requirements with IDs, AI meta-instructions, update log |
| D | `docs/LLM_PROCESS.md` | Per session: task given to the AI, what it produced, what I kept/changed, observations |

## 2. Grading

| Dimension | Pass (E/G) | Higher (A/VG) |
| --------- | ---------- | ------------- |
| App | Runs on simulator/device; main flow works without crashes | Edge cases handled; loading/error states; works under real conditions |
| Code quality | Readable; recognisable patterns | Deliberate, visible architecture; separated concerns; specific naming |
| UI / UX | Functional and usable | Looks designed; consistent visual language; hierarchy guides the user |
| Oral exam | Can trace data flow API → screen (*what*) | Can explain *why*, defend trade-offs, reason about consequences |
| SPEC.md | Requirements with IDs; AI usage noted | Reflects real process; oral questions mapped to IDs; update log |

The oral exam is the main criterion for the higher grade.

## 3. Oral exam

- Starts with a demo of the running app, then questions from the list of 30 (mapped in `SPEC.md` §9).
- **The opening question is always Q26:** show the AI meta-instructions in `SPEC.md` and trace one requirement to its code.
- No memorising needed, but I must find the code and explain how it works — **including any line the AI wrote**.

## 4. Technical constraints

- Platform: iOS, Swift/SwiftUI, Xcode. Stay on this platform for the whole lab.
- **Apple SDK only** — no third-party packages.
- **Multiple files, organised by layer** (`STYLE.md` §3). The course's general template suggests "single-file preferred", but the higher grade requires separated layers, so we use separate files.
- Testing must run on the **Xcode Simulator or a physical device** — browser previews don't count. Check iPhone and iPad, portrait and landscape.
- All code, comments and docs in English.

## 5. APIs

### Open-Meteo (forecast)

- Endpoint: `https://api.open-meteo.com/v1/forecast` — no API key. Docs: <https://open-meteo.com/en/docs>
- Example:
  ```
  ?latitude=59.33&longitude=18.07
  &current=temperature_2m,weather_code,wind_speed_10m
  &hourly=temperature_2m,weather_code,precipitation_probability
  &daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max
  &timezone=auto&forecast_days=7
  ```
- `hourly` and `daily` are **parallel arrays** (`time[i]` belongs to `temperature_2m[i]`) — the parser has to zip them.
- `weather_code` uses WMO codes (0 = clear, 61 = rain, 95 = thunderstorm, …) → map to icons in one place.
- `timezone=auto` returns local times without an offset; needed to find "today".
- Free for non-commercial use with a daily request limit — use saved fixtures during development.

### geocode.maps.co (place search)

- Endpoint: `https://geocode.maps.co/search?q={place}&api_key={key}`
- **Requires a free API key** → keep it out of git (`SPEC.md` §7 #1). Free tier is rate-limited (≈ 1 request/second — check the account dashboard).
- Returns a JSON array; `lat` and `lon` are **strings**, `display_name` is the full place name. An empty array means no results.
- Rate limiting means no search-as-you-type without debouncing.

### Test proxy

- The KTH proxy (`maceo.sth.kth.se/weather/...`) mirrors the **SMHI** format, so it doesn't fit Open-Meteo. Use saved JSON fixtures instead to avoid rate limits.
- **The final submission must use the real APIs.**

## 6. AI rules from the course

- AI tools are allowed and encouraged.
- `SPEC.md` must state which parts were AI-assisted and which prompts or tools were used.
- I verify and test all AI-generated code myself before submitting.
- The AI must not write `docs/REFLECTION.md` or `docs/LLM_PROCESS.md`, and must not tick requirements or write test results.

## 7. Common pitfalls (from Lab B:1)

| Pitfall | How we avoid it |
| ------- | --------------- |
| AI writes Core code unnoticed | Core is listed in `STYLE.md` §2.1; explain-back after every piece |
| AI takes over when I'm unsure | Hint ladder (`STYLE.md` §2.2) |
| AI writes the reflection | Forbidden in `SPEC.md` §1; I keep running notes |
| AI answers in the wrong language | English rule in `SPEC.md` §1 |
| Test suite grows out of control | No new tests without my approval |
| Screenshots used as the test report | Test report = unit tests + mutation tests + UX scenario table |
