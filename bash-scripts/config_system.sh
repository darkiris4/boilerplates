#!/bin/bash

# Clear the screen
clear

# Function to install Nala
install_nala() {
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y nala
    echo "Nala is successfully installed."
    read -n 1 -s -r -p "Press any key to continue..."
}

# Function to install Docker
install_docker() {
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y docker.io
    echo "Docker.io is successfully installed."
    read -n 1 -s -r -p "Press any key to continue..."
}

# Function to install Docker Compose
install_docker_compose() {
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y docker-compose
    echo "Docker-Compose is successfully installed."
    read -n 1 -s -r -p "Press any key to continue..."
}

# Function to expose Docker API by modifying docker.service file
expose_docker_api() {
    # Check if Docker API is already exposed
    if grep -q 'tcp://0.0.0.0:2375' /lib/systemd/system/docker.service; then
        echo "Docker API is already exposed."
    else
        echo "Exposing Docker API..."
        sudo sed -i 's/ExecStart=\/usr\/bin\/dockerd/ExecStart=\/usr\/bin\/dockerd -H tcp:\/\/0.0.0.0:2375/' /lib/systemd/system/docker.service
        echo "Restarting deamon..."
        sudo systemctl daemon-reload
        echo "Restarting Docker"
        sudo systemctl restart docker
        echo "Docker API exposed on port 2375 successfully."
    fi
    read -n 1 -s -r -p "Press any key to continue..."
}

# Function to install Neofetch
install_neofetch() {
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y neofetch
    echo "Neofetch is successfully installed."
    read -n 1 -s -r -p "Press any key to continue..."
}

# Function to configure hostname and domain
configure_hostname() {
    read -p "Enter the desired hostname: " hostname
    read -p "Enter the domain: " domain

    sudo hostnamectl set-hostname "$hostname" && \
    sudo sed -i "s/127.0.1.1\s.*/127.0.1.1\t${hostname}.${domain} $hostname/" /etc/hosts && \
    sudo sed -i 's/preserve_hostname: false/preserve_hostname: true/' /etc/cloud/cloud.cfg && \
    sudo systemctl restart systemd-hostnamed
    echo "FQDN has been updated to $hostname.$domain"
    read -n 1 -s -r -p "Press any key to continue..."
}

# Function to update .bashrc for customized prompt
update_bashrc() {
    bashrc_line='export PS1="\[\e[1;32m\]\u@\[\e[1;34m\]$(hostname -f):\[\e[0;37m\]\w\[\e[0m\]\$ "'

    if ! line_exists "$bashrc_line" ~/.bashrc; then
        echo "$bashrc_line" >> ~/.bashrc
    fi

    # Check if neofetch is already present in .bashrc before appending
    if ! line_exists "neofetch" ~/.bashrc; then
        echo 'neofetch' >> ~/.bashrc
    fi
    source ~/.bashrc  # Reload .bashrc to apply changes immediately
    read -n 1 -s -r -p "Press any key to continue..."
}

# Function to check if a line is present in a file
line_exists() {
    grep -Fxq "$1" "$2"
}

# Function to display menu options
display_menu() {
    clear  # Clear the screen before displaying the menu
    echo "Available tasks:"
    echo "1. Install Nala"
    echo "2. Install Docker"
    echo "3. Install Docker Compose"
    echo "4. Expose Docker API"
    echo "5. Install Neofetch"
    echo "6. Configure hostname and domain"
    echo "7. Update .bashrc for customized prompt"
    echo "8. Exit"
}

# Prompt the user for selection
while true; do
    selected_tasks=()
    display_menu

    read -p "Enter your choice(s) separated by commas (e.g., 1,2,3): " choices

    IFS=',' read -ra selected_choices <<< "$choices"

    for choice in "${selected_choices[@]}"; do
        case $choice in
            1)
                install_nala
                ;;
            2)
                install_docker
                ;;
            3)
                install_docker_compose
                ;;
            4)
                expose_docker_api
                ;;
            5)
                install_neofetch
                ;;
            6)
                configure_hostname
                ;;
            7)
                update_bashrc
                ;;
            8)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo "Invalid option. Please enter a number between 1 and 8."
                ;;
        esac
    done
done
