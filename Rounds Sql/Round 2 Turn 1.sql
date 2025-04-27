-- Set Gareth's last roll to 4
UPDATE Player
SET last_roll = 4
WHERE name = 'Gareth';

-- Move Gareth to new location (RAG 1 - location_id 7)
UPDATE Player
SET current_location_id = 7
WHERE name = 'Gareth';

