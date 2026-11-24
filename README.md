# B2_WeatherApp

## Setup

The city search uses **geocode.maps.co**, which needs an API key. The key is kept on each Mac and **never** goes into git (`SPEC.md` §8, 2026-11-24). The weather data (Open-Meteo) needs no key.

1. **Get a key:** ask a team member to send it privately (never in a PR, issue, commit or shared document), or sign up for a free key at [geocode.maps.co](https://geocode.maps.co).
2. **Create your private settings file** from the template, in the project folder:
   ```
   cp Config/Secrets.example.xcconfig Config/Secrets.xcconfig
   ```
3. **Open `Config/Secrets.xcconfig`** and paste the key after `=`, without quotes:
   ```
   GEOCODING_API_KEY = paste-the-key-here
   ```
4. **Check that git ignores it:** `git status` must **not** list `Secrets.xcconfig`.
5. **Build and run** in Xcode (⌘R). The start screen shows Stockholm's real weather; the favourite chips show their own cities.

**Troubleshooting**

| Problem | Fix |
| ------- | --- |
| Every search shows "Couldn't load the forecast" | The key is missing or mistyped. Check step 3, then **Product › Clean Build Folder** (⇧⌘K) and build again. |
| `Secrets.xcconfig` is red in Xcode | The file doesn't exist yet — do step 2. |
| Error after tapping many cities quickly | The free plan allows about 1 search per second. Wait a moment and tap **Try again**. |

**Live API tests** (optional, use the real services):
```
TEST_RUNNER_LIVE_API_TESTS=1 xcodebuild test -scheme WeatherApp -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:WeatherAppTests/LiveWeatherRepositoryTests
```
