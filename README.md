# Skills

Personal catalog of agent skills. Each folder is one skill (`SKILL.md` plus any references, scripts, or licenses). Flat on purpose so Grok, Cursor, Gemini, and OpenCode can discover them.

`/setup-dev-environment` runs `setup-dev-environment/scripts/setup.sh`: copies skills into `~/.grok/skills/<name>` and `~/.cursor/skills/<name>`, clones firstmate, pins Herdr, and installs the firstmate toolchain. Captain is Grok Build (`grok --trust` inside Herdr).

`grill-me` starts a `grilling` session. Keep both; do not replace `grill-me` with the older self-contained copy from GenesisRust.
