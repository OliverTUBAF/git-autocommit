#!/usr/local/bin/bash
##!/usr/bin/env bash
MESSAGE="Auto-commit: $(date +%Y-%m-%d_%H-%M)"
REPO_PATH="/path/to/git/repo"
export PATH=$PATH:/usr/local/bin:/root/bin
#echo $PATH

# Check if git command is available
if ! (which -s git); then
	echo "git command not found. Please install git or fix \$PATH variable."
	exit 1
fi

# Check if REPO_PATH is a git repository
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
echo $MESSAGE
git -C "$REPO_PATH" add -A
git -C "$REPO_PATH" commit -m "$MESSAGE" #--no-status #--quiet
