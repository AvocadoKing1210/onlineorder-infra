-- Enable Realtime for the order table
-- This allows Supabase Realtime subscriptions to receive updates
-- Run this in Supabase SQL Editor after creating the table

-- Method 1: Add table to replication publication (Required)
ALTER PUBLICATION supabase_realtime ADD TABLE "order";

-- Method 2: Set replica identity to FULL (Required for UPDATE/DELETE events)
-- This ensures UPDATE and DELETE events include complete row data
-- Without this, UPDATE events may not include all column changes
ALTER TABLE "order" REPLICA IDENTITY FULL;

-- Verify the table is added to replication
-- Run this query to check:
-- SELECT * FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'order';

-- IMPORTANT: After running this SQL, you may also need to:
-- 1. Go to Supabase Dashboard → Database → Replication
-- 2. Find the "order" table in the list
-- 3. Toggle the switch to enable replication
-- 
-- Note: Realtime requires the table to be in the supabase_realtime publication
-- and replication must be enabled in the dashboard for changes to be broadcast.

