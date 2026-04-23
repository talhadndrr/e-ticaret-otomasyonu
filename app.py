from flask import Flask, jsonify, request, render_template
import psycopg2
from datetime import date
import os

app = Flask(__name__)


DB_HOST = "localhost"
DB_NAME = "market_db"
DB_USER = "postgres"
DB_PASS = "4sifreadmin"   

def get_db_connection():
    conn = psycopg2.connect(
        host=DB_HOST,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASS
    )
    return conn

# Vitrin Sayfası (Ana Sayfa)
@app.route('/')
def ana_sayfa():
    return render_template('index.html')

# Mağazalar Sayfası
@app.route('/magazalar')
@app.route('/magazalar.html')
def magazalar_sayfasi():
    return render_template('magazalar.html')

# İletişim Sayfası
@app.route('/iletisim')
@app.route('/iletisim.html')
def iletisim_sayfasi():
    return render_template('iletisim.html')

# Giriş Yap / Kayıt Ol Sayfası
@app.route('/login')
@app.route('/login.html')
def login_sayfasi():
    return render_template('login.html')

# (Admin Paneli)
@app.route('/admin')
@app.route('/admin.html')
def admin_paneli():
    return render_template('admin.html')

# Veritabanına Bağlı Ürünler Sayfası
@app.route('/products')
@app.route('/products.html')
def urunler_sayfasi():
    return render_template('products.html')

# ÜRÜNLERİ GETİRME API 
@app.route('/urunler', methods=['GET'])
def urunleri_getir():
    try:
       
        db_url = os.environ.get("DATABASE_URL")
        if db_url:
            if db_url.startswith("postgres://"):
                db_url = db_url.replace("postgres://", "postgresql://", 1)
            conn = psycopg2.connect(db_url)
        else:
           
            conn = psycopg2.connect(
                host="localhost",
                database="aydin_market_db",
                user="postgres",
                password="4sifreadmin"
            )
        
        cur = conn.cursor()
        
       
        cur.execute("SELECT urun_id, urun_adi, stok, fiyat, kategori_id FROM urun")
        db_urunler = cur.fetchall()
        
        cur.close()
        conn.close()

        urun_listesi = []
        for row in db_urunler:
            urun_listesi.append({
                "urun_id": row[0],
                "urun_adi": row[1],
                "stok": row[2],
                "fiyat": float(row[3]),
                "kategori_id": row[4],
                "resim_url": "/static/images/varsayilan.png" 
            })

        return jsonify(urun_listesi), 200
        
    except Exception as e:
        
        return jsonify([{"urun_id": 999, "urun_adi": f"HATA: {str(e)}", "stok": 0, "fiyat": 0, "kategori_id": 1, "resim_url": "/static/images/varsayilan.png"}]), 200

#  Satış Yapma ve Stok Düşme API'ı
@app.route('/satis-yap', methods=['POST'])
def satis_yap():
    data = request.get_json()
    gelen_urun_id = data.get('urun_id')
    gelen_adet = data.get('adet')
    musteri_id = data.get('musteri_id') # Tarayıcıdan gelen müşteri numarası

    try:
        conn = get_db_connection()
        cur = conn.cursor()
        bugun = date.today()
        
        # Müşteri giriş yapmışsa siparişi ona bağla, yapmamışsa NULL (ziyaretçi) bırak
        if musteri_id:
            cur.execute("INSERT INTO satis (tarih, musteri_id) VALUES (%s, %s) RETURNING satis_id;", (bugun, musteri_id))
        else:
            cur.execute("INSERT INTO satis (tarih) VALUES (%s) RETURNING satis_id;", (bugun,))
            
        yeni_satis_id = cur.fetchone()[0] 
        cur.execute("INSERT INTO satis_detay (satis_id, urun_id, adet) VALUES (%s, %s, %s);", (yeni_satis_id, gelen_urun_id, gelen_adet))

        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"mesaj": "Satış tamamlandı"}), 201
    except Exception as e:
        return jsonify({"hata": str(e)}), 500
    #   KAYIT OL API
@app.route('/kayit-ol', methods=['POST'])
def kayit_ol():
    data = request.get_json()
    ad_soyad = data.get('ad_soyad')
    email = data.get('email')
    sifre = data.get('sifre')

    try:
        conn = get_db_connection()
        cur = conn.cursor()
        # Veritabanına yeni müşteriyi ekliyoruz
        cur.execute(
            "INSERT INTO musteri (ad_soyad, email, sifre) VALUES (%s, %s, %s)",
            (ad_soyad, email, sifre)
        )
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"mesaj": "Kayıt işlemi başarıyla tamamlandı!"}), 201
    except Exception as e:
        # Eğer aynı email varsa UNIQUE kuralı hata fırlatır, biz de yakalarız
        return jsonify({"hata": "Bu e-posta adresi zaten kullanılıyor!"}), 400

