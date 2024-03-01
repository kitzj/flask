#!/bin/bash

# Prompt for the folder name and framework to identify resources to clean up
echo "Enter the folder name used for the application:"
read folder_name
folder_name=$(echo "$folder_name" | tr '[:upper:]' '[:lower:]')

echo "What framework did you use? (for specific cleanup operations)"
read framework
framework=$(echo "$framework" | tr '[:upper:]' '[:lower:]')

# Remove the application directory
echo "Removing the application directory..."
rm -rf ~/$folder_name

# Remove nginx site configuration and disable site
echo "Removing Nginx site configuration..."
sudo rm -f /etc/nginx/sites-available/$folder_name
sudo rm -f /etc/nginx/sites-enabled/$folder_name

# Optionally, you might want to restart nginx to apply changes
sudo nginx -t && sudo service nginx restart

# Remove systemd service file if it exists
echo "Removing systemd service file for the application..."
sudo systemctl stop $folder_name.service
sudo systemctl disable $folder_name.service
sudo rm -f /etc/systemd/system/$folder_name.service
sudo systemctl daemon-reload
sudo systemctl reset-failed

# Framework-specific cleanup
case $framework in
  react|vuejs|express|nextjs|gatsby|angular|angularjs|svelte)
    echo "Removing Node.js and npm..."
    sudo apt remove --purge -y nodejs npm
    ;;

  flask|django)
    echo "Removing Python-related packages..."
    sudo apt remove --purge -y python3-pip python3-dev build-essential libssl-dev libffi-dev python3-setuptools python3-venv
    ;;

  rails)
    echo "Removing Ruby and Rails..."
    rvm implode
    sudo apt remove --purge -y ruby
    ;;

  laravel|symfony)
    echo "Removing PHP and Composer..."
    sudo apt remove --purge -y php* composer
    ;;

  asp)
    echo "Removing .NET Core SDK..."
    sudo apt remove --purge -y dotnet-sdk-6.0
    ;;
esac

# Optionally, clean up any other services or packages installed by the script
# For example, removing nginx and expect if they are no longer needed
sudo apt remove --purge -y nginx expect

echo "Cleanup complete."
