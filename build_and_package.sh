#!/bin/bash
set -e

REPO_DIR=$1
OUTPUT_DIR=$2
mkdir -p $OUTPUT_DIR

if [[ -z "$REPO_DIR" || -z "$OUTPUT_DIR" ]]; then
    echo "Usage: $0 <repo_dir> <output_dir>"
    exit 1
fi

cd "$REPO_DIR/src"

# Run cross build
if [["$REPO_DIR" ~= fsphil ]]; then
    ../../build_win64.sh
else
    ./build_win64.sh
fi

# Confirm binary exists
if [[ ! -f ./hacktv.exe ]]; then
    echo "Build failed!"
    exit 1
fi

# Generate metadata
DESC=$(git show HEAD --pretty=format:"%s" --no-patch)
CID=$(git show HEAD --pretty=format:"%h" --no-patch)
echo "$CID ($DESC)" > ./readme.txt

# Determine zip name
if [[ -f ./resources.h ]]; then
    ZIPNAME=captainjack.zip
elif [[ -f ./testsignal.c ]]; then
    ZIPNAME=mattstvbarn.zip
else
    ZIPNAME=fsphil.zip
fi

# Debugging
echo $OUTPUT_DIR

# Copy files
cp hacktv.exe $OUTPUT_DIR
cp readme.txt $OUTPUT_DIR
if [[ -d ../testsignals ]]; then
    mkdir -p "$OUTPUT_DIR/testsignals"
    cp ../testsignals/*.bin "$OUTPUT_DIR/testsignals"
fi

# Zip
pushd "$OUTPUT_DIR"
zip -r "$ZIPNAME" *
popd

echo "Artifact ready: $ZIPNAME"
