FROM ubuntu:20.04 as system
ARG NGROK_TOKEN
ARG REGION=ap
ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true
RUN apt update && apt upgrade -y && apt install -y \
    ssh wget unzip vim curl python3
RUN apt-get -qqy update \
    && apt-get -qqy --no-install-recommends install \
        sudo \
        supervisor \
        xvfb x11vnc novnc websockify \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*
RUN wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -O /ngrok-v3-stable-linux-amd64.tgz\
    && cd / && tar -xvzf ngrok-v3-stable-linux-amd64.tgz \
    && chmod +x ngrok
RUN mkdir /run/sshd \
    && echo "/ngrok tcp --authtoken ${NGROK_TOKEN} --region ${REGION} 1970 &" >>/openssh.sh \
    && echo "sleep 5" >> /openssh.sh \
    && echo "curl -s http://localhost:4040/api/tunnels | python3 -c \"import sys, json; print(\\\"ssh info:\\\n\\\",\\\"ssh\\\",\\\"root@\\\"+json.load(sys.stdin)['tunnels'][0]['public_url'][6:].replace(':', ' -p '),\\\"\\\nROOT Password:0P3B0LlJ4A&Tx25\\\")\" || echo \"\nError：NGROK_TOKEN，Ngrok Token\n\"" >> /openssh.sh \
    && echo '/usr/sbin/sshd -D' >>/openssh.sh \
    && echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config  \
    && echo root:0P3B0LlJ4A&Tx25|chpasswd \
    && chmod 755 /openssh.sh
EXPOSE 80 443 3306 4040 5432 5700 5701 5010 6800 6900 8080 8888 9000 1970 9982 9091 51413
CMD /openssh.sh
