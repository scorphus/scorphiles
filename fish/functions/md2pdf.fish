function md2pdf -a md pdf -d "Convert Markdown to PDF"
    if not type pandoc > /dev/null 2>&1
        echo "Install pandoc"
        return
    end
    if not type wkhtmltopdf > /dev/null 2>&1
        echo "Install wkhtmltopdf"
        return
    end
    type gmktemp > /dev/null 2>&1; or alias mktemp=gmktemp
    test -z "$pdf"; and set pdf "-"
    set -l tmp (gmktemp -t md2pdf_XXXXXXXX.html)
    pandoc --standalone --from markdown --to html -o $tmp $md
    wkhtmltopdf $tmp $pdf
    rm -f $tmp
end
