#!/bin/bash

function make_model(){
	echo ""
	echo "--------------------------------------------------------"
	echo "Building $1......"
	echo "--------------------------------------------------------"
	[ ! -f ".config.$1" ]  && {
		echo ".config.$1 does not exist!"
		return
	}
	[ ! -d "out" ] && mkdir "out"
	{
		cp -f ".config.$1" ".config" &&
		make dirclean  >/dev/null 2>&1 &&
		make -j4 &&
		cp -u -f bin/targets/*/*/lede-*-squashfs-sysupgrade.bin out/ &&
		make dirclean  >/dev/null 2>&1 &&
		rm -rf bin/* build_dir/* tmp/ staging_dir/* .config
	} || exit
}



clear

build_dir_path="`pwd`/build_dir"
[ ! -d "${build_dir_path}" ] && mkdir -p "${build_dir_path}"
rm -rf ${build_dir_path}/*

mount_record=`mount | grep "${build_dir_path}"`
[ ! -n "${mount_record}" ] && {
	echo "123456" | sudo -S mount -t tmpfs -o size=9G myramdisk ${build_dir_path} 
	echo ""
}

models=(	
	"ar71xx.74kc.usb"
	"7621"
	"841.24kc"
	"841.941.74kc"
	"941v2"	 
	)
n=${#models[@]}
for i in `seq 0 $(expr $n - 1)`; do
	make_model ${models[i]}	
done

./cksum.sh

rm -rf ${build_dir_path}/*
mount_record=`mount | grep "${build_dir_path}"`
[ -n "${mount_record}" ] && {
	echo "123456" | sudo -S umount ${build_dir_path} 
	echo ""
}

