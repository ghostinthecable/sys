#!/bin/bash

#
# ghostinthecable's sys scripts;
# fail2ban-manager.sh - does what it says on the tin (hopefully).
#

# Fail2Ban Management Script with Menu Interface;

# Function to check if the script is run as root
check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "This script must be run as root. Please use sudo."
        exit 1
    fi
}

# Function to display the main menu
show_menu() {
    echo "-------------------------------------"
    echo "        Fail2Ban Manager Menu        "
    echo "-------------------------------------"
    echo "1. View Fail2Ban Status"
    echo "2. List All Jails"
    echo "3. View Banned IPs for a Jail"
    echo "4. Unban an IP"
    echo "5. Ban an IP"
    echo "6. Restart Fail2Ban Service"
    echo "7. Exit"
    echo "-------------------------------------"
}

# Function to view Fail2Ban status
view_status() {
    echo "Fail2Ban Status:"
    fail2ban-client status
    echo ""
}

# Function to list all jails
list_jails() {
    echo "Configured Jails:"
    fail2ban-client status | grep "Jail list" | sed 's/Jail list://'
    echo ""
}

# Function to view banned IPs for a specific jail
view_banned_ips() {
    read -rp "Enter the jail name: " jail
    if fail2ban-client status "$jail" >/dev/null 2>&1; then
        echo "Banned IPs for jail '$jail':"
        fail2ban-client status "$jail" | grep "Banned IP list" | sed 's/Banned IP list://'
    else
        echo "Jail '$jail' does not exist."
    fi
    echo ""
}

# Function to unban an IP
unban_ip() {
    read -rp "Enter the jail name: " jail
    if ! fail2ban-client status "$jail" >/dev/null 2>&1; then
        echo "Jail '$jail' does not exist."
        echo ""
        return
    fi

    read -rp "Enter the IP address to unban: " ip
    if [[ -z "$ip" ]]; then
        echo "No IP address entered."
        echo ""
        return
    fi

    fail2ban-client set "$jail" unbanip "$ip"
    if [[ $? -eq 0 ]]; then
        echo "Successfully unbanned IP $ip from jail '$jail'."
    else
        echo "Failed to unban IP $ip from jail '$jail'."
    fi
    echo ""
}

# Function to ban an IP
ban_ip() {
    read -rp "Enter the jail name: " jail
    if ! fail2ban-client status "$jail" >/dev/null 2>&1; then
        echo "Jail '$jail' does not exist."
        echo ""
        return
    fi

    read -rp "Enter the IP address to ban: " ip
    if [[ -z "$ip" ]]; then
        echo "No IP address entered."
        echo ""
        return
    fi

    fail2ban-client set "$jail" banip "$ip"
    if [[ $? -eq 0 ]]; then
        echo "Successfully banned IP $ip on jail '$jail'."
    else
        echo "Failed to ban IP $ip on jail '$jail'."
    fi
    echo ""
}

# Function to restart Fail2Ban service
restart_fail2ban() {
    echo "Restarting Fail2Ban service..."
    systemctl restart fail2ban
    if [[ $? -eq 0 ]]; then
        echo "Fail2Ban service restarted successfully."
    else
        echo "Failed to restart Fail2Ban service."
    fi
    echo ""
}

# Main script execution starts here
check_root

while true; do
    show_menu
    read -rp "Enter your choice [1-7]: " choice
    echo ""

    case $choice in
        1)
            view_status
            ;;
        2)
            list_jails
            ;;
        3)
            view_banned_ips
            ;;
        4)
            unban_ip
            ;;
        5)
            ban_ip
            ;;
        6)
            restart_fail2ban
            ;;
        7)
            echo "Exiting Fail2Ban Manager. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter a number between 1 and 7."
            echo ""
            ;;
    esac
done
