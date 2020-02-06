--this is a work in progress file, the goal is to have a single script to run to build the database
-- need to add indices to user_id, status_id, created_at
create index rtweet_users_idx
on rtweet_table (user_id);

create index rtweet_status_idx
on rtweet_table (status_id);

create index rtweet_created_date_idx
on rtweet_table (created_at);
