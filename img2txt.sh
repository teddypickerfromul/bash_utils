#!/bin/bash
#===============================================================================
#
#          FILE:  img2txt.sh
# 
#         USAGE:  ./img2txt.sh 
# 
#   DESCRIPTION:  Simple image to plain text converter using tesseract and imagemagik tools
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  --- tesseract-ocr, convert
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Yuri Kuznetsov (), teddypickerfromul@gmail.com
#       COMPANY:  /dev/null Inc.
#       VERSION:  1.0
#       CREATED:  28.12.2012 19:32:01 MSK
#      REVISION:  ---
#===============================================================================

export TESSDATA_PREFIX=/usr/share/tesseract-ocr/

DEFAULT_OUTPUT_DIR="/text"
DEFAULT_PREPARED_IMAGES_DIR="/prepared"

CURRENT_PATH=`pwd`

mkdir ${CURRENT_PATH}${DEFAULT_PREPARED_IMAGES_DIR}
mkdir ${CURRENT_PATH}${DEFAULT_OUTPUT_DIR}

FILES_NUMBER=`ls ${CURRENT_PATH} *.jpg | wc -l`

index=0

for image in *.jpg; do
    mv $image "image"${index}".jpg"
    echo "image"${index}".jpg"  
    index=`expr $index + 1`
done

for image in *.jpg; do
    convert -density 300 -units PixelsPerInch -type Grayscale +compress $image ${CURRENT_PATH}${DEFAULT_PREPARED_IMAGES_DIR}/${image%.*}".tiff";
    echo $image" grayscaled. Trying to tesseract it";
    tesseract ${CURRENT_PATH}${DEFAULT_PREPARED_IMAGES_DIR}/${image%.*}".tiff" ${CURRENT_PATH}${DEFAULT_OUTPUT_DIR}/${image%.*} -l rus;
done

cd ${CURRENT_PATH}${DEFAULT_OUTPUT_DIR}

for item in *.txt; do
    unix2dos $item $item        
done
