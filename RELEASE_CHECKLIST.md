# Release Checklist

Everything that has to be true before a public build goes out. Status: **skeleton** (22 October 2026). Items are filled in and checked off as each release approaches. Platform order: Steam first, then Android and iOS together (D5, D8).

## Every build

- [ ] CI green on the release commit (script check, tests, exports)
- [ ] Version bumped in `project.godot` and each export preset (Android `version/code` must increase every upload)
- [ ] Played start to finish on the target platform; TEST_PLAN manual checks done
- [ ] Every asset in the build has a row in ASSET_REGISTER.md; CC-BY credits in the credits screen
- [ ] No test, tool, experiment or research files in the export (presets exclude them; spot-check the build)

## Before the first store upload (one-off)

- [ ] Final game name; app icon
- [ ] **Package and bundle ID confirmed.** The placeholder is `com.yashaggarwal.zombieshooter`. It can't change after the first upload to Google Play or the App Store.
- [ ] Android upload key made, backed up in two places, never committed; Play App Signing enrolled
- [ ] Privacy policy (stores need one even for offline games)

## Steam

- [ ] Steam Direct fee paid (the ₹10,000 budget, D5)
- [ ] Store page, capsule art, trailer
- [ ] Demo and Next Fest plan
- [ ] Wishlist gate met (15k, Stage A amendments)
- [ ] GodotSteam achievements and cloud save, if C5 passed
- [ ] Steam Deck check

## Android (port)

- [ ] Google Play developer account
- [ ] AAB export with the release keystore (CI secrets)
- [ ] Target SDK meets Play's current requirement
- [ ] Touch controls, safe areas, suspend/resume tested on at least two phones

## iOS (port, parked until then per D8)

- [ ] Apple Developer Program ($99 a year)
- [ ] Export from the Mac with Xcode; Team ID set in the iOS preset
- [ ] Tested on an iPhone with a notch or Dynamic Island
- [ ] App Store review notes
