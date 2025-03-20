#!/bin/bash

log_file="check_install.log"
echo "🔍 Début de la vérification : $(date)" > "$log_file"

echo "🔍 Vérification de l'installation de l'environnement ALGEM..."
echo "Toutes les sorties seront enregistrées dans $log_file"

check_command() {
    cmd=$1
    name=$2
    solution=$3

    if eval "$cmd" &>> "$log_file"; then
        echo "✅ $name est installé et fonctionne correctement."
        echo "✅ $name OK" >> "$log_file"
    else
        echo "❌ $name n'est pas installé ou ne fonctionne pas !"
        echo "   👉 Solution : $solution"
        echo "❌ $name ÉCHEC" >> "$log_file"
    fi
}

# Vérification de NetBeans
echo "➡️  Vérification de NetBeans..."
check_command "dpkg -l | grep netbeans" "NetBeans" "Réinstaller avec ./install.sh"

# Vérification de Git
echo "➡️  Vérification de Git..."
check_command "git --version" "Git" "Installer avec : sudo apt install git"

# Vérification d'Apache
echo "➡️  Vérification d'Apache..."
check_command "apt list --installed | grep apache2" "Apache" "Installer avec : sudo apt install apache2"

# Vérifier si Apache écoute sur le port 80
echo "➡️  Vérification du port 80 (Apache)..."
check_command "ss -tlnp | grep ':80 '" "Apache écoute sur le port 80" "Vérifier avec : sudo systemctl restart apache2"

# Vérification de PostgreSQL
echo "➡️  Vérification de PostgreSQL..."
check_command "pg_isready" "PostgreSQL" "Vérifier le service avec : sudo systemctl restart postgresql"

# Vérifier si PostgreSQL écoute sur le port 5432
echo "➡️  Vérification du port 5432 (PostgreSQL)..."
check_command "ss -tlnp | grep ':5432 '" "PostgreSQL écoute sur le port 5432" "Vérifier avec : sudo systemctl restart postgresql"

# Vérification de Tomcat 9
echo "➡️  Vérification de Tomcat 9..."
check_command "systemctl is-active --quiet tomcat9" "Tomcat 9" "Vérifier le service avec : sudo systemctl restart tomcat9"

# Vérifier si Tomcat écoute sur le port 8080
echo "➡️  Vérification du port 8080 (Tomcat)..."
check_command "ss -tlnp | grep ':8080 '" "Tomcat écoute sur le port 8080" "Vérifier avec : sudo systemctl restart tomcat9"

echo "✅ Vérification terminée ! Consultez $log_file pour plus de détails."
