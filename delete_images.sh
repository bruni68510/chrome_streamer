#!/bin/sh
docker images -q | grep -v 97b0f69ffdb9 | xargs docker rmi -f 