# GİRİŞ YAP API ---
@app.route('/giris-yap', methods=['POST'])
def giris_yap():
    data = request.get_json()
    email = data.get('email')
    sifre = data.get('sifre')

    conn = get_db_connection()
    cur = conn.cursor()
    # Veritabanından ad_soyad ile birlikte ID numarasını da çekiyoruz
    cur.execute("SELECT id, ad_soyad FROM musteri WHERE email = %s AND sifre = %s", (email, sifre))
    user = cur.fetchone()
    cur.close()
    conn.close()

    if user:
        # user[0] = id, user[1] = ad_soyad
        return jsonify({"mesaj": "Giriş başarılı! Hoş geldin, " + user[1], "ad_soyad": user[1], "id": user[0]}), 200
    else:
        return jsonify({"hata": "E-posta veya şifre hatalı!"}), 401
    
   # PROFİL SAYFASI VE GEÇMİŞ SİPARİŞLER API ---
@app.route('/profil')
def profil_sayfasi():
    return render_template('profil.html')

@app.route('/siparislerim', methods=['POST'])
def siparislerim():
    data = request.get_json()
    musteri_id = data.get('musteri_id')

    try:
        conn = get_db_connection()
        cur = conn.cursor()
        # SQL ile tabloları birleştirip müşterinin geçmiş siparişlerini buluyoruz
        sorgu = """
            SELECT s.tarih, u.urun_adi, sd.adet, (u.fiyat * sd.adet) as toplam
            FROM satis s
            JOIN satis_detay sd ON s.satis_id = sd.satis_id
            JOIN urun u ON sd.urun_id = u.urun_id
            WHERE s.musteri_id = %s
            ORDER BY s.tarih DESC;
        """
        cur.execute(sorgu, (musteri_id,))
        siparisler = cur.fetchall()
        cur.close()
        conn.close()

        liste = [{"tarih": s[0].strftime("%d.%m.%Y"), "urun_adi": s[1], "adet": s[2], "toplam": float(s[3])} for s in siparisler]
        return jsonify(liste), 200
    except Exception as e:
        return jsonify({"hata": str(e)}), 500
    # --- İLETİŞİM MESAJI KAYDETME API ---
@app.route('/mesaj-gonder', methods=['POST'])
def mesaj_gonder():
    data = request.get_json()
    ad_soyad = data.get('ad_soyad')
    email = data.get('email')
    mesaj = data.get('mesaj')

    if not ad_soyad or not email or not mesaj:
        return jsonify({"hata": "Lütfen tüm alanları doldurunuz!"}), 400

    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Mesajı veritabanına ekliyoruz
        cur.execute(
            "INSERT INTO iletisim_mesajlari (ad_soyad, email, mesaj) VALUES (%s, %s, %s)",
            (ad_soyad, email, mesaj)
        )
        
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"mesaj": "Mesajınız başarıyla iletildi. Teşekkür ederiz!"}), 201
        
    except Exception as e:
        return jsonify({"hata": f"Veritabanı Hatası: {str(e)}"}), 500
    # --- ADMİN: YENİ ÜRÜN EKLEME API ---
@app.route('/admin/urun-ekle', methods=['POST'])
def admin_urun_ekle():
    data = request.get_json()
    ad = data.get('urun_adi')
    fiyat = data.get('fiyat')
    stok = data.get('stok')
    kategori_id = data.get('kategori_id')
    resim_url = data.get('resim_url', '/static/images/varsayilan.png') # Boş bırakılırsa varsayılan resim atar

    if not ad or not fiyat or not stok or not kategori_id:
        return jsonify({"hata": "Lütfen gerekli tüm alanları doldurun!"}), 400

    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute(
            "INSERT INTO urun (urun_adi, fiyat, stok, kategori_id, resim_url) VALUES (%s, %s, %s, %s, %s)",
            (ad, fiyat, stok, kategori_id, resim_url)
        )
        
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"mesaj": f"{ad} ürünü başarıyla eklendi!"}), 201
        
    except Exception as e:
        return jsonify({"hata": f"Veritabanı Hatası: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(debug=True)
