#!/bin/bash
ROLLOUT_TEMP_DIR=/tmp/rollout-installation/
BUILD_ARGS="BUILD_ROOT=$ROLLOUT_TEMP_DIR BUILD_DIR=$ROLLOUT_TEMP_DIR SYMROOT=$ROLLOUT_TEMP_DIR TARGET_TEMP_DIR=$ROLLOUT_TEMP_DIR"

if [ $2 == "i386" ] ; then
  SIMULATOR_SDK=$(xcrun xcodebuild -showsdks 2>/dev/null | grep Simulator | tail -1 | awk '{print $NF}')
  cd "$1" && xcrun xcodebuild VALID_ARCHS=i386 ARCHS=i386 ONLY_ACTIVE_ARCH=NO -arch i386 -sdk "$SIMULATOR_SDK" -configuration Debug -alltargets -parallelizeTargets $BUILD_ARGS 
else
  cd "$1" && xcrun xcodebuild -arch "$2" -configuration Debug -alltargets -parallelizeTargets $BUILD_ARGS
fi


