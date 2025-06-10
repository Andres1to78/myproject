#!/bin/bash

show_help() {
    echo "Usage: $0 [--help] [--brief] [--disk] [--services service1 service2 ...] [--full]"
}

show_brief() {
    echo "Hostname: $(hostname)"
    echo "IP Address: $(hostname -I | awk '{print $1}')"
    echo "Uptime: $(uptime -p)"
    echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
    echo "Memory Usage: $(free -h | awk '/Mem:/ {print $3 " / " $2}')"
}

show_disk() {
    df -h | grep -vE '^tmpfs|^udev'
}

show_services() {
    for service in "${SERVICES[@]}"; do
        if systemctl is-active --quiet "$service"; then
            echo "$service: ACTIVE"
        else
            echo "$service: INACTIVE"
        fi
    done
}

SHOW_BRIEF=false
SHOW_DISK=false
SHOW_SERVICES=false
SHOW_FULL=false
SERVICES=()

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --help) show_help; exit 0 ;;
        --brief) SHOW_BRIEF=true ;;
        --disk) SHOW_DISK=true ;;
        --services) SHOW_SERVICES=true; shift; while [[ "$1" && "$1" != --* ]]; do SERVICES+=("$1"); shift; done; continue ;;
        --full) SHOW_FULL=true ;;
        *) echo "Unknown parameter passed: $1"; show_help; exit 1 ;;
    esac
    shift
done

if $SHOW_FULL; then
    show_brief
    echo
    show_disk
    echo
    SERVICES=(nginx ssh docker)
    show_services
    exit 0
fi

$SHOW_BRIEF && show_brief
$SHOW_DISK && show_disk
$SHOW_SERVICES && show_services
