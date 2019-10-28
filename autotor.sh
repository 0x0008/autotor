#!/bin/sh

watch="$HOME/Downloads"
tor_base=${tor_base:-${HOME}/tor}
period="2"

activate_venv() {
	. $HOME/bencode/bin/activate || exit 1
}

nap() {
    sleep "$period" &
    sleeper_pid="$!"
    wait
    sleeper_pid=
}

event_check() {
    [ -n "$sleeper_pid" ] && kill "$sleeper_pid"
}

find_torrents() {
	find $watch -name '*.torrent' | while read torrent; do
		mv_torrent "$torrent"
	done
}

mv_torrent() {
	_torrent="$1"
	_host=$($HOME/bin/announce_host.py "$_torrent")
	if [ $? -ne 0 ]; then
		echo "Tracker host not found for $_torrent" >&2
		return 1
	fi
	_target=$(case $_host in
		please.passthepopcorn.me) echo $tor_base/ptp ;;
		bibliotik.*) echo $tor_base/bib ;;
		flacsfor.me) echo $tor_base/red ;;
		landof.tv)   echo $tor_base/btn ;;
		*)           echo $tor_base/other ;;
	esac)
	echo mv "$_torrent" $_target
	mv "$_torrent" $_target
}

trap event_check hup

activate_venv

while :; do
	nap
	find_torrents
done
