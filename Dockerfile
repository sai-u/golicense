FROM centos:7
COPY golicense /opt/bin/
COPY /root/go/pkg/mod/ /app
CMD [ "/bin/bash" ]
