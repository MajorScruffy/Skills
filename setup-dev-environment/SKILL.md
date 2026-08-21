---
name: setup-dev-environment
description: >
  Bootstrap this machine for Grok Build firstmate: install the Skills catalog
  into ~/.grok/skills and ~/.cursor/skills, clone firstmate, pin the Herdr
  backend, and install the firstmate toolchain. Use when setting up a machine,
  bootstrapping Grok, installing firstmate, copying skills to ~/.grok or
  ~/.cursor, or the user runs /setup-dev-environment.
---

# Setup dev environment

Run the installer from a git clone of this catalog.

1. Resolve the catalog root: `SKILLS_ROOT` if set, otherwise a checkout of `MajorScruffy/Skills`. Clone it if it is missing.
2. Run `setup-dev-environment/scripts/setup.sh` from that root. Read the script's `--help` for env vars rather than restating them. It also installs a `gh-axi` wrapper into `$GROK_HOME/bin` so `gh-axi repo list --limit N` lists the authenticated GitHub account instead of GitHub user `N`.
3. Report the script's output, including the launch block. Done when it exits 0 and prints the `herdr` / `grok --trust` commands.

The captain is Grok Build. After setup, those launch commands must run inside Herdr so crew tabs spawn next to the captain.
