# Makefile ottimizzato per WordPress + MariaDB

DOCKER_COMPOSE = docker compose -f srcs/docker-compose.yaml
WORDPRESS_DIR = /home/gnicolo/data/wordpress
MARIADB_DIR = /home/gnicolo/data/mariadb


.PHONY: up down prepare clean show reset rebuild reset-full fix-perms

# Prepara la directory di WordPress
prepare:
	@echo "⚡ Preparazione ambiente..."
	mkdir -p $(WORDPRESS_DIR)
	mkdir -p $(MARIADB_DIR)
	sudo chown -R 1000:1000 $(WORDPRESS_DIR)
	sudo chown -R 1000:1000 $(MARIADB_DIR)
	sudo chmod -R 755 $(WORDPRESS_DIR)
	sudo chmod -R 755 $(MARIADB_DIR)

# Avvia stack Docker in background (detached)
up: prepare
	@echo "🚀 Avvio stack in background..."
	$(DOCKER_COMPOSE) up --build -d

# Avvia stack Docker in foreground (log live)
show: prepare
	@echo "🚀 Avvio stack in foreground..."
	$(DOCKER_COMPOSE) up --build

# Ferma stack Docker senza cancellare dati
down:
	@echo "🛑 Stop stack..."
	$(DOCKER_COMPOSE) down --remove-orphans

# Pulizia completa: ferma tutto e rimuove container, volumi e immagini
clean:
	@echo "🧹 Pulizia completa..."
	$(DOCKER_COMPOSE) down -v --rmi all --remove-orphans
	docker system prune -af --volumes
	sudo rm -rf $(WORDPRESS_DIR)/*

# Reinizializza solo i dati (volumi) senza cancellare immagini
reset:
	@echo "♻️ Reinizializzazione dei dati (volumi WordPress/MariaDB)..."
	$(DOCKER_COMPOSE) down -v
	sudo rm -f $(WORDPRESS_DIR)/wp-config.php

# Reset completo: pulisce tutto (volumi + directory WordPress)
reset-full:
	@echo "♻️ Reset completo (volumi + WordPress locale)..."
	$(DOCKER_COMPOSE) down -v --remove-orphans
	sudo rm -rf $(WORDPRESS_DIR)/*

# Fissa i permessi della directory WordPress
fix-perms:
	@echo "🔧 Sistemazione permessi WordPress..."
	sudo chown -R 33:33 $(WORDPRESS_DIR)

# Pulizia completa e riavvio fresh
rebuild: clean up
	@echo "🔄 Ricostruzione completa dello stack Docker"
