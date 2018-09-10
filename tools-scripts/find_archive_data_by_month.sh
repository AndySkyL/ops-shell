#/bin/bash
# Warning: use tar unpress the packages need add "-P" option, eg: tar xfP  [Filename]
# Recommend use  relative path instead of absolute path when use tar command.

DirPath=/root
StartTime='2017-04-01 00:00:00'
EndTime='2017-04-30 23:59:59'
ArchiveDir=/tmp/test
ArchiveFile=/tmp/test.tar.gz

[ ! -d $ArchiveDir ] && mkdir -p $ArchiveDir

# cp file to the des dir
FileFilter(){
for filename in `find $DirPath/*  -newermt "$StartTime" -a ! -newermt  "$EndTime"`
  do 
     cp -r -p $filename  $ArchiveDir/
done

}

FileArchive(){

#tar zcvPf ${ArchiveFile} ${ArchiveDir} 
cd $ArchiveDir && cd ..
tarDir=`echo $ArchiveDir|awk -F '/' '{print $NF}'`
tar zcvf ${ArchiveFile} ${tarDir} 
rm -fr $ArchiveDir

}
main(){
FileFilter
FileArchive
}

main




