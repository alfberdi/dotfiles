setxkbmap es;
[[ -f ~/.Xresources ]] && xrdb -I$HOME ~/.Xresources

/usr/bin/dropbox &
/usr/bin/xscreensaver &
/usr/bin/pidgin &
/usr/bin/mpd &

print_song_info() {
	if [[ $(mpc status | grep playing) ]]; then
		song_info="Playing"
	else
		song_info="Paused"
	fi
	echo -ne "MPD: ${song_info}"
}

print_bat_info() {
	#batstatus=${acpi -b}
	#if [[ $( acpi -b | grep Charging ) ]]; then
	#	Bat_info="C"
	#else
	#	Bat_info="D"
	#fi
	echo -ne "Bat: $( acpi -b | awk 'sub(/,/,"") {print $4}')"
}

while true; do


	#DWM_CPU_TMP="TMP: $(sensors | awk 'BEGIN{i=0;t=0;b=0}/id [0-9]/{b=$4};/Core/{++i;t+=$3}END{if(i>0){printf("%0.1f\n",t/i)}else{sub(/[^0-9.]/,"",b);print b}}') $("\xc2\xb0")"

	#DWM_CPU_USE="USE: $(eval $(awk '/^cpu /{print "previdle=" $5 "; prevtotal=" $2+$3+$4+$5 }' /proc/stat); sleep 0.4; eval $(awk '/^cpu /{print "idle=" $5 "; total="$2+$3+$4+$5 }' /proc/stat); intervaltotal=$((total-${prevtotal:-0})); echo "$((100*( (intervaltotal) - ($idle-${previdle:-0}) ) / (intervaltotal) ))")%"

	#DWM_RAM="RAM: $(free -m | grep '^Mem' | awk '{print int($3 / $2 * 100) "%" }')"

	DWM_BAT="Bat: $( acpi -b | awk 'sub(/,/,"") {print $4}')"

	# Wifi Status
	DWM_ESSID="WiFi: $( /sbin/iwgetid -r )"

	# Volume Level
	DWM_VOL="Vol: $( amixer sget Master | awk -vORS=' ' '/Mono:/ {print($6$4)}' )"
	
	# Time Date
	DWM_TIME="$( date +"%F %R" )"

	#xsetroot -name "$(print_song_info) | CPU: $DWM_CPU_TMP $DWM_CPU_USE | $DWM_RAM | $DWM_ESSID | $DWM_BAT | $DWM_VOL| $DWM_TIME"
	xsetroot -name "$(print_song_info) | $DWM_ESSID | $DWM_BAT | $DWM_VOL| $DWM_TIME"

	sleep 30s;

done &

feh --bg-scale .allpaper.jpg 

exec dwm

