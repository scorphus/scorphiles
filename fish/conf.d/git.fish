function __git_available_lines --on-signal winch
  set -gx __git_available_lines (math "ceil($LINES * 0.7)")
end

__git_available_lines
