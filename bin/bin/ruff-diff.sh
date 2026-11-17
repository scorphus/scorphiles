#!/bin/bash
# ruff-diff.sh

# Script para rodar ruff apenas nas linhas modificadas em relação a uma branch

# Branch de referência (padrão: origin/dev, mas pode ser passada como argumento)
BASE_BRANCH="${1:-origin/dev}"

echo -e "🔍 Analisando apenas suas mudanças em relação a $BASE_BRANCH...\n"

# Para cada arquivo Python modificado
git diff --name-only "$BASE_BRANCH" | grep '\.py$' | while read -r file; do
    # Pega as linhas modificadas neste arquivo
    git diff "$BASE_BRANCH" --unified=0 -- "$file" 2>/dev/null | \
    grep -E "^@@" | \
    sed -E 's/.*\+([0-9]+)(,([0-9]+))?.*/\1 \3/' | \
    while read -r start count; do
        end=$((start + ${count:-1} - 1))
        # Checa com ruff e filtra apenas essas linhas
        uv run ruff check "$file" 2>/dev/null | \
        awk -v s="$start" -v e="$end" '
            /^[A-Z][A-Z0-9]+/ { error_msg = $0; next }
            /-->/ {
                split($2, parts, ":")
                line_num = parts[2]
                if (line_num >= s && line_num <= e) {
                    if (error_msg) {
                        print error_msg
                    }
                    print $0
                    print ""  # blank line for readability
                    error_msg = ""
                }
            }
        '
    done
done
