#!/bin/bash

# Set the necessary variables
SERVICE_ACCOUNT_FILE="path/to/your/service-account-key.json"
GROUP_EMAIL_ADDRESS="your-group@example.com"
GROUP_NAME="Your Group Name"
GROUP_DESCRIPTION="Your Group Description"

# Function to create the Google Group
create_google_group() {
  curl -X POST \
    -H "Authorization: Bearer $(get_access_token)" \
    -H "Content-Type: application/json" \
    -d "{
      \"email\": \"$GROUP_EMAIL_ADDRESS\",
      \"name\": \"$GROUP_NAME\",
      \"description\": \"$GROUP_DESCRIPTION\",
      \"allowExternalMembers\": true,
      \"whoCanJoin\": \"INVITED_CAN_JOIN\",
      \"whoCanPostMessage\": \"ANYONE_CAN_POST\",
      \"whoCanViewGroup\": \"ALL_MEMBERS_CAN_VIEW\",
      \"whoCanViewMembership\": \"ALL_MEMBERS_CAN_VIEW\",
      \"membersCanPostAsTheGroup\": false,
      \"archiveOnly\": false,
      \"isArchived\": false
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

# Function to add members to the Google Group from the CSV file
add_members_to_google_group() {
  while IFS= read -r member; do
    curl -X POST \
      -H "Authorization: Bearer $(get_access_token)" \
      -H "Content-Type: application/json" \
      -d "{
        \"fullname\": \"$member\",
        \"role\": \"MEMBER\"
      }" \
      "https://www.googleapis.com/admin/directory/v1/groups/$GROUP_EMAIL_ADDRESS/members"
    echo "Added '$member' to the group '$GROUP_EMAIL_ADDRESS'."
  done < users.csv
}

# Main script execution
create_google_group
add_members_to_google_group

echo "Google Group creation and user addition completed."
