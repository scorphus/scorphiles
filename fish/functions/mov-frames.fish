function mov-frames -a video dir -d "Extract frames from a .mov video into a directory (creates dir if missing)"
    if test -z "$video" -o -z "$dir"
        echo "Usage: mov-frames <video> <output-dir>"
        return 1
    end
    if not type ffmpeg > /dev/null 2>&1
        echo "Install ffmpeg"
        return 1
    end
    if not test -f "$video"
        echo "Video not found: $video"
        return 1
    end
    mkdir -p "$dir"
    find "$dir" -maxdepth 1 -type f -name 'f*.png' -delete
    ffmpeg -y -i "$video" -vf "fps=4,scale=1000:-2" "$dir/f%03d.png" 2>&1 | tail -1
    set -l n (find "$dir" -maxdepth 1 -type f -name 'f*.png' | wc -l | string trim)
    echo "Extracted $n frames to $dir"
end
