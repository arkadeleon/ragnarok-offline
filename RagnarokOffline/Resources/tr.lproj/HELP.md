# Ragnarok Online İstemci Dosyalarını Cihazına Kopyalama

## Yöntem 1: Wi-Fi (Windows'tan iPhone/iPad'e)

**Adım 1 — Windows'ta klasörü paylaş**

1. kRO istemci klasörüne sağ tıkla ve **Özellikler**'i seç
2. **Paylaşım** sekmesini aç ve **Gelişmiş Paylaşım**'a tıkla
3. **Bu klasörü paylaş**'ı işaretle ve **Tamam**'a tıkla
4. **Ayarlar** → **Ağ ve İnternet**'i aç ve ağ profilinin **Özel** olarak ayarlandığını doğrula
5. **Denetim Masası** → **Ağ ve Paylaşım Merkezi** → **Gelişmiş paylaşım ayarlarını değiştir**'de **Ağ keşfi**ni ve **Dosya ve yazıcı paylaşımı**nı etkinleştir

**Adım 2 — PC'nin IP adresini bul**

**Win + R** tuşlarına bas, `cmd` yaz, Enter'a bas, ardından `ipconfig` yaz. **IPv4 Adresini** not al (örn. `192.168.1.10`).

**Adım 3 — iOS'tan bağlan**

1. **Dosyalar** uygulamasını aç
2. Sağ üst köşedeki **···** simgesine dokun ve **Sunucuya Bağlan**'ı seç
3. `smb://192.168.1.10` gir (PC'nin IP adresini kullan)
4. Windows kullanıcı adı ve şifreni gir, ardından **Bağlan**'a dokun

**Adım 4 — Dosyaları kopyala**

Aşağıdaki öğeleri **iPhone/iPad'imde → Ragnarok Offline**'a kopyala (her öğeye uzun bas → **Kopyala**, hedefe git → **Yapıştır**):

- **data.grf** (kRO kök klasöründen)
- **BGM** klasörü (kRO kök klasöründen)
- **System** klasörü (kRO kök klasöründen)

---

## Yöntem 2: USB Kablosu

**Mac:** Cihazını bağla → **Finder**'ı aç → iPhone/iPad'ini seç → **Dosyalar** sekmesi → **Ragnarok Offline**'ı genişlet → dosyalarını sürükle.

**Windows:** Cihazını bağla → **iTunes**'u aç → cihazını seç → **Dosya Paylaşımı** → **Ragnarok Offline**'ı seç → dosyalarını sürükle.
