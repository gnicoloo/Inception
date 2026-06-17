# Documentazione per sviluppatori – Inception

Questo documento fornisce istruzioni tecniche dettagliate per configurare, costruire e gestire l'infrastruttura Inception dal punto di vista dello sviluppatore.

## Configurazione dell'ambiente da zero

**1. Prerequisiti:**

- Un sistema Linux (preferibilmente Debian o Alpine, come indicato dal subject).
- Pacchetti installati: `docker`, `docker-compose`, `make`.
- Risoluzione del dominio: aggiungi la seguente riga al tuo `/etc/hosts`:
127.0.0.1 <tuo_login>.42.fr

text

**2. Creazione delle directory per i volumi persistenti:**

Prima del primo avvio, crea le cartelle sull'host che verranno montate come volumi Docker:
```bash
sudo mkdir -p /home/<tuo_login>/data/wordpress
sudo mkdir -p /home/<tuo_login>/data/mariadb
Assicurati che l'utente che esegue Docker abbia i permessi di lettura/scrittura su queste cartelle.

3. File di configurazione e secrets:

.env: crea il file srcs/.env con le variabili non sensibili, ad esempio:

text
DOMAIN_NAME=<tuo_login>.42.fr
MYSQL_USER=wp_user
MYSQL_DATABASE=wp_database



le regole makefile implementate sono:
up down prepare clean show reset rebuild reset-full fix-perms
