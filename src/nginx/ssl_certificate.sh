#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne "0" ]; then
    echo "This script must be run as root." 1>&2
    exit 1
fi

# Check if the correct number of arguments are provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <domain>" 1>&2
    exit 1
fi

DOMAIN=$1

echo "Starting."

# Obtain and install the SSL certificate if Certbot is installed
echo "Checking for Certbot installation..."
if command -v certbot &> /dev/null; then
    echo "Certbot found. Obtaining SSL certificate for $DOMAIN..."
    sudo certbot --nginx -d $DOMAIN

    # Reload Nginx to apply SSL changes
    systemctl reload nginx

    echo "SSL certificate has been obtained and Nginx reloaded."
else
    echo "Certbot is not installed. SSL certificate setup skipped."
fi
