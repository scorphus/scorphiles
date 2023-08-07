function slugify
  if isatty stdin
    echo -n $argv | sed -e 's/[^[:alnum:]]/-/g' | tr -s '-' | tr A-Z a-z
  else
    cat - | sed -e 's/[^[:alnum:]]/-/g' | tr -s '-' | tr A-Z a-z
  end
end
