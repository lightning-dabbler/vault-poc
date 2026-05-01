FROM hashicorp/vault:2.0.0

USER root
RUN apk add curl make bash jq
# Set a custom PS1
ENV PS1='\[\e[1;32m\]\u@\h:\w\$ \[\e[0m\]'

# The image already comes with a vault user in the vault user group
USER vault
RUN mkdir /vault/vault
WORKDIR /vault/vault

EXPOSE 8200
EXPOSE 8201
