# WordClock TODOs

- [x] Update packages to resolve "incompatible with dependency constraints" warning.
- [x] Change time rounding logic: round down to the nearest 5 minutes (e.g., 4:16 -> 4:15, 4:14 -> 4:10).
- [x] Add four minute indicator dots in the corners to represent the additional 0-4 minutes.
- [x] Style unlit letters more visibly (outline or grey) instead of nearly invisible.
- [ ] Optimize Web load time (investigate font loading, renderer, etc.).
- [x] Implement a Settings Page (color schemes, logic toggles?).
- [x] Create a script/tool to generate new clock faces/grids from configuration.
- [ ] Add integration tests.
- [x] Create animating backgrounds (like a plasma effect)
- [x] Add a debug mode, where we can set the time, or make the time tick extremely fast (one minute each second)
- [x] Can we ensure all tests pass, and test is always formatted/linted before commit. Perhaps a pre-commit hook?
- [x] 21:45 doesn't work
- [x] Draw a ' after O, so it reads O'Clock, but the O' should take up a single space on the grid (with the O aligned as normal).
- [x] Use a grid we generate
- [x] We should make it possible to copy and paste the time
- [x] When the app is resized, the grey letters animate their change, but the illumatned ones don't. That seems wrong behaviour
- [x] Add a debug toggle to hide the "padding" letters.
- [ ] Add support for other languages (see <https://en.wikipedia.org/wiki/Languages_used_on_the_Internet> for list)
- [ ] Generate railroad diagrams (instead of dot diagrams) see <https://github.com/GuntherRademacher/rr>
- [ ] The output of bin/extract_scriptable_highlights.js is not always correct
  - [ ] "E3" has "IT IS ONE FIVE" but it would be better as "IT IS ONE OH FIVE"
  - [x] "CA" mixes correct Catalan time expressions with corrupted hour names. - Lines containing NAO, NZE, D'R, or missing the hour noun are incorrect.
- [x] Can we add a padding field to ScriptableLanguageData, which is the list of all the characters discovered in the grid that are never mapped to by the time. That data should end up in the WordClockLanguage children.
- [ ] In lib/generator some languages (such as Japnese) don't require padding. Can we annotate that on the WordClockLanguage, then tweak the generator to not require it.
- [ ] Can we review all the TimeToWord implementations in lib/logic. Many of the language variants (e.g English and German) share the same words. Can we dedup and make common functions where nessacary. For all TimeToWord implementations can we review the code, and refactor into the concise, easy to read, and maintain style. Comments for translations are important, but make sure all the other comments are useful. We don't need to refer back to the Scritable origins of the code. Just focus on making clean, modern dart code. Please create a TODO list to stay focused on this tak, and do one at a time.
- [ ] Consider using
      <https://pub.dev/documentation/quiver/latest/quiver.time/Clock-class.html>
      instead of Clock.
- [ ] Default to the language the user natively speaks
- [ ] Translate the app
- [ ] Fix the issue where foreign characters take a while to load. We should pre-load the google fonts, and maybe bundle them with the app - especially if we can strip them to just the required characters (to keep the app small).
- [ ] Add Google Analytics
  - [ ] For GDPR compliance, you may need to add a consent banner
  - [ ] Add tracking of how long the user keeps the app open for.
- [ ] Allow for wordclock.me/$lang/ routing
- [ ] Replace the word "atom" with "word"
- [ ] Add additional visual modes to the clock. Such as displaying the time in seconds. Or a audio visualizer.
- [x] We no longer need `atomizePhrases`, it produces poor grids. So we should just remove that feature.

## Language Grid Status

The following languages have successfully generated optimal grids:

- [x] CH (Bernese German)
- [x] CA (Catalan)
- [x] CS (Chinese Simplified)
- [x] CT (Chinese Traditional)
- [x] CZ (Czech)
- [x] DK (Danish)
- [x] NL (Dutch)
- [x] D4 (East German)
- [x] E2 (English Alternative)
- [x] EN (English)
- [x] FR (French)
- [x] D2 (German Alternative)
- [x] DE (German)
- [x] GR (Greek)
- [x] IT (Italian)
- [x] JP (Japanese)
- [x] NO (Norwegian)
- [x] PE (Portuguese)
- [x] RO (Romanian) - Generated via `-a trie`
- [x] ES (Spanish)
- [x] D3 (Swabian German)
- [x] SE (Swedish)
- [x] TR (Turkish)

The following languages currently timeout and need optimization or a different approach:

- [ ] PL (Polish) - We need to fix TimeToWords - it generates far too many
- [ ] RU (Russian)
- [ ] Hebrew - We need to support right to left.
