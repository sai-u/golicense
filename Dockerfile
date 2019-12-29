FROM centos:7
COPY golicense /opt/bin/
COPY /var/jenkins_home/workspace/pkg/mod/ /app
CMD [ "/bin/bash" ]
