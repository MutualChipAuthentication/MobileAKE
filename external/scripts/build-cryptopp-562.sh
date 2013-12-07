#!/bin/bash

PKG_VERSION="5.6.2"
SDK_VERSION="7.0"

#############

PKG_NAME="cryptopp"
LIB_NAME="lib${PKG_NAME}.a"
ARCHIVE_NAME=${PKG_NAME}`echo ${PKG_VERSION} | sed 's/\.//g'`.zip
DOWNLOAD_URL="http://www.cryptopp.com/cryptopp562.zip"

WORK_PATH=`cd $(dirname $0) && cd .. && pwd`

ARCHS="i386 armv6 armv7 armv7s"

mkdir -p ${WORK_PATH}/tmp
mkdir -p ${WORK_PATH}/lib
mkdir -p ${WORK_PATH}/include/${PKG_NAME}
mkdir -p ${WORK_PATH}/objs
rm -r ${WORK_PATH}/tmp
rm -r ${WORK_PATH}/lib
rm -r ${WORK_PATH}/include
rm -r ${WORK_PATH}/objs
mkdir -p ${WORK_PATH}/tmp
mkdir -p ${WORK_PATH}/lib
mkdir -p ${WORK_PATH}/include/${PKG_NAME}
mkdir -p ${WORK_PATH}/objs

pushd ${WORK_PATH}/tmp > /dev/null
if [ ! -e ${ARCHIVE_NAME} ]; then
	echo "Downloading ${ARCHIVE_NAME}"
    curl -O ${DOWNLOAD_URL}
else
	echo "Using ${ARCHIVE_NAME}"
fi

# HASHCHECK_RESULT=`shasum -c ${WORK_PATH}/scripts/${ARCHIVE_NAME}.sha512`
# if [ "${HASHCHECK_RESULT}" != "${ARCHIVE_NAME}: OK" ]; then
# 	echo "Downloaded file ${ARCHIVE_NAME} is broken. remove it manually and restart build script again"
# 	exit 1
# fi

for ARCH in ${ARCHS}
do
	if [ "${ARCH}" == "i386" ]; then
		PLATFORM="iPhoneSimulator"
	else
		PLATFORM="iPhoneOS"
	fi
	
	export TOOLS_ROOT="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain"
	
	export DEV_ROOT="/Applications/Xcode.app/Contents/Developer/Platforms/${PLATFORM}.platform/Developer"
	export SDK_ROOT="${DEV_ROOT}/SDKs/${PLATFORM}${SDK_VERSION}.sdk"
	
    BUILD_PATH="${WORK_PATH}/objs/${PLATFORM}${SDK_VERSION}-${ARCH}.sdk"

	export CC="${TOOLS_ROOT}/usr/bin/gcc -arch ${ARCH}"
	
	export LD=${TOOLS_ROOT}/usr/bin/ld
	export CXX=${TOOLS_ROOT}/usr/bin/clang
	export AR=${TOOLS_ROOT}/usr/bin/ar
	export AS=${TOOLS_ROOT}/usr/bin/as
	export NM=${TOOLS_ROOT}/usr/bin/nm
	export RANLIB=${TOOLS_ROOT}/usr/bin/ranlib
	
	export LDFLAGS="-arch ${ARCH} -isysroot ${SDK_ROOT}"
	export CXXFLAGS="-x c++ -arch ${ARCH} -isysroot ${SDK_ROOT} -I${WORK_PATH}/include/${PKG_NAME} -I${BUILD_PATH}"

	echo "Building ${PKG_NAME} for ${PLATFORM} ${SDK_VERSION} ${ARCH} ..."
	unzip -o ${ARCHIVE_NAME} > /dev/null
	
	mkdir -p ${BUILD_PATH}
	mv *.cpp ${BUILD_PATH}
	mv ${BUILD_PATH}/*test* . # move back test files here, which aren't neccesary
	mv *.h ${WORK_PATH}/include/${PKG_NAME}

	LOG="${BUILD_PATH}/build-${PKG_NAME}-${PKG_VERSION}.log"

	pushd ${BUILD_PATH} > /dev/null
	make -f ${WORK_PATH}/scripts/Makefile >> "${LOG}" 2>&1
	popd > /dev/null
done

echo "Creating universal library..."
lipo -create ${WORK_PATH}/objs/iPhoneSimulator${SDK_VERSION}-i386.sdk/${LIB_NAME} ${WORK_PATH}/objs/iPhoneOS${SDK_VERSION}-armv6.sdk/${LIB_NAME} ${WORK_PATH}/objs/iPhoneOS${SDK_VERSION}-armv7.sdk/${LIB_NAME} ${WORK_PATH}/objs/iPhoneOS${SDK_VERSION}-armv7s.sdk/${LIB_NAME} -output ${WORK_PATH}/lib/${LIB_NAME}
echo "Build ${LIB_NAME} done."
