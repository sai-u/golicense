FROM centos:7
WORKDIR /app
COPY golicense /opt/bin/
COPY go /app
CMD [ "/bin/bash" ]
