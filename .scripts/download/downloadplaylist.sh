mkdir /home/adrian/Music/$1
cd /home/adrian/Music/$1
youtube-dl -x --audio-format mp3 $2
mpc update
