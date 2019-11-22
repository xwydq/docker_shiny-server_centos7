#!/bin/bash


## install R package
echo "install R package start ..."
# R -e "install.packages(c('leaflet'), repos='https://mirrors.tongji.edu.cn/CRAN/')"
echo "install R package over ..."

# start server 
echo "start server ..."
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
