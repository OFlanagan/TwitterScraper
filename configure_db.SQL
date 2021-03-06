--this is a work in progress file, the goal is to have a single script to run to build the database
-- need to add indices to user_id, status_id, created_at
create index rtweet_users_idx
on rtweet_table (user_id);

create index rtweet_status_idx
on rtweet_table (status_id);

create index rtweet_created_date_idx
on rtweet_table (created_at);

create index word_count_tweetdate_idx
on word_count (tweetdate);

create unique index word_count_tweetdate_search_query_word_unique_idx
on word_count (tweetdate,search_query,word);

create table row_count
(source_table text,
n integer
);

insert into row_count
(source_table, n)
values ('rtweet_table',0);

create index word_count_unaggregated on rtweet_table (word_count_aggregated)
where word_count_aggregated is not true;
