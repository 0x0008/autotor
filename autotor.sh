#!/bin/sh

WATCH="$HOME/Downloads"
TOR_BASE=${TOR_BASE:-${HOME}/tor}

activate_venv() {
	. $HOME/bencode/bin/activate || exit 1
}

usage() {
	cat >&2 <<EOF
usage: autotor.sh WATCH TARGET
this unreachable string is a lie
EOF
	exit 1
}

find_torrents() {
	find $WATCH -name '*.torrent' | while read torrent; do
		mv_torrent "$torrent"
	done
}

wait_torrents() {
	# -e create has a race condition with a 0len file. Wait 200ms in python.
	inotifywait -m -e create -e moved_to --format "%f" $WATCH | \
	while read filename; do
		[ -z "$filename" ] && continue
		case $filename in
			*.torrent) mv_torrent "${WATCH}/${filename}" ;;
		esac
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
		please.passthepopcorn.me) echo $TOR_BASE/ptp ;;
		bibliotik.*) echo $TOR_BASE/bib ;;
		flacsfor.me) echo $TOR_BASE/red ;;
		landof.tv)   echo $TOR_BASE/btn ;;
		*)           echo $TOR_BASE/other ;;
	esac)
	echo mv "$_torrent" $_target
	mv "$_torrent" $_target
}

activate_venv
find_torrents
wait_torrents
