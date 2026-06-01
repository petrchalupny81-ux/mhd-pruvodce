# MHD Průvodce — Nastavení projektu

## 1. Vytvoření Xcode projektu

1. Otevři Xcode 15+
2. **File → New → Project → iOS → App**
3. Nastav:
   - **Product Name:** MHDPruvodce
   - **Bundle Identifier:** cz.mhd.pruvodce
   - **Interface:** SwiftUI
   - **Language:** Swift
   - **Storage:** SwiftData
   - **Team:** (tvůj Apple ID / Developer účet)
4. Uložit do: `C:/Users/Adam/MHDPruvodce/`

## 2. Přidání souborů

Přetáhni celou složku `MHDPruvodce/` do Xcode Project Navigatoru nebo:
- **File → Add Files to "MHDPruvodce"** a vyber všechny Swift soubory podle struktury.

Zachovej skupiny (Groups) odpovídající adresářové struktuře.

## 3. Config.plist

```bash
cp MHDPruvodce/Config/Config.example.plist MHDPruvodce/Config/Config.plist
```
Otevři `Config.plist` a vyplň:
- `CHAPS_API_KEY` — API klíč z portálu CHAPS/IDOS
- `CHAPS_APP_ID`  — App ID

Přidej `Config.plist` do `.gitignore`!

## 4. Assets.xcassets

Viz `Assets_README.md` — přidej všechny barevné sety ručně v Xcode.

## 5. Info.plist

Obsah `MHDPruvodce/Info.plist` přidej do svého projektového Info.plist,  
nebo nahraď celý soubor (zkontroluj, že Bundle ID a ostatní klíče zůstaly).

## 6. Background Tasks Capability

V Xcode:
1. Vyber projekt → Target → **Signing & Capabilities**
2. **+ Capability → Background Modes**
   - ✅ Location updates
   - ✅ Background fetch
   - ✅ Background processing
   - ✅ Audio, AirPlay, and Picture in Picture
3. **+ Capability → Push Notifications** (pro LiveActivity)

## 7. LiveActivity — Widget Extension (volitelné)

Pro Live Activity / Dynamic Island musíš přidat **Widget Extension** target:
1. **File → New → Target → Widget Extension**
2. Jméno: `MHDWidget`
3. Přidej `MHDJourneyAttributes.swift` a `MHDLiveActivityView.swift` do obou targetů

## 8. Zvukové soubory

Viz `Assets_README.md` — přidej `.caf` soubory do složky `Resources/`  
a přetáhni do Xcode (Target Membership: MHDPruvodce ✅).

## 9. Swift Package Manager

Tento projekt záměrně nepoužívá žádné externí závislosti (SPM).  
Vše je řešeno nativními frameworky iOS 17+.

## 10. Spuštění

- Vyber simulator nebo fyzické zařízení (iOS 17+)
- **⌘R** — Build & Run
- Pro testování lokalizace nastav simulator na Czech (cs)
