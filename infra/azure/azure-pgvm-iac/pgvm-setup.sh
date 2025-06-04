#!/bin/bash
set -e
sudo apt update
sudo apt install postgresql-common -y
# Define the file to edit
CONFIG_FILE="/etc/postgresql-common/createcluster.conf"

# Check if the file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: File $CONFIG_FILE does not exist!"
  exit 1
fi

# Update or add 'create_main_cluster = true'
if grep -q "^#create_main_cluster" "$CONFIG_FILE"; then
  # Replace the line if it exists
  sudo sed -i "s/^#create_main_cluster.*/create_main_cluster = true/" "$CONFIG_FILE"
fi

# Update the 'data_directory' setting
if grep -q "^#data_directory" "$CONFIG_FILE"; then
  # Replace the line with the new value
  sudo sed -i "s|^#data_directory.*|data_directory = '/ssdv2drive/postgresql/%v/%c'|" "$CONFIG_FILE"
else
  # Add the line if it doesn't exist
  sudo echo "data_directory = '/ssdv2drive/postgresql/%v/%c'" >> "$CONFIG_FILE"
fi

# Confirm the changes
echo "Configuration updated successfully in $CONFIG_FILE."

sudo apt install dirmngr ca-certificates software-properties-common apt-transport-https lsb-release curl -y
curl -fSsL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /usr/share/keyrings/postgresql.gpg > /dev/null
echo deb [arch=amd64,arm64,ppc64el signed-by=/usr/share/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main | sudo tee /etc/apt/sources.list.d/postgresql.list
sudo apt update
sudo apt upgrade -y
sudo apt install postgresql-client-16 postgresql-16 -y
echo "PostgreSQL 16 installed successfully."

echo "Installing required packages..."
sudo apt install make
sudo apt install gcc -y
sudo apt install postgresql-server-dev-16 -y
echo "Make gcc and postgresql-server-dev-16 installed successfully."

echo "Installing pgvector..."
git clone --branch v0.7.4 https://github.com/pgvector/pgvector.git
cd pgvector
make
sudo make install
echo "pgvector installed successfully."
cd ..

# Define the new PostgreSQL password
PASSWORD="postgres"

# Run the commands as the 'postgres' user
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '$PASSWORD';"

# Confirm success
if [[ $? -eq 0 ]]; then
  echo "Password for 'postgres' user has been successfully changed."
else
  echo "Failed to change password for 'postgres' user."
fi

#Define the file to edit
PG_HBA_FILE="/etc/postgresql/16/main/pg_hba.conf"

# Define the rule to add
RULE="host all all 10.0.0.0/16 md5"

# Check if the file exists
if [[ ! -f "$PG_HBA_FILE" ]]; then
  echo "Error: File $PG_HBA_FILE does not exist!"
  exit 1
fi

# Check if the rule already exists in the file
if sudo grep -Fxq "$RULE" "$PG_HBA_FILE"; then
  echo "The rule '$RULE' already exists in $PG_HBA_FILE."
else
  # Append the rule to the file
  sudo echo "$RULE" | sudo tee -a "$PG_HBA_FILE" > /dev/null
  echo "The rule '$RULE' has been added to $PG_HBA_FILE."
fi

sudo service postgresql restart
export PGPASSWORD="$PASSWORD"
psql -U postgres -d postgres -h localhost -c "CREATE EXTENSION IF NOT EXISTS vector;"
FOLDER_NAME="pg_diskann"

# Check if the folder exists
if [[ ! -d "$FOLDER_NAME" ]]; then
  echo "Folder '$FOLDER_NAME' does not exist. Creating it..."
  mkdir "$FOLDER_NAME" && cd "$FOLDER_NAME" || { echo "Failed to create or navigate to the folder."; exit 1; }
  echo "Folder '$FOLDER_NAME' created and navigated successfully."
else
  echo "Folder '$FOLDER_NAME' already exists. Navigating to it..."
  cd "$FOLDER_NAME" || { echo "Failed to navigate to the folder."; exit 1; }
  echo "Navigated to the folder '$FOLDER_NAME'."
fi
tar -xvf $1 

#Copy necessary files
sudo cp pgsql-16.4/lib/pg_diskann.so /usr/lib/postgresql/16/lib
sudo cp pgsql-16.4/share/extension/pg_diskann.control /usr/share/postgresql/16/extension/
sudo cp pgsql-16.4/share/extension/*.sql /usr/share/postgresql/16/extension/

#Change permissions of copied files
sudo chmod 644 /usr/share/postgresql/16/extension/pg_diskann*.sql
sudo chmod 644 /usr/share/postgresql/16/extension/pg_diskann.control
sudo chmod 644 /usr/lib/postgresql/16/lib/pg_diskann.so

psql -U postgres -d postgres -h localhost -c "CREATE EXTENSION pg_diskann CASCADE;"
cd ..
unset PGPASSWORD
echo "pgvector and pg-diskann have created successfully."
echo "please connect to postrgesql and verify the extension versions."