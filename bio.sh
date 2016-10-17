#!/bin/bash

export PATH="$PATH:$HOME/.biosphere/core/bin"

if [ -d "$HOME/.biosphere/current_sphere" ]
	then
	CURRENT_SPHERE=`readlink ~/.biosphere/current_sphere`
	echo -e "Using sphere \x1B[92m$CURRENT_SPHERE\x1B[39m"
	
	if [ -f "$HOME/.biosphere/current_sphere/augmentations/bash_profile" ]
		then
		echo -e "Running \x1B[92m$HOME/.biosphere/current_sphere/augmentations/bash_profile\x1B[39m"
		source $HOME/.biosphere/current_sphere/augmentations/bash_profile
	fi
fi

