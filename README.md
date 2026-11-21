# cactus

Public repository for the cactus project.

## Branches

- `dev` contains active development work and frequent restore points.
- `master` contains only verified release versions. Release commits use version-only messages such as `V1.0.0`.

## Local configuration and private data

This is a public repository. Real credentials, personal data, private network details, access tokens, session files, and other sensitive values must not be committed.

When the project needs local configuration:

1. Copy the provided example file, such as `.env.example`, to its local counterpart, such as `.env`.
2. Replace placeholders such as `YOUR_API_TOKEN` or `YOUR_DEVICE_IP` with local values.
3. Keep the completed local file untracked. Do not commit it.

Specific configuration fields and startup instructions will be documented here as the application is added.

## Local backup directory

Backups, large files, and temporarily unused project material are stored outside the repository in `D:\CactusBack`. Nothing from that directory should be committed or pushed to GitHub.
