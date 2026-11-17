function check-exported-variable
  python -c 'import os; print os.environ.get("'$argv'", "--")'
end
