# WordClock TODOs

## Core
- [x] Add Firebase / Google Analytics
  - [x] For GDPR compliance, you may need to add a consent banner
  - [x] Add tracking of how long the user keeps the app open for.
- [ ] Optimize Web load time (investigate font loading, renderer, etc.).
- [ ] Add integration tests.
- [ ] Persist all the settings (language, grid, etc.)
- [ ] Persisting of grid does not seem to work.
- [x] Replace the word "atom" with "word"
- [ ] When "Show minute dots" is disabled, the grid should be larger, to fill the gap.

## Platform
- [ ] Add support for Web
- [ ] Add support for Android
- [ ] Add support for iOS
- [ ] Add support for Windows
- [ ] Add support for Linux
- [ ] Add support for MacOS

## Internationalization
- [ ] Translate the app
- [x] Allow for wordclock.me/$lang/ routing
- [ ] Fix the issue where foreign characters take a while to load. We should pre-load the google fonts, and maybe bundle them with the app - especially if we can strip them to just the required characters (to keep the app small).
- [ ] Add support for other languages (see <https://en.wikipedia.org/wiki/Languages_used_on_the_Internet#Usage_statistics_of_content_languages_for_websites> for list)
- [X] We need tests, to ensure the correct language selection behaviour
- [ ] The UI language, should try and use the URL language as a hint, if needed

## Visual
- [ ] Add additional visual modes to the clock. Such as displaying the time in seconds. Or a audio visualizer.

## Language Grid Status

### Top Internet Languages ([Wikipedia](https://en.wikipedia.org/wiki/Languages_used_on_the_Internet#Usage_statistics_of_content_languages_for_websites))
- [x] English (EN, E2)
- [x] Spanish (ES)
- [x] German (DE, CH, D2, D3, D4)
- [x] Japanese (JP)
- [x] French (FR)
- [x] Portuguese (PE)
- [x] Russian (RU)
- [x] Italian (IT)
- [x] Dutch (NL)
- [x] Polish (PL) - Refactored for consistency.
- [x] Turkish (TR)
- [x] Chinese (CS, CT)
- [ ] Vietnamese
- [x] Czech (CZ)
- [ ] Indonesian
- [ ] Korean
- [ ] Ukrainian
- [ ] Hungarian
- [x] Swedish (SE)
- [x] Romanian (RO) - Generated via `-a trie`
- [x] Greek (GR)
- [x] Danish (DK)
- [ ] Finnish
- [ ] Slovak
- [ ] Thai
- [ ] Bulgarian
- [ ] Croatian
- [x] Norwegian Bokmål (NO)
- [ ] Lithuanian
- [ ] Serbian
- [ ] Slovenian
- [x] Catalan, Valencian (CA)
- [ ] Estonian
- [x] Norwegian (NO)
- [ ] Latvian

### Top constructed languages
- [ ] Esperanto
- [ ] Klingon
- [ ] High Valyrian (Game of Thrones)
- [ ] Na'vi (Avatar)
- [ ] Elvish / Quenya (The Lord of the Rings)
- [ ] Circular Gallifreyan (Doctor Who)
- [ ] Dothraki (Game of Thrones)
- [ ] Black Speech (The "Mordor" Language)

### Top 10 Indian Languages
- [ ] Hindi
- [ ] Bengali
- [ ] Marathi
- [ ] Telugu
- [x] Tamil
- [ ] Gujarati
- [ ] Urdu
- [ ] Kannada
- [ ] Odia
- [ ] Malayalam

### Top languages to support onces right-to-left is supported
- [ ] Persian
- [ ] Arabic
- [ ] Hebrew
