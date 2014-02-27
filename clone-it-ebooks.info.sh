#!/bin/bash
mkdir dump html images pdf
for (( i=$1;i<=$2;i++ ));do
        lynx -source http://it-ebooks.info/book/$i >site.html
        lynx -dump site.html >site.txt
        LINK=`grep go.php site.txt | awk '{print $NF}' | awk -F\/ '{print "http://www.it-ebooks.info/" $NF}'`
        NOME=`grep "QR code" site.txt | sed "s/   QR code - //g" | sed "s/\//-/g" | sed "s/ /_/g"`
        DOWN=`echo $LINK|awk -F\/ '{print $NF}'`
        #|egrep "go.php|QR code"|sed "s/QR code - //g"
        if [ "$NOME" != "" ];then
                mv site.html html/"${NOME}.html"
                echo "html/${NOME}.html"
                LINKIMG=`grep 'src="/images/ebooks/' html/"${NOME}.html" |awk -F\= '{print $2}'|awk -F\" '{print$2}'`
                echo "$LINKIMG"
                cd imagens
                wget -c http://www.it-ebooks.info/${LINKIMG}
                cd ..
        fi
        if [ ! -f pdf/"${NOME}_${i}.pdf" ] && [ "$NOME" != "" ];then
                echo "Baixando $i -  $NOME.pdf"
                wget $LINK #2>baixando.wget
                mv $DOWN pdf/"${NOME}_${i}.pdf" 
                mv site.txt dump/"${NOME}_${i}.html"
        else
                echo "Ja temos ${NOME}_$i ou o livro ainda nao existe"
        fi
done
