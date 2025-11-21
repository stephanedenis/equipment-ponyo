#!/bin/bash
# Script de monitoring en temps réel - Ponyo
# Affiche CPU, RAM, température, fréquences en direct

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

while true; do
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║           Monitoring Système - Ponyo (AMD A6)              ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # CPU
    echo -e "${GREEN}🖥️  CPU${NC}"
    echo "   $(cat /proc/cpuinfo | grep "model name" | head -1 | cut -d':' -f2 | xargs)"
    echo ""
    
    # Fréquences
    echo -e "${GREEN}⚡ Fréquences${NC}"
    grep MHz /proc/cpuinfo | awk '{printf "   CPU %d: %.0f MHz\n", NR-1, $4}'
    echo ""
    
    # Governor
    GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
    echo "   Governor: $GOV"
    echo ""
    
    # RAM
    echo -e "${GREEN}💾 RAM${NC}"
    free -h | awk 'NR==2{printf "   Utilisé: %s / %s (%.0f%%)\n", $3,$2,($3/$2)*100}'
    
    # ZRAM si actif
    if [ -e /dev/zram0 ]; then
        ZRAM_SIZE=$(zramctl | awk 'NR==2{print $3}')
        ZRAM_USED=$(zramctl | awk 'NR==2{print $4}')
        [ -n "$ZRAM_SIZE" ] && echo "   ZRAM: $ZRAM_USED / $ZRAM_SIZE"
    fi
    echo ""
    
    # Swap
    echo -e "${GREEN}💿 Swap${NC}"
    SWAP_TOTAL=$(free -h | awk '/^Swap:/{print $2}')
    SWAP_USED=$(free -h | awk '/^Swap:/{print $3}')
    SWAP_PERCENT=$(free | awk '/^Swap:/ && $2>0{printf "%.0f", ($3/$2)*100}')
    if [ -z "$SWAP_PERCENT" ]; then SWAP_PERCENT=0; fi
    
    if [ "$SWAP_PERCENT" -gt 50 ]; then
        echo -e "   ${RED}Utilisé: $SWAP_USED / $SWAP_TOTAL ($SWAP_PERCENT%)${NC}"
    elif [ "$SWAP_PERCENT" -gt 20 ]; then
        echo -e "   ${YELLOW}Utilisé: $SWAP_USED / $SWAP_TOTAL ($SWAP_PERCENT%)${NC}"
    else
        echo "   Utilisé: $SWAP_USED / $SWAP_TOTAL ($SWAP_PERCENT%)"
    fi
    echo ""
    
    # Température
    if command -v sensors &> /dev/null; then
        echo -e "${GREEN}🌡️  Température${NC}"
        sensors 2>/dev/null | grep -E "°C" | head -5 | sed 's/^/   /'
        echo ""
    fi
    
    # Load Average
    echo -e "${GREEN}📊 Load Average${NC}"
    LOAD=$(uptime | awk -F'load average:' '{print $2}')
    echo "   $LOAD"
    echo ""
    
    # Top processes
    echo -e "${GREEN}🔝 Top 5 Processus CPU${NC}"
    ps aux --sort=-%cpu | awk 'NR<=6 && NR>1 {printf "   %s: %.1f%% CPU, %.1f%% RAM\n", $11, $3, $4}'
    echo ""
    
    # Disque I/O
    echo -e "${GREEN}💾 Disque (racine)${NC}"
    df -h / | awk 'NR==2{printf "   Utilisé: %s / %s (%s)\n", $3, $2, $5}'
    echo ""
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "   Rafraîchissement: 2s | Ctrl+C pour quitter"
    
    sleep 2
done
