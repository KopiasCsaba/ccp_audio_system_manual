#!/bin/bash

# All-in-one Docker Compose management script

if [ ! -f "$(dirname "$0")/.env" ]; then
    echo "Error: .env file not found. Copy .env.example to .env and fill in the values."
    exit 1
fi

case "$1" in
    start)
        if [ -z "$2" ]; then
            echo "Starting all services..."
            docker compose up -d
        else
            echo "Starting $2..."
            docker compose up -d "$2"
        fi
        docker compose ps
        ;;
    stop)
        if [ -z "$2" ]; then
            echo "Stopping all services..."
            docker compose stop
        else
            echo "Stopping $2..."
            docker compose stop "$2"
        fi
        ;;
    restart)
        if [ -z "$2" ]; then
            echo "Restarting all services..."
            docker compose restart
        else
            echo "Restarting $2..."
            docker compose restart "$2"
        fi
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
        if [ -z "$2" ]; then
            echo "Stopping and removing all services..."
            docker compose down
        else
            echo "Stopping and removing $2..."
            docker compose down "$2"
        fi
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
        echo "  start   - Start services in detached mode (optional: specify service name)"
        echo "  stop    - Stop services (optional: specify service name)"
        echo "  restart - Restart services (optional: specify service name)"
        echo "  reload  - Rebuild and recreate services (optional: specify service name)"
        echo "  logs    - Show logs (optional: specify service name)"
        echo "  status  - Show service status"
        echo "  shell   - Open shell in container (requires service name)"
        echo "  down    - Stop and remove services (optional: specify service name)"
        echo ""
        echo "Services:"
        docker compose config --services 2>/dev/null | sed 's/^/  /' || echo "  (run from project directory to list services)"
        exit 1
        ;;
esac
