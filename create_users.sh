#!/bin/bash

# Check if the script is run with sudo/root privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "This script requires superuser privileges. Please run with sudo or as root."
  exit 1
fi

# Check if the CSV file is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 path/to/users.csv"
  exit 1
fi

# CSV file path
csv_file="$1"

# Function to create a regular user
function create_user() {
  local username="$1"
  local full_name="$2"
  local job_position="$3"

  # Set a default password or generate a random one
  local password="Welcome123!"
  # You can implement a password generation logic if needed
  # password=$(your_password_generation_function)

  # Create the user with home directory and default shell (/bin/bash)
  useradd -m -c "$full_name, $job_position" -s /bin/bash "$username"
  echo "$username:$password" | chpasswd
}

# Read the CSV file and create users
while IFS=, read -r username full_name job_position; do
  # Skip the header row
  if [ "$username" != "Username" ]; then
    create_user "$username" "$full_name" "$job_position"
    echo "User $username created successfully."
  fi
done < "$csv_file"

echo "Regular user creation complete"
