#!/bin/sh
localDir="/Users/$USER/Pictures/BingWallpaper"
filenameRegex=".*"$(date "+%Y-%m-%d")".*jpg"
log="$localDir/bin/log.log"

if [ ! -d "$localDir" ]; then
    mkdir "$localDir"
fi

findResult=$(find $localDir -regex $filenameRegex)

if [ ! -n "$findResult" ]; then
    baseUrl="cn.bing.com"
    html=$(curl -L -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36 Edg/111.0.1661.51" $baseUrl)
    imgurl=$(echo "$html" | grep 'preload' | grep -oE 'https://[a-zA-Z0-9./?=_-]*_1920x1080.jpg' | head -n 1)
    imgurl=$(echo $imgurl | sed 's/1920x1080/UHD/') 
    echo "img: $imgurl"
    filename=$(echo $imgurl | sed -n 's/.*id=OHR\.\([^&]*\).*/\1/p')
    echo $filename
    localpath="$localDir/$(date "+%Y-%m-%d")-$filename"
    curl --output $localpath -H 'Cache-Control: no-cache' $imgurl

    des=$(expr "$(echo "$html" | grep "id=\"sh_cp\" class=\"sc_light\"")" : '.*id=\"sh_cp\".*title=\"\(.*\)\" aria-label=\"主页图片信息\"')

    osascript -e "                              \
        tell application \"System Events\" to   \
            tell every desktop to               \
                set picture to \"$localpath\""
    osascript -e "display notification \"$des\" with title \"BingWallpaper\""
    echo "$(date +"%Y-%m-%d %H:%M:%S") Downloaded $filename" >> $log
else
    echo "$(date +"%Y-%m-%d %H:%M:%S") Exist" >> $log
    exit 0
fi
