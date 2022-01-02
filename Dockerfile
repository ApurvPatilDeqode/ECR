FROM ubuntu:20.04

RUN apt -y update
RUN apt -y install wget 
# RUN apt -y install sed
# RUN apt -y install cl-base64
COPY bash.sh ./
RUN chmod +x bash.sh

ENV EMAIL_PASSWORD=$EMAIL_PASSWORD
RUN export $EMAIL_PASSWORD

# install prometheus and configure
RUN wget https://github.com/prometheus/prometheus/releases/download/v2.32.0-rc.0/prometheus-2.32.0-rc.0.linux-amd64.tar.gz 
RUN tar -xvf prometheus-2.32.0-rc.0.linux-amd64.tar.gz 
RUN cp -r prometheus-2.32.0-rc.0.linux-amd64/prometheus /usr/local/bin/ 
RUN mkdir -p /etc/prometheus/ 
#RUN cp -r prometheus-2.32.0-rc.0.linux-amd64/prometheus.yml /etc/prometheus/
COPY prometheus.yml /etc/prometheus/
COPY alert.rules.yml /etc/prometheus/
RUN chmod +x /etc/prometheus/prometheus.yml 
RUN chmod +x /etc/prometheus/alert.rules.yml
RUN cp -r prometheus-2.32.0-rc.0.linux-amd64/consoles /etc/prometheus/ 
RUN cp -r prometheus-2.32.0-rc.0.linux-amd64/console_libraries /etc/prometheus/ 

# install alertmanager and configure    
RUN wget https://github.com/prometheus/alertmanager/releases/download/v0.23.0/alertmanager-0.23.0.linux-amd64.tar.gz  
RUN tar -xvf alertmanager-0.23.0.linux-amd64.tar.gz 
RUN cp -r alertmanager-0.23.0.linux-amd64/alertmanager /usr/local/bin/ 
RUN mkdir -p /etc/alertmanager/
#RUN cp alertmanager-0.23.0.linux-amd64/alertmanager.yml /etc/alertmanager/alertmanager.yml
COPY alertmanager.yml /etc/alertmanager/
RUN chmod +x /etc/alertmanager/alertmanager.yml
# COPY email_pass.txt /etc/alertmanager

# #RUN sed -i "s/replace/$EMAIL_PASSWORD/g" /etc/alertmanager/alertmanager.yml


#install node_exporter and configure
RUN wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz 
RUN tar -xvf node_exporter-1.3.1.linux-amd64.tar.gz 
RUN cp -r node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/ 



EXPOSE 9090
EXPOSE 9100
EXPOSE 9093

ENTRYPOINT ["/bash.sh"]  

CMD ["sh"]
