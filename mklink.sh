if [[ ! -e links/$1 && -L ~/$1 ]]; then
	mv ~/$1 links/$1
	ln ~/$1 links
fi
	
