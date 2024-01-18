#!/usr/bin/env bash
##!/bin/bash
MESSAGE="Auto-commit: $(date +%Y-%m-%d_%H-%M)"
# Staticly provide the path to repo. When "-p" option is given, this will overwritten.
REPO_PATH="/path/to/git/repo"
export PATH=$PATH:/usr/local/bin:/root/bin
#echo $PATH

function show_help {
	SCRIPT_NAME=$(basename "$0")
	echo "$SCRIPT_NAME - Automatically commits a local git repository."
	echo "Usage: $SCRIPT_NAME [options]"
	echo ""
	echo "Options:"
	echo "-p PATH      Path to local repository."
	echo "-b BRANCH    Branch to use in local repository."
	echo "-h           Show this help"
}

#echo "Analyzing given options \"$*\""
while getopts ":p:b:h" opt; do
    	case $opt in
		p) REPO_PATH="${OPTARG}" ;;
		b) REPO_BRANCH="${OPTARG}" ;;
		h) show_help; exit 1;;
		\?) echo "Unknown option: -${OPTARG}";;
		:) echo "Option -$OPTARG requires an argument." >&2; exit 1;;
	esac
done


# Check if git command is available
if ! (which git 2>&1 >>/dev/null); then
	echo "git command not found. Please install git or fix \$PATH variable."
	exit 1
fi

# Check if REPO_PATH is a git repository
if [ ! -d  $REPO_PATH ]; then
	echo "Path \"${REPO_PATH}\" does not exist."
	exit 1
fi
git -C "$REPO_PATH" status >/dev/null 2>&1 
if [ ! $? -eq 0 ]; then
	echo "Path \"${REPO_PATH}\" not initialized as git repository, please execute manually:"
	echo "git -C \"${REPO_PATH}\" init --initial-branch=main"
	exit
fi

# Check if user.name and user.email is set
if ! (git config --global user.name >/dev/null 2>&1) && ! (git -C $REPO_PATH config user.name >/dev/null 2>&1); then
	echo "User name is not set, manually set with one of these commands:"
	echo "git config --global user.name \"Your Name\""
	echo "git -C \"${REPO_PATH}\" config user.name \"Your Name\""
fi
if ! (git config --global user.email >/dev/null 2>&1) && ! (git -C $REPO_PATH config user.email >/dev/null 2>&1); then
	echo "User email is not set, manually set with one of these commands:"
	echo "git config --global user.email \"you@example.com\""
	echo "git -C \"${REPO_PATH}\" config user.email \"you@example.com\""
	exit 1
fi

# This currently ends always in an exit 1, because one cannot switch branches without commiting first.
# If you commit first, there is no need to switch, because everything is already commited.
# Maybe implement some stashing mechanism?
if [ ! -z "$REPO_BRANCH" ]; then
	REPO_PREV_BRANCH=$(git branch --show-current)
	if (git -C "$REPO_PATH" branch --list | grep -q "$REPO_BRANCH"); then
		git -C "$REPO_PATH" checkout $REPO_BRANCH
		if [ ! $? -eq 0 ]; then
			exit $?
		fi
	fi
fi

echo $MESSAGE
git -C "$REPO_PATH" add -A
git -C "$REPO_PATH" commit -m "$MESSAGE" #--no-status #--quiet

if [ ! -z "$REPO_BRANCH" ] && [ "$REPO_BRANCH" != "$REPO_PREV_BRANCH" ]; then
	git checkout $REPO_PREV_BRANCH
fi
