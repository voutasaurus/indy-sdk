#!/bin/bash -xe

if [ "$1" = "--help" ] ; then
  echo "Usage: <version> <key> <type> <number>"
  return
fi

version="$1"
key="$2"
type="$3"
number="$4"

[ -z $version ] && exit 1
[ -z $key ] && exit 2
[ -z $type ] && exit 3
[ -z $number ] && exit 4

mkdir indy-cli-zip
mkdir indy-cli-zip/lib
cp ./target/release/*.dll ./indy-cli-zip/lib/
cp ./target/release/*.exe ./indy-cli-zip/lib/
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::CreateFromDirectory('indy-zip-cli', 'indy-cli_$version.zip'); }"
rm -rf ./indy-cli-zip

cat <<EOF | sftp -v -oStrictHostKeyChecking=no -i $key repo@192.168.11.115
mkdir /var/repository/repos/windows/indy-cli
mkdir /var/repository/repos/windows/indy-cli/master
mkdir /var/repository/repos/windows/indy-cli/rc
mkdir /var/repository/repos/windows/indy-cli/stable
mkdir /var/repository/repos/windows/indy-cli/$type/$version-$number
cd /var/repository/repos/windows/indy-cli/$type/$version-$number
put -r indy-cli_"$version".zip
ls -l /var/repository/repos/windows/indy-cli/$type/$version-$number
EOF