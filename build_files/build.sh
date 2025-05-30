#!/usr/bin/env bash

set -eo pipefail

CONTEXT_PATH="$(realpath "$(dirname "$0")/..")" # should return /ctx
BUILD_SCRIPTS_PATH="$(realpath "$(dirname $0)")"
MAJOR_VERSION_NUMBER="$(sh -c '. /usr/lib/os-release ; echo $VERSION_ID')"
SCRIPTS_PATH="$(realpath "$(dirname "$0")/scripts")"
export CONTEXT_PATH
export SCRIPTS_PATH
export MAJOR_VERSION_NUMBER

echo "CONTEXT_PATH:          $CONTEXT_PATH"
echo "BUILD_SCRIPTS_PATH:    $BUILD_SCRIPTS_PATH"
echo "MAJOR_VERSION_NUMBER:  $MAJOR_VERSION_NUMBER"
echo "SCRIPTS_PATH:          $SCRIPTS_PATH"

run_buildscripts_for() {
	WHAT=$1
	echo "WHAT: $SHAT"
	shift
	# Complex "find" expression here since there might not be any overrides
	# Allows us to numerically sort scripts by stuff like "01-packages.sh" or whatever
	# CUSTOM_NAME is required if we dont need or want the automatic name
	find "${BUILD_SCRIPTS_PATH}/$WHAT" -maxdepth 1 -iname "*-*.sh" -type f -print0 | sort --zero-terminated --sort=human-numeric | while IFS= read -r -d $'\0' script ; do
		if [ "${CUSTOM_NAME}" != "" ] ; then
			WHAT=$CUSTOM_NAME
		fi
		echo "WHAT: $WHAT"
		printf "::group:: ===$WHAT-%s===\n" "$(basename "$script")"
		"$(realpath $script)"
		printf "::endgroup::\n"
	done
}

copy_systemfiles_for() {
	WHAT=$1
	echo "WHAT: $WHAT"
	shift
	DISPLAY_NAME=$WHAT
	echo "DISPLAY_NAME: $DISPLAY_NAME"
	if [ "${CUSTOM_NAME}" != "" ] ; then
		DISPLAY_NAME=$CUSTOM_NAME
	fi
	echo "DISPLAY_NAME: $DISPLAY_NAME"
	printf "::group:: ===%s-file-copying===\n" "${DISPLAY_NAME}"
	cp -avf "${CONTEXT_PATH}/$WHAT/." /
	printf "::endgroup::\n"
}

CUSTOM_NAME="base"
copy_systemfiles_for files
run_buildscripts_for .
CUSTOM_NAME=
