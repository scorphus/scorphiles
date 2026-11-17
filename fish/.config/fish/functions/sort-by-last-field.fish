function sort-by-last-field --no-scope-shadowing -a sep -d "Sort input by last field"
  test -z $sep
    and echo "warning: you must inform separator" >&2
    and set sep ","
  set lf ""
  set lines ""
  while read line_
    set lines $lines$lf$line_
    set lf \n
  end
  echo $lines | awk -F$sep "{print \$NF\"$sep\"\$0}" | sort | cut -f2- -d$sep
end
