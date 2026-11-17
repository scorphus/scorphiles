# rg.fish - Paginate ripgrep[1] output when convenient
#
#     1: https://github.com/BurntSushi/ripgrep
#
# Copyright 2018 Pablo Santiago Blum de Aguiar <scorphus@gmail.com>. All rights
# reserved. Use of this source code is governed by the 3-clause BSD license,
# which can be found on https://opensource.org/licenses/BSD-3-Clause
#

function rg
  if isatty stdout
    command rg -S --pretty $argv | less -RMFXK
  else
    command rg -S $argv
  end
end

# Options:
# -R: support color output (ANSI color sequences)
# -M: show line number information in the bottom of screen (current/pages X%)
# -F: automatically quit less if the entire example fits on the first page
# -X: do not use init/deinit strings; in other words: do not clear the screen
# -K: exit less in response to Ctrl-C (^C)
