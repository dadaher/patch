# patch
./createPatchWithNewFiles.sh $old $new
./CommunChangedNonJarFiles.sh $old $new
./CopyTnexusJarsToPatch.sh $old $new
./CommunChangedJarFiles.sh $old $new
./Complete3rdPJars.sh PATCH /var/lib/jenkins/thirdparties/lib/
./createDeletedFileReport.sh $old $new

-delete compact from PATCH
-add deleted files report to PATCH
