# --- ROCK-COPYRIGHT-NOTE-BEGIN ---
# 
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# Please add additional copyright information _after_ the line containing
# the ROCK-COPYRIGHT-NOTE-END tag. Otherwise it might get removed by
# the ./scripts/Create-CopyPatch script. Do not edit this copyright text!
# 
# ROCK Linux: rock-src/package/*/sysfiles/stone_mod_runlevel.sh
# Copyright (C) 1998 - 2003 ROCK Linux Project
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version. A copy of the GNU General Public
# License can be found at Documentation/COPYING.
# 
# Many people helped and are helping developing ROCK Linux. Please
# have a look at http://www.rocklinux.org/ and the Documentation/TEAM
# file for details.
# 
# --- ROCK-COPYRIGHT-NOTE-END ---
#
# [MAIN] 80 runlevel Runlevel Configuration (Services)

# Remove dead symlinks
for x in /etc/rc.d/rc[0-6].d/* ; do
	[ -L "$x" -a ! -e "$x" ] && rm -f "$x"
done

chrlv() {
	local srv=$1 rl=$2 pri=$3
	if [ ! -e /etc/rc.d/rc$rl.d/S??$srv ]
	then
		ln -sf ../init.d/$srv /etc/rc.d/rc$rl.d/S$pri$srv
		kpr=`printf "%02d" $(( 100 - $pri ))`
		ln -sf ../init.d/$srv /etc/rc.d/rc$rl.d/K$kpr$srv
	else
		rm -f /etc/rc.d/rc$rl.d/[SK]??$srv
	fi
}

chpri() {
	local srv=$1 pri=$2

	gui_input "Changing priority for service $1" "$pri" pri

	if [ ! -z "${pri#[0-9][0-9]}" ]
	then
		gui_message "The value you entered is not valid."
		return
	fi

	rm -f /etc/rc.d/rcX.d/X??$srv
	echo "The script '$srv' has the priority $pri." \
						> /etc/rc.d/rcX.d/X$pri$srv

	for x in 0 1 2 3 4 5 6 ; do
		if [ -e /etc/rc.d/rc$x.d/S??$srv ] ; then
			rm -f /etc/rc.d/rc$x.d/[SK]??$srv
			ln -sf ../init.d/$srv /etc/rc.d/rc$x.d/S$pri$srv
			kpr=`printf "%02d" $(( 100 - $pri ))`
			ln -sf ../init.d/$srv /etc/rc.d/rc$x.d/K$kpr$srv
		fi
	done
}

edit_srv() {
	local srv=$1 id="runlevel_$RANDOM" cmd=""

	while
		cmd="gui_menu $id 'Runlevel Editor - $srv'"
		pri=`ls /etc/rc.d/rc?.d/[SX]??$srv 2> /dev/null | \
		     cut -c18-19 | head -n 1`
		[ -z "$pri" ] && pri=99

		for rl in 1 2 3 4 5 ; do
			if [ -e /etc/rc.d/rc$rl.d/S??$srv ]
			then cmd="$cmd '[*] " ; else cmd="$cmd '[ ] " ; fi
			cmd="$cmd Run this script in runlevel $rl'"
			cmd="$cmd 'chrlv $srv $rl $pri'"
		done

		cmd="$cmd '$pri   This scripts priority (01-99)'"
		cmd="$cmd 'chpri $srv $pri' '' ''"

		cmd="$cmd 'Edit /etc/rc.d/init.d/$srv script'"
		cmd="$cmd \"gui_edit 'SysV Init Script $srv'"
		cmd="$cmd /etc/rc.d/init.d/$srv\""
		cmd="$cmd \"(Re-)Start the '$srv' system service\""
		cmd="$cmd '$STONE runlevel restart $srv'"
		eval "$cmd"
	do : ; done
}

restart() {
	gui_cmd "(Re-)Starting System Service '$1'" \
		"/sbin/rc $1 stop ; /sbin/rc $1 start"
}

main() {
	while
		cmd="gui_menu runlevel 'Runlevel Editor - Select an"
		cmd="$cmd item to change the priority or runlevels'"

		x=`mktemp`
		for srv in $( ls /etc/rc.d/init.d/ )
		do
			[ -f /etc/rc.d/init.d/$srv ] || continue

			pri=`ls /etc/rc.d/rc?.d/[SX]??$srv \
				2> /dev/null | cut -c18-19 | head -n 1`
			[ -z "$pri" ] && pri=99

			rlv=''
			for x in 1 2 3 4 5 ; do
				if [ -e /etc/rc.d/rc$x.d/S??$srv ]
				then rlv="${rlv}$x" ; else rlv="${rlv}-" ; fi
			done

			desc=`grep '# *Desc:' /etc/rc.d/init.d/$srv | \
			      cut -f2- -d: | tr -d "'" | cut -c1-45`
			desc="$( printf "%-10s %s" "$srv" "$desc" )"

			echo "$pri$srv '$pri $rlv  $desc' 'edit_srv $srv'"
		done | sort > $x
		cmd="$cmd $(cut -f2- -d' ' < $x | tr '\n' ' ')"
		rm -f $x ; eval "$cmd"
	do : ; done
}

