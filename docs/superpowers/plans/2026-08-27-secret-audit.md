# Dotfiles secret audit — pre-publish gate

Audit of `/Users/paul/.local/share/chezmoi` at `main = ac54f3cd1790` ahead of
publishing into the public `github.com/paulsmith/nixos-config` repo (Task 2 of
the dotfiles migration plan).

**This audit records findings only. It does not make the publish decision.**
Two files below are `needs redaction`, which per the Task 2 brief's decision
gate means: **stop and escalate to Paul before Task 3 proceeds.**

## Summary

- 43 files in the reconciled chezmoi tree; 39 in scope (4 excluded because
  nothing copies them: `.chezmoiignore`, `AGENTS.md`, `CLAUDE.md`, `README.md`
  — confirmed against Task 3's copy list).
- 37 `clean`
- 2 `needs redaction`
- 0 `must stay private`

## Method

1. Mechanical grep for secret shapes (passwords, API keys, tokens, private
   key headers, `ghp_`/`sk-`/`AKIA` patterns) — no true hits; a handful of
   benign matches on the word "password"/"secret" in comments and a
   `1password`/`onepassword` app identifier.
2. A second mechanical pass for private-network shapes (RFC1918/CGNAT IP
   ranges, `.local`/`.internal` suffixes, employer name, SSH key material) —
   no hits in the 39 in-scope files.
3. Read all 39 in-scope files end to end for what grep cannot find: internal
   hostnames, tailnet details, employer references, personal identifiers,
   leaking absolute paths.

## Findings by file

### needs redaction

**`dot_hammerspoon/init.lua`** — needs redaction
- Line 47: hardcoded home WiFi SSID (`homeSSID = "<redacted: site-local value, see ~/.hammerspoon/private.lua>"`).
- Line 60: the same SSID repeated in a notification string.
- Line 51: Tailscale exit-node hostname (`exitNode = "<redacted: site-local value, see ~/.hammerspoon/private.lua>"`), used at
  lines 66 and 70.
- Reasoning: a home WiFi SSID is a geolocatable identifier (wardriving
  databases such as WiGLE map SSIDs to physical locations), and the exit-node
  name is private tailnet topology. Redaction is well-defined: replace the
  SSID and exit-node values with placeholders/env-driven config, or extract
  this logic into a file that stays out of the public repo. Task 3's current
  copy list moves this file verbatim into `home/dotfiles/hammerspoon/init.lua`
  with no stripping step — this gap needs to be added to the plan.

**`dot_config/git/config`** — needs redaction
- Line 40: personal email address (`paulsmith@pobox.com`) in `[user]`.
- Line 8: `hooksPath = "/Users/paul/.config/git/hooks"` — a private absolute
  path (lower severity — reveals only home-directory layout, no content).
- Reasoning: publishing a personal email address as plaintext in a public
  repo invites harvesting; it's a different address than the one associated
  with the target GitHub account context. Redaction is well-defined: remove
  the `[user]` block and the `hooksPath` line. This exactly matches what
  Task 3 Step 4 already plans to do (remove `[user]`, strip `hooksPath` only
  from `[core]`) — Task 3's redaction is necessary and sufficient for this
  file; no plan change needed here, just confirmation the step actually runs
  before anything is made public.

### clean (with notes — not blocking)

- **`dot_config/jj/config.toml.tmpl`** — clean. Has a hardcoded
  `name = "Paul Smith"` (not sensitive; the repo will already be publicly
  attributed to this GitHub account) and `email = {{ .email | quote }}`,
  which is a chezmoi template variable, not a literal value — the actual
  email is supplied by local chezmoi data that is not among the 43 files in
  this repo, so nothing literal is exposed. Task 3 strips the whole
  `[user]` block anyway, for an unrelated architectural reason (Home Manager
  generates identity per host) — not required by this audit, but harmless.
- **`dot_claude/settings.json`** — clean. Hooks shell out to
  `/Users/paul/Library/Application Support/Bartender/NotchBar/AgentStatus/hooks/claude-event-hook.sh`.
  This is a hardcoded, non-portable absolute path specific to Paul's
  machine, but it contains no token, no employer reference, and reveals only
  that Paul uses Bartender/NotchBar (a menu-bar utility) — not something I'd
  call sensitive. Flagged per the brief's explicit ask to check settings.json
  hooks; verdict is clean.
- **`dot_config/nvim/init.lua`** — clean. Line 62 has a commented-out
  personal project path (`/Users/paul/projects/incubator/nvim-exec-scratch/`)
  — a personal side-project name, not employer/client-identifying.
- **`run_onchange_before_install-packages-darwin.sh.tmpl`** — clean.
  References `{{ .chezmoi.hostname == "io" }}` as a template gate for one
  Mac App Store cask. "io" is a short personal machine nickname, not an
  internal/employer hostname; no other sensitive content in the brew/cask/mas
  list.
- **`dot_config/private_karabiner/private_karabiner.json`** — clean. Read in
  full (125 lines). Only generic key-remap rules and USB `vendor_id`/
  `product_id` numbers identifying keyboard/mouse hardware models — not
  personally identifying.
- **Hammerspoon Spoons** (`AClock.spoon/*`, `ClipboardTool.spoon/*`,
  `ReloadConfiguration.spoon/*`, 6 files) — clean. Unmodified third-party
  code from the upstream `Hammerspoon/Spoons` repo, MIT licensed, with the
  original authors' names/emails in the metadata headers (not Paul's) — this
  is normal, already-public open-source code.

