pip install -U pip ansible 
git clone https://github.com/skynetlab1/azcoops.git && cd azcoops
terraform init -upgrade
terraform apply -auto-aprove
sudo ls -la sshcopyid
