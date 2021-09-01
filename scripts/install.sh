#!/bin/bash

#installing PostgreSQL
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "starting update"
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
sudo apt-get install -y -q
sudo apt-get update
echo "starting upgrade"
sudo apt-get upgrade -y
sudo apt-get install build-essential -y
sudo apt-get -y install postgresql-9.6

sudo systemctl enable postgresql

if sudo systemctl is-active --quiet postgresql; then
        echo "Service is running"

else
        echo "Starting the service"
        sudo service postgresql start

fi

sudo -u postgres psql -c "ALTER USER postgres WITH ENCRYPTED PASSWORD 'mysecurepassword';"

wget https://golang.org/dl/go1.17.linux-amd64.tar.gz

sudo tar -C /usr/local/ -xzf go1.17.linux-amd64.tar.gz

sudo groupadd -r servian
sudo usermod -a -G servian local
sudo cp /etc/sudoers /etc/sudoers.orig
echo "local  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/local

sudo -H -i -u local 

echo user is $USER 

export GOROOT=/usr/local/go
export GOPATH=/home/local/go
export GOCACHE=/home/local/.cache/go
export XDG_CACHE_HOME=/home/local/.cache/xdg
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin:$GOCACHE:$XDG_CACHE_HOME


echo "check go version"
go version

git clone https://github.com/servian/TechChallengeApp.git

echo "cloning the repo at $PWD"

cd ./TechChallengeApp

#calling builld.sh to build the applicaation
echo user is $USER

go get -d github.com/servian/TechChallengeApp

if [ $? -eq 0 ]; then
        echo "dependies downloaded and current working directory is $PWD"
        go version
else
        echo "trying again"
        go get -d github.com/servian/TechChallengeApp
        sleep 10
fi

echo user is $USER

echo PWD is $PWD

echo "calling build.sh"

sh ./build.sh

if [ $? -eq 0 ]; then
        echo "build script completed"
        echo "current working directory is $PWD"
else
        exit 1
fi

cd ./dist

#changing the password for db configuration in conf.toml

sed -i 's/changeme/mysecurepassword/g' conf.toml
sed -i 's/"ListenHost" = "localhost"/"ListenHost" = "servianvm"/g' conf.toml

#Creating tables and DB
./TechChallengeApp updatedb

# starting the application
nohup ./TechChallengeApp serve &

proj_base=/proj/servian
std_logs=/var/lib/waagent/custom-script/download/0/

sudo mkdir -p "$proj_base"

sudo ln -s "$std_logs" "$proj_base"/app

status_code="$(curl --write-out %{http_code} --silent --output /dev/null http://servianvm:3000/healthcheck/)"

echo "$status_code"

if [ "$status_code" -eq 200 ] ; then
        echo "server started successfully. check the service at 3000 "
else
  echo "something is not right, please check the "$proj_base"/app directory "
fi
