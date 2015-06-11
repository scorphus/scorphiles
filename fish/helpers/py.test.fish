function py.test-cov-html -d 'Run py.test missing with html coverage'
    py.test --cov-report html --cov $argv tests/
    open htmlcov/index.html
end

function py.test-cov-missing -d 'Run py.test missing with missing coverage'
    py.test --cov-report term-missing --cov $argv tests/
end

function py.test-cov-all -d 'Run py.test missing with missing and html coverage'
    py.test --cov-report term-missing --cov-report html --cov $argv tests/
end
