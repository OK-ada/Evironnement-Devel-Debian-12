#!/bin/bash

# Fonction pour vérifier les erreurs et arrêter le script en cas de problème
check_error() {
  if [ $? -ne 0 ]; then
    echo "Erreur détectée lors de l'exécution de la commande : $1"
    exit 1
  fi
}

# Vérifier si le script est exécuté en tant que root
if [ "$EUID" -ne 0 ]; then
  echo "Veuillez exécuter ce script avec sudo: sudo ./install.sh"
  exit 1
fi

# Mise à jour des paquets
echo "Mise à jour des paquets..."
apt update -y
check_error "apt update"

# Installation de Git
echo "Installation de Git..."
apt install -y git
check_error "apt install git"

echo "Vérification de la version de Git..."
git --version

echo "Configuration de Git..."
git config --global user.name "devel"
git config --global user.email "devel@algem.org"
check_error "git config"

echo "Git installé et configuré avec succès."

# Installation de NetBeans
echo "Téléchargement et installation de NetBeans..."
cd /opt
wget https://dlcdn.apache.org/netbeans/netbeans-installers/25/apache-netbeans_25-1_all.deb
check_error "wget"

echo "Installation de NetBeans..."
apt install -y ./apache-netbeans_25-1_all.deb
check_error "apt install ./apache-netbeans_25-1_all.deb"

echo "NetBeans installé avec succès."

# Installation d'Apache
echo "Installation d'Apache..."
apt install -y apache2
check_error "apt install apache2"

echo "Démarrage du service Apache..."
systemctl start apache2
check_error "systemctl start apache2"

echo "Apache installé et démarré avec succès."

# Installation de PostgreSQL
echo "Installation de PostgreSQL..."
apt install -y postgresql postgresql-client postgresql-contrib
check_error "apt install postgresql"

echo "Activation du service PostgreSQL..."
systemctl enable --now postgresql
check_error "systemctl enable --now postgresql"

echo "PostgreSQL installé et activé avec succès."

# Installation de Tomcat
echo "Installation de Java pour Tomcat..."
apt install -y default-jdk
check_error "apt install default-jdk"

echo "Création du répertoire et de l'utilisateur Tomcat..."
mkdir -p /opt/tomcat9
useradd -m -d /opt/tomcat9 -U -s /bin/false tomcat
check_error "useradd tomcat"

echo "Téléchargement et installation de Tomcat..."
VER=9.0.102
cd /tmp
wget https://dlcdn.apache.org/tomcat/tomcat-9/v${VER}/bin/apache-tomcat-${VER}.tar.gz
check_error "wget"

tar xzf apache-tomcat-${VER}.tar.gz -C /opt/tomcat9 --strip-components=1
check_error "tar"

chown -R tomcat:tomcat /opt/tomcat9
chmod -R 755 /opt/tomcat9
check_error "chown/chmod"

echo "Création du fichier de service systemd pour Tomcat..."
cat > /etc/systemd/system/tomcat.service << EOF
[Unit]
Description=Apache Tomcat 9
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat
Environment="JAVA_HOME=/usr/lib/jvm/default-java"
Environment="CATALINA_HOME=/opt/tomcat9"
Environment="CATALINA_BASE=/opt/tomcat9"
ExecStart=/opt/tomcat9/bin/startup.sh
ExecStop=/opt/tomcat9/bin/shutdown.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
check_error "cat"

echo "Recharger systemd et activer Tomcat..."
systemctl daemon-reload
systemctl enable --now tomcat
check_error "systemctl"

echo "Tomcat installé et démarré avec succès."

# Installation de pgAdmin4
echo "Installation de pgAdmin4..."
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg
check_error "curl"

sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list'
apt update -y
check_error "apt update"

apt install -y pgadmin4
check_error "apt install pgadmin4"

echo "pgAdmin4 installé avec succès."

echo "Installation complète avec succès !"

