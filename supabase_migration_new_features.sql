-- =============================================
-- Supabase Migration: New Features
-- Run this in Supabase Dashboard > SQL Editor
-- =============================================

-- 1. TARAWIH SCHEDULE TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS tarawih_schedule (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    ramadan_day INTEGER NOT NULL UNIQUE CHECK (ramadan_day >= 1 AND ramadan_day <= 30),
    imam_name VARCHAR(255),
    start_time TIME,
    rakaat INTEGER DEFAULT 20,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for quick lookup by day
CREATE INDEX IF NOT EXISTS idx_tarawih_ramadan_day ON tarawih_schedule(ramadan_day);

-- RLS policies
ALTER TABLE tarawih_schedule ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on tarawih_schedule"
    ON tarawih_schedule FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Allow authenticated write access on tarawih_schedule"
    ON tarawih_schedule FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- 2. KAJIAN TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS kajian (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    speaker VARCHAR(255),
    date DATE NOT NULL,
    time TIME,
    location VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for date-based queries
CREATE INDEX IF NOT EXISTS idx_kajian_date ON kajian(date);

-- RLS policies
ALTER TABLE kajian ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on kajian"
    ON kajian FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Allow authenticated write access on kajian"
    ON kajian FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- 3. INFAQ TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS infaq (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
    donor_name VARCHAR(255),
    message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for time-based queries
CREATE INDEX IF NOT EXISTS idx_infaq_created_at ON infaq(created_at DESC);

-- RLS policies
ALTER TABLE infaq ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on infaq"
    ON infaq FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Allow authenticated write access on infaq"
    ON infaq FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- 4. INFAQ TARGET TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS infaq_target (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    target_amount DECIMAL(15, 2) NOT NULL CHECK (target_amount > 0),
    description TEXT,
    year INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Only one active target at a time
CREATE UNIQUE INDEX IF NOT EXISTS idx_infaq_target_active 
    ON infaq_target(is_active) WHERE is_active = true;

-- RLS policies
ALTER TABLE infaq_target ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on infaq_target"
    ON infaq_target FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Allow authenticated write access on infaq_target"
    ON infaq_target FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- =============================================
-- VERIFICATION: Check tables created
-- =============================================
SELECT 
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public' 
AND table_name IN ('tarawih_schedule', 'kajian', 'infaq', 'infaq_target');
