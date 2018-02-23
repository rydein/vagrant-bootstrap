# Exit if already bootstrapped
if test -f /etc/bootstrapped; then
  echo "exit"
  exit
fi

sudo chmod 777 /usr/local/src/

if [ ! -x /usr/local/bin/git ]
then
  echo "Installing git"
  sudo yum -y install gcc wget tree libcurl-devel openssl-devel expat-devel perl-ExtUtils-MakeMaker
  cd /usr/local/src
  wget -O git-2.16.2.tar.gz --no-check-certificate https://www.kernel.org/pub/software/scm/git/git-2.16.2.tar.gz
  tar -zxf git-2.16.2.tar.gz
  cd /usr/local/src/git-2.16.2/
  make prefix=/usr/local all
  sudo make prefix=/usr/local install
fi

if [ ! -f /home/vagrant/.nvm/nvm.sh ]
then
  echo "Installing nvm"
  wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
  source /home/vagrant/.bashrc
fi

if [ ! -x /usr/local/bin/pt ]
then
  echo "Installing pt"
  sudo yum -y install wget
  cd /usr/local/src
  wget -O pt_linux_amd64.tar.gz https://github.com/monochromegane/the_platinum_searcher/releases/download/v2.1.5/pt_linux_amd64.tar.gz
  tar -zxf pt_linux_amd64.tar.gz
  sudo cp /usr/local/src/pt_linux_amd64/pt /usr/local/bin/pt
fi

if [ ! -x /home/vagrant/.anyenv/envs/pyenv/shims/python3 ]
then
  echo "Installing anyenv pyenv python3"
  sudo yum install -y zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel xz xz-devel
  /usr/local/bin/git clone https://github.com/riywo/anyenv /home/vagrant/.anyenv
  echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> /home/vagrant/.bash_profile
  echo 'eval "$(anyenv init -)"' >> /home/vagrant/.bash_profile
  source /home/vagrant/.bash_profile
  anyenv install pyenv
  source /home/vagrant/.bash_profile
  CONFIGURE_OPTS="--enable-shared" pyenv install 2.7.14
  CONFIGURE_OPTS="--enable-shared" pyenv install 3.6.4
  pyenv local --unset
  pyenv shell --unset
  pyenv global 2.7.14 3.6.4
fi

if [ ! -x /usr/local/bin/vim ]
then
  echo "Installing vim"
  sudo yum install -y ctags
  cd /usr/local/src
  /usr/local/bin/git clone https://github.com/vim/vim
  cd vim/src
  # python must exists in rpath
  LDFLAGS="-Wl,-rpath=${HOME}/.anyenv/envs/pyenv/versions/2.7.14/lib:${HOME}/.anyenv/envs/pyenv/versions/3.6.4/lib" ./configure --enable-fail-if-missing --enable-pythoninterp=dynamic --enable-python3interp=dynamic --enable-multibyte --enable-fontset --with-features=huge
  make && sudo make install

fi

if [ ! -x /usr/bin/docker ]
then
  # Install required packages
  sudo yum install -y yum-utils device-mapper-persistent-data lvm2
  # set up the stable repository.
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  # disable edge or test repo
  sudo yum-config-manager --disable docker-ce-edge
  # install docker
  sudo yum install -y docker-ce
  sudo systemctl start docker
  
  # install docker compose
  sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  
  # docker group
  sudo gpasswd -a vagrant docker
  sudo systemctl status docker
fi

# phpenv

if [ ! -x /home/vagrant/.anyenv/envs/phpenv/shims/php ]
then
sudo yum install -y autoconf automake bison gcc-c++ libxml2-devel libjpeg-devel libpng-devel libicu-devel epel-release
sudo yum install -y libmcrypt-devel libtidy-devel libxslt-devel
cd /usr/local/src/
wget https://jaist.dl.sourceforge.net/project/re2c/1.0.1/re2c-1.0.1.tar.gz
tar -zxf re2c-1.0.1.tar.gz
cd re2c-1.0.1/
./configure
make && sudo make install
anyenv install phpenv
source /home/vagrant/.bash_profile
phpenv install 7.1.14
phpenv global 7.1.14
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
fi

date > /home/vagrant/bootstrapped
