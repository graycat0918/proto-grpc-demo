#! /bin/bash

## date:	2021.05.14
## file:	compile and install protobuf
## author:	duruyao@hikvision.com

CONSOLE_COLOR_NONE="\033[m"
CONSOLE_COLOR_RED="\033[1;32;31m"
CONSOLE_COLOR_GREEN="\033[0;32;32m"
CONSOLE_COLOR_YELLOW="\033[0;33m"
CONSOLE_COLOR_MAGENTA="\033[1;35m"
CONSOLE_COLOR_CYAN_BLUE="\033[1;36m"
CONSOLE_COLOR_LIGHT_BLUE="\033[1;32;34m"

function prt_re(){
	printf "${CONSOLE_COLOR_RED}"
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

proto_languages="all"
proto_version="3.17.0"
proto_zip_dir=${PWD}/protobuf-${proto_languages}-${proto_version}.zip
proto_ins_dir="/opt/HikSDK/proto"

if [ -n "${1}" ] && [ -n "${2}" ]; then
	proto_zip_dir="${1}"
    proto_ins_dir="${2}"
else
    prt_ye "USAGE (sudo permission may be needed):\n"
	printf "	\`${0} <PROTO_ZIP_DIR> <PROTO_INSTALL_DIR>\`\n"
	exit 1;
fi

printf "\n"
prt_gr "Compile and Install Protocol Buffers in Linux\n\n"

printf "More info see this:\n"
prt_bl "    https://developers.google.com/protocol-buffers\n"
printf "Other releases see this:\n"
prt_bl "    https://github.com/protocolbuffers/protobuf/releases\n"
printf "Compile guide see this:\n"
prt_bl "    https://github.com/protocolbuffers/protobuf/blob/master/src/README.md\n\n"

## 1st step

prt_ye "1)\n"
printf "To build protobuf from source, the following tools are needed:\n"

req_app_list=("g++" "make" "unzip" "autoconf" "automake" "libtool")

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
printf "Unzip \`${proto_zip_dir}\` ...\n"

new_folder="${PWD}/proto_source"

mkdir -p ${new_folder} && rm -rf ${new_folder}/*
unzip -q ${proto_zip_dir} -d ${new_folder}

proto_src_dir="${new_folder}/`ls ${new_folder}`"

printf "Generate source code to \`${proto_src_dir}\`:\n"
ls ${proto_src_dir}

printf "\n"

## 3rd step

prt_ye "3)\n"
printf "Compile protobuf ...\n"

mkdir -p ${proto_ins_dir} && rm -rf ${proto_ins_dir}/*
cd ${proto_src_dir}
./configure --prefix=${proto_ins_dir}
make -j16 && make check
make install						## copy `lib`, `bin`, `include` to distination (sudo permission needed).
ldconfig 							## refresh shared library cache (sudo permission needed).

printf "\n"
printf "Install protobuf "
prt_ye "(`${proto_ins_dir}/bin/protoc --version`) "
printf "to \`${proto_ins_dir}\`:\n"
ls -all ${proto_ins_dir}
printf "\n"

