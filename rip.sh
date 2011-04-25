#!/bin/sh

cdparanoia -vzl -O +48 [::]- CDImage.wav
cdrdao read-toc disk.toc
cueconvert -i toc disk.toc disk.cue
cuebreakpoints disk.cue | shnsplit -o wav CDImage.wav
lame -h -b 320 split-track*.wav
cuetag disk.cue split-track*.mp3
