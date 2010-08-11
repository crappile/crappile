#!/usr/bin/env bash
#########  there was no /bin/env  on this Mac OS

CRAP_DIR="$HOME/.dir with spaces/.crap_dir/"
CP_TAGS_FILE_SUFFIX=".tags.crap.pile"
CP_LAST_LINE_UPON_SUCCESS="Done."

# serious todo!
# must add instructions that we can output from "print_help"
print_help () 
{
    echo Welcome to crappile.
    echo Have a nice day.

    return 0
}

# Gets a 10-char string suitable for a filename.
# Return value is in $CP_RANDOM_STRING_RESULT
get_random_string ()
{
    CP_RANDOM_STRING_RESULT=`head -100 /dev/urandom | uuencode -m - | awk '{ print substr($1,1,10) }' | grep -v [/=+] | grep -v 'begin' | head -1`
}

# Creates a new, empty file in $CRAP_DIR .
# Return value is in $CP_FULL_PATH_TO_NEW_RANDOM_FILE
# If file creation fails, $CP_FULL_PATH_TO_NEW_RANDOM_FILE
# will be set to the empty string.
make_empty_crappile_freeform_file ()
{
    get_random_string

    local LOOP_COUNT=0
    CP_FULL_PATH_TO_NEW_RANDOM_FILE=""

    while true 
    do
	local LOOP_COUNT=$(( LOOP_COUNT += 1 )) 

	# If we haven't come up with a unique new file after
	# this many tries, then just give up.
	if [ "$LOOP_COUNT" == "50" ]
        then
	    break
        fi

	if [ -e  "$CRAP_DIR/$CP_RANDOM_STRING_RESULT" ]
        then
	    false
	    # nothing we can do yet.
        else
	    touch "$CRAP_DIR/$CP_RANDOM_STRING_RESULT"

	    # check to make sure the 'touch' command succeeded.
	    if [ "$?" -eq "0" ]
            then
		CP_FULL_PATH_TO_NEW_RANDOM_FILE="$CRAP_DIR/$CP_RANDOM_STRING_RESULT"
		break
            fi
        fi
	
    done	
}

# First parameter should be the full path to the CONTENT file.
# Result is returned in $CP_FULL_PATH_TO_ADJACENT_FILE .
# If the result is an empty string, then file creation failed.
make_adjacent_tags_file ()
{
    CP_FULL_PATH_TO_ADJACENT_FILE=""
    
    local TARGET_DIR=`dirname "$1"`
    local TARGET_BASE_FILE=`basename "$1"`

    touch "$TARGET_DIR/$TARGET_BASE_FILE$CP_TAGS_FILE_SUFFIX"

    # check to make sure the 'touch' command succeeded.
    if [ "$?" -eq "0" ]
    then
	CP_FULL_PATH_TO_ADJACENT_FILE="$TARGET_DIR/$TARGET_BASE_FILE$CP_TAGS_FILE_SUFFIX"
    fi
}

# First argument is the tag.
# Second argument is the tag file.
# Returns 0 on success, and >0 otherwise.
add_one_tag_to_tag_file ()
{
    echo "$1" >> "$2"
    
    if [ "$?" -ne "0" ]
    then
        return 1    
    else
        return 0
    fi
}

# First argument is the prompt text.
# Second argument is the full path to the tags file.
# Returns 0 on success, and >0 otherwise.
populate_one_tags_file ()
{
    local PROMPT_SHOWN_TO_USER=$1
    local TAGS_FILE=$2

    echo
    echo $PROMPT_SHOWN_TO_USER

    while read  -a array; do 

	for word in "${array[@]}"; do 
	    true # maybe do something here later
	done

	local WHOLE_LINE="${array[@]}"
	add_one_tag_to_tag_file "$WHOLE_LINE"  "$TAGS_FILE"

	# check to make sure the 'add_one_tag_to_tag_file' command succeeded.
	if [ "$?" -ne "0" ]
	then
	    echo "Error writing tags."
	    #break
            return 1
	fi
    done

    return 0
}


do_freeform_behavior ()
{
    make_empty_crappile_freeform_file
    local FREEFORM_FILE=$CP_FULL_PATH_TO_NEW_RANDOM_FILE

    make_adjacent_tags_file "$FREEFORM_FILE"
    local TAGS_FILE=$CP_FULL_PATH_TO_ADJACENT_FILE

    local ERROR_STATUS=""

    if [[ "$FREEFORM_FILE" == "" || "$TAGS_FILE" == "" ]]
    then
	echo "Failed to create the storage file and/or the tags file."
    else

	echo
	echo "Enter the plain-text content you want to store:"

	while read  -a array; do 

	    for word in "${array[@]}"; do 
		true # maybe do something here later
	    done

	    local WHOLE_LINE="${array[@]}"
	    echo "$WHOLE_LINE" >> "$FREEFORM_FILE"

	    # check to make sure the 'echo' command succeeded.
	    if [ "$?" -ne "0" ]
            then
		echo "Error writing content to the storage file."
		local ERROR_STATUS="error"
		break
            fi
	done

	if [ "$ERROR_STATUS" != "" ]
        then
	    # we already displayed error message earlier.
	    false
	else

	    populate_one_tags_file "Enter tags. One tag per line:" "$TAGS_FILE"

	    # check to make sure the 'populate_one_tags_file' command succeeded.
	    if [ "$?" -ne "0" ]
	    then
		local ERROR_STATUS="error"
	    fi

	fi # if [ "$ERROR_STATUS" != "" ]

    fi # if [[ "$FREEFORM_FILE" == "" || "$TAGS_FILE" == "" ]]

    if [ "$ERROR_STATUS" == "" ]
    then
        echo "New content stored in $FREEFORM_FILE"
        echo $CP_LAST_LINE_UPON_SUCCESS
    fi
}

