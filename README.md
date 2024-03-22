# Bash System Configuration Script

This Bash script provides a simple and interactive way to perform common system configuration tasks on Linux systems. It offers a menu-driven interface allowing users to select and execute various tasks such as installing packages, configuring hostname and domain, updating .bashrc for customized prompts, exposing Docker API, and more.

## Features

- **Package Installation**: Easily install Nala, Docker, Docker Compose, Neofetch, and other essential packages with a single selection.
- **Configuration Management**: Configure hostname, domain, and customize the bash prompt with ease.
- **Docker API Exposition**: Expose Docker API on port 2375 for remote access.
- **Interactive Menu**: User-friendly menu-driven interface for selecting tasks.
- **Error Handling**: Basic error handling to provide informative messages in case of failures or errors.
- **Feedback and Continual Improvement**: Welcome user feedback and suggestions for improving script functionality and usability.

## Prerequisites

- This script is designed for use on Linux systems.
- Ensure that you have appropriate permissions to execute the script and perform system-level tasks.

## Usage

1. Clone or download the script file (`config_system.sh`) to your local system.
2. Open a terminal and navigate to the directory containing the script.
3. Run the script using the following command: ./config_system.sh
4. Follow the on-screen instructions to select and execute desired tasks from the menu.

## Notes

- Some tasks may require superuser (root) privileges to execute. Ensure you have the necessary permissions before running the script.
- It's recommended to review the script and understand the tasks it performs before executing it on your system.
- Use caution when making system-level changes, especially when exposing services or modifying system configuration files.

## License

This project is licensed under the [MIT License](LICENSE).
