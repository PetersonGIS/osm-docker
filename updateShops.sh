#!/bin/sh
db=osm
pguser=osm
pgpassword=osm
pghost=192.168.59.103
path=/Users/Juan/Development/imposm
repopath=/Users/Juan/data/repos/osm_shop
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk7/Contents/Home


rm $data/update.osc.gz
/usr/local/bin/osmosis --rri workingDirectory=$path --wxc $path/update.osc.gz
/Users/Juan/Development/imposm/bin/imposm3 diff -config $path/config-shop.json $path/update.osc.gz
cd $repopath
/Users/Juan/Development/GeoGig/src/cli-app/target/geogig/bin/geogig pg import --host $pghost --port 5432 --schema public --database $db --user $pguser --password $pgpassword -t osm_shop
/Users/Juan/Development/GeoGig/src/cli-app/target/geogig/bin/geogig add
/Users/Juan/Development/GeoGig/src/cli-app/target/geogig/bin/geogig commit -m "Automatic OSM Update"
/Users/Juan/Development/GeoGig/src/cli-app/target/geogig/bin/geogig push origin master

