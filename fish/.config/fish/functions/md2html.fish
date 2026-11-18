function md2html -a md html -d "Convert Markdown to HTML"
    if not type -q pandoc
        echo "Install pandoc"
        return 1
    end
    test -z "$html"; and set html -
    pandoc --standalone --from markdown --to html -o $html $md
end
