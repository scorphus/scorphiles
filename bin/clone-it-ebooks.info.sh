#!/bin/bash
mkdir dump html images pdf
for (( i=$1;i<=$2;i++ ));do
        lynx -source http://it-ebooks.info/book/$i >site.html
        lynx -dump site.html >site.txt
        LINK_PDF=`grep '<tr><td>Download:' site.html | awk -F"'" '{print $2}'`
        LINK_IMG=`grep 'src="/images/ebooks/' site.html |awk -F\= '{print $2}'|awk -F\" '{print$2}'`
        PUBLISHER=`grep 'Publisher:' site.txt | awk -F']' '{print $2}' | sed -e 's/[^[:alnum:]]/_/g' | tr -s '_'`
        NOME=`grep "QR code" site.txt | sed "s/   QR code - //g" | sed -e 's/[^[:alnum:]]/_/g' | tr -s '_'`
        mv site.html html/"${NOME}.html"
        mv site.txt dump/"${NOME}_${i}.html"
        if [ "$NOME" != "" ];then
                echo "Baixando $i - $NOME.pdf"
                cd images
                wget -c http://www.it-ebooks.info/${LINK_IMG}
                cd ..
                mkdir "pdf/${PUBLISHER}"
                wget -c $LINK_PDF --referer=http://it-ebooks.info/book/$i -O "pdf/${PUBLISHER}/${NOME}_${i}.pdf"
        fi
done
