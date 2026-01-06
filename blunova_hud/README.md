# BluNova HUD (ESX) – FiveM NUI HUD

Modernes, schlankes **HUD für FiveM ESX** mit Fokus auf **Performance** und **saubere Integration**.  
Kompatibel mit **ESX Legacy** und älteren ESX-Versionen (SharedObject/Export wird automatisch erkannt).

![Version](https://img.shields.io/badge/Version-1.1.0-blue)
![ESX](https://img.shields.io/badge/ESX-Compatible-green)
![FiveM](https://img.shields.io/badge/FiveM-Ready-orange)

---

## ✨ Features

### Spieler-Status
- ❤️ Gesundheit (live)
- 🛡️ Rüstung (blendet automatisch aus, wenn 0)
- 🍔 Hunger & 💧 Durst (**esx_status** kompatibel)
- 🎤 Mikrofon / Voice-Range (**pma-voice** kompatibel)
- 🆔 Player-ID Anzeige

### Fahrzeug
- 🚗 Speedometer (KM/H oder MPH)
- ⛽ Fuel Anzeige (GTA natives `GetVehicleFuelLevel`)
- 🔧 Engine Status
- 🔒 Seatbelt System + Unfall/Ragdoll (wenn nicht angeschnallt)

### Komfort
- ⏸️ HUD versteckt sich im Pause-Menü (optional)
- ⌨️ Toggle HUD per Command + Keymapping

---

## ✅ Requirements

Pflicht:
- `es_extended`

Optional (wird automatisch erkannt):
- `esx_status` (Hunger/Durst)
- `pma-voice` (Mic Anzeige)
- `esx_notify` (schönere Notifications – sonst Fallback auf `ESX.ShowNotification`)

---

## 📦 Installation

1. Ordner nach `resources` kopieren:
   - Empfohlen: `resources/[ui]/blunova_hud`

2. In der `server.cfg` starten:
```cfg
ensure blunova_hud
```

3. Server neu starten.

---

## ⚙️ Konfiguration

In `client/main.lua`:
```lua
local Config = {
    UpdateInterval = 200,
    MaxSpeed = 250,        -- Skala für den Tacho
    UseMPH = false,
    HideInPauseMenu = true,

    ToggleHudKey = 'F7',
    SeatbeltKey = 'B',
}
```

---

## 🎨 Farben anpassen

In `html/css/style.css` (`:root`):
```css
:root {
  --primary: #00d4ff;
  --secondary: #00ffcc;
  --accent: #0099cc;

  --health: #ff3b5c;
  --armor: #00d4ff;
  --hunger: #ff9f1c;
  --thirst: #00b4d8;

  --dark: #0a0a0f;
}
```

---

## 🧩 Exporte

```lua
exports['blunova_hud']:IsHudVisible()
```

---

## 📫 Kontakt
- 📧 blunovaesx@gmail.com

---

**Author:** BluNovaESX
