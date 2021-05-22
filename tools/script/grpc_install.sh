#! /bin/bash

## date:	2021.05.17
## file:	compile and install grpc
## author:	duruyao@hikvision.com

CONSOLE_COLOR_NONE="\033[m"
CONSOLE_COLOR_RED="\033[1;32;31m"
CONSOLE_COLOR_GREEN="\033[0;32;32m"
CONSOLE_COLOR_YELLOW="\033[0;33m"
CONSOLE_COLOR_MAGENTA="\033[1;35m"
CONSOLE_COLOR_CYAN_BLUE="\033[1;36m"
CONSOLE_COLOR_LIGHT_BLUE="\033[1;32;34m"

function prt_re(){
	printf "${@}"
	printf "${CONSOLE_COLOR_NONE}"
}

function prt_ye(){
	printf "${CONSOLE_COLOR_YELLOW}"
	printf "${@}"
	printf "${CONSOLE_COLOR_NONE}"
}

function prt_gr(){
	printf "${CONSOLE_COLOR_GREEN}"
	printf "${@}"
	printf "${CONSOLE_COLOR_NONE}"
}

function prt_bl(){
	printf "${CONSOLE_COLOR_LIGHT_BLUE}"
	printf "${@}"
	printf "${CONSOLE_COLOR_NONE}"
}

## pre-check

#grpc_languages="all"
grpc_version="1.37.1"
grpc_zip_dir=${PWD}/grpc-${grpc_version}.zip

grpc_ins_dir="/opt/HikSDK/grpc"

if [ -n "${1}" ] && [ -n "${2}" ]; then
	grpc_zip_dir="${1}"
    grpc_ins_dir="${2}"
else
    prt_ye "USAGE (sudo permission may be needed):\n"
	printf "	\`${0} <GRPC_ZIP_DIR> <GRPC_INSTALL_DIR>\`\n"
	exit 1;
fi

printf "\n"
prt_gr "Compile and Install gRPC for C++ in Linux\n\n"

printf "More info see this:\n"
prt_bl "    https://grpc.io/\n"
printf "Other releases see this:\n"
prt_bl "    https://github.com/grpc/grpc/releases\n"
printf "Compile guide for C++ see this:\n"
prt_bl "    https://github.com/grpc/grpc/blob/master/BUILDING.md\n\n"

## 1st step

prt_ye "1)\n"
printf "To build gRPC from source, the following tools are needed:\n"

req_app_list=("g++" "make" "cmake" "autoconf" "libtool" "pkg-config" "build-essential")

for req_app in ${req_app_list[@]}; do
	prt_ye "    %-16s" ${req_app}
	printf ":	 "
	
	req_app_dir="`which ${req_app}`"
	if [ -z ${req_app_dir} ]; then
		prt_re "NOT FOUND\n"
	else
		printf "\`${req_app_dir}\`\n"
	fi
done

printf "On Ubuntu/Debian, you can install them with:\n"
printf "   \`sudo apt-get install ${req_app_list[*]}\`\n\n"

## 2nd step

prt_ye "2)\n"
printf "Unzip \`${grpc_zip_dir}\` ...\n"

new_folder="${PWD}/grpc_source"

mkdir -p ${new_folder} && rm -rf ${new_folder}/*
unzip -q ${grpc_zip_dir} -d ${new_folder}

grpc_src_dir="${new_folder}/`ls ${new_folder}`"

printf "Generate source code to \`${grpc_src_dir}\`:\n"
ls ${grpc_src_dir}

printf "\n"

## 3rd step

prt_ye "3)\n"
printf "Compile grpc for C++ ...\n"

mkdir -p ${grpc_ins_dir} && rm -rf ${grpc_ins_dir}/*

grpc_build_dir="${grpc_src_dir}/cmake/build"
mkdir -p ${grpc_build_dir} && cd ${grpc_build_dir}

HIKSDK_DIR="/opt/HikSDK"

my_prefix_path="${HIKSDK_DIR}/proto;${HIKSDK_DIR}/absl;${HIKSDK_DIR}/cares;${HIKSDK_DIR}/re2;${HIKSDK_DIR}/zlib"
my_cxx_flags="-I${HIKSDK_DIR}/proto/include ${HIKSDK_DIR}/zlib/include"    ## (higher version cmake be needed)
my_cmake=${HIKSDK_DIR}/cmake/bin/cmake

## add rpath for the installed lib

${my_cmake} ${grpc_src_dir}                             \
            -DgRPC_INSTALL=ON                		    \
		        -DBUILD_SHARED_LIBS=ON		   		        \
	          -DCMAKE_BUILD_TYPE=Release       		    \
		        -DCMAKE_INSTALL_PREFIX=${grpc_ins_dir}      \
		        -DgRPC_ABSL_PROVIDER=package     		    \
		        -DgRPC_CARES_PROVIDER=package    		    \
		        -DgRPC_PROTOBUF_PROVIDER=package 		    \
		        -DgRPC_RE2_PROVIDER=package      		    \
		        -DgRPC_SSL_PROVIDER=package      		    \
		        -DgRPC_ZLIB_PROVIDER=package			    \
		        -DCMAKE_PREFIX_PATH=${my_prefix_path}	    \
		        -DCMAKE_CXX_FLAGS=${my_cxx_flags}           \
            -DCMAKE_SKIP_BUILD_RPATH=OFF                \
            -DCMAKE_BUILD_WITH_INSTALL_RPATH=OFF        \
            -DCMAKE_INSTALL_RPATH="${grpc_ins_dir}/lib;${HIKSDK_DIR}/re2/lib" \
            -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON

${my_cmake} --build ${grpc_build_dir} --target clean
${my_cmake} --build ${grpc_build_dir} --target all -- -j 16
${my_cmake} --build ${grpc_build_dir} --target install

printf "\n"
printf "Install grpc "
printf "to \`${grpc_ins_dir}\`:\n"
ls -all ${grpc_ins_dir}
printf "\n"

