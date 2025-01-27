function install_docker {
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    
    # install
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo usermod -aG docker $USER

    sudo newgrp docker
    
}

function folder_exists() {
    local folder_path="$1"
    if [ -d "$folder_path" ]; then
        return 0  # Folder exists
    else
        return 1  # Folder does not exist
    fi
}


function network_exists() {
    local network_name="$1"
    if docker network ls | grep -w "$network_name" > /dev/null; then
        return 0  # Network exists
    else
        return 1  # Network does not exist
    fi
}

function setup_traefik {
    # Example usage of the function in an if statement
    NETWORK_NAME="traefik_proxy"

    if network_exists "$NETWORK_NAME"; then
        echo "Network '$NETWORK_NAME' exists."
    else
        echo "Network '$NETWORK_NAME' does not exist, creating now...."
        docker network create $NETWORK_NAME
    fi

    mkdir -p "/services/traefik"
    echo "Creating traefik directory"

    cp -r "$PWD/traefik/*" /services/traefik
}

function main {
    echo "Checking docker installation"

    if command -v docker &> /dev/null; then
        echo "Docker installation found"
    else
        echo "Docker installation not found, installing now..."
        install_docker        
    fi

    # Function to check if a folder exists
  
    # Example usage of the function in an if statement
    FOLDER_PATH="/services/traefik"

    if folder_exists "$FOLDER_PATH"; then
       echo "Traefik already exists" 
    else
        setup_traefik
    fi

}


main
