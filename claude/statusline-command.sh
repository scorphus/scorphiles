#!/bin/sh
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "?"')
model=$(echo "$input" | jq -r '.model.display_name // "?"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

dir=$(basename "$cwd")

# Build the base line: dir and model
line=$(printf "\033[34m%s\033[0m  \033[33m%s\033[0m" "$dir" "$model")

# Append context window usage if available
if [ -n "$used" ]; then
  line=$(printf "%s  ctx:\033[32m%.0f%%\033[0m" "$line" "$used")
fi

# Append rate limit info if available (Claude.ai subscribers only, after first response)
# five_hour = 5-hour session rolling window; seven_day = 7-day weekly rolling window
if [ -n "$five_pct" ] || [ -n "$week_pct" ]; then
  rate_parts=""
  if [ -n "$five_pct" ]; then
    rate_parts=$(printf "5h:\033[35m%.0f%%\033[0m" "$five_pct")
  fi
  if [ -n "$week_pct" ]; then
    if [ -n "$rate_parts" ]; then
      rate_parts=$(printf "%s 7d:\033[35m%.0f%%\033[0m" "$rate_parts" "$week_pct")
    else
      rate_parts=$(printf "7d:\033[35m%.0f%%\033[0m" "$week_pct")
    fi
  fi
  line=$(printf "%s  %s" "$line" "$rate_parts")
fi

printf "%s" "$line"
