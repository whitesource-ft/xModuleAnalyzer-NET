#!/bin/bash
# For use with linux actions in https://github.com/whitesource-ft/ws-examples/tree/main/Prioritize/DotNet/Multi-Module

for csproject in  $(find ./src -type f \( -wholename "*.csproj" ! -wholename "*build*" ! -wholename "*test*" ! -wholename "*host*" ! -wholename "*migration*" \))

do
echo "Found" $csproject 
CSPROJ=$(basename $csproject .csproj)

find ./ -type f \( -wholename "*/bin/Release/*/$CSPROJ.dll" ! -wholename "*build*" ! -wholename "*test*" ! -wholename "*host*" ! -wholename "*migration*" \) -print >> multi-module.txt

done

file="./multi-module.txt"
dlls=`cat $file`

for DLL in $dlls;

do 
echo "appPath:" $DLL
DIR=$(echo $DLL | awk -F/bin '{print $1}')
echo "directory:" $DIR
PROJECT=$(basename $DLL .dll)
echo "PROJECT:" $PROJECT
java -jar wss-unified-agent.jar -appPath $DLL -d $DIR -project $PROJECT

done
