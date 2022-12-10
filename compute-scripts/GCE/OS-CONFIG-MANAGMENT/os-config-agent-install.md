## `sudo systemctl status google-osconfig-agent` # to confirm os config agent 
## installing google-osconfig-agent for Ubuntu 20.04
sudo su -c "echo 'deb http://packages.cloud.google.com/apt google-compute-engine-bionic-stable main' > \/etc/apt/sources.list.d/google-compute-engine.list"

## installing google-osconfig-agent for Ubuntu 18.04
sudo su -c "echo 'deb http://packages.cloud.google.com/apt google-compute-engine-bionic-stable main' > /etc/apt/sources.list.d/google-compute-engine.list"

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

sudo apt update
sudo apt -y install google-osconfig-agent



