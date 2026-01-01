# WordClock TODOs

- [x] Update packages to resolve "incompatible with dependency constraints" warning.
- [x] Change time rounding logic: round down to the nearest 5 minutes (e.g., 4:16 -> 4:15, 4:14 -> 4:10).
- [x] Add four minute indicator dots in the corners to represent the additional 0-4 minutes.
- [x] Style unlit letters more visibly (outline or grey) instead of nearly invisible.
- [ ] Optimize Web load time (investigate font loading, renderer, etc.).
- [x] Implement a Settings Page (color schemes, logic toggles?).
- [x] Create a script/tool to generate new clock faces/grids from configuration.
- [ ] Add integration tests.
- [ ] Create animating backgrounds (like a plasma effect)
- [x] Add a debug mode, where we can set the time, or make the time tick extremely fast (one minute each second)
- [X] Can we ensure all tests pass, and test is always formatted/linted before commit. Perhaps a pre-commit hook?
- [x] 21:45 doesn't work
- [ ] Draw a ' after O, so it reads O'Clock, but the O' should take up a single space on the grid (with the O aligned as normal).
- [x] Use a grid we generate
- [ ] We should make it possible to copy and paste the time
