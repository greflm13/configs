#!/usr/bin/env bash

echo ""
magnet=$(echo "$1" | sed -n -e 's/^.*magnet//p' | sed 's/%26/\&/g' | sed 's/%3D/=/g' | sed 's/%25/%/g')
echo "https://torrent.sorogon.eu/#download=magnet$magnet"
