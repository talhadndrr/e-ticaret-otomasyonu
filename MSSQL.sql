-- 1. TABLOLAR
CREATE TABLE kategori (
    kategori_id SERIAL PRIMARY KEY,
    kategori_adi VARCHAR(50)
);

CREATE TABLE urun (
    urun_id SERIAL PRIMARY KEY,
    urun_adi VARCHAR(100),
    fiyat INT,
    stok INT,
    kategori_id INT,
    FOREIGN KEY (kategori_id) REFERENCES kategori(kategori_id)
);

CREATE TABLE satis (
    satis_id SERIAL PRIMARY KEY,
    tarih DATE
);

CREATE TABLE satis_detay (
    id SERIAL PRIMARY KEY,
    satis_id INT,
    urun_id INT,
    adet INT,
    FOREIGN KEY (satis_id) REFERENCES satis(satis_id),
    FOREIGN KEY (urun_id) REFERENCES urun(urun_id)
);

CREATE TABLE musteri (
    id SERIAL PRIMARY KEY,
    ad_soyad VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    sifre VARCHAR(100) NOT NULL
);

-- 2. VERİ EKLEME
INSERT INTO kategori (kategori_adi) VALUES
('Gıda'), ('İçecek'), ('Temizlik'), ('Atıştırmalık');

INSERT INTO urun (urun_adi, fiyat, stok, kategori_id) VALUES
('Ekmek',10,100,1), ('Süt',25,80,1), ('Peynir',60,50,1), ('Yoğurt',30,60,1),
('Makarna',20,120,1), ('Kola',35,70,2), ('Fanta',33,65,2), ('Su',5,200,2),
('Meyve Suyu',28,90,2), ('Deterjan',50,40,3), ('Sabun',20,90,3),
('Şampuan',45,55,3), ('Çikolata',15,120,4), ('Bisküvi',12,150,4), ('Cips',18,130,4);

INSERT INTO satis (tarih) VALUES
('2026-04-01'), ('2026-04-02'), ('2026-04-03');

INSERT INTO satis_detay (satis_id, urun_id, adet) VALUES
(1,1,3), (1,2,2), (1,6,1),
(2,3,1), (2,10,2), (2,14,5),
(3,7,4), (3,8,10), (3,15,3);

-- 3. TRIGGER VE FONKSİYONLAR
CREATE OR REPLACE FUNCTION fn_stok_azalt() RETURNS TRIGGER AS $$
BEGIN
    UPDATE urun SET stok = stok - NEW.adet WHERE urun_id = NEW.urun_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_stok_azalt
AFTER INSERT ON satis_detay
FOR EACH ROW EXECUTE FUNCTION fn_stok_azalt();

CREATE OR REPLACE FUNCTION fn_stok_iade() RETURNS TRIGGER AS $$
BEGIN
    UPDATE urun SET stok = stok + OLD.adet WHERE urun_id = OLD.urun_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_stok_iade
AFTER DELETE ON satis_detay
FOR EACH ROW EXECUTE FUNCTION fn_stok_iade();

CREATE OR REPLACE FUNCTION fn_stok_kontrol() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.stok < 0 THEN
        NEW.stok := 0;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_stok_kontrol
BEFORE UPDATE ON urun
FOR EACH ROW EXECUTE FUNCTION fn_stok_kontrol();

CREATE OR REPLACE FUNCTION fn_fiyat_kontrol() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fiyat < 0 THEN
        NEW.fiyat := 0;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_fiyat_kontrol
BEFORE INSERT ON urun
FOR EACH ROW EXECUTE FUNCTION fn_fiyat_kontrol();

CREATE OR REPLACE FUNCTION fn_isim_kontrol() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.urun_adi = '' OR NEW.urun_adi IS NULL THEN
        NEW.urun_adi := 'Bilinmeyen';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_isim_kontrol
BEFORE INSERT ON urun
FOR EACH ROW EXECUTE FUNCTION fn_isim_kontrol();

CREATE OR REPLACE FUNCTION fn_adet_kontrol() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.adet < 1 THEN
        NEW.adet := 1;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_adet_kontrol
BEFORE INSERT ON satis_detay
FOR EACH ROW EXECUTE FUNCTION fn_adet_kontrol();

CREATE OR REPLACE FUNCTION fn_fiyat_guncelleme_kontrol() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fiyat <= 0 THEN
        NEW.fiyat := OLD.fiyat;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_fiyat_guncelleme_kontrol
BEFORE UPDATE ON urun
FOR EACH ROW EXECUTE FUNCTION fn_fiyat_guncelleme_kontrol();

CREATE OR REPLACE FUNCTION fn_stok_baslangic() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.stok < 0 THEN
        NEW.stok := 0;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_stok_baslangic
BEFORE INSERT ON urun
FOR EACH ROW EXECUTE FUNCTION fn_stok_baslangic();

CREATE OR REPLACE FUNCTION fn_adet_guncelleme_kontrol() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.adet < 1 THEN
        NEW.adet := OLD.adet;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_adet_guncelleme_kontrol
BEFORE UPDATE ON satis_detay
FOR EACH ROW EXECUTE FUNCTION fn_adet_guncelleme_kontrol();

CREATE OR REPLACE FUNCTION fn_max_adet() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.adet > 100 THEN
        NEW.adet := 100;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_max_adet
BEFORE INSERT ON satis_detay
FOR EACH ROW EXECUTE FUNCTION fn_max_adet();

CREATE OR REPLACE FUNCTION urunleri_listele() RETURNS SETOF urun AS $$
BEGIN
    RETURN QUERY SELECT * FROM urun;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION kategori_listele() RETURNS SETOF kategori AS $$
BEGIN
    RETURN QUERY SELECT * FROM kategori;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION stoklari_goster() RETURNS TABLE(urun_adi VARCHAR, stok INT) AS $$
BEGIN
    RETURN QUERY SELECT u.urun_adi, u.stok FROM urun u;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pahali_urunler() RETURNS SETOF urun AS $$
BEGIN
    RETURN QUERY SELECT * FROM urun WHERE fiyat > 50;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ucuz_urunler() RETURNS SETOF urun AS $$
BEGIN
    RETURN QUERY SELECT * FROM urun WHERE fiyat <= 20;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION toplam_urun_sayisi() RETURNS TABLE(urun_sayisi BIGINT) AS $$
BEGIN
    RETURN QUERY SELECT COUNT(*) FROM urun;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION toplam_ciro() RETURNS TABLE(ciro BIGINT) AS $$
BEGIN
    RETURN QUERY 
    SELECT SUM(u.fiyat * sd.adet)::BIGINT 
    FROM satis_detay sd 
    JOIN urun u ON u.urun_id = sd.urun_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION satislari_listele() RETURNS SETOF satis AS $$
BEGIN
    RETURN QUERY SELECT * FROM satis;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION satis_detaylari() RETURNS SETOF satis_detay AS $$
BEGIN
    RETURN QUERY SELECT * FROM satis_detay;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION en_cok_satanlar() RETURNS TABLE(urun_id INT, toplam_satis BIGINT) AS $$
BEGIN
    RETURN QUERY 
    SELECT sd.urun_id, SUM(sd.adet)::BIGINT
    FROM satis_detay sd
    GROUP BY sd.urun_id
    ORDER BY SUM(sd.adet) DESC;
END;
$$ LANGUAGE plpgsql;
