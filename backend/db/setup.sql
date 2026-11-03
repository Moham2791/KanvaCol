CREATE USER kanvacol WITH PASSWORD 'dev';
CREATE DATABASE kanvacol OWNER kanvacol;

--Command to run this SQL command:
-- cd D:\KanvaCol
-- & "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -h 127.0.0.1 -f backend\db\setup.sql
-- start the application
-- draw something and refresh the front end after 2 secs
-- the picture should remain on the front end as a proof
-- of database auto-saving the progress now