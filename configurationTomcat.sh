#!/bin/bash

# Variables
tomcat_dir="/opt/tomcat9"
tomcat_users="$tomcat_dir/conf/tomcat-users.xml"
war_source="/home/ada/algem.war"
war_dest="$tomcat_dir/webapps/algem.war"
tomcat_user="tomcat"
tomcat_service="tomcat9"

# Vérification des droits d'exécution
if [[ $EUID -ne 0 ]]; then
   echo "Ce script doit être exécuté en tant que root (sudo)."
   exit 1
fi

# Ajout des rôles et de l'utilisateur dans tomcat-users.xml
echo "Configuration de tomcat-users.xml..."
cat > $tomcat_users <<EOL
<?xml version='1.0' encoding='utf-8'?>
<tomcat-users>
    <role rolename="manager-gui"/>
    <role rolename="admin-gui"/>
    <user username="user" password="unmotdepasse" roles="manager-gui,admin-gui"/>
</tomcat-users>
EOL

# Attribution des droits corrects
chown $tomcat_user:$tomcat_user $tomcat_users
chmod 640 $tomcat_users

echo "tomcat-users.xml configuré."

# Déploiement du fichier WAR
echo "Déploiement du fichier WAR..."
if [[ -f "$war_source" ]]; then
    mv $war_source $war_dest
    chown $tomcat_user:$tomcat_user $war_dest
    echo "Déploiement effectué avec succès."
else
    echo "Erreur : Le fichier WAR source n'existe pas."
    exit 1
fi

# Redémarrage de Tomcat
echo "Redémarrage de Tomcat..."
systemctl restart $tomcat_service

echo "Tomcat est redémarré. L'application est déployée."
