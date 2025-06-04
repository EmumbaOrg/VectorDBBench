#!/bin/bash
set -e
sudo apt update
echo "Installing PostgreSQL 16..."
sudo apt install postgresql-common -y
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
echo "Make, gcc and postgresql-server-dev-16 installed successfully."

echo "Installing pgvector..."
git clone --branch v0.8.0 https://github.com/pgvector/pgvector.git
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
RULE="host all all 10.0.0.0/24 md5"

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
unset PGPASSWORD
echo "pgvector and pg-diskann have created successfully."