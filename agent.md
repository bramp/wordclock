# Agent Rules

- **Commit Policy**: You must fully tested all code before commmiting. Do not commit changes automatically. Wait for the user to review and ask for a commit.
- **Code Style**: Prefer modern Dart syntax.
- **Testing**: Code should be designed to be testable (dependency injection, pure functions where possible).
- **Git**: Prefer `git add [file]` over `git add .` to ensure atomic and precise commits. Never run a command that wipes out uncommited work. No `git reset --hard` unless explicitly asked.
- **File Safety**: DO NOT forcefully delete files (e.g. `rm -f`, `git rm -f`). If a file is in the way or causing issues, ask the user or use safer alternatives (e.g. moving/renaming or unstaging).
