-- ============================================================================
-- DATASHEET TV (Direction Jean-Yves) — Schéma PostgreSQL, Storage & RLS
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Paramètres globaux du site
CREATE TABLE IF NOT EXISTS public.site_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_name TEXT NOT NULL DEFAULT 'Jean-Yves',
  hero_title TEXT NOT NULL DEFAULT 'DATASHEET TV — Vos moments, notre regard.',
  hero_subtitle TEXT NOT NULL DEFAULT 'Nous capturons vos émotions, sublimons vos événements et transformons vos plus beaux instants en souvenirs inoubliables.',
  about_text TEXT NOT NULL,
  logo_url TEXT NOT NULL DEFAULT '/images/logo_official.jpg',
  hero_image_url TEXT NOT NULL DEFAULT '/images/hero_wedding.jpg',
  hero_video_url TEXT,
  phone TEXT DEFAULT '+225 07 00 00 00 00',
  whatsapp TEXT DEFAULT '2250700000000',
  email TEXT DEFAULT 'contact@datasheet-tv.com',
  location TEXT DEFAULT 'Abidjan, Côte d''Ivoire',
  instagram_url TEXT,
  tiktok_url TEXT,
  facebook_url TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Galerie Photo & Vidéo
CREATE TABLE IF NOT EXISTS public.gallery_media (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL CHECK (category IN ('Mariages','Baptêmes','Anniversaires','Événements','Drone','Portraits')),
  media_type TEXT NOT NULL CHECK (media_type IN ('photo','video')),
  media_url TEXT NOT NULL,
  thumbnail_url TEXT,
  is_featured BOOLEAN DEFAULT false,
  is_published BOOLEAN DEFAULT true,
  display_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Packs Tarifaires
CREATE TABLE IF NOT EXISTS public.pricing_packs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  price_label TEXT NOT NULL DEFAULT 'Sur devis',
  features JSONB NOT NULL DEFAULT '[]'::jsonb,
  is_popular BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  display_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Réservations Clients
CREATE TABLE IF NOT EXISTS public.bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_name TEXT NOT NULL,
  client_phone TEXT NOT NULL,
  client_email TEXT NOT NULL,
  event_type TEXT NOT NULL,
  event_date DATE NOT NULL,
  event_location TEXT NOT NULL,
  selected_pack TEXT NOT NULL,
  message TEXT,
  status TEXT NOT NULL DEFAULT 'En attente' CHECK (status IN ('En attente','Confirmée','Terminée','Annulée')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Activation obligatoire de Row Level Security (RLS)
ALTER TABLE public.site_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gallery_media ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pricing_packs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Politiques RLS : Lecture publique sur les contenus publiés
CREATE POLICY "Public read site_settings" ON public.site_settings FOR SELECT USING (true);
CREATE POLICY "Public read published gallery" ON public.gallery_media FOR SELECT USING (is_published = true);
CREATE POLICY "Public read active packs" ON public.pricing_packs FOR SELECT USING (is_active = true);
CREATE POLICY "Public insert bookings" ON public.bookings FOR INSERT WITH CHECK (true);

-- Politiques RLS : Administration complète réservée aux administrateurs authentifiés via Supabase Auth
CREATE POLICY "Admin full access site_settings" ON public.site_settings FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Admin full access gallery" ON public.gallery_media FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Admin full access packs" ON public.pricing_packs FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Admin full access bookings" ON public.bookings FOR ALL USING (auth.role() = 'authenticated');

-- Configuration du Bucket Supabase Storage pour les photos et vidéos
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'datasheet-media',
  'datasheet-media',
  true,
  52428800, -- Limite de 50 Mo par fichier
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'video/mp4', 'video/webm']
) ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Public view media files" ON storage.objects
  FOR SELECT USING (bucket_id = 'datasheet-media');

CREATE POLICY "Admin upload/update/delete media files" ON storage.objects
  FOR ALL USING (bucket_id = 'datasheet-media' AND auth.role() = 'authenticated');
