function shortid
    LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c (set -q argv[1]; and echo $argv[1]; or echo 8)
end