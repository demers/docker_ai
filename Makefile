
all: help

help:
	echo
	echo "Usage:"
	echo
	echo "    make create"
	echo
	echo " to create Dockerfile"
	echo
	echo "    make remove"
	echo
	echo

create:
	./dockerfile.bash

remove:
	rm -f ./after.vimrc
	rm -f ./extra.vimrc
	rm -f ./rc.conf
	rm -f ./commands.py
	rm -f Dockerfile


.SILENT: help
