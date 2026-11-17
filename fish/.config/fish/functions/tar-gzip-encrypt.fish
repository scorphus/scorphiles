function tar-gzip-encrypt -d "Compress w/ tar and gzip and encrypt w/ openssl"
  test (count $argv) -lt 2; or contains -- "--help" $argv; or contains -- "-h" $argv; and begin
    echo "Usage: tar-gzip-encrypt <compressed_name> <file[ file ...]>"
    return 0
  end
  tar cz $argv[2..-1] | openssl enc -aes-256-cbc -e > $argv[1].tar.gz.enc
end
