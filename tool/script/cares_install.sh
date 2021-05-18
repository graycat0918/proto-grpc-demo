#! /bin/bash

## https://github.com/c-ares/c-ares/releases

if [ $# != 2 ]; then
    printf "USAGE (sudo permission may be needed):\n"
	printf "	\`${0} <ZIP_DIR> <INSTALL_DIR>\`\n"
	exit 1;
fi

zip_dir="${1}"
ins_dir="${2}"
new_folder="${PWD}/cares_source"

mkdir -p ${new_folder} && rm -rf ${new_folder}/*
unzip -q ${zip_dir} -d ${new_folder}

src_dir="${new_folder}/`ls ${new_folder}`"

mkdir -p ${ins_dir} && rm -rf ${ins_dir}/*
cd ${src_dir}
./buildconf
autoconf configure.ac
./configure --prefix=${ins_dir}
make -j16 && make install

