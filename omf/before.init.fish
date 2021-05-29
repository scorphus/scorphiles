function epoch
  test (uname) = Darwin
    and eval $OMF_PATH/pkg/fish-spec/utils/epoch.osx
    or eval $OMF_PATH/pkg/fish-spec/utils/epoch.linux
end

function perf:timer:start --on-event my:perf:timer:start --on-event perf:timer:start
  set -g __start_ticks $__start_ticks "$argv" (epoch)
end

function perf:timer:finish --on-event my:perf:timer:finish --on-event perf:timer:finish
  set key_index (contains -i -- "$argv" $__start_ticks)
  set value_index (math $key_index + 1)
  set duration (math (epoch) - $__start_ticks[$value_index])
  emit perf:timer:report "$argv" $duration
  set -e __start_ticks[$key_index $value_index]
end

function perf:timer:report --on-event perf:timer:report -a name time
  echo $name loaded in $time ms
end
