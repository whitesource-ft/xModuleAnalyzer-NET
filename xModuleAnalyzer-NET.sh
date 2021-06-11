#!/bin/bash
# For use with linux actions in https://github.com/whitesource-ft/ws-examples/tree/main/Prioritize/DotNet/Multi-Module
# Modify SEARCHDIR & RELEASEDIR before running
SEARCHDIR=$(PWD)
RELEASEDIR=*bin*
for csproject in  $(find $SEARCHDIR -type f \( -wholename "*.csproj" ! -wholename "*build*" ! -wholename "*test*" ! -wholename "*host*" ! -wholename "*migration*" \))

do
echo "Found" $csproject 
CSPROJ=$(basename $csproject .csproj)

find ./ -type f \( -wholename "$RELEASEDIR$CSPROJ.dll" ! -wholename "*build*" ! -wholename "*test*" ! -wholename "*host*" ! -wholename "*migration*" \) -print >> multi-module.txt

done

file="./multi-module.txt"
dlls=`cat $file`

for DLL in $dlls;

do 
echo "appPath:" $DLL
DIR=$(echo $DLL | awk -F $RELEASEDIR '{print $1}')
echo "directory:" $DIR
PROJECT=$(basename $DLL .dll)
echo "PROJECT:" $PROJECT
java -jar wss-unified-agent.jar -appPath $DLL -d $DIR -project $PROJECT

done
