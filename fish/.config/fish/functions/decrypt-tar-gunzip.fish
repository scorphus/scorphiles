function decrypt-tar-gunzip -d "Compress w/ tar and gzip and encrypt w/ openssl"
  test (count $argv) -lt 2; or contains -- "--help" $argv; or contains -- "-h" $argv; and begin
    echo "Usage: decrypt-tar-gunzip <tv|x> <compressed_name>"
    return 0
  end
  openssl aes-256-cbc -d -in $argv[2] | tar $argv[1]z
end
