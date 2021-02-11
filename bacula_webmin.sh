sudo apt update
sudo apt-get install postgresql postgresql-contrib
sudo service postgresql start
sudo -u postgres psql
create database bacula;
create user bacula with encrypted password 'bacula';
 grant all privileges on database bacula to bacula;
service postgresql restart

sudo apt-get install -y mariadb-server 

sed -i "/#log-bin=mysql-bin/a\#binlog_format=mixed" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i "/#binlog_format=mixed/a\bind-address = 127.0.0.1" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -e '13i innodb_default_row_format=dynamic' -i  /etc/mysql/mariadb.conf.d/50-server.cnf
sed -e '14i innodb_file_format=barracuda' -i  /etc/mysql/mariadb.conf.d/50-server.cnf
sed -e '15i innodb_file_per_table=true' -i  /etc/mysql/mariadb.conf.d/50-server.cnf
sed -e '16i innodb_large_prefix=true' -i  /etc/mysql/mariadb.conf.d/50-server.cnf
sudo service  mysql  start #sudo service mariadb startse
sudo service  mysql status
sudo service  mysql enable

mysqladmin -u root password toor001 #toor001 #connect to mysqlser

echo 'CREATE DATABASE 'bacula';' | mysql -u root -ptoor001
echo "CREATE USER 'bacula';" | mysql -u root -ptoor001
echo "FLUSH PRIVILEGES;" | mysql -u root -ptoor001
echo "GRANT USAGE ON bacula.* to 'bacula'@'localhost' IDENTIFIED BY 'bacula';" | mysql -u root -ptoor001
echo "FLUSH PRIVILEGES;" | mysql -u root -ptoor001

echo 'GRANT ALL PRIVILEGES ON `bacula`.* TO 'bacula'@'localhost';' | mysql -u root -ptoor001
echo "FLUSH PRIVILEGES;" | mysql -u root -ptoor001


sudo service  mysql restart


sudo apt install -y nginx
sudo service nginx start
sudo service nginx enable

sudo apt-get install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt install -y php7.1-fpm php7.1-common php7.1-curl php7.1-intl php7.1-mbstring php7.1-mcrypt php7.1-json php7.1-xmlrpc php7.1-soap php7.1-mysql php7.1-gd php7.1-xml php7.1-cli php7.1-zip
apt install php7.1-bcmath
sed -i "/;date.timezone.*/a\date.timezone = America/New_York" /etc/php/7.1/fpm/php.ini
sed -i 's/memory_limit.*/memory_limit = 64M/g' /etc/php/7.1/fpm/php.ini
sed -i 's/expose_php.*/expose_php = Off/g' /etc/php/7.1/fpm/php.ini
sed -i "/;session.save_path.*/a\session.save_path = /tmp/" /etc/php/7.1/fpm/php.ini

sudo service php7.1-fpm start
sudo service php7.1-fpm enable

sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default
cat > /etc/nginx/sites-available/mydomain.conf <<END
server {
    server_name henintsoa;
    listen 80;
    root /var/www/html;
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    index index.php index.html index.htm ;
    
    client_max_body_size 100M;

    location ~ ^/api/(?!(index\.php))(.*) {
      try_files $uri /api/index.php/$2?$query_string;
    }

    location ~ [^/]\.php(/|$) {
        include fastcgi_params;
        if (!-f $document_root$fastcgi_script_name) {
            return 404;
        }
        fastcgi_pass           unix:/var/run/php/php7.1-fpm.sock;
        fastcgi_param   SCRIPT_FILENAME $document_root$fastcgi_script_name;
     }
}
END
sudo ln -s /etc/nginx/sites-available/mydomain.conf /etc/nginx/sites-enabled/
nginx -t
sudo service  nginx restart

echo -e "<?php\n\tphpinfo();" > /var/www/html/info.php

cd /var/www/html
wget http://prdownloads.sourceforge.net/webadmin/webmin-1.960.tar.gz
gunzip webmin-1.960.tar.gz
tar xf webmin-1.960.tar
cd webmin-1.960
./setup.sh /usr/local/webmin


sudo apt-get install bacula-server bacula-director-pgsql bacula-common-pgsql bacula-console bacula-client
sudo mkdir -p /bacula/backup /bacula/restore /etc/bacula/conf.d/clients /etc/bacula/conf.d/filesets /etc/bacula/conf.d/jobs
sudo chown -R bacula /etc/bacula
sudo chmod -R 700 /etc/bacula
sudo nano /etc/bacula/bacula-dir.conf



Job {
  Name = "RestoreFiles"
  Type = Restore
  Client=Blank-fd
  FileSet="Full Set"
  Storage = File
  Pool = Default
  Messages = Standard
  Where = /bacula/restore
}


Include {
    Options {
      signature = MD5
      compression = GZIP
    }
# 
#  Put your list of files here, preceded by 'File =', one per line
#    or include an external list with:
#
#    File = file-name
#
#  Note: / backs up everything on the root partition.
#    if you have other partitions such as /usr or /home
#    you will probably want to add them too.
#
#  By default this is defined to point to the Bacula binary
#    directory to give a reasonable FileSet to backup to
#    disk storage during initial testing.
#
    File = /
  }


Exclude {
    File = /var/lib/bacula
    File = /bacula
    File = /proc
    File = /tmp
    File = /.journal
    File = /.fsck
  }

 nano /etc/bacula/bacula-sd.conf
Device {
  Name = FileStorage1
  Media Type = File1
  Archive Device = /bacula/backup
  Device Type = File
  LabelMedia = yes;                   # lets Bacula label unlabeled media
  Random Access = Yes;
  AutomaticMount = yes;               # when device opened, read it
  RemovableMedia = no;
  AlwaysOpen = yes;
}

sudo bacula-dir -tc /etc/bacula/bacula-dir.conf

sudo bacula-sd -tc /etc/bacula/bacula-sd.conf



