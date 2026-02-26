# 🌳 Familia Yangu v2 — Mti wa Ukoo

> Design mpya kabisa iliyobuniwa kutoka HTML UI yenye rangi za msitu (forest green),
> vigae vya parchment, na nodes za duara zinazounganishwa na mistari ya SVG.

---

## 🎨 Design (Matching HTML UI)

| Kipengele | Maelezo |
|-----------|---------|
| **Rangi kuu** | Forest green `#1e3d0f` / `#2d5016` |
| **Msingi** | Parchment `#f5f0e8` |
| **Wanaume** | Buluu `#2e5f8a` |
| **Wanawake** | Pinki/Purple `#8b3070` |
| **Dashi ya ndoa** | Bark/Kahawia `#8b5e3c` — dashed line |
| **Mistari ya wazazi** | Forest green — L-shaped path |
| **Moyo** | ♥ kati ya wenzi wa ndoa |

---

## 📱 Vipengele Vyote

- 🔐 **Auth** — Ingia / Jiandikisha (TabBar wazi)
- ➕ **Ongeza Mtu** — Jina, jinsia, tarehe, mahali, mawasiliano
- ✏️ **Badilisha Taarifa** — Hariri kila taarifa
- 🗑️ **Futa Mtu** — Pamoja na viungo vyake vyote
- 👶 **Ongeza Mtoto** | 👴 **Ongeza Mzazi** | 💑 **Ongeza Mwenzi**
- 🌳 **Mti wa Ukoo** — Nodes za duara, SVG connections, zoom/pan
- 🔍 **Utafutaji** — Real-time search
- 🎨 **Badilisha Theme** — Dark/Light + rangi 5
- 📤 **Export** — JSON + clipboard copy
- 📥 **Import** — Paste JSON
- 📊 **Takwimu** — Stats za familia

---

## 🚀 Kujenga APK

```bash
# 1. Sakinisha Flutter: https://flutter.dev
# 2.
cd familia_v2
flutter pub get
flutter build apk --release

# APK → build/app/outputs/flutter-apk/app-release.apk
```

---

## 📁 Muundo

```
lib/
├── main.dart
├── utils/app_colors.dart          ← Rangi zote (forest palette)
├── models/
│   ├── mtu.dart
│   └── mtumiaji_auth.dart
├── providers/
│   ├── familia_provider.dart      ← CRUD + Auth + Import/Export
│   └── theme_provider.dart        ← 5 themes + dark mode
├── widgets/
│   └── mtu_node.dart              ← Circle node (matching HTML nodes)
└── screens/
    ├── splash_screen.dart
    ├── nyumbani_screen.dart
    ├── auth/auth_screen.dart
    ├── watu/
    │   ├── orodha_watu_screen.dart
    │   ├── fomu_mtu_screen.dart
    │   └── maelezo_mtu_screen.dart
    ├── mti/mti_ukoo_screen.dart   ← Tree + CustomPainter connections
    └── mipangilio/mipangilio_screen.dart
```
# Ukoo-wa-Albatawy
# BATAWY
