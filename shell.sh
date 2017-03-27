#!/bin/bash -x
if [[ ${SHARE_FROM_URL} == *[0-9]/ ]]; then
  SHARE_FROM_URL=${SHARE_FROM_URL}
elif [[ ${SHARE_FROM_URL} == *[0-9] ]]; then 
  SHARE_FROM_URL=${SHARE_FROM_URL}/ 
else
  echo "===================================> Share Link Error!"
  exit $?
fi

curl -s "${BUILD_URL}submitDescription" --data-urlencode "description=${SHARE_FROM_URL}"
SAVE_DIR=${WORKSPACE}/share/${BUILD_NUMBER}
mkdir -p ${SAVE_DIR}
cd ${SAVE_DIR}
echo ${SHARE_FROM_URL} > 0_share_from.txt

SHARE_ARCHIVE=${SHARE_FROM_URL}/artifact/*zip*/archive.zip
while [ -n "${SHARE_ARCHIVE}" ]
do
    wget ${SHARE_ARCHIVE}
    unzip $(basename $SHARE_ARCHIVE)
    md5_file=`find archive/ -name "md5sum.txt"`
    app_file=`find archive/ -name "APP-SW*.zip"`
    fs_file=`find archive/ -name "FS*.zip"`
    if [ -n "${md5_file}" -a -n "${app_file}" -a -n "${fs_file}" ]; then
        app_file_md5=`md5sum ${app_file} | cut -d " " -f 1`
        fs_file_md5=`md5sum ${fs_file} | cut -d " " -f 1`
        app_share_md5=`cat "${md5_file}" | grep "APP-SW.*\.zip$" | cut -d " " -f 1`
        fs_share_md5=`cat "${md5_file}" | grep "FS.*\.zip$" | cut -d " " -f 1`
        echo $app_share_md5
        echo $fs_share_md5
        echo $app_file_md5
        echo $fs_file_md5
        if [ $app_share_md5 == $app_file_md5 -a $fs_share_md5 == $fs_file_md5 ]; then
            rm $(basename $SHARE_ARCHIVE)
            echo "===================================> Share Complete!"
            break;
        fi
    fi
    echo "===================================> Data Error!"
    rm $(basename $SHARE_ARCHIVE)
done 
exit $?
