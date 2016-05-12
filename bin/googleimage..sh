#!/bin/bash

#    // options: 'stdout', 'file' (set in config.logFile) or 'none'
#    // options: 'json' or 'csv'
#    // options: 'stdout' or 'file' (set in config.outFile)
#    // single URL or array
#    // single function or array, evaluated in the client

siteq=""
imageurl=$1

if [ "$#" == "2" ]
then
    siteq="q=$2&"
fi

crawl() {
    page=""
    if [ "$#" == 1 ]
    then
        page=$1
    fi

    script="
    pjs.config({ 
        log: 'stdout',
        format: 'json',
        writer: 'file',
        outFile: '/tmp/output.json'
    });

    pjs.addSuite({
        url: 'https://images.google.com.hk/searchbyimage?${siteq}image_url=${imageurl}${page}',
        scraper: function() {
            var list=[];
            \$('div.rc > h3.r > a').each(
                function(){list.push(\$(this).attr('href'));}
            );
            return list;
        }
    });
    "

    echo $script > /tmp/script.js

    ./pjscrape.sh /tmp/script.js 1>/dev/null

}

crawl 
result=`cat /tmp/output.json`

p=0
while [ "[]" != "${result}" ] && [ "${p}" != "100" ]
do
    echo $result
    p=$(expr $p + 10)
    
    crawl "&start=${p}"
    result=`cat /tmp/output.json`
done
