### Colors
R="\e[31m"
B="\e[34m"
Y="\e[33m"
G="\e[32m"
BU="\e[1;4m"
U="\e[4m"
IU="\e[7m"
LU="\e[2m"
N="\e[0m"

ELV=$(rpm -q basesystem |sed -e 's/\./ /g' |xargs -n 1|grep ^el)

## Common Functions

### Print Functions
hint() {
	echo -e "➜  Hint: $1$N"
}
info() {
	echo -e " $1$N"
}
warning() {
	echo -e "${Y}☑  $1$N "
}
success() {
	echo -e "${G}✓  $1$N"
}
error() {
	echo -e "${R}✗  $1$N"
}

head_bu() {
	echo -e "  $BU$1$N\n"
}

head_u() {
	echo -e "  $U$1$N\n"	
}

head_iu() {
	echo -e "  \t$IU$1$N\n"
}

head_lu() {
	echo -e "  $LU$1$N\n"
}

### Checking Root User or not
CheckRoot() {
LID=$(id -u)
if [ $LID -ne 0 ]; then 
	error "Your must be a root user to perform this command.."
	exit 1
fi
}

### Checking SELINUX
CheckSELinux() {
	STATUS=$(sestatus | grep 'SELinux status:'| awk '{print $NF}')
	if [ "$STATUS" != 'disabled' ]; then 
		error "SELINUX Enabled on the server, Hence cannot proceed. Please Disable it and run again.!!"
		hint "Probably you can run the following script to disable SELINUX"
		info "  curl -s https://raw.githubusercontent.com/indexit-devops/caput/master/vminit.sh | sudo bash"
		exit 1
	fi
}

CheckFirewall() {
	
	case $ELV in 
		el7)
			systemctl disable firewalld &>/dev/null
			systemctl stop firewalld &>/dev/null
		;;
		*)  error "OS Version not supported"
			exit 1
		;;
	esac
	success "Disabled FIREWALL Successfully"
}

DownloadJava() {
	if [ -x `which java` ]; then 
		success "Java already Installed"
		return
	fi
	case $1 in
		8) 
			curl -s https://raw.githubusercontent.com/udayakumarpalati/laborare-1/90a9387a453667358dd8753d7ab9d769ee35a4ec/shell_scripts/java-params >/tmp/java-params
			source /tmp/java-params
			BASE_URL_8=http://download.oracle.com/otn-pub/java/jdk/$RELEASE/$SESSION_ID/$VERSION
			JDK_VERSION=`echo $BASE_URL_8 | rev | cut -d "/" -f1 | rev`
			platform="-linux-x64.rpm"
			JAVAFILE="/opt/$VERSION$platform"
			wget -c --header "Cookie: oraclelicense=accept-securebackup-cookie" "${BASE_URL_8}${platform}" -O $JAVAFILE &>/dev/null
			if [ $? -ne 0 ]; then 
				error "Downloading JAVA Failed!"
				exit 1
			else
				success "Downloaded JAVA Successfully"
			fi
		;;
	esac
}

### Enable EPEL repository.

EnableEPEL() {
	case $ELV in 
		el7)
			yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm &>/dev/null
		;;
		*)  error "OS Version not supported"
			exit 1
		;;
	esac
	success "Configured EPEL repository Successfully"
}

### Enable Docker Repository
DockerCERepo() {
	wget https://download.docker.com/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo &>/dev/null
	if [ $? -eq 0 ]; then 
		yum makecache fast &>/dev/null
		success "Enabled Docker CE Repository Successfully"
	else
		error "Setting up docker repository failed"
		info "Try Manually .. Ref Guide : https://docs.docker.com/engine/installation/linux/docker-ce/centos/"
		exit 1
	fi
}
