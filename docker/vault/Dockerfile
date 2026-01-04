FROM hashicorp/vault:1.20.4
RUN apk add curl make bash jq
RUN curl -o wait-for-it https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh
RUN chmod +x wait-for-it
RUN mv wait-for-it /usr/local/bin/wait-for-it
# Set a custom PS1
ENV PS1='\[\e[1;32m\]\u@\h:\w\$ \[\e[0m\]'

# The image already comes with a vault user in the vault user group
USER vault
RUN mkdir /vault/vault
WORKDIR /vault/vault

EXPOSE 8200
EXPOSE 8201
