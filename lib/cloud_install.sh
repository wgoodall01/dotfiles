cloud_install(){
	printf "[install] gcloud CLI: init... "
	CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
	echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" \
		| sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
		&>> "$LOGS/gcloud"\
		|| fatal "Couldn't fetch gcloud repo"

	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
		2>> "$LOGS/gcloud" \
		| sudo apt-key add -\
		&>> "$LOGS/gcloud"\
		|| fatal "Couldn't add gcloud key"
	
	sudo apt-get update \
		&>> "$LOGS/gcloud" \
		|| fatal "Couldn't update apt for gcloud"

	printf "done\n"	
	
	install_apt google-cloud-sdk
}
