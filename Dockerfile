FROM centos:7
COPY golicense /opt/bin/
COPY /root/pkg/mod/ /app
CMD [ "/bin/bash" ]
