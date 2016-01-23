# Bash script for creating a universal iphoneos + iphonesimulator framework
# Modified code from http://insert.io/framework-ios8-xcode6/  - Oded Regev

set -e
set +u
# Avoid recursively calling this script.
if [[ $SF_MASTER_SCRIPT_RUNNING ]]
then
exit 0
fi
set -u
export SF_MASTER_SCRIPT_RUNNING=1


# Constants
FRAMEWORK_NAME="${PRODUCT_NAME}"
OUTPUT_PATH="${BUILD_DIR}/${CONFIGURATION}"
UNIVERSAL_OUTPUTFOLDER="${OUTPUT_PATH}-universal"

# Functions

function build_static_library {
    # Will rebuild the static library as specified
    #     build_static_library sdk
    echo "Building static library for ${1}"
    xcrun xcodebuild -project "${PROJECT_FILE_PATH}" \
    -target "${TARGET_NAME}" \
    -configuration "${CONFIGURATION}" \
    -sdk "${1}" \
    ONLY_ACTIVE_ARCH=NO \
    BUILD_DIR="${BUILD_DIR}" \
    OBJROOT="${OBJROOT}" \
    BUILD_ROOT="${BUILD_ROOT}" \
    CONFIGURATION_BUILD_DIR="${2}" \
    OTHER_CFLAGS="-fembed-bitcode" \
    SYMROOT="${SYMROOT}" $ACTION
}

function make_fat_library {
    # Will smash 2 static libs together
    #     make_fat_library in1 in2 out
    echo "Making fat library..."
    xcrun lipo -create "${1}" "${2}" -output "${3}"
}

# Take build target
if [[ "$SDK_NAME" =~ ([A-Za-z]+) ]]
then
SF_SDK_PLATFORM=${BASH_REMATCH[1]}
else
echo "Could not find platform name from SDK_NAME: $SDK_NAME"
exit 1
fi

# TODO: Update to be able to build with either target scheme
if [[ "$SF_SDK_PLATFORM" = "iphoneos" ]]
then
SF_SDK_OTHER_PLATFORM="iphonesimulator9.2"
else
SF_SDK_OTHER_PLATFORM="iphoneos"
fi

OTHER_DEVICE_BUILD_DIR=${OUTPUT_PATH}-$SF_SDK_OTHER_PLATFORM

# Build the other (non-simulator) platform
build_static_library "${SF_SDK_OTHER_PLATFORM}" "${OTHER_DEVICE_BUILD_DIR}"

# Copy the framework structure to the universal folder (clean it first)
rm -rf "${UNIVERSAL_OUTPUTFOLDER}"
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"

SOURCE_PATH="${OUTPUT_PATH}-${SF_SDK_PLATFORM}/${FRAMEWORK_NAME}.framework"
COPY_LOCATION_PATH="${UNIVERSAL_OUTPUTFOLDER}/$FRAMEWORK_NAME.framework"

echo "SOURCE_PATH: ${SOURCE_PATH}"
echo "COPY_LOCATION_PATH: ${COPY_LOCATION_PATH}"

cp -R "${SOURCE_PATH}" "${COPY_LOCATION_PATH}"

# Smash them together to combine all architectures
# PLATFORM_PATH="${OUTPUT_PATH}-${SF_SDK_PLATFORM}/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"
PLATFORM_PATH="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/${FRAMEWORK_NAME}"
PLATFORM_OTHER_PATH="${OUTPUT_PATH}-${SF_SDK_OTHER_PLATFORM}/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"
OUTPUT_PATH="${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"

echo "PLATFORM_PATH: ${PLATFORM_PATH}"
echo "PLATFORM_OTHER_PATH: ${PLATFORM_OTHER_PATH}"
echo "OUTPUT_PATH: ${OUTPUT_PATH}"

make_fat_library "${PLATFORM_PATH}" "${PLATFORM_OTHER_PATH}" "${OUTPUT_PATH}"


# Copy to Build Folder
ditto "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_NAME}.framework" "${SRCROOT}/../Builds/${FRAMEWORK_NAME}.framework"

# Copy to Deliverable Folder
ditto "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_NAME}.framework" "${SRCROOT}/../../tealium-ios/${FRAMEWORK_NAME}.framework"

# Copy Bridging Header to support folder
#ditto "${PROJECT_DIR}/../source/TealiumIOSBridgingHeader.h" "${SRCROOT}/../../tealium-ios/support/"