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
  echo "Veuillez exécuter ce script avec sudo: sudo ./uninstall.sh"
  exit 1
fi

# Désinstallation de Git
echo "Désinstallation de Git..."
apt remove -y git
check_error "apt remove git"

# Désinstallation de NetBeans
echo "Suppression de NetBeans..."
rm -f /opt/apache-netbeans_25-1_all.deb
check_error "rm /opt/apache-netbeans_25-1_all.deb"

# Désinstallation d'Apache
echo "Arrêt et suppression d'Apache..."
systemctl stop apache2
check_error "systemctl stop apache2"
apt remove -y apache2
check_error "apt remove apache2"

# Désinstallation de PostgreSQL
echo "Suppression de PostgreSQL..."
systemctl stop postgresql
check_error "systemctl stop postgresql"
apt remove -y postgresql postgresql-client postgresql-contrib
check_error "apt remove postgresql"

# Désinstallation de Tomcat
echo "Suppression de Tomcat..."
systemctl stop tomcat
check_error "systemctl stop tomcat"

rm -rf /opt/tomcat9
check_error "rm -rf /opt/tomcat9"

echo "Tomcat supprimé avec succès."

# Désinstallation de pgAdmin4
echo "Suppression de pgAdmin4..."
apt remove -y pgadmin4
check_error "apt remove pgadmin4"

echo "Désinstallation complète avec succès !"

