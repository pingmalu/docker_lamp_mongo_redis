#!/bin/bash

if [ "${AUTHORIZED_KEYS}" != "**None**" ]; then
    echo "=> Found authorized keys"
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    touch /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    IFS=$'\n'
    arr=$(echo ${AUTHORIZED_KEYS} | tr "," "\n")
    for x in $arr
    do
        x=$(echo $x |sed -e 's/^ *//' -e 's/ *$//')
        cat /root/.ssh/authorized_keys | grep "$x" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "=> Adding public key to /root/.ssh/authorized_keys: $x"
            echo "$x" >> /root/.ssh/authorized_keys
        fi
    done
fi

if [ ! -f /.root_pw_set ]; then
	/set_root_pw.sh
fi

sed -i '1i\requirepass '$REDIS_PASS /etc/redis/redis.conf
sed -i 's/^daemonize yes/daemonize no/' /etc/redis/redis.conf
sed -i 's/^bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf
sed -i 's/^dir \/var\/lib\/redis/dir \/app\/data/' /etc/redis/redis.conf
sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
sed -i 's/^bind_ip = 127.0.0.1/bind_ip = 0.0.0.0/' /etc/mongodb.conf
sed -i 's/^dbpath=\/var\/lib\/mongodb/dbpath=\/app\/mongodb\/db/' /etc/mongodb.conf
sed -i 's/^logpath=\/var\/log\/mongodb\/mongodb.log/logpath=\/app\/mongodb\/log/' /etc/mongodb.conf
echo 'extension=mongo.so' >> /etc/php5/apache2/php.ini

wget http://pecl.php.net/get/mongo-1.6.13.tgz -P /root/
tar -zxvf /root/mongo-1.6.13.tgz -C /root/
cd /root/mongo-1.6.13/
phpize
./configure
make install

exec /usr/bin/supervisord -n
