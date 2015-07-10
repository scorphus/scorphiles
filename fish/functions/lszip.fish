function lszip -a zip -d 'List content of a zip file'
    unzip -l $zip | less -XRF
end
