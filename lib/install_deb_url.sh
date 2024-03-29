#!/usr/bin/env bash

install_deb_url(){
	name="$1";
	url="$2";
	
	tempdir="$(mktemp -d -t 'install_deb_url.XXXXXX')";
	logfile="$LOGS/install_deb_url_$name";

	printf "[install] $1: ";

	if dpkg -s $name &>/dev/null; then
		printf "already installed\n";
	else
		printf "installing..."

		printf "\n\nInstalling $name from $url on $(date)\n" >>$logfile;
		echo "Temp dir is $tempdir" >>$logfile;
		echo "Retrieved from $1 on $(date)" > $tempdir/info.txt;

		result=\
			curl -L "$url" -o "$tempdir/package.deb" &>$logfile &&\
			sudo gdebi -n "$tempdir/package.deb" &>$logfile;
		
		if $result; then
			printf "done\n";
			rm -rf $tempdir;
		else
			fatal "failed -- check $logfile\n"
		fi

	fi
}
