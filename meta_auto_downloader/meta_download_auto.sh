#!/bin/bash

#### Meta Download script for Automotive Korea
#### gunwoow.qti.qualcomm.com
####

CUR_PATH=/local2/mnt/workspace
FINDBUILD=/prj/qct/asw/qctss/linux/ubuntu/14.04/bin/FindBuild
PREFIX=/prj/qct/asw/crmbuilds

BUILD_PATH=common/build
BUILD_PATH_ALT=common/tools/meta
PYTHON_GEN_MIN=gen_minimized_build.py

META_BUILD_ROOT=$CUR_PATH/META_BUILD
WATCH_DIR=$CUR_PATH/watch

META_LOG=$WATCH_DIR/_meta_down.log

echo_meta(){
	echo $@
	echo $@  [`date`] >> $META_LOG
}

copy_meta_min(){
	BUILD_ID=$1
	META_MIN_OUTPUT=$META_BUILD_ROOT/$BUILD_ID
	mv $WATCH_DIR/$BUILD_ID $WATCH_DIR/$BUILD_ID.doing

	if [[ -d $META_MIN_OUTPUT ]]; then
		echo_meta ""
		echo_meta "*** $BUILD_ID already exists.."
		mv $WATCH_DIR/$BUILD_ID.doing $WATCH_DIR/$BUILD_ID.check
		return ;
	fi

	FIND_RESULT=$($FINDBUILD -long $BUILD_ID | grep "LinuxPath")
	echo_meta $FIND_RESULT

    if [[ $FIND_RESULT = "" ]] || [[ $FIND_RESULT = *"No Location"* ]]; then
        echo_meta "No such Build ID and Location found! : $1"
		mv $WATCH_DIR/$BUILD_ID.doing $WATCH_DIR/$BUILD_ID.check
        return ;
    fi

	LINUX_PATH=$(echo $FIND_RESULT | grep -oP '(?=/).*')
#echo_meta "Final LINUX_PATH :  $LINUX_PATH"

	TOOL_PATH=$LINUX_PATH/$BUILD_PATH/$PYTHON_GEN_MIN
#echo_meta "Python Tool PATH : $TOOL_PATH"

	if [ ! -f $TOOL_PATH ]; then
		echo_meta "Trying to find the alternative tool path : $PYTHON_GEN_MIN"
		TOOL_PATH=$LINUX_PATH/$BUILD_PATH_ALT/$PYTHON_GEN_MIN
#echo_meta "ALT Python Tool PATH : $TOOL_PATH"
	fi

	if [ ! -f $TOOL_PATH ]; then
		echo_meta "No such file found  : $PYTHON_GEN_MIN"
		mv $WATCH_DIR/$BUILD_ID.doing $WATCH_DIR/$BUILD_ID.check
		return ;
	fi

	mkdir -p $META_MIN_OUTPUT
	chmod 777 $META_MIN_OUTPUT
	GEN_TOOL_VER=$(grep "gen_minimized_build.py --dest=<dest>" $TOOL_PATH)

	if [[ $GEN_TOOL_VER = "" ]]; then
		OUTPUT_OPTION=""
	else
		OUTPUT_OPTION="--dest="
	fi

	echo_meta "Run command :python $TOOL_PATH $OUTPUT_OPTION$META_MIN_OUTPUT"
	python $TOOL_PATH $OUTPUT_OPTION$META_MIN_OUTPUT

	mv $WATCH_DIR/$BUILD_ID.doing $WATCH_DIR/$BUILD_ID.done
	echo_meta "Download done : $BUILD_ID"
}

script_start(){
	mkdir -p $WATCH_DIR
    cd $WATCH_DIR
	while true
	do
		list=`ls --hide=*.done --hide=*.doing --hide=*.check --hide=*.log --hide=*.txt --hide=*.lock`
		for tmp in $list
		do
			echo "" >> $META_LOG
			echo "-------------------------------------------------------------------------------------------------" >> $META_LOG
			echo_meta "START Downloading --  Meta Build ID: $tmp"
			echo "-------------------------------------------------------------------------------------------------" >> $META_LOG

			## Main Function START
			copy_meta_min $tmp
		done
		sleep 5
	done
}

case "$1" in
	start)
		script_start &
		;;
	stop)
		;;
	*)
		echo_meta "Usage: $0 start | stop"
		;;
esac
