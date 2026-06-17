
---

### 2. `USER_DOC.md` 

```markdown
# Documentazione per l'utente finale – Inception

Benvenuto nel progetto Inception. Questo documento spiega come interagire con l'infrastruttura dal punto di vista di un utente finale o di un amministratore di sistema.

## Servizi disponibili

L'infrastruttura fornisce un ambiente web sicuro e funzionante, composto da:

- **Web server (NGINX)** – gestisce tutto il traffico in ingresso usando crittografia SSL/TLS.
- **Sito web (WordPress)** – un sistema di gestione dei contenuti già pronto all'uso.
- **Database (MariaDB)** – memorizza utenti, articoli e configurazioni del sito in modo sicuro e nascosto alla rete esterna.

## Avvio e arresto del progetto

Il progetto è gestito interamente tramite un `Makefile` situato nella directory principale.

- **Avviare l'infrastruttura**: apri il terminale ed esegui `make`. Questo comando costruisce le immagini e avvia tutti i servizi in background.
- **Arrestare i servizi**: esegui `make down` per fermare i container in modo ordinato, senza cancellare i dati persistenti.
- **Ripristino completo**: esegui `make fclean` per fermare tutto e rimuovere container, immagini e volumi (attenzione: cancella tutti i dati se i volumi vengono rimossi).

## Accesso al sito e al pannello di amministrazione

- **Sito principale**: apri il browser e vai a `https://<tuo_login>.42.fr`.
- **Pannello di amministrazione**: per accedere alla dashboard di WordPress, vai a `https://<tuo_login>.42.fr/wp-admin`. Usa le credenziali amministrative che hai definito durante la configurazione iniziale (nel file di secret `wp_admin_password.txt` e `wp_admin_user.txt`).
- **Certificato SSL autofirmato**: il browser potrebbe segnalare un problema di sicurezza. Dovrai accettare il rischio per proseguire (si tratta di un certificato generato localmente, non riconosciuto dalle autorità di certificazione pubbliche).

## Gestione delle credenziali

Per ragioni di sicurezza, nessuna password è scritta in chiaro nei file del progetto.

- **Variabili d'ambiente**: i parametri di configurazione generici (come il nome di dominio o l'utente del database) sono nel file `srcs/.env`.
- **Secrets**: i dati più sensibili (password di root del database, password dell'amministratore WordPress, ecc.) devono essere conservati in file `.txt` all'interno della cartella `secrets/` (alla radice del progetto). **Non committare mai questi file su Git** – aggiungili al `.gitignore`.

## Verifica dello stato dei servizi

Per controllare che tutto funzioni correttamente, puoi usare i comandi Docker standard:

- Elencare i container in esecuzione: `docker ps`
- Visualizzare i log di un servizio specifico (ad esempio NGINX): `docker logs nginx`
- Verificare la connettività tra i container: puoi entrare in un container e usare `ping` o `curl` verso il nome del servizio (es. `curl mariadb:3306`).

## Backup e ripristino

I dati persistenti sono memorizzati nei volumi Docker nominati, che risiedono fisicamente in:
- `/home/<tuo_login>/data/wordpress` per i file di WordPress (temi, plugin, upload).
- `/home/<tuo_login>/data/mariadb` per i file del database.

Per fare un backup, puoi semplicemente comprimere queste cartelle. Per ripristinare, ferma i container, sostituisci i contenuti e riavvia.
