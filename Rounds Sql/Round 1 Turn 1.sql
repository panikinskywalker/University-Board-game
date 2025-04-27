-- Set Gareth's last roll to 4
UPDATE Player
SET last_roll = 4
WHERE name = 'Gareth';

-- Move Gareth to new location (IT - location_id 3)
UPDATE Player
SET current_location_id = 3
WHERE name = 'Gareth';

