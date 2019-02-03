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

# Validate message
if [ -z "$MESSAGE" ]; then
	echo "No release note specified"
	exit 1
fi

# Change version and release note in haxelib.json
echo "Update version to $VERSION"
EXTRA_PATTERN="s/-D react=[0-9]+.[0-9]+.[0-9]+/-D react=$VERSION/g"

V=$VERSION RN=$MESSAGE jq '. + {"version": env.V, "releasenote": env.RN}' ./haxelib.json | sponge ./haxelib.json
V=$VERSION jq '. + {"version": env.V}' ./mdk/info.json | sponge ./mdk/info.json
sed -E -i "$EXTRA_PATTERN" ./extraParams.hxml
MESSAGE=" - $MESSAGE"

# Tag, commit and push to trigger a new CI release
git add ./haxelib.json
git add ./mdk/info.json
git add ./extraParams.hxml
git commit -m "$VERSION$MESSAGE"
git push fork next
git tag $VERSION
git push fork $VERSION
