#!/bin/bash

filename=`basename "$1"`
directory=`dirname "$1"`

filename3=${filename%.*} # remove .pile
filename2=${filename3%.*} # remove .crap
filename1=${filename2%.*} # remove .tags

extension3=${filename##*.} # should be "pile"
extension2=${filename3##*.} # should be "crap"
extension1=${filename2##*.} # should be "tags"

echo "$extension3"
echo "$extension2"
echo "$extension1"

echo "$directory/$filename1"

open "$directory/$filename1"
