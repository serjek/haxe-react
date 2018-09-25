#!/bin/sh
set -e

VERSION=$1
MESSAGE=$2

# Validate version
if [ -z "$VERSION" ]; then
    echo "No version specified"
    exit 1
fi
if [ $(git tag -l "$VERSION") ]; then
    echo "Tag $VERSION already exists"
    exit 1
fi

if [ -z "$MESSAGE" ]; then
	MESSAGE=""
else
	MESSAGE=" - $MESSAGE"
fi

# Change version in haxelib.json and package.json
echo "Update version to $VERSION"
PATTERN="s/\"version\": \"[0-9]+.[0-9]+.[0-9]+\"/\"version\": \"$VERSION\"/g"

case "$(uname -s)" in
   Darwin)
     sed -E -i "" "$PATTERN" ./haxelib.json
     sed -E -i "" "$PATTERN" ./mdk/info.json
     ;;
   *)
     sed -E -i "$PATTERN" ./haxelib.json
     sed -E -i "$PATTERN" ./mdk/info.json
     ;;
esac

# Tag, commit and push to trigger a new CI release
git add ./haxelib.json
git add ./mdk/info.json
git commit -m "$VERSION$MESSAGE"
git push fork next
git tag $VERSION
git push fork $VERSION
