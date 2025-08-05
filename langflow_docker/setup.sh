#!/bin/bash

# Langflow Docker Setup Script
# This script helps you build and run Langflow with uv

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
check_docker() {
    print_status "Checking Docker..."
    if ! docker --version >/dev/null 2>&1; then
        print_error "Docker is not installed or not running"
        exit 1
    fi
    
    if ! docker compose version >/dev/null 2>&1; then
        print_error "Docker Compose is not installed"
        exit 1
    fi
    
    print_success "Docker is ready"
}

# Build the Docker image
build_image() {
    print_status "Building Langflow Docker image with uv..."
    docker compose build --no-cache
    print_success "Image built successfully"
}

# Start services
start_services() {
    print_status "Starting Langflow services..."
    docker compose up -d
    print_success "Services started"
    
    print_status "Waiting for services to be ready..."
    sleep 10
    
    # Check service health
    check_services
}

# Check service health
check_services() {
    print_status "Checking service health..."
    
    # Check PostgreSQL
    if docker compose exec postgres pg_isready -U langflow >/dev/null 2>&1; then
        print_success "PostgreSQL is ready"
    else
        print_warning "PostgreSQL is not ready yet"
    fi
    
    # Check Redis
    if docker compose exec redis redis-cli ping >/dev/null 2>&1; then
        print_success "Redis is ready"
    else
        print_warning "Redis is not ready yet"
    fi
    
    # Check Langflow
    sleep 5
    if curl -f http://localhost:7860/health >/dev/null 2>&1; then
        print_success "Langflow is ready"
        print_success "Access Langflow at: http://localhost:7860"
    else
        print_warning "Langflow is starting up... Please wait a few more seconds"
    fi
}

# Show logs
show_logs() {
    print_status "Showing Langflow logs..."
    docker compose logs -f langflow
}

# Stop services
stop_services() {
    print_status "Stopping services..."
    docker compose down
    print_success "Services stopped"
}

# Clean up everything
cleanup() {
    print_warning "This will remove all containers, volumes, and data!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Cleaning up..."
        docker compose down -v --remove-orphans
        docker system prune -f
        print_success "Cleanup completed"
    else
        print_status "Cleanup cancelled"
    fi
}

# Show help
show_help() {
    echo "Langflow Docker Management Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  build     Build the Docker image"
    echo "  start     Start all services"
    echo "  stop      Stop all services"
    echo "  restart   Restart all services"
    echo "  logs      Show Langflow logs"
    echo "  status    Check service status"
    echo "  cleanup   Remove all containers and volumes"
    echo "  help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build && $0 start"
    echo "  $0 logs"
    echo "  $0 restart"
}

# Main script logic
main() {
    case "${1:-help}" in
        build)
            check_docker
            build_image
            ;;
        start)
            check_docker
            start_services
            ;;
        stop)
            stop_services
            ;;
        restart)
            stop_services
            sleep 2
            start_services
            ;;
        logs)
            show_logs
            ;;
        status)
            check_services
            ;;
        cleanup)
            cleanup
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
