FROM centos:7.6.1810
MAINTAINER xuwy

    
COPY shiny-server-1.5.12.933-x86_64.rpm /shiny-server-1.5.12.933-x86_64.rpm
COPY rstudio-server-rhel-1.2.5001-x86_64.rpm /rstudio-server-rhel-1.2.5001-x86_64.rpm
COPY CentOS-Base.repo /etc/yum.repos.d/
    

RUN set -ex \
    # 预安装所需组件
    && echo "nameserver 144.144.144.144" >> /etc/resolv.conf \
    && yum -y install epel-release \
    && yum update -y \
    && yum upgrade -y \
    && yum -y install kde-l10n-Chinese telnet \
    && yum reinstall -y glibc-common \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/yum/* \
    && yum clean all -y \
    && localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8 \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && yum install -y wget tar libffi-devel zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gcc make initscripts \
    && yum install -y mysql-devel postgresql-devel libsasl2-devel gcc-c++ libaio git xml2 libxml2-devel curl curl-devel pandoc \
    && yum install -y locales java-1.8.0-openjdk java-1.8.0-openjdk-devel libcurl-devel \
    && yum install -y openssl098e supervisor passwd

ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8
    
WORKDIR /home/root
RUN yum install -y R

RUN R -e "install.packages(c('shiny', 'rmarkdown', 'devtools', 'RJDBC', 'dplyr', 'plotly', 'RPostgreSQL', 'lubridate', 'DT', 'shinydashboard', 'shinyWidgets', 'readr', 'RMySQL', 'stringr', 'reshape2', 'xts', 'htmlwidgets', 'tools', 'digest', 'scales', 'ggplot2', 'shinyjs', 'shinyBS', 'forecast'), repos='https://mirrors.tongji.edu.cn/CRAN/')"



#-----------------------
# Install Rstudio server:
RUN yum -y install --nogpgcheck /rstudio-server-rhel-1.2.5001-x86_64.rpm \
	&& rm -rf /rstudio-server-rhel-1.2.5001-x86_64.rpm

RUN groupadd rstudio \
	&& useradd -g rstudio rstudio \
	&& echo isyscore | passwd rstudio --stdin
	
# Add RStudio binaries to PATH
# export PATH="/usr/lib/rstudio-server/bin/:$PATH"
#ENV PATH /usr/lib/rstudio-server/bin/:$PATH 
#ENV LANG zh_CN.UTF-8

#-----------------------
# Install Shiny server:
RUN yum -y install --nogpgcheck /shiny-server-1.5.12.933-x86_64.rpm \
	&& rm -rf /shiny-server-1.5.12.933-x86_64.rpm

RUN mkdir -p /var/log/shiny-server \
	&& chown shiny:shiny /var/log/shiny-server \
	&& chown shiny:shiny -R /srv/shiny-server \
	&& chmod 755 -R /srv/shiny-server

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/log/supervisor \
	&& chmod 755 -R /var/log/supervisor


COPY entrypoint.sh /entrypoint.sh
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf

RUN chmod +x /entrypoint.sh

EXPOSE 8787 3838

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"] 
