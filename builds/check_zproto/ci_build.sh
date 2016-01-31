#!/usr/bin/env bash
set -ex

docker run -e GSL_BUILD_DIR=/code/src -v "$REPO_DIR":/code zeromqorg/zproto -zproject:1 -q zre_msg.xml

# keep an eye on git version used by CI
git --version
if [[ $(git --no-pager diff -w api/*) ]]; then
    git --no-pager diff -w api/*
    echo "There are diffs between current code and code generated by zproto!"
    exit 1
fi
if [[ $(git status -s api) ]]; then
    git status -s api
    echo "zproto generated new files!"
    exit 1
fi
