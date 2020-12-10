export LD_LIBRARY_PATH=/usr/lib

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

echo $DIR
$DIR/opencv_descriptors "$@"
