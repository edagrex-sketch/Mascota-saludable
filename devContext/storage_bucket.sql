-- ============================================================
-- Mascota Saludable — Storage Bucket para Fotos de Mascotas
-- ============================================================
-- Ejecuta este script en el SQL Editor de tu proyecto Supabase
-- DESPUÉS de haber creado las tablas pets y vaccines.
-- ============================================================

-- Crear bucket público para fotos de perfil de mascotas
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'pet-photos',
  'pet-photos',
  true,
  5242880, -- 5 MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp']::text[]
)
ON CONFLICT (id) DO NOTHING;

-- ── RLS Policies ─────────────────────────────────────────────

-- Usuarios autenticados pueden subir fotos
CREATE POLICY "Users can upload pet photos"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'pet-photos'
  AND auth.role() = 'authenticated'
);

-- Usuarios pueden ver cualquier foto (bucket público)
CREATE POLICY "Anyone can view pet photos"
ON storage.objects FOR SELECT
USING (bucket_id = 'pet-photos');

-- Usuarios pueden actualizar sus propias fotos
CREATE POLICY "Users can update own pet photos"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'pet-photos'
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Usuarios pueden eliminar sus propias fotos
CREATE POLICY "Users can delete own pet photos"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'pet-photos'
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- ============================================================
-- FEEDBACK: verificar bucket creado
-- ============================================================
SELECT
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
FROM storage.buckets
WHERE id = 'pet-photos';
