function mdview -d 'Display a Markdown file'
    pandoc -s -f markdown -t man $argv | groff -Tutf8 -man - | less -XRF
end
