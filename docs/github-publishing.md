# GitHub Publishing

Do not paste personal access tokens into chats, commits, issues, or scripts.

## Create The Remote

After revoking the exposed token and creating a fresh one, authenticate with GitHub CLI or Git Credential Manager from your own terminal:

```bash
gh auth login
```

Then create the repository:

```bash
git init
git add .
git commit -m "Initial Bytefall distro tree"
gh repo create Bytefall --public --source . --remote origin --push
```

## Suggested Repositories

- `Bytefall`: distro source tree, ArchISO profile, configs, branding, docs.
- `bytefall-apps`: custom apps such as Bytefall Welcome once they outgrow this mono-repo.
- `bytefall-repo`: pacman package build recipes and signed package metadata once releases begin.

For now, keeping `apps/` inside this tree is simpler because ISO integration is changing quickly.
