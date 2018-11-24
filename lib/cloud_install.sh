gcloud_install(){
	if [ -d "$HOME/google-cloud-sdk" ]; then
		printf "[install] gcloud: already installed.\n"
	else 
		printf "[install] gcloud: CLI... "
		export CLOUDSDK_CORE_DISABLE_PROMPTS=1
		curl https://sdk.cloud.google.com 2>>$LOGS/gcloud_install \
			| bash &>>$LOGS/gcloud_install \
			&& printf "done.\n" \
			|| fatal "Error - check \$LOGS/gcloud_install\n"

		PATH="$PATH:$HOME/google-cloud-sdk/bin/"
		
		printf "[install] gcloud: datastore..."
		gcloud components install cloud-datastore-emulator &>>$LOGS/gcloud_datastore \
			&& printf "done.\n" \
			|| fatal "Error - check \$LOGS/gcloud_install\n"
		
		printf "[install] gcloud: beta..."
		gcloud components install beta &>>$LOGS/gcloud_beta \
			&& printf "done.\n"\
			|| fatal "Error - check \$LOGS/gcloud_beta"
		
		printf "[install] gcloud: kubectl..."
		gcloud components install kubectl &>>$LOGS/gcloud_kubectl \
			&& printf "done.\n"\
			|| fatal "Error - check \$LOGS/gcloud_kubectl"
			
		printf "[install] gcloud: docker-credential-gcr..."
		gcloud components install docker-credential-gcr &>> $LOGS/gcloud_docker_creds \
			&& printf "done.\n" \
			|| fatal "Error - check \$LOGS/gcloud_docker_creds"
	fi
}


add_docker_user_group(){
	printf "[ docker] Add user to docker group... "\
		&& sudo usermod -a -G docker "$(whoami)" &>$LOGS/docker_group\
		&& printf "done.\n"\
		|| fatal "couldn't add user - check LOGS/docker_group"
}
