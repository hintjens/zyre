#! /bin/bash
#
#   Builds zyre.node package from a fresh git clone
#
set -e                      #   exit on any error
FORCE=0
VERBOSE=0
QUIET="--quiet"
LOGLEVEL="--loglevel=error"

for ARG in $*; do
    if [ "$ARG" == "--help" -o "$ARG" == "-h" ]; then
        echo "build.sh"
        echo " --help / -h          This help"
        echo " --force / -f         Force full rebuild"
        echo " --verbose / -v       Show build output"
        echo " --xverbose / -x      Extra verbose"
        exit
    elif [ "$ARG" == "--force" -o "$ARG" == "-f" ]; then
        FORCE=1
    elif [ "$ARG" == "--verbose" -o "$ARG" == "-v" ]; then
        VERBOSE=1
        QUIET=""
        LOGLEVEL=""
    elif [ "$ARG" == "--xverbose" -o "$ARG" == "-x" ]; then
        VERBOSE=1
        QUIET=""
        LOGLEVEL="--loglevel=verbose"
        set -x
    fi
done

BUILD_ROOT=`pwd`
cd ../../..

#   Check dependent projects
if [ ! -d libzmq ]; then
    echo "I:    cloning https://github.com/zeromq/libzmq into `pwd`/libzmq..."
    git clone $QUIET https://github.com/zeromq/libzmq
fi
if [ ! -f libzmq/builds/gyp/project.gyp ]; then
    echo "E:    `pwd`/libzmq out of date (builds/gyp/project.gyp missing)"
    exit
fi

#   Check dependent projects
if [ ! -d czmq ]; then
    echo "I:    cloning https://github.com/zeromq/czmq into `pwd`/czmq..."
    git clone $QUIET https://github.com/zeromq/czmq
fi
if [ ! -f czmq/builds/gyp/project.gyp ]; then
    echo "E:    `pwd`/czmq out of date (builds/gyp/project.gyp missing)"
    exit
fi


#   Check Node.js dependencies
cd $BUILD_ROOT
echo "I: checking Node.js dependencies..."

failed=0
set +e
for package in node-ninja bindings nan prebuild; do
    npm list --depth 1 $package > /dev/null 2>&1
    if [ $? -eq 1 ]; then
        npm list --global --depth 1 $package > /dev/null 2>&1
        if [ $? -eq 1 ]; then
            echo "E: $package isn't installed, run 'npm install [-g] $package'"
            failed=1
        fi
    fi
done
test $failed -eq 0 || exit
set -e

#   Calculate how many compiles we can do in parallel
export JOBS=$([[ $(uname) = 'Darwin' ]] \
    && sysctl -n hw.logicalcpu_max \
    || lscpu -p | egrep -v '^#' | wc -l)

#   Build the binding using node-ninja directly, not prebuild
echo "I: building Node.js binding:"
node-ninja configure
node-ninja build
