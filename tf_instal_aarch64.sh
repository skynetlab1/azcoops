if [[ "$(uname -m)" == "aarch64" ]]; then
    # Necessary workaround on ARM until this issue is resolved: https://github.com/hashicorp/terraform/issues/32008

    # Pull the latest terraform version from the file list at https://releases.hashicorp.com/terraform by selecting all versions, sorting, and selecting the latest/last.   
    LATEST_TF_VERSION=$(curl -X GET "https://releases.hashicorp.com/terraform" | sed -rn "s/.*terraform_([0-9]+\.[0-9]+\.[0-9]+).*/\1/p" | sort | tail -n 1)

    # Pull and extract terraform at the target version in /usr/local/bin
    cd /usr/local/bin
    sudo wget "https://releases.hashicorp.com/terraform/${LATEST_TF_VERSION}/terraform_${LATEST_TF_VERSION}_linux_arm64.zip"
    sudo unzip terraform_${LATEST_TF_VERSION}_linux_arm64.zip
    sudo chmod +x terraform
    sudo rm -f terraform_${LATEST_TF_VERSION}_linux_arm64.zip
else
    if [[ "$(lsb_release -i -s)" == "Ubuntu" ]] || [[ "$(lsb_release -i -s)" == "Debian" ]]; then
        # Following the documentation for Ubuntu/Debian here - https://learn.hashicorp.com/tutorials/terraform/install-cli

        # Add the HashiCorp GPG key
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

        # Add the official HashiCorp Linux repository
        sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

        # Update and install
        sudo apt-get update && sudo apt-get install -y terraform
    elif [[ "$(lsb_release -i -s)" == "CentOS" ]] || [[ "$(lsb_release -i -s)" == "RHEL" ]]; then
        # Following the documentation for RHEL/CentOS here - https://www.terraform.io/downloads

        # Add HashiCorp repo
        sudo yum config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

        # Install terraform
        sudo yum install -y terraform

        sudo yum clean all
    else
        echo "Unsupported operating system. Please run this script on Ubuntu, Debian, CentOS or RHEL."
        exit 1
    fi
fi
