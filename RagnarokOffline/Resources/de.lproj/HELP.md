# Ragnarok Online Client-Dateien auf dein Gerät kopieren

## Methode 1: WLAN (Windows zu iPhone/iPad)

**Schritt 1 — Ordner unter Windows freigeben**

1. Rechtsklick auf den kRO-Client-Ordner und **Eigenschaften** auswählen
2. Den Reiter **Freigabe** öffnen und auf **Erweiterte Freigabe** klicken
3. **Diesen Ordner freigeben** ankreuzen und auf **OK** klicken
4. **Einstellungen** → **Netzwerk & Internet** öffnen und sicherstellen, dass das Netzwerkprofil auf **Privat** gesetzt ist
5. In **Systemsteuerung** → **Netzwerk- und Freigabecenter** → **Erweiterte Freigabeeinstellungen ändern**: **Netzwerkerkennung** und **Datei- und Druckerfreigabe** aktivieren

**Schritt 2 — IP-Adresse des PCs herausfinden**

**Win + R** drücken, `cmd` eingeben, Enter drücken, dann `ipconfig` eingeben. Die **IPv4-Adresse** notieren (z. B. `192.168.1.10`).

**Schritt 3 — Vom iOS-Gerät verbinden**

1. Die App **Dateien** öffnen
2. Auf **···** oben rechts tippen und **Mit Server verbinden** auswählen
3. `smb://192.168.1.10` eingeben (eigene IP-Adresse des PCs verwenden)
4. Windows-Benutzername und -Passwort eingeben, dann auf **Verbinden** tippen

**Schritt 4 — Dateien kopieren**

Die folgenden Elemente in **Auf meinem iPhone/iPad → Ragnarok Offline** kopieren (lange drücken → **Kopieren**, zum Ziel navigieren → **Einsetzen**):

- **data.grf**
- **BGM**-Ordner

---

## Methode 2: USB-Kabel

**Mac:** Gerät verbinden → **Finder** öffnen → iPhone/iPad auswählen → Reiter **Dateien** → **Ragnarok Offline** aufklappen → Dateien hineinziehen.

**Windows:** Gerät verbinden → **iTunes** öffnen → Gerät auswählen → **Dateifreigabe** → **Ragnarok Offline** auswählen → Dateien hineinziehen.
