cd src/main/assets
MAX_OPEN_FILE=$(ulimit -n)
if [ $MAX_OPEN_FILE -lt 2048 ]
then
ulimit -n 2048
fi
./doomtool -i assets/ -o assets.pak
if [ $MAX_OPEN_FILE -lt 2048 ]
then
ulimit -n $MAX_OPEN_FILE
fi
rm -rf assets
cd ../../..
