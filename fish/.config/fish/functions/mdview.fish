function mdview -d "Markdown viewer for terminal"
  pandoc -s -f markdown -t man $argv | groff -kTutf8 -man - | less -XRF
end
