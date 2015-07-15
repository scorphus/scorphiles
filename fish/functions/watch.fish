function watch -d 'An overridden, fish-wise watch'
    set -l cmd "fish -ic '$argv[-1]'"
    set -l pre_cmd_args ""
    if test (count $argv) -gt 1
        set pre_cmd_args $argv[1..-2]
    end
    command watch --color $pre_cmd_args $cmd
end
