-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

-- Create database for tournament.
CREATE DATABASE tournament;

-- Connect to tournament database.
\c tournament;

-- Create table for players with serial id and text name.
CREATE TABLE players ( id SERIAL PRIMARY KEY, name TEXT);

-- Create table for matches with serial id, winner id, and loser id.
CREATE TABLE matches ( id SERIAL PRIMARY KEY,
                       winner INTEGER REFERENCES players (id),
                       loser INTEGER REFERENCES players (id));

-- Create view for determining win count per player and their rank order
-- sorted in descending order by wins.
CREATE VIEW win_count as SELECT players.id, players.name,
                          count(matches.winner) AS wins,
                          row_number() OVER(ORDER BY count(matches.winner) DESC)
                         FROM players
                         LEFT JOIN matches
                         ON players.id = matches.winner
                         GROUP BY players.id
                         ORDER BY wins DESC;

-- Create view for determining total matches played per player sorted in
-- descending order by total matches played.
CREATE VIEW total_count as SELECT players.id, players.name,
                            count(matches.winner + matches.loser) AS total
                           FROM players
                           LEFT JOIN matches
                           ON players.id = matches.winner
                           OR players.id = matches.loser
                           GROUP BY players.id
                           ORDER BY total DESC;

-- Create view for id, name of odd-numbered rankings (non-divisble by 2) to be
-- paired against corresponding row_number of even-numbered rankings
CREATE VIEW odd_ranks as SELECT id, name,
                          row_number() OVER(ORDER BY row_number)
                         FROM win_count
                         WHERE row_number%2 != 0;

-- Create view for id, name of even-numbered rankings (divisble by 2) to be
-- paired against corresponding row_number of odd-numbered rankings 
CREATE VIEW even_ranks as SELECT id, name,
                           row_number() OVER(ORDER BY row_number)
                          FROM win_count
                          WHERE row_number%2 = 0;
