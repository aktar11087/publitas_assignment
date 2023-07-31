#!/bin/bash

# Set variables
SERVICE_ACCOUNT_KEY='path/to/your/service_account_key.json'
DOMAIN='aktar.i-leaflets.net'

# Function to create a user
function create_user() {
  local first_name=$1
  local last_name=$2
  local email=$3
  local employee_title=$4

  # Create a JSON payload for the user
  local payload=$(cat << EOF
{
  "name": {
    "givenName": "$first_name",
    "familyName": "$last_name"
  },
  "primaryEmail": "$email",
  "password": "password123",  # Set a default password or generate one
  "changePasswordAtNextLogin": true
}
EOF
)

  # Make the API call to create the user
  curl --request POST \
    --header "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
    --header "Content-Type: application/json" \
    --data "$payload" \
    "https://www.googleapis.com/admin/directory/v1/users"
}

# Read the CSV file and create users
while IFS=, read -r first_name last_name email; do
  create_user "$first_name" "$last_name" "$email" "$employee_title"
done < 'path/to/your/csv_file.csv'

echo "Users created successfully!"
