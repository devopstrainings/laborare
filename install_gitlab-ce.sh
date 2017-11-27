sudo yum install postfix
sudo systemctl enable postfix
sudo systemctl start postfix

curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash

echo "Run this command by replacing gitlab.example.com with External / Public IP address"
echo 'sudo EXTERNAL_URL="http://gitlab.example.com" yum install -y gitlab-ce'
