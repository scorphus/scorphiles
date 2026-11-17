function pyclean -d 'burn them all in fire'
  find . -type f -name "*.pyc" -delete -print
  find . -type f -iname '.coverage' -exec rm -rf \{\} + -print
  find . -type d -iname '.pytest_cache' -exec rm -rf \{\} + -print
  find . -type d -iname '__pycache__' -exec rm -rf \{\} + -print
  find . -type d -iname '.benchmarks' -exec rm -rf \{\} + -print
  find . -type d -iname '*.egg-info' -exec rm -rf \{\} + -print
  find . -type d -iname '.mypy_cache' -exec rm -rf \{\} + -print
end
