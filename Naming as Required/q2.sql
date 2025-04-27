-- Set Uli's last roll to 5
UPDATE Player
SET last_roll = 5
WHERE name = 'Uli';

-- Move Uli to new location (RAG 1 - location_id 7)
UPDATE Player
SET current_location_id = 7
WHERE name = 'Uli';

