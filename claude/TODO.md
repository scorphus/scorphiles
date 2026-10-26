# Claude announcements, next

- Colour by reason: the script sets `@announce done` or `@announce waiting` on the window, the tmux window formats paint done green and waiting red, an `after-select-window` hook clears it on visit.
- Claude state in the window capsule: the busy/idle dot of `claude-fleet.sh` inside the capsule of the window that runs the session.
- Jump to the last announcement: the script records the announced window in a server option, a key binding selects it.
- Spoken message names the window number as well as the session.
