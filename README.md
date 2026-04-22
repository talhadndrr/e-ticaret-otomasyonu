# 🛒 Aydın Market E-Ticaret Otomasyonu

Bu proje, modern teknoloji kullanılarak geliştirilmiş, tam kapsamlı bir e-ticaret ve market yönetim sistemidir. Kullanıcı dostu arayüzü ve güçlü veritabanı altyapısıyla hem müşteriler hem de yöneticiler için kusursuz bir deneyim sunar.

[Aydın Market Ana Sayfa Ekran Görüntüsü](https://prnt.sc/YRbtU7cGxDMu)

## ✨ Öne Çıkan Özelliklerimiz:
* **Canlı Sepet ve Güvenli Ödeme:** Sayfa yenilemeden çalışan sepet mantığı ve şık ödeme modalı.
* **Admin Kontrol Merkezi:** Anlık satış grafiklerinin ve kritik stokların takip edilebildiği şifreli yönetici paneli.
* **Kullanıcı Profili:** Müşterilerin geçmiş siparişlerini görebildiği kişiselleştirilmiş hesap ekranı.
  
## 🛠️ Kullanılan Teknolojiler

| Alan / Kategori | Teknolojiler |
| :--- | :--- |
| **Backend** | Python, Flask |
| **Veritabanı** | PostgreSQL, MSSQL |
| **Frontend** | HTML5, CSS3, JavaScript, Chart.js |


## 📁 Proje Yapısı

```text
aydin-market/
├── app.py              # Ana Flask uygulaması ve API route'ları
├── requirements.txt    # Gerekli Python kütüphaneleri (Flask, Psycopg2 vb.)
├── static/             # Sabit dosyalar
│   ├── css/            # Stil dosyaları
│   └── images/         # Ürün fotoğrafları (.png dosyaların burada)
├── templates/          # HTML sayfaları
│   ├── index.html      # Ana sayfa (Vitrin ve Öne Çıkanlar)
│   ├── products.html   # Tüm ürünler ve kategori filtreleme
│   ├── admin.html      # Yönetici paneli ve grafikler
│   ├── iletisim.html   # İletişim sayfası
│   └── login.html      # Kullanıcı giriş ekranı
└── db/                 # Veritabanı dosyaları
    ├── schema.sql      # Tablo yapıları (Ürün, Kategori, Satış)
    └── seed.sql        # Başlangıçta attığımız UPDATE ve INSERT kodları

```
## 🗄️ Veritabanı Tasarımı

Veritabanı PostgreSQL üzerinde `market_db` adıyla oluşturulmuştur. Sistemdeki tablolar ve işlevleri aşağıda listelenmiştir:

| Tablo | Açıklama |
| :--- | :--- |
| `kategori` | Ana kategoriler (Gıda, İçecek, Temizlik, Atıştırmalık vb.) |
| `urun` | Ürün kataloğu (İsim, fiyat, stok adedi ve yüksek çözünürlüklü resim linkleri) |
| `musteri` | Kayıtlı müşteri bilgileri (Ad, soyad, iletişim bilgileri) |
| `satis` | Satış kayıtları (Müşteri bağlantısı ve otomatik toplam tutar hesabı) |
| `satis_detay` | Hangi siparişte hangi üründen kaç adet alındığının detayı |
| `stok_log` | Sistem log kayıtları (Satış sonrası PostgreSQL Trigger'ları tarafından otomatik düşülür) |


## 📁 Proje Yapısı

```text
|   app.py
|   bakkal veri tabanı postgreSQL UYUMLU.txt
|   mssql.sql
|   
+---static
|   \---images
|           biskuvi.png
|           cikolata.png
|           cips.png
|           deterjan.png
|           ekmek.png
|           fanta.png
|           kola.png
|           makarna.png
|           meyve_suyu.png
|           peynir.png
|           sabun.png
|           sampuan.png
|           su.png
|           sut.png
|           yogurt.png
|           
\---templates
        admin.html
        iletisim.html
        index.html
        login.html
        magazalar.html
        products.html
        profil.html
```
GELİŞTİRİCİLER :
Hüseyin Talha Dündar.
Firdevs Nergiz Boz.
Enes Aytürk. 
Emre Meriç. 
Yasin Efe Gerek.
Batur Kayı Pınarbaşı. 
Gökçe Aleyna Yıldız.
Elif Sultan Özel.
İbrahim Mert Kaya.
Hatice Nisa Kızılbağlı.
