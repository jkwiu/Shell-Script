#!/bin/bash

OS=""
OS_ID=""
OS_CODENAME=""
CPU_ARCH=""

#
# HLF설치시 hostname에 따라 make 명령어가 다릅니다. hostname을 수정하고 사용해주세요.(peer, orderer, admin, kafka etc.)
#
# echo "install virtualbox extention"
# apt-get --assume-yes install virtualbox-guest-dkms
# apt-get --assume-yes install linux-headers-virtual

# echo "Then, Change the VM option : 장치 -> 양방향"

aptToolInstall(){
echo -e "\e[32mapt update" #&& apt upgrade\e[0m"
sudo apt-get update -y #&& apt-get --assume-yes upgrade
echo -e "\e[32mInstall VIM\e[0m"

sudo apt-get install --assume-yes vim

echo -e "\e[32mInstall\e[0m \e[31mgit\e[0m, \e[37mcurl\e[0m, \e[33mlibltdl-dev\e[0m, \e[34mtree\e[0m, \e[35mopenssh-server\e[0m, \e[36mnet-tools\e[0m, \e[38mmake\e[0m"

sudo apt-get install --assume-yes git curl libltdl-dev tree openssh-server net-tools make -y
}

goInstall(){
	        echo -e "\e[32mInstall Golang\e[0m"
		wget -P $HOME/Downloads  https://dl.google.com/go/go1.12.5.${OS}-${CPU_ARCH}.tar.gz
		tar -C /usr/local -xzf $HOME/Downloads/go1.12.5.${OS}-${CPU_ARCH}.tar.gz
		sed -i "\$aexport GOROOT=/usr/local/go/" $HOME/.profile		
		mkdir -p $HOME/work/go/{src,pkg,bin}
		sed -i "\$aexport GOPATH=\$HOME/work/go" $HOME/.profile
		sed -i "\$aexport PATH=\$PATH:$GOROOT/bin" $HOME/.profile
		echo -e "\e[32mGo install finished.\e[0m"
		. $HOME/.profile
}

installDocker(){
	echo -e "\e[32mInstall Docker\e[0m"
	if [ $OS_ID=="ubuntu" ]; then
		wget -P ./docker.deb https://download.docker.com/$OS/$OS_ID/dists/$OS_CODENAME/pool/stable/$CPU_ARCH/containerd.io_1.2.4-1_amd64.deb
		wget -P ./docker.deb https://download.docker.com/$OS/$OS_ID/dists/$OS_CODENAME/pool/stable/$CPU_ARCH/docker-ce-cli_18.09.3~3-0~ubuntu-bionic_amd64.deb
		wget -P ./docker.deb https://download.docker.com/$OS/$OS_ID/dists/$OS_CODENAME/pool/stable/$CPU_ARCH/docker-ce_18.09.3~3-0~ubuntu-bionic_amd64.deb
		wget -P ./docker.deb http://kr.archive.ubuntu.com/ubuntu/pool/main/libt/libtool/libltdl7_2.4.6-2_amd64.deb
		sudo dpkg -i ./docker.deb/containerd.io_1.2.4-1_amd64.deb
		sudo dpkg -i ./docker.deb/libltdl7_2.4.6-2_amd64.deb
		sudo dpkg -i ./docker.deb/docker-ce-cli_18.09.3~3-0~ubuntu-bionic_amd64.deb
		sudo dpkg -i ./docker.deb/docker-ce_18.09.3~3-0~ubuntu-bionic_amd64.deb
	fi
	USER=`logname`
	sudo usermod -aG docker $USER
	sudo service docker restart
	echo -e "\e[32mDocker install finished\e[0m"
	installDockerCompose
}

installDockerCompose(){
	echo -e "\e[32mInstall Docker Compose\e[0m"
	if [ $OS=="linux" ]; then
		sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
		sudo chmod +x /usr/local/bin/docker-compose
	fi
	echo -e "\e[32mDocker Compose install finished.\e[0m"
}


installHLF(){
	USER=`logname`
	echo -e "\e[32mInstall Hyperledger Fabric 1.4\e[0m"
        sudo git clone -v -b release-1.4 --progress https://github.com/hyperledger/fabric  /home/$USER/work/go/src/github.com/hyperledger/fabric
	sed -i "\$aexport FABRIC_HOME=/home/$USER/work/go/src/github.com/hyperledger/fabric" $HOME/.profile  &&  source $HOME/.profile
      	 cd $FABRIC_HOME
		   case $(hostname) in
		   		peer*) make - peer;;
				orderer*) make - orderer;;
				kafka-zookeeper*) make - docker-thirdparty;;
		   esac

	sed -i "\$aexport PATH=\$PATH:$GOPATH/src/github.com/hyperledger/fabric/.build/bin" $HOME/.profile  &&  . $HOME/.profile
	echo -e "\e[32mHLF install finished.\e[0m"
}

installFabricCa(){
	mkdir $HOME/testnet/
	echo -e "\e[32mInstall Hyperledger Fabric-Ca\e[0m"
	git clone -v -b release-1.4 --progress https://github.com/hyperledger/fabric-ca/  home/$USER/work/go/src/github.com/hyperledger/fabric-ca
	cd home/$USER/work/go/src/github.com/hyperledger/fabric-ca
	case $(hostname) in
		   		*client*) 	make fabric-ca-server && sed -i "\$aexport FABRIC_CA_SERVER_HOME=$HOME/testnet";;
				*admin*)	make fabric-ca-client && sed -i "\$aexport FABRIC_CA_CLIENT_HOME=$HOME/testnet";;
	esac
	sed -i "\$aexport PATH=$PATH:$GOPATH/src/github.com/hyperledger/fabric-ca/bin" $HOME/.profile
	source $HOME/.profile
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
echo -e "\e[197mSystem Detected.\e[0m"
echo -e "\e[197mOS(Operation System)\e[0m		$OS"
echo -e "\e[197mOS Type\e[0m				$OS_ID"
echo -e "\e[197mOS Code Name\e[0m			$OS_CODENAME"
echo -e "\e[197mCPU Architecture\e[0m			$CPU_ARCH"
fi


#aptToolInstall
#goInstall
#installDocker
#installHLF
installFabricCa

					







