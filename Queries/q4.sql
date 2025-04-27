-- Set Ruth's last roll to 5
UPDATE Player
SET last_roll = 5
WHERE name = 'Ruth';

-- Move Ruth to new location (Crawford - location_id 9)
UPDATE Player
SET current_location_id = 9
WHERE name = 'Ruth';

