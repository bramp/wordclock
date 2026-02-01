# Agent Rules

- **Commit Policy**: fully tested tasks must be committed immediately.
- **Code Style**: Prefer modern Dart syntax.
- **Testing**: Code should be designed to be testable (dependency injection, pure functions where possible).
- **Git**: Prefer `git add [file]` over `git add .` to ensure atomic and precise commits. Never run a command that wipes out uncommited work. No `git reset --hard` unless explicitly asked.
