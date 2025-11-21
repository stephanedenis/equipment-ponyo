# AMD A6 Optimizations Memo - Quick Reference

## 🚀 One-Liner Installation

```bash
cd ~/equipment-ponyo && sudo bash scripts/install-complete.sh
```

## ⚡ Quick Commands

### Audit & Monitoring
```bash
bash scripts/audit-hardware.sh          # Full system audit
bash scripts/monitor.sh                 # Live monitoring (Ctrl+C to exit)
bash scripts/benchmark.sh               # Performance tests
```

### Optimization
```bash
sudo bash scripts/optimize-system.sh    # Auto-optimize everything
sudo bash scripts/maintenance.sh        # Clean & maintain
```

### Diagnostics
```bash
vainfo                                  # VAAPI status
sensors                                 # Temperatures
htop                                    # CPU/RAM usage
cat /proc/sys/vm/swappiness            # Current swappiness
zramctl                                 # ZRAM status (if enabled)
```

## 🎯 Key Settings by RAM

| RAM | Swappiness | ZRAM | Desktop |
|-----|-----------|------|---------|
| ≤4GB | 35 | **Required** | XFCE/LXQt |
| 4-6GB | 20 | Recommended | Any |
| ≥8GB | 10 | Optional | Any |

## 🔧 Manual Quick Fixes

### VAAPI Not Working
```bash
export LIBVA_DRIVER_NAME=radeonsi
echo 'export LIBVA_DRIVER_NAME=radeonsi' >> ~/.bashrc
```

### CPU Too Hot (>85°C)
```bash
# Set powersave governor
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo powersave | sudo tee $cpu
done
```

### Slow Disk (HDD)
```bash
# Set BFQ scheduler
echo bfq | sudo tee /sys/block/sda/queue/scheduler
```

### High Swap Usage
```bash
# Clear swap
sudo swapoff -a && sudo swapon -a
```

## 📊 Expected Performance

| Task | CPU Load | Notes |
|------|----------|-------|
| Idle | <10% | Normal |
| YouTube 1080p | <30% | With VAAPI |
| Compilation | 100% | Use ccache |
| Multiple tabs | Varies | Depends on RAM |

## 🔗 Quick Links

- [5min Setup](docs/QUICK_START.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Distributions](docs/DISTRIBUTIONS.md)
- [AMD Details](system/OPTIMISATIONS_AMD.md)

## 🆘 Emergency Commands

```bash
# Reset to safe governor
echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Check logs
journalctl -xe
dmesg | tail -50

# Temperatures
watch -n 1 sensors

# Kill heavy process
htop  # Press F9 to kill
```

## 📝 Config Files Locations

```
System configs:
  /etc/sysctl.d/99-ponyo.conf          # Kernel optimizations
  ~/.config/ponyo.env                   # GPU environment vars
  ~/.bashrc                             # Auto-source ponyo.env

Project files:
  ~/equipment-ponyo/config/             # All configs
  ~/equipment-ponyo/scripts/            # All scripts
```

## 🎮 Firefox Quick Setup

1. Open `about:config`
2. Copy settings from `config/firefox-prefs.js`
3. Test YouTube 1080p → CPU should be <30%

## 💡 Tips

- Run `maintenance.sh` weekly
- Keep Mesa drivers updated
- Monitor temps with `sensors`
- Use `monitor.sh` to watch real-time stats
- Check audit after system changes

---

**Print this memo or bookmark for quick reference!** 📄
