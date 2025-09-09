#!/bin/bash

# Team Setup Script for Dev Container
# This script helps add team members to the dev container

set -e

NAMESPACE="dev-environment"
SECRET_NAME="dev-container-ssh-keys"

echo "👥 Dev Container Team Setup"
echo "=========================="

# Function to add SSH key for a team member
add_team_member() {
    local member_name="$1"
    local ssh_key="$2"
    
    if [ -z "$member_name" ] || [ -z "$ssh_key" ]; then
        echo "❌ Usage: add_team_member <member_name> <ssh_public_key>"
        return 1
    fi
    
    echo "➕ Adding team member: $member_name"
    
    # Check if secret exists
    if ! kubectl get secret $SECRET_NAME -n $NAMESPACE >/dev/null 2>&1; then
        echo "📝 Creating SSH keys secret..."
        kubectl create secret generic $SECRET_NAME -n $NAMESPACE --from-literal=authorized_keys="$ssh_key"
    else
        echo "📝 Updating SSH keys secret..."
        # Get existing keys
        existing_keys=$(kubectl get secret $SECRET_NAME -n $NAMESPACE -o jsonpath='{.data.authorized_keys}' | base64 -d)
        
        # Add new key if not already present
        if ! echo "$existing_keys" | grep -q "$(echo "$ssh_key" | cut -d' ' -f2)"; then
            updated_keys="$existing_keys"$'\n'"$ssh_key"
            kubectl patch secret $SECRET_NAME -n $NAMESPACE -p="{\"data\":{\"authorized_keys\":\"$(echo -n "$updated_keys" | base64 -w 0)\"}}"
            echo "✅ SSH key added for $member_name"
        else
            echo "⚠️  SSH key already exists for this user"
        fi
    fi
}

# Function to list current team members
list_team_members() {
    echo "👥 Current team members with SSH access:"
    echo "========================================"
    
    if kubectl get secret $SECRET_NAME -n $NAMESPACE >/dev/null 2>&1; then
        kubectl get secret $SECRET_NAME -n $NAMESPACE -o jsonpath='{.data.authorized_keys}' | base64 -d | while read -r line; do
            if [ -n "$line" ]; then
                # Extract username from SSH key (usually the last part)
                username=$(echo "$line" | awk '{print $NF}')
                echo "  - $username"
            fi
        done
    else
        echo "  No SSH keys configured yet"
    fi
}

# Function to remove team member
remove_team_member() {
    local member_name="$1"
    
    if [ -z "$member_name" ]; then
        echo "❌ Usage: remove_team_member <member_name>"
        return 1
    fi
    
    echo "➖ Removing team member: $member_name"
    
    if kubectl get secret $SECRET_NAME -n $NAMESPACE >/dev/null 2>&1; then
        # Get existing keys
        existing_keys=$(kubectl get secret $SECRET_NAME -n $NAMESPACE -o jsonpath='{.data.authorized_keys}' | base64 -d)
        
        # Remove the key for the specified member
        updated_keys=$(echo "$existing_keys" | grep -v "$member_name")
        
        if [ "$existing_keys" != "$updated_keys" ]; then
            kubectl patch secret $SECRET_NAME -n $NAMESPACE -p="{\"data\":{\"authorized_keys\":\"$(echo -n "$updated_keys" | base64 -w 0)\"}}"
            echo "✅ SSH key removed for $member_name"
        else
            echo "⚠️  No SSH key found for $member_name"
        fi
    else
        echo "❌ SSH keys secret not found"
    fi
}

# Function to generate SSH key pair for a team member
generate_ssh_key() {
    local member_name="$1"
    local key_type="${2:-rsa}"
    local key_size="${3:-4096}"
    
    if [ -z "$member_name" ]; then
        echo "❌ Usage: generate_ssh_key <member_name> [key_type] [key_size]"
        return 1
    fi
    
    echo "🔑 Generating SSH key pair for: $member_name"
    
    local key_file="~/.ssh/${member_name}_dev_container_${key_type}"
    
    # Generate the key
    ssh-keygen -t "$key_type" -b "$key_size" -f "$key_file" -N "" -C "${member_name}@dev-container"
    
    echo "✅ SSH key pair generated:"
    echo "   Private key: $key_file"
    echo "   Public key:  $key_file.pub"
    echo ""
    echo "📋 Public key content:"
    cat "${key_file}.pub"
    echo ""
    echo "💡 Add this public key to the dev container using:"
    echo "   ./team-setup.sh add $member_name \"\$(cat $key_file.pub)\""
}

# Main script logic
case "$1" in
    "add")
        if [ $# -ne 3 ]; then
            echo "❌ Usage: $0 add <member_name> <ssh_public_key>"
            exit 1
        fi
        add_team_member "$2" "$3"
        ;;
    "list")
        list_team_members
        ;;
    "remove")
        if [ $# -ne 2 ]; then
            echo "❌ Usage: $0 remove <member_name>"
            exit 1
        fi
        remove_team_member "$2"
        ;;
    "generate")
        if [ $# -lt 2 ]; then
            echo "❌ Usage: $0 generate <member_name> [key_type] [key_size]"
            exit 1
        fi
        generate_ssh_key "$2" "$3" "$4"
        ;;
    *)
        echo "👥 Dev Container Team Setup"
        echo "=========================="
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  add <member_name> <ssh_public_key>  - Add team member with SSH key"
        echo "  list                                - List current team members"
        echo "  remove <member_name>                - Remove team member"
        echo "  generate <member_name> [type] [size] - Generate SSH key pair"
        echo ""
        echo "Examples:"
        echo "  $0 add john 'ssh-rsa AAAAB3NzaC1yc2E... john@laptop'"
        echo "  $0 list"
        echo "  $0 remove john"
        echo "  $0 generate jane rsa 4096"
        ;;
esac


