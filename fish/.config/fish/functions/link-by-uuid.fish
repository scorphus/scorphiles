function link-by-uuid -d "Link components by UUID"
    set -l components $argv[-1]
    set -l configs $argv[1..-2]
    for config in $configs
        extract_yaml.py $config uuid | read -l uuid
        if [ "$uuid" != "" ]
            set -l src (dirname (realpath $config))
            set -l dst $components$uuid
            echo Linking $uuid
            ln -s $src $dst
        end
    end
end
