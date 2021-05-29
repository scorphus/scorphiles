function md2pdf -a md pdf -d "Convert Markdown to PDF"
    test (uname) = Darwin; and alias mktemp gmktemp
    if not type pandoc > /dev/null 2>&1
        echo "Install pandoc"
        return
    end
    if not type wkhtmltopdf > /dev/null 2>&1
        echo "Install wkhtmltopdf"
        return
    end
    test -z "$pdf"; and set pdf "-"
    set -l tmp (mktemp -t md2pdf_XXXXXXXX.html)
    mv $tmp .
    set tmp (basename $tmp)
    pandoc --standalone --from markdown --to html -o $tmp $md
    wkhtmltopdf $tmp $pdf
    rm $tmp
end
