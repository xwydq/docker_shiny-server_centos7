### Docker Configuration for Shiny-Server and RStudio Server on CentOS7.6

### This configuration includes:

* R

* RStudio Server

* Shiny-Server

### Additional key R Packages include:

* tidyverse readr RMySQL stringr reshape2

* plotly ggplot2

* DT

* lubridate xts forecast

* shinydashboard htmlwidgets shinyjs shinyBS shinyWidgets



### Install other R packages with `entrypoint.sh`

```
R -e "install.packages(c('shiny'), repos='https://mirrors.tongji.edu.cn/CRAN/')"
```

# Setup

1. Install [Docker](https://docs.docker.com/engine/installation/) on your system.

2. Download or clone this repository.

### Build the Dockerfile

```
docker build /YOUR_PATH_TO/docker_shiny-server_centos7 --tag="shiny-server"
```

### View Your Docker Images

```
docker images
```

### Run your Shiny-Server Docker image.

```
docker run -p 3838:3838 -p 8787:8787 -d shiny-server
```

* Shiny-Server is running at localhost:3838

* RStudio Server is running at localhost:8787

* The username and password for RStudio Server is `rstudio/isyscore`.


### Run your Shiny-Server Docker image with shiny app.

```
docker pull xwydq/rstudio-shiny-server
docker run --name zlj_shiny -p 7022:3838 -p 8786:8787 -v $(pwd)/hello_app/:/srv/shiny-server/hello_app xwydq/rstudio-shiny-server -d shiny-server
```
* Shiny-Server is running at localhost:7022, view hello_app url http://localhost:7022/hello_app

### Volumn rstudio project dir to local

```
mkdir -p $(pwd)/rstudio_project
chmod 777 $(pwd)/rstudio_project
docker run --name zlj_shiny -p 7022:3838 -p 8786:8787 -v $(pwd)/rstudio_project/:/home/rstudio/project xwydq/rstudio-shiny-server -d shiny-server
```

### docker container manage

```
# start 
docker container start <container ID>
# stop
docker container stop <container ID>
# delete
docker container rm -f <container ID>
# logs
docker logs <container ID>
```


# Modify the Docker Container

This is a bare-bones container, so there is a good chance you will want to do some additional configuration. The command below will start your Docker instance and dump you into the root shell.

```
docker run -p 3838:3838 -p 8787:8787 -it shiny-server /bin/bash
```

* Arg -i tells docker to attach stdin to the container.

* Arg -t tells docker to give us a pseudo-terminal.

* Arg /bin/bash will run a terminal process in your container.

### Install Additional Stuff

Maybe you need a PostgreSQL instance?

```
yum install postgresql-devel -y
```

### Exit the Container

```
exit
```

### Find the Container ID

```
docker ps -a
```

### Use Docker Commit to Save

The syntax is:

```
docker commit [CONTAINER ID] [REPOSITORY:TAG]
```

It should look something like this:

```
docker commit b59185b5ba4b docker-shiny:shiny-server-v2
```

### See New Container

```
docker images
```