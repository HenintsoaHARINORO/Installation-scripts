sudo apt update
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

echo 'CREATE DATABASE 'netpro';' | mysql -u root -ptoor001
echo "CREATE USER 'netpro';" | mysql -u root -ptoor001
echo "FLUSH PRIVILEGES;" | mysql -u root -ptoor001
echo "GRANT USAGE ON netpro.* to 'netpro'@'localhost' IDENTIFIED BY 'netpro';" | mysql -u root -ptoor001
echo "FLUSH PRIVILEGES;" | mysql -u root -ptoor001
echo "UPDATE mysql.user SET Password=PASSWORD('netpro') WHERE User='netpro' AND Host='%';" | mysql -u root -ptoor001
echo 'GRANT ALL PRIVILEGES ON `netpro`.* TO 'netpro'@'localhost';' | mysql -u root -ptoor001
echo "FLUSH PRIVILEGES;" | mysql -u root -ptoor001
echo "UPDATE user SET plugin='mysql_native_password' WHERE User='root';" | mysql -u root -ptoor001
echo "FLUSH PRIVILEGES;" | mysql -u root -ptoor001
sudo service  mysql start

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
wget -c https://files.froxlor.org/releases/froxlor-latest.tar.gz
wget -c https://wordpress.org/latest.tar.gz
wget -c https://master.dl.sourceforge.net/project/dolibarr/Dolibarr%20ERP-CRM/8.0.3/dolibarr-8.0.3.zip
tar -xvzf froxlor-latest.tar.gz
tar -xvzf latest.tar.gz
unzip dolibarr-8.0.3.zip
mv -f dolibarr-8.0.3/htdocs dolibarr
chown -R www-data:www-data /var/www/html/*
chown www-data:www-data -R /var/www/html/dolibarr
mkdir /var/www/html/dolibarr/documents/
chmod 777 /var/www/html/dolibarr/documents/
chmod 777 /var/www/html/wordpress/
chmod 777 /var/www/html/dolibarr
chmod 777 /var/lib/php/sessions/
mkdir /var/customers/
mkdir /var/customers/logs/
mkdir /etc/ssl/froxlor-custom/
chmod 777 /etc/ssl/froxlor-custom/
chmod 777 /var/customers/logs/
/usr/bin/php /var/www/html/froxlor/scripts/froxlor_master_cronjob.php --force --debug
sudo service mysql restart
#config froxlor
#after installation
mv /tmp/fxQBPP03 /var/www/html/froxlor/lib/userdata.inc.php
