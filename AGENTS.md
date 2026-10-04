# AGENTS.md

## Project
Raspberry Pi tools and installers for the itsdarklikehell fleet.

## Conventions
- Shell scripts use `#!/bin/bash` shebang
- All scripts must pass `bash -n` syntax check
- Use `set -euo pipefail` for robust error handling
- Prefer `shellcheck`-clean code
- Commit messages follow conventional commits format

## Testing
- Run `bash -n <script>.sh` for syntax validation
- Run `shellcheck <script>.sh` for linting
- Test scripts in a safe environment before deploying

## Security
- Never hardcode credentials or secrets
- Use `curl | bash` only with verified sources
- Validate all user input
- Use `sudo` only when necessary
