#!/bin/bash

# Set the necessary variables
SERVICE_ACCOUNT_FILE="path/to/your/service-account-key.json"
GROUP_EMAIL_ADDRESS="your-group@example.com"

# Function to create the Google Workspace Group
create_google_workspace_group() {
  ACCESS_TOKEN=$(get_access_token)
  curl -X POST \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"email\": \"$GROUP_EMAIL_ADDRESS\"
    }" \
    "https://www.googleapis.com/admin/directory/v1/groups"
}

# Function to get the access token
get_access_token() {
  ACCESS_TOKEN=$(curl -s "https://www.googleapis.com/oauth2/v4/token" \
    -d "client_id=$(jq -r '.client_id' $SERVICE_ACCOUNT_FILE)" \
    -d "client_secret=$(jq -r '.client_secret' $SERVICE_ACCOUNT_FILE)" \
    -d "refresh_token=$(jq -r '.refresh_token' $SERVICE_ACCOUNT_FILE)" \
    -d "grant_type=refresh_token" | jq -r '.access_token')
  echo $ACCESS_TOKEN
}

# Function to add members to the Google Workspace Group from the CSV file
add_members_to_google_workspace_group() {
  ACCESS_TOKEN=$(get_access_token)
  while IFS= read -r member; do
    curl -X POST \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{
        \"email\": \"$member\",
        \"role\": \"MEMBER\"
      }" \
      "https://www.googleapis.com/admin/directory/v1/groups/$GROUP_EMAIL_ADDRESS/members"
    echo "Added '$member' to the group '$GROUP_EMAIL_ADDRESS'."
  done < users.csv
}

# Main script execution
create_google_workspace_group
add_members_to_google_workspace_group

echo "Google Workspace Group creation and user addition completed."