# Returns 0 upon success.
# Returns >0 otherwise.
# First argument must be full path to file to be stored.
# Second argument, if present, must be a NON-empty string with a default tag.
# (The presence of the second argument causes us to SKIP PROMPTING for tags.)
do_one_file ()
{
    local BASE_NAME=`basename "$1"`
    local TARGETED_DESTINATION="$CRAP_DIR/$BASE_NAME"
    local RESULT="1"

    # see if $1 is a valid file.
    if [ ! -e "$1" ]
    then
        echo "Error. Invalid file $1"        
    
    # see if basename $1 already exists in CRAP_DIR
    elif [ -e "$TARGETED_DESTINATION" ]
    then
        echo "Error. Preexisting file $BASE_NAME"
        echo "Try re-naming the file then try starting over."
    else
    # try to create basename $1 + CP_TAGS_FILE_SUFFIX in CRAP_DIR
    
	make_adjacent_tags_file "$TARGETED_DESTINATION"

	local TAGS_FILE=$CP_FULL_PATH_TO_ADJACENT_FILE

	if [ "$TAGS_FILE" == "" ]
        then
            echo "Cannot add $BASE_NAME due to failure to create tags file."
        else
            local RESULT="0"
        fi
    fi

    # copy $1 into CRAP_DIR
    if [ "$RESULT" -eq "0" ]
    then
        cp "$1" "$CRAP_DIR"

	# check to make sure the 'cp' command succeeded.
	if [ "$?" -ne "0" ]
	then
	    local RESULT="1"
	fi
    fi

    # ask for tags for $1
    if [ "$RESULT" -eq "0" ]
    then
	
	if [ "$2" != "" ]
        then
            add_one_tag_to_tag_file "$2" "$TAGS_FILE"
        else
	    populate_one_tags_file "Enter tags for $BASE_NAME. One tag per line:" "$TAGS_FILE"
        fi

	# check to make sure the 'populate_one_tags_file' command succeeded.
	if [ "$?" -ne "0" ]
	then
	    local RESULT="1"
	fi
    fi 

    # be sure to return 0 or 1
    if [ "$RESULT" -eq "0" ]
    then
        return 0
    else
        return 1
    fi
}

do_file_by_file_behavior ()
{
    while [ "$1" != "" ]
    do
	local the_file_name="$1"
	shift

	do_one_file "$the_file_name"

	# check to make sure the 'do_one_file' command succeeded.
	if [ "$?" -ne "0" ]
	then
            return 1
	fi

    done

    echo $CP_LAST_LINE_UPON_SUCCESS
}

do_quiet_quick_behavior ()
{
    local WHO_AM_I=`who am i`
    local HOSTNAME_TXT=`hostname`
    local WHEN_IS_NOW=`date`
    local AUTO_TAG="$WHO_AM_I $HOSTNAME_TXT $WHEN_IS_NOW"

    while [ "$1" != "" ]
    do
	local the_file_name="$1"
	shift

	do_one_file "$the_file_name" "$AUTO_TAG"

	# check to make sure the 'do_one_file' command succeeded.
	if [ "$?" -ne "0" ]
	then
            return 1
	fi

    done

    echo $CP_LAST_LINE_UPON_SUCCESS
}

###################################
E_WRONG_ARGS=85
script_parameters="-e"
Number_of_expected_args=1
if false ; then # begin commented-out portion

if [ $# -ne $Number_of_expected_args ]
then
  echo "Usage: `basename $0` $script_parameters"
  # `basename $0` is the script's filename.
  exit $E_WRONG_ARGS
fi

fi # end commented-out portion
###################################


OUR_ALLOWED_OPTS=ehiq
FINISH_EARLY=0
FREEFORM_ENTRY=0
INTERACTIVE_FILE_BY_FILE=0
QUIET_AND_QUICK=0
DEFAULT=0

if [ "$#" -eq "0" ]
then
    print_help
    FINISH_EARLY=1
else

    while getopts "$OUR_ALLOWED_OPTS" flag
    do
#  echo "$flag" $OPTIND $OPTARG

	if [ "$flag" == "h" ]
	then
	    print_help
	    FINISH_EARLY=1
	elif [ "$flag" == "e" ]
	then
	# zero files. enter some notes, then some tags.
	    FREEFORM_ENTRY=1
	elif [ "$flag" == "i" ]
	then
	# N files, to be automatically followed by N prompts for tags.
	    INTERACTIVE_FILE_BY_FILE=1
	elif [ "$flag" == "q" ]
	then
	# no tag cloud
	    QUIET_AND_QUICK=1
	fi    

    done
fi

################################# commented out
if false
then
#echo "Resetting"
# if you uncomment the next line, you REMOVE any already-consumed args
#shift $((OPTIND-1))
OPTIND=1

while getopts  "$OUR_ALLOWED_OPTS" flag
do
    true
  #echo "$flag" $OPTIND $OPTARG
done
fi
################################# commented out END



if [ "$FINISH_EARLY" == "1" ]
then
    echo $CP_LAST_LINE_UPON_SUCCESS
else
    # next line REMOVES any already-consumed args
    shift $((OPTIND-1))
    if [ "$FREEFORM_ENTRY" == "1" ]
    then
	do_freeform_behavior "$@"
    elif [ "$INTERACTIVE_FILE_BY_FILE" == "1" ]
    then
	do_file_by_file_behavior "$@"
    elif [ "$QUIET_AND_QUICK" == "1" ]
    then
	do_quiet_quick_behavior "$@"
    else #elif [ "$DEFAULT" == "1" ]
	echo "Default behavior (upon lack of all command options) not yet implemented"
    fi

fi



exit 0