### clean (no notes)

- `dot_bash_profile`
- `dot_bashrc` (includes the `q` quickserve function and the `google()`
  helper mentioned in the brief — both benign; no secrets)
- `dot_claude/CLAUDE.md`
- `dot_claude/commands/.keep` (empty)
- `dot_config/bat/config`
- `dot_config/fontconfig/fonts.conf`
- `dot_config/git/ignore`
- `dot_config/nvim/lazy-lock.json`
- `dot_config/nvim/lua/plugins/conform.lua`
- `dot_config/nvim/lua/plugins/gitsigns.lua`
- `dot_config/nvim/lua/plugins/lsp.lua`
- `dot_config/nvim/lua/plugins/neo-tree.lua`
- `dot_config/nvim/lua/plugins/nvim-cmp.lua`
- `dot_config/nvim/lua/plugins/telescope.lua`
- `dot_config/nvim/lua/plugins/todo-comments.lua`
- `dot_config/nvim/lua/plugins/tokyonight.lua`
- `dot_config/nvim/lua/plugins/treesitter.lua`
- `dot_config/nvim/lua/plugins/undotree.lua`
- `dot_config/nvim/lua/plugins/which-key.lua`
- `dot_gitattributes`
- `dot_gitignore_global`
- `dot_inputrc`
- `dot_sqliterc`
- `empty_dot_tmux.conf` (empty file)
- `private_dot_npmrc` (single `prefix=/Users/paul/.local` line, verified —
  no auth token)
- `private_Library/private_Application Support/com.mitchellh.ghostty/config`

## Uncertain / worth a second look

- The `/Users/paul` username appears throughout (bash_profile, npmrc, git
  config's `hooksPath`, the settings.json hook path, a comment in
  `init.lua`). I did not flag these individually — "paul" matches the
  target GitHub account's own name, so it doesn't disclose anything not
  already implied by the repo's ownership. Flagging here in case a stricter
  standard is wanted (e.g. if this repo could ever be forked/mirrored under
  a different identity).
- I judged the git-config email and the hammerspoon SSID/exit-node as the
  two items worth blocking on, and treated the jj-config template email and
  the settings.json hook path as non-blocking. Reasonable people could set
  the bar differently (e.g. also redacting the git hooksPath, or the "io"/
  "andon" hostnames) — flagging so the human reviewer can recalibrate if the
  bar should be stricter.
- I have no way to verify from the repo alone whether "<redacted: site-local value, see ~/.hammerspoon/private.lua>" or "<redacted: site-local value, see ~/.hammerspoon/private.lua>"
  are still in active use (i.e., whether disclosure has any live safety
  implication versus being stale) — treat as live unless Paul says otherwise.

## Decision gate

Per Task 2's Step 5: not every file is `clean`. **Escalating to Paul before
Task 3 proceeds**, per the brief's binding instruction that a single
sensitive file reopens the "one repo, public" decision.
