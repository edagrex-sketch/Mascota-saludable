-- ============================================================
-- Mascota Saludable — Esquema de Base de Datos (Supabase)
-- ============================================================
-- Ejecuta este script en el SQL Editor de tu proyecto Supabase.
-- ============================================================

-- ── 1. Extensión UUID ────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- TABLA: pets
-- ============================================================
CREATE TABLE IF NOT EXISTS pets (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name          TEXT NOT NULL,
  breed         TEXT NOT NULL DEFAULT '',
  age_years     INTEGER NOT NULL DEFAULT 0,
  weight_kg     DOUBLE PRECISION NOT NULL DEFAULT 0,
  photo_url     TEXT,
  status        TEXT NOT NULL DEFAULT 'healthy'
                  CHECK (status IN ('healthy', 'attention', 'critical')),
  notes         TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_pets_user_id ON pets(user_id);
CREATE INDEX IF NOT EXISTS idx_pets_status ON pets(status);
CREATE INDEX IF NOT EXISTS idx_pets_created_at ON pets(created_at DESC);

-- ── RLS: pets ────────────────────────────────────────────────
ALTER TABLE pets ENABLE ROW LEVEL SECURITY;

-- Los usuarios solo pueden ver sus propias mascotas
CREATE POLICY "Users can view own pets"
  ON pets FOR SELECT
  USING (auth.uid() = user_id);

-- Los usuarios pueden crear sus propias mascotas
CREATE POLICY "Users can create own pets"
  ON pets FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Los usuarios pueden actualizar sus propias mascotas
CREATE POLICY "Users can update own pets"
  ON pets FOR UPDATE
  USING (auth.uid() = user_id);

-- Los usuarios pueden eliminar sus propias mascotas
CREATE POLICY "Users can delete own pets"
  ON pets FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- TABLA: vaccines
-- ============================================================
CREATE TABLE IF NOT EXISTS vaccines (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pet_id            UUID NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
  name              TEXT NOT NULL,
  application_date  DATE NOT NULL,
  next_dose_date    DATE,
  veterinarian      TEXT,
  clinic            TEXT,
  batch_number      TEXT,
  certificate_url   TEXT,
  status            TEXT NOT NULL DEFAULT 'pending'
                      CHECK (status IN ('completed', 'pending', 'overdue')),
  notes             TEXT,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_vaccines_pet_id ON vaccines(pet_id);
CREATE INDEX IF NOT EXISTS idx_vaccines_status ON vaccines(status);
CREATE INDEX IF NOT EXISTS idx_vaccines_application_date ON vaccines(application_date DESC);
CREATE INDEX IF NOT EXISTS idx_vaccines_next_dose ON vaccines(next_dose_date)
  WHERE status != 'completed';

-- ── RLS: vaccines ───────────────────────────────────────────
ALTER TABLE vaccines ENABLE ROW LEVEL SECURITY;

-- Los usuarios pueden ver vacunas de sus mascotas
CREATE POLICY "Users can view own pet vaccines"
  ON vaccines FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM pets
      WHERE pets.id = vaccines.pet_id
        AND pets.user_id = auth.uid()
    )
  );

-- Los usuarios pueden crear vacunas para sus mascotas
CREATE POLICY "Users can create vaccines for own pets"
  ON vaccines FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM pets
      WHERE pets.id = vaccines.pet_id
        AND pets.user_id = auth.uid()
    )
  );

-- Los usuarios pueden actualizar vacunas de sus mascotas
CREATE POLICY "Users can update own pet vaccines"
  ON vaccines FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM pets
      WHERE pets.id = vaccines.pet_id
        AND pets.user_id = auth.uid()
    )
  );

-- Los usuarios pueden eliminar vacunas de sus mascotas
CREATE POLICY "Users can delete own pet vaccines"
  ON vaccines FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM pets
      WHERE pets.id = vaccines.pet_id
        AND pets.user_id = auth.uid()
    )
  );

-- ============================================================
-- TRIGGER: auto-update updated_at en pets
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_pets_updated_at ON pets;
CREATE TRIGGER trg_pets_updated_at
  BEFORE UPDATE ON pets
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- FEEDBACK: verificar tablas creadas
-- ============================================================
SELECT
  table_name,
  table_type
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('pets', 'vaccines')
ORDER BY table_name;
