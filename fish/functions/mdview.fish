function mdview -d "Markdown viewer for terminal"
  pandoc -s -f markdown -t man $argv | groff -Tutf8 -man - | less -XRF
end
