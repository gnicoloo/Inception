**Inception — Ambiente Docker multi-servizio**

Un README professionale e pratico per il repository Inception: un ambiente containerizzato che mette insieme Nginx, MariaDB e WordPress (PHP-FPM). Questo progetto fornisce una configurazione pronta per sviluppo, test e demo locale.

**Caratteristiche**:
- **Architettura a servizi**: Nginx (reverse proxy), PHP-FPM / WordPress, MariaDB.
- **Container-first**: costruzione e avvio con Docker Compose.
- **Script di test e utilità**: include script locali per test e verifiche automatiche.

**Requisiti**:
- Docker (>= 20.10)
- Docker Compose (integrato in Docker CLI o v2+)
- Accesso terminale su Linux / macOS / Windows WSL

**Setup rapido**
1. Clona il repository:

```
git clone <REPO_URL>
cd Inception
```

2. (Opzionale) Personalizza eventuali variabili segrete nella cartella `secrects/` o crea il tuo file `.env` se necessario.

3. Avvia i servizi (dal root del repository):

```
docker compose -f srcs/docker-compose.yaml up --build -d
```

4. Per fermare ed eliminare i container:

```
docker compose -f srcs/docker-compose.yaml down
```

**Verifiche rapide**
- Controlla i container in esecuzione:

```
docker ps
```

- Log di un servizio (es. nginx):

```
docker compose -f srcs/docker-compose.yaml logs -f nginx
```

**Script utili nel repository**
- `test.sh` — script di verifica base.
- `test_final.sh` — script di verifica finale / grading.
- `super_test.sh` — suite estesa di test.

Esegui gli script locali per verifiche rapide:

```
./test.sh
```

**Struttura del progetto (sintesi)**
- `srcs/docker-compose.yaml` — definizione dei servizi e delle reti.
- `srcs/nginx/` — Dockerfile, configurazione `nginx.conf` e script di inizializzazione.
- `srcs/mariadb/` — Dockerfile, configurazioni MariaDB e script di init.
- `srcs/wordpress/` — Dockerfile, configurazione PHP-FPM e script di setup WordPress.
- `secrects/` — cartella per gestione segreti/credenziali locali (non committare credenziali reali).

**Uso tramite Makefile**
Il repository include un `Makefile` ottimizzato per lo sviluppo locale. Esegui i comandi dalla root del progetto.

- `make prepare` : prepara la directory WordPress (crea `$(WORDPRESS_DIR)`, sistema owner/permessi e rimuove `wp-config.php`).
- `make up` : prepara e avvia lo stack in background (`docker compose ... up --build -d`).
- `make show` : prepara e avvia lo stack in foreground (log live).
- `make down` : ferma lo stack senza rimuovere i dati.
- `make clean` : pulizia completa (ferma, rimuove volumi, immagini e svuota la directory WordPress).
- `make reset` : reinizializza i dati (rimuove volumi e `wp-config.php`).
- `make reset-full` : reset completo (rimuove volumi e la directory WordPress locale).
- `make rebuild` : esegue `clean` quindi `up` per una ricostruzione completa.
- `make fix-perms` : sistema i permessi della directory WordPress (owner `33:33`).

Nota: nel `Makefile` la variabile `WORDPRESS_DIR` punta a `/home/gnicolo/data/wordpress` e alcuni target eseguono comandi `sudo` per modificare permessi/owner. Se usi un percorso diverso o un altro utente, aggiorna il `Makefile` o esegui i comandi manualmente.

**Consigli di sicurezza**
- Non committare password o chiavi private: mantieni segreti fuori dal controllo versione.
- Usa file `.env` o strumenti di secret management per valori sensibili.

**Contribuire**
- Apri un issue per discutere modifiche importanti.
- Per patch rapide: Fork → branch feature → Pull Request con descrizione chiara dei cambiamenti.

**Licenza**
Specifica qui la licenza scelta (es. MIT, GPL-3.0). Se non è presente, aggiungi un file `LICENSE` con la licenza desiderata.

**Contatti**
- Autore: aggiungi nome e contatto (email / GitHub profile).

---
Se vuoi, posso:
- personalizzare il README con il nome esatto del repository e il link remoto;
- aggiungere badge (build, license, docker image) e screenshot;
- tradurlo in inglese o affinare la sezione operativa per ambienti specifici.
# Inception
