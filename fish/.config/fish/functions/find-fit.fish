function find-fit -d "List FIT activity files under a folder (default: here), oldest first"
    set -l dir .
    set -q argv[1]; and set dir $argv[1]
    gfind $dir -type f -printf "%T@\t%p\0" | sort -zn | gcut -zf2- \
        | xargs -0 file -N -F \t -- | string match -rg "^(.*)\t\s*FIT "
end
