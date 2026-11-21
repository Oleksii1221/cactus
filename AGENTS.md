# cactus project instructions

## Scope and directories

- The repository root (`cactus`) is the main working directory and the only Git repository for this project.
- Run Git commands only from this repository. Before committing or pushing, verify that `git rev-parse --show-toplevel` resolves to the `cactus` directory, never to its parent `PycharmProjects` directory.
- `D:\CactusBack` is a local backup and archive directory. Never initialize Git there, add it as a worktree or submodule, copy it into the repository, or commit/push any of its contents.
- Store backups, temporarily unused material, and large files that do not belong in Git in `D:\CactusBack`.

## Repository and branches

- The public repository is `https://github.com/Oleksii1221/cactus`.
- Keep all publishable project source code and its supporting documentation in this repository.
- `dev` is the default branch for development work.
- After each coherent completed change, commit and push the relevant changes to `origin/dev` without asking for additional permission. This provides restore points and preserves earlier working states.
- Write `dev` commit messages in English as a single concise line that summarizes all changes in that commit.
- Keep unrelated user changes out of commits. Review the staged diff before every commit.
- `master` contains only release versions that have been verified to work correctly.
- Do not commit, merge, or push to `master` unless the user explicitly instructs you to publish a release. Do not ask whether to publish to `master`; wait for the instruction.
- Commit messages on `master` must contain only the release version in the form `VMAJOR.MINOR.PATCH`, for example `V1.0.0`, `V1.0.1`, or `V1.0.2`.

## Public-repository safety

- Treat every tracked file and Git commit as public.
- Never commit or push secrets or personal, private, access-bearing, or potentially harmful data. This includes passwords, API keys, tokens, cookies, session files, private keys, credentials, Wi-Fi data, private or fixed IP addresses, internal hostnames, device identifiers, personal contact details, private paths, databases, logs containing private data, and similar information.
- Before every commit, inspect new files and the staged diff for sensitive data. If any is found, remove it from the staged content and report the issue without reproducing the secret in chat or commit messages.
- Put real local values in ignored files such as `.env` or other local configuration files. Track only sanitized templates such as `.env.example` or `config.example.*`, using obvious placeholders.
- When configuration is required, document every required field and setup step in `README.md`, but never place real private values there.
- Replace sensitive example values with neutral placeholders such as `YOUR_API_TOKEN`, `YOUR_DEVICE_IP`, or `192.0.2.1`.
- Do not commit backups, generated archives, large temporary artifacts, local IDE state, logs, databases, or session files. Keep needed local copies in `D:\CactusBack`.

## Working and verification rules

- Inspect the current branch, status, and relevant existing code before making changes.
- Preserve user-authored work and avoid unrelated edits.
- Follow the existing project style and architecture once code is present.
- Add or update tests when appropriate and run the relevant available checks before declaring work complete.
- Clearly distinguish verified results from work that still requires hardware, deployment, or user verification.
- Keep `README.md` current when setup, configuration, usage, or required placeholders change.
