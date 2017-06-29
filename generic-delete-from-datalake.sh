#!/bin/bash

dl=

if [ $# -ne 2 ]; then
  echo 1>&2 "Usage: $0 <dir> <number of files to keep>"
  exit 1
fi

no_files_in_dir=`/opt/datalake-1.4/bin/dl -ls $dl/$1 | wc -l`
echo "files in dir $1 :" `expr $no_files_in_dir - 2`

files_to_delete=`expr $no_files_in_dir - $2 - 2`
echo "files to delete" $files_to_delete
files_to_delete2=`expr $files_to_delete - 2 `

if [ $files_to_delete -gt 0 ]; then
 torm=`/opt/datalake-1.4/bin/dl -ls $dl/$1 | tail -n $files_to_delete | awk '{print $8}' `
 # desc: `| tail -n $tail_ | head -n $files_to_delete | awk '{print $8}' `
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
