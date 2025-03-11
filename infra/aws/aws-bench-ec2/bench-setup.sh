#!/bin/bash

#exit the script on error 
set -e

sudo apt update
sudo apt install curl ca-certificates
sudo install -d /usr/share/postgresql-common/pgdg
sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc

# Create the repository configuration file:
sudo sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Update the package lists:
sudo apt update

sudo apt install postgresql-client -y

sudo apt install default-jdk -y
java -version
sudo apt-get -y install maven
mvn -version
git clone https://github.com/prometheus/cloudwatch_exporter.git
cd cloudwatch_exporter
mvn install
cd ..

#download and extract hammerdb 
wget https://github.com/TPC-Council/HammerDB/releases/download/v4.11/HammerDB-4.11-Linux.tar.gz
tar -zxvf HammerDB-4.11-Linux.tar.gz 

#stop unattended restart services dialogue to ask for user input
sudo sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf

mkdir vdbbenchmark && cd vdbbenchmark
echo "Checking & Installing python 3.11"
# Check Python version
python_version=$(python3 --version 2>&1 | cut -d ' ' -f2)

if [[ "$python_version" != "3.11"* ]]; then
    echo "Python version is not 3.11. Removing current version and installing Python 3.11..."
    # Remove current Python version
    # Install Python 3.11
    echo -ne '\n' | sudo add-apt-repository ppa:deadsnakes/ppa
    sudo apt-get update --fix-missing
    sudo apt install python3.11 -y
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2
    echo -ne '\n' | sudo update-alternatives --config python3
    python3 -V
else
    echo "Python version is already 3.11."
fi

# Check if pip is installed
echo "Checking & Installing pip"
if ! command -v pip &> /dev/null; then
    echo "pip is not installed. Installing pip..."

    # Install pip for Python 3
    sudo apt install python3-pip -y
else
    echo "pip is already installed."
fi

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Installing Git..."
    sudo apt install git -y
else
    echo "Git is already installed."
fi

#latest code base changes

echo "Clonning from repository URL"
# Define the repository URL 
repo_url="https://github.com/EmumbaOrg/VectorDBBench.git"

# Check if the .git directory exists
if [ ! -d "pgvector-benchmarking" ]; then
    echo "VectorDBBench repository not found. Cloning repository..."

    # Clone the repository
    git clone -b pgvector-testing $repo_url 
    
    echo "Repository cloned successfully."
else
    echo "VectorDBBench repository already exists in the current directory."
fi

cd VectorDBBench
pwd
# Check if any Python virtual environment is installed
if [ -d "venv" ]; then
    echo "Python virtual environment found. Removing existing venv..."

    # Remove the existing venv
    sudo rm -rf venv
    sudo apt purge python3-venv -y
fi

# Install python3.11-venv package
echo "Installing python3.11-venv package..."
sudo apt install python3.11-venv -y
echo "Python 3.11 venv installed successfully."

#creating venv
python3.11 -m venv venv

echo "Activating venv in VectorDBBench"
# Activate the virtual environment (source command might differ based on your shell)
source venv/bin/activate

echo "Installing pycog"
pip install psycopg2-binary

echo "Installing pgvector"
# Install dependencies using pip (modify the requirements file name if needed)
pip install -e '.[test]'
pip install -e '.[pgvector]'

echo "VectorDB Benchmark has been successfully installed along with its specific requirements."
echo "Activate the venv and run run.py to start the server"

# Install netdata for monitoring
wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh
printf "y\ny\ny\n" | sh /tmp/netdata-kickstart.sh --stable-channel --disable-telemetry