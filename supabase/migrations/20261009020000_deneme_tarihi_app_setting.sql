INSERT INTO app_settings (key, value, updated_at)
VALUES ('deneme_sinavi_tarihi', '"2026-11-15T06:00:00.000Z"', now())
ON CONFLICT (key) DO NOTHING;
