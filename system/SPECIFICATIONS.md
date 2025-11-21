# Spécifications Détaillées - Ponyo

## 📋 À Compléter sur la Machine

### CPU
```bash
# Exécuter sur Ponyo:
lscpu
cat /proc/cpuinfo | grep -E "model name|cpu MHz|cores"
```

**Résultat attendu:**
- Modèle: AMD A6-???? (ex: A6-7310, A6-9225)
- Architecture: Excavator / Piledriver / Bulldozer
- Cores: 2 ou 4
- Threads: 2 ou 4
- Fréquence base: _____ GHz
- Fréquence max: _____ GHz (Turbo Core)

### RAM
```bash
# Exécuter:
free -h
sudo dmidecode -t memory | grep -E "Size|Speed|Type:"
```

**Résultat:**
- Capacité totale: _____ GB
- Type: DDR3 / DDR3L
- Fréquence: _____ MHz
- Slots utilisés: _____ / 2

### GPU
```bash
# Exécuter:
lspci | grep -i vga
glxinfo | grep "OpenGL renderer"
```

**Résultat:**
- GPU: AMD Radeon R4/R5 (APU intégré)
- Architecture: GCN 1.0 / 2.0 / 3.0
- Driver: Mesa _____ / AMDGPU

### Stockage
```bash
# Exécuter:
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,ROTA
sudo hdparm -I /dev/sda | grep -E "Model|TRIM"
```

**Résultat:**
- Type: HDD (ROTA=1) / SSD (ROTA=0)
- Capacité: _____ GB
- Modèle: _____
- TRIM support: Oui / Non

### Système
- **OS**: _____
- **Version**: _____
- **Kernel**: _____
- **Desktop**: _____

### Réseau
```bash
lspci | grep -i network
```

**Résultat:**
- WiFi: _____
- Ethernet: _____

### Batterie
```bash
upower -i /org/freedesktop/UPower/devices/battery_BAT0
```

**État:**
- Capacité design: _____ Wh
- Capacité actuelle: _____ Wh
- État santé: _____ %

