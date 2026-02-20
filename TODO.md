# WordClock TODOs

## Core
- [x] Add Firebase / Google Analytics
  - [x] For GDPR compliance, you may need to add a consent banner
  - [x] Add tracking of how long the user keeps the app open for.
- [x] Optimize Web load time (investigate font loading, renderer, etc.).
- [x] Add integration tests.
- [x] Persist all the settings (language, grid, etc.)
- [x] Replace the word "atom" with "word"
- [x] When "Show minute dots" is disabled, the grid should be larger, to fill the gap.
- [x] Add a licences popup
- [x] Add semantic labels for accessibility
- [x] Add golden image tests
- [ ] With the White theme, the plasma text effect is not relevant (and should be disabled)
- [ ] Add screenshot/animations to the README, and a link to the live site.

## Platform
- [x] Add support for Web
- [ ] Add support for Android
- [ ] Add support for iOS
- [ ] Add support for Windows
- [ ] Add support for Linux
- [ ] Add support for MacOS

## Internationalization
- [ ] Translate the app
- [x] Hide the language dropdown when there is only one language.
- [x] Allow for wordclock.me/$lang/ routing
- [x] Fix the issue where foreign characters take a while to load. We should pre-load the google fonts, and maybe bundle them with the app - especially if we can strip them to just the required characters (to keep the app small).
- [ ] Add support for other languages (see <https://en.wikipedia.org/wiki/Languages_used_on_the_Internet#Usage_statistics_of_content_languages_for_websites> for list)
- [X] We need tests, to ensure the correct language selection behaviour
- [ ] The UI language, should try and use the URL language as a hint, if needed
- [ ] Consider allowing compact languages (like Japnese) to count in minutes, not five minutes.

## Visual
- [ ] Add additional visual modes to the clock. Such as displaying the time in seconds. Or a audio visualizer.
- [x] The fonts don't always load before being shown
- [x] The font subsetting, will include all ascii in the say the Tamil font, that only needs a very short list
- [x] The font download / subsetting fetches regular and renames as Bold. Which is wrong. We should try and fetch the variable fonts, subset them.

## Language Grid Status

### Top Internet Languages ([Wikipedia](https://en.wikipedia.org/wiki/Languages_used_on_the_Internet#Usage_statistics_of_content_languages_for_websites))
- [x] English (EN, E2)
- [x] Spanish (ES)
- [x] German (DE, CH, D2, D3, D4)
- [x] Japanese (JP)
- [x] French (FR)
- [x] Portuguese (PE)
- [ ] Russian (RU)
- [x] Italian (IT)
- [x] Dutch (NL)
- [ ] Polish (PL) - Refactored for consistency.
- [x] Turkish (TR)
- [x] Chinese (CS, CT)
- [ ] Vietnamese
- [x] Czech (CZ)
- [ ] Indonesian
- [ ] Korean
- [ ] Ukrainian
- [ ] Hungarian
- [x] Swedish (SE)
- [ ] Romanian (RO) - Generated via `-a trie`
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
- [x] Esperanto
- [x] Klingon
  - [X] Update the display name to use pIqaD script
  - [X] Ensure the font is compressed / pruned
  - [X] Add some instructions, to ask developers to install assets/fonts/pIqaD.ttf (so they can see it in the terminal)
  - [ ] We get the error "Could not find a set of Noto fonts to display all missing characters. Please add a font asset for the missing characters. See: https://docs.flutter.dev/cookbook/design/fonts"
- [x] High Valyrian (Game of Thrones)
  - [ ] Add "Tubī" (In the day) / "Gēlenka" (In the night)
- [ ] Na'vi (Avatar)
- [x] Quenya (High-Elven)
- [x] Sindarin (Grey-Elven)
- [ ] Dothraki (Game of Thrones)
- [x] Aurebesh
- [x] Mando'a (Mandalorian)

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
