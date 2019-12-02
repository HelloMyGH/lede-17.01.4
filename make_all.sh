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
		make download -j16 &&
		make -j1 V=s &&
		cp -u -f bin/targets/*/*/lede-*-squashfs-sysupgrade.bin out/ &&
		make dirclean  >/dev/null 2>&1 &&
		rm -rf bin/* build_dir/* tmp/ staging_dir/* .config
	} || exit
}


clear


models=(
	"841.24kc"
	)
n=${#models[@]}
for i in `seq 0 $(expr $n - 1)`; do
	make_model ${models[i]}	
done

./cksum.sh
