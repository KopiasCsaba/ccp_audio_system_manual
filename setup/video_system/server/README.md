
# Configuration
See files in [server_files](server_files)

# Noteworthy files
## .env
Based on .env.example: rename this to .env and set values properly

## manage.sh

```bash
$ ./manage.sh 
Usage: ./manage.sh {start|stop|restart|reload|logs|status|shell|down} [service_name]

Commands:
  start   - Start services in detached mode (optional: specify service name)
  stop    - Stop services (optional: specify service name)
  restart - Restart services (optional: specify service name)
  reload  - Rebuild and recreate services (optional: specify service name)
  logs    - Show logs (optional: specify service name)
  status  - Show service status
  shell   - Open shell in container (requires service name)
  down    - Stop and remove services (optional: specify service name)

Services:
  reverse_proxy_webserver
  video-processor
  atem-nas-sync
  companion
  postgres
  n8n
  restreamer
```

## create_backup.sh
Creates a full backup of all services and their data into the backups/ folder.
 
# Services
* [Restreamer](restreamer)
* [N8N](n8n)
* [Companion](companion)