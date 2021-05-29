function reefwatch -d 'An overridden, fish-wise watch. Refers to a place where fish gather and are observed — like watching over a reef.'
    if test (count $argv) -eq 1
        switch $argv[1]
            case '--help'
                printf "reefwatch: An overridden, fish-wise watch. Usage: reefwatch [watch options] <command>\n"
                return 0
            case '--version'
                printf "reefwatch version 1.0\n"
                return 0
        end
    end
    set -l last_arg (string escape -- $argv[-1])
    set -l cmd "fish -lc 'last_arg'"
    set -l pre_cmd_args ""
    if test (count $argv) -gt 1
        set pre_cmd_args $argv[1..-2]
    end
    command watch --color $pre_cmd_args $cmd
end
