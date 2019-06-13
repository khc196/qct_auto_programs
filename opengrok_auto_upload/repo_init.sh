#!/bin/bash

opt=$(getopt -o c: -- "$@");
eval set -- "$opt"
while true; do
	case "$1" in
		-c) PLATFORM=$2; shift 2 ;;
	--) shift; break ;;
	esac
done

#REPO_URL="--repo-url=git://codeaurora.org/tools/repo.git"
PLATFORM=`echo $PLATFORM | tr '[:lower:]' '[:upper:]'`

if [ "$PLATFORM" = CAF ]; then
	echo "Manifest xml : $1"
else
	echo "AU TAG : $1"
fi

if [ "$PLATFORM" = MDM ] || [ "$PLATFORM" = TIZEN ] || [ "$PLATFORM" = AGL ] || [ "$PLATFORM" = CAF ]; then
	echo "PLATFORM : $PLATFORM"
else
	echo "PLATFORM : MSM/APQ"
fi

if [ "$PLATFORM" = MDM ]; then
	echo "repo init -u git://git.quicinc.com/mdm/manifest.git -b refs/tags/$1 -m versioned.xml $REPO_URL"
	repo init -u git://git.quicinc.com/mdm/manifest.git -b refs/tags/$1 -m versioned.xml $REPO_URL
elif [ "$PLATFORM" = TIZEN ]; then
	echo "repo init -u git://git.quicinc.com/tizen/manifest.git -b tizen_0.1 $REPO_URL"
	repo init -u git://git.quicinc.com/tizen/manifest.git -b tizen_0.1 $REPO_URL
elif [ "$PLATFORM" = AGL ]; then
	echo "repo init -u git://git.quicinc.com/le/manifest.git -b refs/tags/$1 -m versioned.xml $REPO_URL"
	repo init -u git://git.quicinc.com/le/manifest.git -b refs/tags/$1 -m versioned.xml $REPO_URL
elif [ "$PLATFORM" = CAF ]; then
	echo "repo init -u git://codeaurora.org/quic/le/le/manifest.git -b release -m $1 $REPO_URL"
	repo init -u git://codeaurora.org/quic/le/le/manifest.git -b release -m $1 $REPO_URL
else
	echo "repo init -u git://git.quicinc.com/platform/manifest.git -b refs/tags/$1 -m versioned.xml $REPO_URL"
	repo init -u git://git.quicinc.com/platform/manifest.git -b refs/tags/$1 -m versioned.xml $REPO_URL
fi


echo "repo sync -c -q --no-tags -j4"
repo sync -c -q --no-tags -j4

################## Repo Sync Parameters #########################################
#c, --current-branch: fetch only current branch from server
#
#--no-tags: do not sync tags
#If sync with this param, you won't see tag information through "git tag -l" and you couldn't checkout to specific tag.
#
#-d, --detach: detach projects back to manifest version
#if no -d, it will rebase your local change to just sync branch.
#
#-f, --force-broken: continue syncing even if a project fails to sync
#
#--no-clone-bundle
#Avoid show some warnings
#
#q, --quiet: be more quite
#Output less message
#
#-j, --jobs: projects to fetch simultaneously (default 4)
##################################################################################

#AGL LV
#repo init -u git://git.quicinc.com/le/manifest.git -b refs/tags/AU_LINUX_EMBEDDED_LV.HB.1.1.1_RB1_TARGET_ALL.01.14.027 -m versioned.xml  
#repo init -u git://git.quicinc.com/platform/manifest -b refs/tags/AU_LINUX_EMBEDDED_LV.HB.1.1.1_RB1_TARGET_ALL.01.14.027 -m versioned.xml

# LV.0.1 Release Note
#repo init -u git://codeaurora.org/quic/le/le/manifest.git -b release -m LV.HB.1.1.1-06510-8x96.0.xml

## MDM CAF
##repo init -u git://codeaurora.org/quic/le/mdm/manifest.git -b release -m LNX.LE.5.3.1-82109-9x40.xml
