FROM ubuntu

RUN apt-get update && \
        apt-get install -y unzip curl 

RUN  curl -o vault.zip https://releases.hashicorp.com/vault/1.0.3/vault_1.0.3_linux_amd64.zip && \
        unzip vault.zip && \
        mv vault /usr/local/bin/ 

COPY vault.hcl /etc/vault/config/

CMD ["vault", "server", "-config", "/etc/vault/config/vault.hcl"]
