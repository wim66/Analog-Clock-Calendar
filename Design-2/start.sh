#!/bin/sh


killall conky
cd "$(dirname "$0")"

sleep 1
conky -c conky.conf &