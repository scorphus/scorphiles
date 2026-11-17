function __python-line-profile-usage
    echo Usage: python-line-profile \<file.py\>
end

function python-line-profile -a py_file -d 'Alias for kernprof + line_profiler'
    if which kernprof > /dev/null 2>&1
        if test (count $argv) -ne 1
            __python-line-profile-usage
            return 1
        end
        if test ! -f $py_file
            echo $py_file is not a regular file
            __python-line-profile-usage
            return 1
        end
        kernprof -l $py_file > /dev/null
        if test $status -ne 0
            return 1
        end
        python -m line_profiler $py_file.lprof | less -XRF
    else
        echo kernprof is not available, install with: pip install line_profiler
        echo Please check https://github.com/rkern/line_profiler for more info
    end
end
