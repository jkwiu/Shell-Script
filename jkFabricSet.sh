#!/bin/bash

OS=""
OS_ID=""
OS_CODENAME=""
CPU_ARCH=""

apt update

echo "apt update && apt upgrade"
apt-get update -y && apt-get --assume-yes upgrade

echo "install virtualbox extention"
apt-get --assume-yes install virtualbox-guest-dkms
apt-get --assume-yes install linux-headers-virtual

echo "Then, Change the VM option : 장치 -> 양방향"

echo "Install VIM"

apt-get install --assume-yes vim

echo "Install git, curl, libltdl-dev, tree, openssh-server, net-tools"

apt-get install --assume-yes git curl libltdl-dev tree openssh-server net-tools -y

goInstall(){
	        echo "Install Golang"
		wget -P $HOME/Downloads  https://dl.google.com/go/go1.12.5.${OS}-${CPU_ARCH}.tar.gz
		tar -C /usr/local -xzf $HOME/Downloads/go1.12.5.${OS}-${CPU_ARCH}.tar.gz
		sed -i "\$aexport GOROOT=/usr/local/go/bin" $HOME/.profile
		. $HOME/.profile
		mkdir -p $HOME/work/go/{src,pkg,bin}
		sed -i "\$aexport GOPATH=\$HOME/work/go" $HOME/.profile
		sed -i "\$aexport PATH=\$PATH:$GOROOT/bin" $HOME/.profile
		echo "Go install finished."
}

installDocker(){
	echo "Install Docker"
	if [ $OS_ID=="ubuntu" ]; then
		wget -P ./docker.deb https://download.docker.com/$OS/$OS_ID/dists/$OS_CODENAME/pool/stable/$CPU_ARCH/docker-ce_18.09.6~3-0~ubuntu-xenial_amd64.deb
		dpkg -i ./docker.deb/docker-ce_18.09.6~3-0~ubuntu-xenial_amd64.deb
	fi
		usermod -aG docker $(whoami)
		echo "Docker install finished."
	docker run hello-world
																			installDockerCompose
}

installDockerCompose(){
	echo "Install Docker Compose"
	if [ $ OS=="linux" ]; then
		sudo curl -L "https://github.com/docker/compose/release/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	fi
	echo "Docker Compose install finished."
}

installHLF(){
	echo "Install Hyperledger Fabric 1.4"
	mkdir -p $GOPATH/src/github.com/hyperledger
	cd $GOPATH/src/github.com/hyperledger
	git clone https://github.com/hyperledger/fabric.git
	cd $GOPATH/src/github.com/hyperledger/fabric
	make
	sed -i "\$aexport FABRIC_HOME=$GOPATH/src/github.com/hyperledger/fabric"
	sed -i "\$aexport PATH=\$PATH:$GOPATH/srcc/github.com/hyperledger/fabric/.build/bin"
	. $HOME/.profile
	echo "HLF install finished."
}


# Initiate setting
if [ $(uname -s)=="Linux" ]; then
	OS="linux"
	OS_CODENAME=$(lsb_release -c -s)
if [ $(lsb_release -i -s)=="Ubuntu" ]; then
        OS_ID="ubuntu"
elif [ $(lsb_release -i -s)=="CentOS" ]; then
        OS_ID="centos"
fi
   case $(uname -m) in
        i386)   CPU_ARCH="386" ;;
        i686)   CPU_ARCH="386" ;;
        x86_64) CPU_ARCH="amd64" ;;
        arm)    dpkg --print-architecture | grep -q "arm64" && CPU_ARCH="arm64" || CPU_ARCH="arm" ;;
   esac
echo "System Detected."
echo "OS(Operation System)		$OS"
echo "OS Type				$OS_ID"
echo "OS Code Name			$OS_CODENAME"
echo "CPU Architecture			$CPU_ARCH"
fi

goInstall
installDocker
installDockerCompose
					







