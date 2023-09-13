docker run -it -p 8888:8888 jupyter/scipy-notebook:2023-08-19


docker run -it --rm \
    -p 8888:8888 \
    --user root \
    -e NB_USER=mends \
    -e NB_UID="$(id -u)" \
    -e NB_GID="$(id -g)"  \
    -e CHOWN_HOME=yes \
    -e CHOWN_HOME_OPTS="-R" \
    -e GRANT_SUDO=yes \
    -w "/home/mends" \
    -v "${PWD}":/home/mends/mends-on-fhir \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --privileged \
    jupyter/minimal-notebook start-notebook.sh --IdentityProvider.token=''

docker run -it  \
    -p 8888:8888 \
    --user root \
    -e NB_USER=mends \
    -e NB_UID="$(id -u)" \
    -e NB_GID="$(id -g)"  \
    -e CHOWN_HOME=yes \
    -e CHOWN_HOME_OPTS="-R" \
    -e GRANT_SUDO=yes \
    -w "/home/mends" \
    -v "${PWD}/..":/home/mends/mends-on-fhir \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --privileged \
    docker_sock_jupyter start-notebook.sh --IdentityProvider.token=''


# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/recipes.html
# RISE == run jupyter cells as slides
FROM jupyter/base-notebook

RUN mamba install --yes 'jupyterlab_rise' && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"



# Installing docker on Ubunutu
# https://docs.docker.com/engine/install/ubuntu/
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y


# Better way to install Docker: Use get-docker script
# https://docs.docker.com/engine/install/ubuntu/
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Non-root user mode
# https://docs.docker.com/engine/install/linux-postinstall/

# Create docker group
# sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker


sudo sh -eux <<EOF
# Install newuidmap & newgidmap binaries
apt-get install -y uidmap
# Add subuid entry for mends
echo "mends:100000:65536" >> /etc/subuid
# Add subgid entry for mends
echo "mends:100000:65536" >> /etc/subgid
EOF


dockerd-rootless-setuptool.sh install


# How to run docker in docker container [3 easy methods]
# https://devopscube.com/run-docker-in-docker/





docker run -it --rm \
    -p 8888:8888 \
    --user root \
    -e NB_USER=mends \
    -e NB_UID="$(id -u)" \
    -e NB_GID="$(id -g)"  \
    -e CHOWN_HOME=yes \
    -e CHOWN_HOME_OPTS="-R" \
    -e GRANT_SUDO=yes \
    -e LOCAL_MENDS_HOME="${HOME}/Documents/git/mends-on-fhir" \
    -e JUPYTER_MENDS_HOME="/home/mends/mends-on-fhir" \
    -w "/home/mends" \
    -v "${PWD}/..":/home/mends/mends-on-fhir \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --privileged \
    mgkahn_jupyter_docker_rise