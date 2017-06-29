#!/bin/bash
#author: Cosmin Pintoiu
#date: 29.06.2017

HOST=
LOGIN=
PASSWORD=
BUCKET=
HOME=/opt/couchbase/bin
tokeep=6
dl_folder=backup
dl=

date
cd $HOME
now=$(date +"%m_%d_%Y")

./cbbackupmgr config --archive /tmp/backup_data_$now --repo cluster
if [ $? -eq 0 ]; then
    echo "BK folder created succesfully"
else
	echo "folder already exists"
	exit 1
fi

sleep 2s
echo "start backup:"
./cbbackupmgr backup --archive /tmp/backup_data_$now --repo cluster --cluster couchbase://127.0.0.1 --username $LOGIN --password $PASSWORD
if [ $? -eq 0 ]; then
    echo "BK created"
else
	echo "BK failed"
#	exit 1
fi

sleep 2
echo "archive bck"
tar -zcvf /tmp/backup_data_${now}.tar.gz /tmp/backup_data_$now
if [ $? -eq 0 ]; then
    echo "gzip created"
else
	echo "gzip failed"
	exit 1
fi

echo "list datalake:"
/opt/datalake-1.4/bin/dl -ls $dl

sleep 1
echo "upload datalake using dl cmd tool"
/opt/datalake-1.4/bin/dl -put /tmp/backup_data_${now}.tar.gz $dl/$dl_folder
if [ $? -eq 0 ]; then
    echo "upload to datalake succesfully"
else
	echo "upload failed"
	exit 1
fi

echo "remove !!! older backups from datalake. we only keep: $tokeep"

no_files_in_dir=`/opt/datalake-1.4/bin/dl -ls $dl/$dl_folder | wc -l`
echo "files in dir $dl_folder :" `expr $no_files_in_dir `

files_to_delete=`expr $no_files_in_dir - $tokeep - 2`
echo "files to delete" $files_to_delete
tail_=`expr $no_files_in_dir - 2`
if [ $files_to_delete -gt 0 ]; then
 torm=`/opt/datalake-1.4/bin/dl -ls $dl/$dl_folder | tail -n $tail_ | head -n $files_to_delete | awk '{print $8}' `
 for item in $torm
 do 
 	#echo $item " remove current item"
 	echo `/opt/datalake-1.4/bin/dl -rm -skipTrash $item`
		 if [ $? -eq 0 ]; then
		    echo "item removed from dl"
		 else
			echo "failed to remove form dl"
			exit 1
		 fi
	sleep 1s
done
fi

echo "remove !!! backup from couchbase server"
rm -rf /tmp/backup_data_${now}*
if [ $? -eq 0 ]; then
		    echo "item removed from local fs"
		 else
			echo "failed to remove form local fs"
	exit 1
fi

sleep 1s
echo " files in datalake:"
echo `/opt/datalake-1.4/bin/dl -ls $dl/$dl_folder`
echo " done !"
