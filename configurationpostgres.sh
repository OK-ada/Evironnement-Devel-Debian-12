#!/bin/bash

# Variables
PG_VERSION=$(psql -V | awk '{print $3}' | cut -d'.' -f1,2)  # Récupération de la version
PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
DB_NAME="ma_base"
DB_USER="mon_user"
DB_PASS="mon_mot_de_passe"

# Vérification des droits d'exécution
if [[ $EUID -ne 0 ]]; then
   echo "Ce script doit être exécuté en tant que root (sudo)."
   exit 1
fi

# Passage à l'utilisateur postgres
echo "Configuration de PostgreSQL..."
sudo -i -u postgres bash << EOF

# Définir le mot de passe pour l'utilisateur postgres
psql -c "ALTER USER postgres WITH PASSWORD '$DB_PASS';"

# Création d'un nouvel utilisateur
psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';"

# Donner les droits de superutilisateur
psql -c "ALTER USER $DB_USER WITH SUPERUSER;"

# Création de la base de données
psql -c "CREATE DATABASE $DB_NAME;"

# Attribution des droits sur la base
psql -c "GRANT ALL ON DATABASE $DB_NAME TO $DB_USER;"

EOF

echo "Configuration des fichiers de connexion..."

# Modification de postgresql.conf pour écouter sur toutes les interfaces
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*' /" $PG_CONF

# Modification de pg_hba.conf pour autoriser les connexions réseau
cat >> $PG_HBA << EOL
host    all             all             192.168.21.0/24            md5
EOL

# Redémarrage de PostgreSQL
systemctl restart postgresql

echo "PostgreSQL est configuré et redémarré avec succès."
