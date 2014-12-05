#!/bin/bash
BIN_DIR="$(cd "$(dirname "$0")" && pwd )"
BASE_DIR="$(dirname "$BIN_DIR")"
PROJECT_DIR=$(dirname "$BASE_DIR")

add_script="$BIN_DIR/addFile.rb"
if [[ ! -z "$1" ]] ; then
  xcode_dir="$1"
else
  xcode_dir=$(echo "$PROJECT_DIR/"*.xcodeproj)
fi

cd "$BASE_DIR" && "$add_script" "$xcode_dir"  Rollout/RolloutDynamic.m Rollout/Rollout.framework
add_file_exit_status=$?
"$BIN_DIR/create_script.rb" "$xcode_dir" "Rollout Code analyzer" "\"\${SRCROOT}/Rollout-ios-SDK/lib/tweaker\" -k $2"
create_script_exit_status=$?
exit $(( $add_file_exit_status + $create_script_exit_status ))
