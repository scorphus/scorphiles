function retrieve-website -a url \
                          -d "Retrieve a website for offline view with wget"
  wget --mirror \
    --page-requisites \
    --convert-links \
    --span-hosts \
    --domains (echo $url | sed "s|[^:]*://\([^/]*\).*|\1|") \
    $url
    # --reject pattern-list \
end
