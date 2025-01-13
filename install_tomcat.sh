#!/bin/bash

# Actualizamos la instancia
apt update
apt upgrade -y

# Creamos el usuario para Tomcat
useradd -m -d /opt/tomcat -U -s /bin/false tomcat

# Instalamos Java 21
apt install openjdk-21-jdk -y

# Descargamos y descomprimimos Tomcat 11
wget -P /tmp https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.2/bin/apache-tomcat-11.0.2.tar.gz
tar xzvf apache-tomcat-11*tar.gz -C /opt/tomcat --strip-components=1

# Cambiamos el propietario al usuario que hemos creado
chown -R tomcat:tomcat /opt/tomcat/
chmod -R u+x /opt/tomcat/bin

# Configuramos los usuarios administradores
sed -i '/<\/tomcat-users>/i \
<role rolename="manager-gui" />\n\
<user username="manager" password="manager_secret" roles="manager-gui" />\n\
\n\
<role rolename="admin-gui" />\n\
<user username="admin" password="admin_secret" roles="manager-gui,admin-gui" />' /opt/tomcat/conf/tomcat-users.xml

# Permitimos el acceso desde cualquier host
sed -i '/<Valve /,/\/>/ s|<Valve|<!--<Valve|; /<Valve /,/\/>/ s|/>|/>-->|' /opt/tomcat/webapps/manager/META-INF/context.xml
sed -i '/<Valve /,/\/>/ s|<Valve|<!--<Valve|; /<Valve /,/\/>/ s|/>|/>-->|' /opt/tomcat/webapps/host-manager/META-INF/context.xml

# Creamos el servicio systemd
echo '
[Unit]
Description=Tomcat
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-1.21.0-openjdk-amd64"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/tomcat.service

# Recargamos el daemon
systemctl daemon-reload

# Habilitamos Tomcat
systemctl start tomcat

# Iniciamos Tomcat
systemctl enable tomcat