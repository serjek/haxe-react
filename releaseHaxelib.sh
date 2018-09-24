#!/bin/sh
rm -f haxe-react.zip
zip -r haxe-react.zip src haxelib.json README.md changes.md doc extraParams.hxml
# haxelib submit haxe-react.zip $1 $2 --always
haxelib submit haxe-react.zip
