#!/bin/bash

# RELEASE_DIR=$1
# PATCH_FILE=$2
# ROLLBACK_FILE=$3
# VERSION=$4
# BRANCH=$5

git add $RELEASE_DIR $PATCH_FILE $ROLLBACK_FILE

git commit -m "Build version $VERSION. Prepare scripts..." $PATCH_FILE $ROLLBACK_FILE

git push --progress --porcelain origin refs/heads/$BRANCH:$BRANCH --set-upstream

git checkout master

git merge $BRANCH

git commit -m "After mergin of $BRANCH to master"

git push

git checkout $BRANCH