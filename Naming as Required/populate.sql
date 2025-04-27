--Populate the tables according to the current board
--Populate

INSERT INTO Token (token_id, token_name) VALUES 
    (1, 'Certificate'), 
    (2, 'Mortarboard'), 
    (3, 'Book'), 
    (4, 'Pen'), 
    (5, 'Laptop'), 
    (6, 'Gown');


INSERT INTO Location (location_id, location_name, location_type) VALUES 
    (1, 'Welcome Week', 'Corner'), 
    (2, 'Kilburn', 'Building'), 
    (3, 'IT', 'Building'), 
    (4, 'Hearing 1', 'Hearing'), 
    (5, 'Uni Place', 'Building'), 
    (6, 'AMBS', 'Building'), 
    (7, 'RAG 1', 'RAG'), 
    (8, 'Visitor', 'Corner'), 
    (9, 'Crawford', 'Building'), 
    (10, 'Sugden', 'Building'), 
    (11, 'Ali G', 'Corner'), 
    (12, 'Shopping Precinct', 'Building'), 
    (13, 'MECD', 'Building'), 
    (14, 'RAG 2', 'RAG'), 
    (15, 'Library', 'Building'), 
    (16, 'Sam Alex', 'Building'), 
    (17, 'Hearing 2', 'Hearing'), 
    (18, 'You are suspended', 'Corner'), 
    (19, 'Museum', 'Building'), 
    (20, 'Whitworth hall', 'Building');



INSERT INTO Player (player_id, name, token_name, credits, current_location_id) VALUES 
    (1, 'Gareth', 'Certificate', 345, 19), 
    (2, 'Uli', 'Mortarboard', 590, 2), 
    (3, 'Pradyumn', 'Book', 465, 6), 
    (4, 'Ruth', 'Pen', 360, 4);


INSERT INTO Building (building_id, building_name, tuition_fee, color, owner_id, location_id) VALUES 
    (1, 'Kilburn', 15, 'Green', 4, 2), 
    (2, 'IT', 15, 'Green', 1, 3), 
    (3, 'Uni Place', 25, 'Orange', 1, 5), 
    (4, 'AMBS', 25, 'Orange', 2, 6), 
    (5, 'Crawford', 30, 'Blue', 3, 9), 
    (6, 'Sugden', 30, 'Blue', 1, 10), 
    (7, 'Shopping Precinct', 35, 'Brown', NULL, 12), 
    (8, 'MECD', 35, 'Brown', 2, 13), 
    (9, 'Library', 40, 'Grey', 3, 15), 
    (10, 'Sam Alex', 40, 'Grey', NULL, 16), 
    (11, 'Museum', 50, 'Black', 3, 19), 
    (12, 'Whitworth hall', 50, 'Black', 4, 20);


INSERT INTO Specials (special_id, special_name, description, credits_change, location_id) VALUES 
    (7, 'RAG 1', 'You win a fancy dress competition. Awarded 15 credits.', 15, 7), 
    (14, 'RAG 2', 'You receive a bursary and share it with your friends. Give all other players 10 credits.', -10, 14), 
    (4, 'Hearing 1', 'You are found guilty of academic malpractice. Fined 20 credits.', -20, 4), 
    (17, 'Hearing 2', 'You are in rent arrears. Fined 25 credits.', -25, 17);



