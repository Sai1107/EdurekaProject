# Pull tomcat latest image from dockerhub 
From tomcat:latest

# Maintainer
MAINTAINER "Sai Yellepeddi" 

# copy war file on to container 
COPY ./target/ABCtechnologies-1.0.war /usr/local/tomcat/webapps/


