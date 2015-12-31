setxkbmap es;
[[ -f ~/.Xresources ]] && xrdb -I$HOME ~/.Xresources

/usr/bin/dropbox &
/usr/bin/xscreensaver &
/usr/bin/pidgin &
/usr/bin/mpd &

exec awesome

