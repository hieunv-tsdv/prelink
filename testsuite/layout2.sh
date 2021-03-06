#!/bin/bash
. `dirname $0`/functions.sh
rm -f layout2 layout2lib*.so layout2.log
i=1
BINS="layout2"
LIBS=
while [ $i -lt 6 ]; do
  $RUN_HOST $CXX -shared -fpic -o layout2lib$i.so $srcdir/layoutlib.C
  LIBS="$LIBS layout2lib$i.so"
  i=`expr $i + 1`
done
$RUN_HOST $CXXLINK -o layout2 $srcdir/layout.C layout2lib*.so
savelibs
echo $PRELINK ${PRELINK_OPTS--vR} ./layout2 > layout2.log
$RUN_HOST $PRELINK ${PRELINK_OPTS--vR} ./layout2 >> layout2.log 2>&1 || exit 1
grep -q ^`echo $PRELINK | sed 's/ .*$/: /'` layout2.log && exit 2
if [ "x$CROSS" = "x" ]; then
 $RUN LD_LIBRARY_PATH=. ./layout2 || exit 3
fi
$RUN_HOST $READELF -a ./layout2 >> layout2.log 2>&1 || exit 4
# So that it is not prelinked again
chmod -x ./layout2
comparelibs >> layout2.log 2>&1 || exit 5
