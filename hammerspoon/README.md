# Hammerspoon config

`init.lua` only loads `hs.ipc` and requires each module below, in this order.
Everything else lives in `Modules/`.

- `window_layout.lua` — halves/thirds binds, move-to-display, maximize/thirds
  via `M`, center and "nice to look at" position via `K`.
- `mic_mute.lua` — the MicMute spoon, toggled with `F1`.
- `color_picker.lua` — `pickColor` (bound to `⌘⇧⌃P`), exported so the tools
  menu can reuse it.
- `tools_menu.lua` — the menubar entry with the color picker and the Claude
  announcement mute toggle (requires `color_picker.lua`).
- `caffeine.lua` — the sleep-prevention toggle in the menubar.
- `clipboard.lua` — paste-clipboard bind (`⌘⌥V`) plus the clipboard history
  (save with `⌃⌥C`, pick with `⌃⌥V`, delete an entry from the picker with
  Backspace).
- `window_nudge.lua` — repeating move/resize binds on Home/End/PageUp/PageDown.
- `window_hints.lua` — the icon+letter window overlay picker (`⌘⌥⌃H`).
- `scroll.lua` — smooth scroll on `⌃⌥J`/`⌃⌥K` while held, and a bigger jump
  per tick on `⌃⌥⇧J`/`⌃⌥⇧K`; scrolls the active tmux pane directly when the
  focused window is Ghostty.
- `app_launcher.lua` — the app launch/focus table (`⌘⌃<key>`) and its cheat
  sheet (`⌘⌃/`).
- `config_reload.lua` — the watcher that reloads the config whenever a `.lua`
  file under `~/.hammerspoon/` changes.
