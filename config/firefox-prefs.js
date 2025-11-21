// Configuration Firefox optimisée pour AMD Radeon (APU)
// Accélération matérielle et performances améliorées
// 
// Installation:
// 1. Ouvrir Firefox
// 2. about:config
// 3. Copier-coller ces préférences

// ====================================
// Accélération Matérielle GPU
// ====================================

// Activer WebRender (composition GPU)
user_pref("gfx.webrender.all", true);
user_pref("gfx.webrender.enabled", true);

// Activer accélération matérielle
user_pref("layers.acceleration.force-enabled", true);
user_pref("layers.omtp.enabled", true);

// VAAPI pour décodage vidéo (AMD)
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.ffvpx.enabled", false);
user_pref("media.navigator.mediadatadecoder_vpx_enabled", true);

// Activer décodage hardware AV1/VP9
user_pref("media.av1.enabled", true);
user_pref("media.hardware-video-decoding.force-enabled", true);

// ====================================
// Optimisations Mémoire
// ====================================

// Cache mémoire (adapter selon RAM)
// Si RAM ≤4GB: 256000
// Si RAM 4-8GB: 512000
// Si RAM ≥8GB: 1024000
user_pref("browser.cache.memory.capacity", 512000);

// Limiter processus de contenu
// Si RAM ≤4GB: 2-3
// Si RAM ≥6GB: 4-8
user_pref("dom.ipc.processCount", 4);

// Décharger onglets inactifs (si RAM limitée)
user_pref("browser.tabs.unloadOnLowMemory", true);

// ====================================
// Performances Réseau
// ====================================

// HTTP/3 (QUIC)
user_pref("network.http.http3.enabled", true);

// DNS over HTTPS (DoH) - optionnel
user_pref("network.trr.mode", 2);

// Prefetch DNS
user_pref("network.dns.disablePrefetch", false);
user_pref("network.prefetch-next", true);

// ====================================
// Interface Utilisateur
// ====================================

// Animations fluides
user_pref("layout.frame_rate", 60);

// Smooth scrolling
user_pref("general.smoothScroll", true);
user_pref("mousewheel.default.delta_multiplier_y", 275);

// ====================================
// Sécurité & Vie Privée (optionnel)
// ====================================

// Tracking protection strict
user_pref("browser.contentblocking.category", "strict");

// HTTPS-Only mode
user_pref("dom.security.https_only_mode", true);

// Désactiver telemetry (optionnel)
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("toolkit.telemetry.enabled", false);

// ====================================
// Optimisations AMD Spécifiques
// ====================================

// Forcer driver Mesa
user_pref("layers.acceleration.force-enabled", true);

// WebGL
user_pref("webgl.force-enabled", true);
user_pref("webgl.msaa-force", true);

// ====================================
// Notes
// ====================================

// Vérification accélération active:
// 1. about:support
// 2. Section "Graphics"
// 3. Vérifier: "Compositing: WebRender"
// 4. Vérifier: "Decision Log" → pas d'erreurs
//
// Test VAAPI:
// 1. Ouvrir YouTube 1080p/4K
// 2. Monitorer CPU (htop)
// 3. Si VAAPI fonctionne: CPU usage <30%
//
// Variables d'environnement optionnelles (~/.bashrc):
// export MOZ_ENABLE_WAYLAND=1  # Si Wayland
// export MOZ_X11_EGL=1          # Si X11
