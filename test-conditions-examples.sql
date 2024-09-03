
-- Create a table to store conditions data
CREATE TABLE conditions (
   time        TIMESTAMPTZ       NOT NULL,
   location    TEXT              NOT NULL,
   device      TEXT              NOT NULL,
   temperature DOUBLE PRECISION  NULL,
   humidity    DOUBLE PRECISION  NULL
);

-- Create a hypertable on the conditions table with a time-based partitioning of 7 days (default)
SELECT create_hypertable('conditions', by_range('time')); 

-- Insert some random data into the conditions table
INSERT INTO conditions (time, location, device, temperature, humidity)
SELECT
     NOW() - (random() * INTERVAL '7 Days'),
    (ARRAY['greenhouse', 'garage', 'office'])[1 + floor(random() * 3)::INTEGER],
    'sensor',
    20 + (random() * 15)::NUMERIC(5,2),  -- Temperature between 20°C and 35°C
    40 + (random() * 40)::NUMERIC(5,2)   -- Humidity between 40% and 80%
FROM generate_series(1, 1000); 

-- Insert a specific data point, this should create a new chunk 
INSERT INTO conditions (time, location, device, temperature, humidity)
VALUES ('2024-08-19 00:07:44.553474 +00:00', 'garage', 'sensor', 28.87, 68.46); 

-- set the compression options
ALTER TABLE conditions SET (
    timescaledb.compress,
    timescaledb.compress_orderby = 'time ASC'
);

-- disable compression
ALTER TABLE conditions SET (
    timescaledb.compress=false
);

-- add a compression policy to the conditions table, compressing data older than 7 days and starting the compression immediately
SELECT add_compression_policy('conditions', INTERVAL '7 days', initial_start := NOW());

-- remove the compression policy
SELECT remove_compression_policy('conditions'); 

-- Change the chunk time interval to 24 hours (1 day) for the conditions table 
-- https://docs.timescale.com/use-timescale/latest/hypertables/change-chunk-intervals/
SELECT set_chunk_time_interval('conditions', INTERVAL '24 hours');

-- Show all chunks in the conditions table
SELECT show_chunks('conditions');
