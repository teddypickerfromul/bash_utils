#!/bin/bash

cd "/media/MediaDrive/x-files (ort)/x-files - 2 season - ort [torrents.ru]"

isplugged=`ls -l /dev/disk/by-uuid/ | grep -c CDF2-6BE2`
if [ $isplugged -eq "1" ]; then
        counter=$1
        until [  $counter -lt 0 ]; do
            file="./last.txt";
            read -n 2 var < "$file";
            if [ ${var:0:1} -eq "0" ]
	            then
		            last=${var: -1}
	            else
		            last=$var
            fi

            for movie in 2x*$last*.avi; do 
                mencoder "$movie" -o "/media/disk/Videos/xfiles/$movie.mp4" -noskip -of lavf -lavfopts format=mp4 -ovc lavc -oac lavc -lavcopts vcodec=mpeg4:vbitrate=700:acodec=libfaac:abitrate=128:vglobal=3:aglobal=3 -vf dsize=640:360:0,scale=0:0 &>/dev/null 
                echo $last
                notify-send "$movie отправил" -t 3000
                #last=`expr $last + 1`    
                #echo $last > $file
            done
        
            last=`expr $last + 1`
            echo $last > $file
            echo $last
            let counter-=1
        done
   else
        notify-send "Трубка отключена!" -t 5000
fi                         	    
