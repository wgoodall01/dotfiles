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

# Decrypt file
printf "Decrypting $2 to $3..."
case $1 in
	"encrypt") openssl enc -aes-256-cbc -salt -in $2 -out $3 -k "$pw"; exit;;
	"decrypt") openssl enc -aes-256-cbc -d    -in $2 -out $3 -k "$pw"; exit;;
	*) printf "crypto.sh: Command mot supported: only use encrypt/decrypt";;
esac
