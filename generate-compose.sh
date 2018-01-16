#! /bin/bash

cat > docker-compose.yml <<:EOF:

version: '2'
services:
  varnish:
    ports:
      - 80:80
    image: million12/varnish
    environment:
        - VCL_CONFIG=/data/generated.vcl
    volumes:
      - ./varnish/vcl:/data
    links:
:EOF:
for site in `ls sites`
do
    SITENAME="`echo $site|tr -d .`"
cat >> docker-compose.yml <<:EOF:
        - $SITENAME
   $SITENAME:

    ports:
      - 8080:8080
    image: nginx:1.13.6
    links:
#      - mariadb
      - php-$SITENAME:php
    volumes:
        - ./sites/$site:/var/www/$site
        - ./nginx-base-conf:/etc/nginx/
        - ./nginx/non-ssl:/etc/nginx/conf.d
  php-$SITENAME:
    image: php:7-fpm
    volumes:
        - ./sites/$site:/var/www/$site
:EOF:

done
cat >> docker-compose.yml << :EOF:
  ssl-terminate:
    image: nginx:1.13.6
    ports:
      - 443:443
    volumes:
      - ./nginx/ssl:/etc/nginx/conf.d
    links:
      - varnish
  mariadb:
    image: mariadb
    volumes:
      - ./db:/var/lib/mysql
    env_file:
      - ./pw/mysql

:EOF: