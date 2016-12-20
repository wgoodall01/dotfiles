# Script to encrypt files
# Usage: 
#	./crypto.sh encrypt <sourcefile> <dest.enc>
#	./crypto.sh decrypt <source.enc> <destfile>

# Load password
if [ -f password ]; then
	pw=$(<password)
else
	printf "crypto.sh: No password file."
	exit 1
fi

case $1 in
	"encrypt") openssl enc -aes-256-cbc -salt -in $2 -out $3 -k "$pw";;
	"decrypt") openssl enc -aes-256-cbc -d    -in $2 -out $3 -k "$pw";;
	*) printf "crypto.sh: Command mot supported: only use encrypt/decrypt";;
esac
