-- Supabase Migration Script for Takjil Donors Table
-- Run this in your Supabase SQL Editor

-- Create the takjil_donors table
CREATE TABLE IF NOT EXISTS takjil_donors (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    donor_name VARCHAR(255) NOT NULL,
    ramadan_day INTEGER NOT NULL CHECK (ramadan_day >= 1 AND ramadan_day <= 30),
    description TEXT,
    contact VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries by ramadan_day
CREATE INDEX idx_takjil_donors_ramadan_day ON takjil_donors(ramadan_day);

-- Enable Row Level Security
ALTER TABLE takjil_donors ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can read
CREATE POLICY "Allow public read access" ON takjil_donors
    FOR SELECT USING (true);

-- Policy: Only authenticated users can insert/update/delete
CREATE POLICY "Allow authenticated users to insert" ON takjil_donors
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users to update" ON takjil_donors
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users to delete" ON takjil_donors
    FOR DELETE USING (auth.role() = 'authenticated');

-- Sample data (optional - remove in production)
-- INSERT INTO takjil_donors (donor_name, ramadan_day, description) VALUES
--     ('Keluarga Bpk. Ahmad', 1, 'Kolak & Kurma'),
--     ('Keluarga Ibu Fatimah', 1, 'Gorengan & Es Teh'),
--     ('Keluarga Bpk. Mahmud', 2, 'Bubur Sumsum'),
--     ('Keluarga Bpk. Ali', 3, 'Takjil Lengkap');
