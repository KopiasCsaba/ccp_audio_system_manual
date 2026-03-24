#!/bin/bash

# All-in-one Docker Compose management script

if [ ! -f "$(dirname "$0")/.env" ]; then
    echo "Error: .env file not found. Copy .env.example to .env and fill in the values."
    exit 1
fi

case "$1" in
    start)
        echo "Starting services..."
        docker compose up -d
        docker compose ps
        ;;
    stop)
        echo "Stopping services..."
        docker compose stop
        ;;
    restart)
        echo "Restarting services..."
        docker compose restart
        docker compose ps
        ;;
    reload)
        if [ -z "$2" ]; then
            echo "Reloading all services (applying changes)..."
            docker compose up -d --build --force-recreate
        else
            echo "Reloading $2 (applying changes)..."
            docker compose up -d --build --force-recreate "$2"
        fi
        docker compose ps
        ;;
    logs)
        if [ -z "$2" ]; then
            docker compose logs -f --tail=100
        else
            docker compose logs -f --tail=100 "$2"
        fi
        ;;
    ps|status)
        docker compose ps
        ;;
    down)
        echo "Stopping and removing services..."
        docker compose down
        ;;
    shell)
        if [ -z "$2" ]; then
            echo "Error: service name required"
            echo "Usage: $0 shell <service_name>"
            exit 1
        fi
        docker compose exec "$2" bash
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|reload|logs|status|shell|down} [service_name]"
        echo ""
        echo "Commands:"
        echo "  start   - Start services in detached mode"
        echo "  stop    - Stop services"
        echo "  restart - Restart services"
        echo "  reload  - Rebuild and recreate services (optional: specify service name)"
        echo "  logs    - Show logs (optional: specify service name)"
        echo "  status  - Show service status"
        echo "  shell   - Open shell in container (requires service name)"
        echo "  down    - Stop and remove services"
        exit 1
        ;;
esac
