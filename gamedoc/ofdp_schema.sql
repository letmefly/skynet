-- mysql dump 10.13  distrib 5.5.46, for linux (x86_64)
--
-- host: localhost    database: ofdp_360
-- ------------------------------------------------------
-- server version 5.5.46

/*!40101 set @old_character_set_client=@@character_set_client */;
/*!40101 set @old_character_set_results=@@character_set_results */;
/*!40101 set @old_collation_connection=@@collation_connection */;
/*!40101 set names utf8 */;
/*!40103 set @old_time_zone=@@time_zone */;
/*!40103 set time_zone='+00:00' */;
/*!40014 set @old_unique_checks=@@unique_checks, unique_checks=0 */;
/*!40014 set @old_foreign_key_checks=@@foreign_key_checks, foreign_key_checks=0 */;
/*!40101 set @old_sql_mode=@@sql_mode, sql_mode='no_auto_value_on_zero' */;
/*!40111 set @old_sql_notes=@@sql_notes, sql_notes=0 */;

--
-- table structure for table `op_banners`
--

drop table if exists `op_banners`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_banners` (
  `banner_id` int(11) not null auto_increment,
  `name` varchar(50) not null,
  `image_url` varchar(2000) not null,
  `link_url` varchar(2000) not null,
  `callback_url` varchar(2000) not null,
  `start_date` varchar(40) not null,
  `end_date` varchar(40) not null,
  `reward_action` tinyint(4) not null comment '1:click, 2:join',
  `event_id` int(11) not null,
  `create_date` varchar(40) not null,
  `delete_date` varchar(40) default null,
  `is_delete` tinyint(4) not null,
  primary key (`banner_id`),
  key `start_date` (`start_date`,`end_date`,`is_delete`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_banners_users`
--

drop table if exists `op_banners_users`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_banners_users` (
  `user_id` int(11) not null,
  `banner_id` int(11) not null,
  `status` tinyint(4) not null comment '0:click, 1:reward done',
  `create_date` varchar(40) not null,
  `reward_date` varchar(40) default null,
  unique key `user_id` (`user_id`,`banner_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_buy`
--

drop table if exists `op_buy`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_buy` (
  `buy_id` bigint(20) not null auto_increment,
  `user_id` int(11) not null,
  `is_finish` tinyint(4) not null,
  `create_date` varchar(40) not null,
  `finish_date` varchar(40) default null,
  primary key (`buy_id`)
) engine=innodb auto_increment=6224 default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_events`
--

drop table if exists `op_events`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_events` (
  `event_id` int(11) not null auto_increment,
  `process_code` double not null,
  `title` varchar(200) not null,
  `event_detail` varchar(2000) not null,
  `start_date` varchar(40) not null,
  `end_date` varchar(40) not null,
  `user_count` int(11) not null,
  `create_date` varchar(40) not null,
  `update_date` varchar(40) default null,
  `delete_date` varchar(40) default null,
  `is_delete` tinyint(4) not null,
  primary key (`event_id`),
  key `menu_code` (`process_code`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_events_users`
--

drop table if exists `op_events_users`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_events_users` (
  `event_id` int(11) not null,
  `user_id` int(11) not null,
  `create_date` varchar(40) not null,
  key `event_id` (`event_id`,`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_game_item`
--

drop table if exists `op_game_item`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_game_item` (
  `item_info_id` int(11) not null,
  `item_type` tinyint(4) not null comment '1:character, 2:skill, 3:treasure',
  `name` varchar(40) not null,
  `grade` char(1) default null,
  `buy` text,
  `sell` text,
  `upgrade` text,
  primary key (`item_info_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_invites`
--

drop table if exists `op_invites`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_invites` (
  `user_id` int(11) not null,
  `invite_user_id` bigint(20) not null,
  `invite_date` varchar(40) not null,
  unique key `user_id` (`user_id`,`invite_user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_leagues_ranking_20150625`
--

drop table if exists `op_leagues_ranking_20150625`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_leagues_ranking_20150625` (
  `user_id` int(11) not null,
  `grade` int(11) not null,
  `group_id` int(11) not null,
  `score` int(11) not null,
  `reward_ok` tinyint(4) not null,
  unique key `user_id` (`user_id`,`grade`,`group_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_leagues_ranking_20150626`
--



--
-- table structure for table `op_log_game_end_20150701`
--

drop table if exists `op_log_game_end_20150701`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_log_game_end_20150701` (
  `play_code` bigint(20) not null,
  `user_id` int(11) not null,
  `clear_type` tinyint(4) not null,
  `score` int(11) not null,
  `max_combo` int(11) not null,
  `gain_money` int(11) not null,
  `gain_exp_point` int(11) not null,
  `end_date` varchar(40) not null,
  `kill_count` int(11) not null
) engine=archive default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_log_game_end_20150702`
--



--
-- table structure for table `op_log_game_start_20150701`
--

drop table if exists `op_log_game_start_20150701`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_log_game_start_20150701` (
  `play_code` bigint(20) not null,
  `user_id` int(11) not null,
  `stage_id` int(11) not null comment '0:survival',
  `level` int(11) not null,
  `character` varchar(4000) not null,
  `skills` varchar(4000) not null,
  `treasures` varchar(4000) not null,
  `items` varchar(4000) not null,
  `start_date` varchar(40) not null
) engine=archive default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_log_game_start_20150702`
--



--
-- table structure for table `op_managers`
--

drop table if exists `op_managers`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_managers` (
  `manager_id` int(11) not null auto_increment,
  `email` varchar(200) not null,
  `password` varchar(40) not null,
  `name` varchar(40) not null,
  `level` tinyint(4) not null,
  `create_date` varchar(40) not null,
  `update_date` varchar(40) default null,
  `login_date` varchar(40) default null,
  `create_ip` varchar(20) not null,
  `update_ip` varchar(20) default null,
  `login_ip` varchar(20) default null,
  primary key (`manager_id`),
  unique key `email` (`email`)
) engine=innodb auto_increment=4 default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_market_order`
--

drop table if exists `op_market_order`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_market_order` (
  `user_id` int(11) not null,
  `product_id` varchar(100) not null,
  `order_id` varchar(100) not null,
  `purchase_token` varchar(500) not null,
  `signature` varchar(500) not null,
  `receipt` text,
  `create_date` varchar(40) not null,
  unique key `order_id` (`order_id`),
  key `user_id` (`user_id`),
  key `product_id` (`product_id`),
  key `create_date` (`create_date`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_messages`
--

drop table if exists `op_messages`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_messages` (
  `message_id` bigint(20) not null auto_increment,
  `send_user_id` int(11) not null,
  `recieve_user_id` int(11) not null,
  `event_id` int(11) default null,
  `text_id` int(11) default null,
  `gift` varchar(4000) not null,
  `create_date` varchar(40) not null,
  `delete_date` varchar(40) default null,
  `create_ip` varchar(40) not null,
  `delete_ip` varchar(40) default null,
  `is_delete` tinyint(4) not null default '0',
  `msg_title` varchar(50) default null,
  primary key (`message_id`),
  key `send_user_id` (`send_user_id`,`recieve_user_id`),
  key `recieve_user_id` (`recieve_user_id`)
) engine=innodb auto_increment=22287 default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_notices`
--

drop table if exists `op_notices`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_notices` (
  `notice_id` int(11) not null auto_increment,
  `title` varchar(255) not null,
  `content` text not null,
  `manager_id` int(11) not null,
  `start_date` varchar(40) not null,
  `end_date` varchar(40) not null,
  `is_show` tinyint(4) not null,
  `create_date` varchar(40) not null,
  `update_date` varchar(40) default null,
  primary key (`notice_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_play_code_20150630`
--

drop table if exists `op_play_code_20150630`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_play_code_20150630` (
  `play_code` bigint(20) not null auto_increment,
  `user_id` int(11) not null,
  `stage_id` int(11) not null,
  `friend_user_id` int(11) default null,
  `is_finish` tinyint(4) not null,
  `continue_count` int(11) not null,
  `create_date` varchar(40) not null,
  primary key (`play_code`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_play_code_20150701`
--



--
-- table structure for table `op_play_code_20151120`
--

drop table if exists `op_play_code_20151120`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_play_code_20151120` (
  `play_code` bigint(20) not null auto_increment,
  `user_id` int(11) not null,
  `stage_id` int(11) not null,
  `friend_user_id` int(11) default null,
  `is_finish` tinyint(4) not null,
  `continue_count` int(11) not null,
  `create_date` varchar(40) not null,
  primary key (`play_code`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_push_messages`
--

drop table if exists `op_push_messages`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_push_messages` (
  `message_id` int(11) not null auto_increment,
  `title` varchar(255) not null,
  `message` varchar(255) not null,
  `send_date` date not null,
  `send_time` tinyint(4) not null,
  `finish_date` varchar(40) default null,
  `os_type` tinyint(4) not null comment '1:android, 2:ios',
  `total_user_count` int(11) not null,
  `success_count` int(11) default null,
  `create_date` varchar(40) not null,
  `delete_date` varchar(40) default null,
  `is_delete` tinyint(4) not null,
  primary key (`message_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users`
--

drop table if exists `op_users`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users` (
  `user_id` int(11) not null auto_increment,
  `email` varchar(200) not null,
  `password` varchar(40) not null,
  `nickname` varchar(100) not null,
  `level` int(11) not null,
  `exp_point` int(11) not null,
  `money` int(11) not null,
  `cash` int(11) not null,
  `heart` int(11) not null,
  `heart_time` varchar(40) default null,
  `lottery_point` int(11) not null,
  `lottery_high_coupon` int(11) not null,
  `lottery_coupon` int(11) not null,
  `character_id` bigint(20) not null,
  `skill_slot` tinyint(4) not null default '1',
  `treasure_slot` tinyint(4) not null default '1',
  `treasure_inventory` mediumint(9) not null,
  `best_score` int(11) not null,
  `invite_count` int(11) not null default '0',
  `review` tinyint(4) not null default '0',
  `agree_message` tinyint(4) not null default '1' comment '0:disagree, 1:agree',
  `status` tinyint(4) not null comment '0:inactive, 1:active, 9:block',
  `device` varchar(200) default null,
  `os_type` tinyint(4) not null,
  `os_version` varchar(50) not null,
  `market_type` tinyint(4) not null,
  `tutorial` tinyint(4) not null default '0',
  `attendance_count` tinyint(4) not null,
  `attendance_date` date not null,
  `push_id` varchar(400) not null,
  `cellphone` varchar(40) default null,
  `create_date` varchar(40) not null,
  `update_date` varchar(40) default null,
  `delete_date` varchar(40) default null,
  `login_date` varchar(40) default null,
  `create_ip` varchar(40) not null,
  `update_ip` varchar(40) default null,
  `delete_ip` varchar(40) default null,
  `login_ip` varchar(40) default null,
  `hack_count` int(11) default '0',
  `video_reborn_times` int(11) default '0',
  `watch_video_times` int(11) default '0',
  `vip_end_date` varchar(40) default null,
  `version` int(11) not null default '20',
  primary key (`user_id`),
  key `email` (`email`),
  key `nickname` (`nickname`)
) engine=innodb auto_increment=5831 default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_achievements_0`
--

drop table if exists `op_users_achievements_0`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_achievements_0` (
  `achievement_info_id` int(11) not null,
  `user_id` int(11) not null,
  `progress` int(11) not null,
  `reward_ok` tinyint(4) not null,
  `create_date` varchar(40) not null,
  unique key `achievement_info_id` (`achievement_info_id`,`user_id`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_achievements_1`
--

drop table if exists `op_users_achievements_1`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_achievements_1` (
  `achievement_info_id` int(11) not null,
  `user_id` int(11) not null,
  `progress` int(11) not null,
  `reward_ok` tinyint(4) not null,
  `create_date` varchar(40) not null,
  unique key `achievement_info_id` (`achievement_info_id`,`user_id`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_achievements_2`
--

drop table if exists `op_users_achievements_2`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_achievements_2` (
  `achievement_info_id` int(11) not null,
  `user_id` int(11) not null,
  `progress` int(11) not null,
  `reward_ok` tinyint(4) not null,
  `create_date` varchar(40) not null,
  unique key `achievement_info_id` (`achievement_info_id`,`user_id`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_achievements_3`
--

drop table if exists `op_users_achievements_3`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_achievements_3` (
  `achievement_info_id` int(11) not null,
  `user_id` int(11) not null,
  `progress` int(11) not null,
  `reward_ok` tinyint(4) not null,
  `create_date` varchar(40) not null,
  unique key `achievement_info_id` (`achievement_info_id`,`user_id`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_achievements_4`
--

drop table if exists `op_users_achievements_4`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_achievements_4` (
  `achievement_info_id` int(11) not null,
  `user_id` int(11) not null,
  `progress` int(11) not null,
  `reward_ok` tinyint(4) not null,
  `create_date` varchar(40) not null,
  unique key `achievement_info_id` (`achievement_info_id`,`user_id`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_achievements_5`
--

drop table if exists `op_users_achievements_5`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_achievements_5` (
  `achievement_info_id` int(11) not null,
  `user_id` int(11) not null,
  `progress` int(11) not null,
  `reward_ok` tinyint(4) not null,
  `create_date` varchar(40) not null,
  unique key `achievement_info_id` (`achievement_info_id`,`user_id`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_achievements_6`
--

drop table if exists `op_users_achievements_6`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_achievements_6` (
  `achievement_info_id` int(11) not null,
  `user_id` int(11) not null,
  `progress` int(11) not null,
  `reward_ok` tinyint(4) not null,
  `create_date` varchar(40) not null,
  unique key `achievement_info_id` (`achievement_info_id`,`user_id`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_achievements_7`
--

drop table if exists `op_users_achievements_7`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_achievements_7` (
  `achievement_info_id` int(11) not null,
  `user_id` int(11) not null,
  `progress` int(11) not null,
  `reward_ok` tinyint(4) not null,
  `create_date` varchar(40) not null,
  unique key `achievement_info_id` (`achievement_info_id`,`user_id`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_achievements_8`
--

drop table if exists `op_users_achievements_8`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_achievements_8` (
  `achievement_info_id` int(11) not null,
  `user_id` int(11) not null,
  `progress` int(11) not null,
  `reward_ok` tinyint(4) not null,
  `create_date` varchar(40) not null,
  unique key `achievement_info_id` (`achievement_info_id`,`user_id`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_achievements_9`
--

drop table if exists `op_users_achievements_9`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_achievements_9` (
  `achievement_info_id` int(11) not null,
  `user_id` int(11) not null,
  `progress` int(11) not null,
  `reward_ok` tinyint(4) not null,
  `create_date` varchar(40) not null,
  unique key `achievement_info_id` (`achievement_info_id`,`user_id`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_characters`
--

drop table if exists `op_users_characters`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_characters` (
  `character_id` bigint(20) not null auto_increment,
  `character_info_id` int(11) not null,
  `user_id` int(11) not null,
  `level` int(11) not null,
  `create_date` varchar(40) not null,
  primary key (`character_id`),
  unique key `character_info_id` (`character_info_id`,`user_id`),
  key `user_id` (`user_id`)
) engine=innodb auto_increment=6024 default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_friends`
--

drop table if exists `op_users_friends`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_friends` (
  `user_id` int(11) not null,
  `friend_user_id` bigint(20) not null,
  `create_date` varchar(40) not null,
  `delete_date` varchar(40) default null,
  `play_date` varchar(40) default null,
  `status` tinyint(4) not null ,
  unique key `user_id` (`user_id`,`friend_user_id`),
  key `user_id_2` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_instant_items`
--

drop table if exists `op_users_instant_items`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_instant_items` (
  `user_id` int(11) not null,
  `instant_item_id` int(11) not null,
  `amount` int(11) not null,
  unique key `user_id` (`user_id`,`instant_item_id`),
  key `user_id_2` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_missions_20150701`
--

drop table if exists `op_users_missions_20150701`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_missions_20150701` (
  `mission_id` bigint(20) not null auto_increment,
  `mission_info_id` int(11) not null,
  `user_id` int(11) not null,
  `is_clear` tinyint(4) not null,
  `update_date` varchar(40) default null,
  primary key (`mission_id`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_missions_20150702`
--


--
-- table structure for table `op_users_skills`
--

drop table if exists `op_users_skills`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_skills` (
  `skill_id` bigint(20) not null auto_increment,
  `skill_info_id` int(11) not null,
  `user_id` int(11) not null,
  `level` int(11) not null,
  `slot_number` tinyint(4) default null,
  `create_date` varchar(40) not null,
  primary key (`skill_id`),
  unique key `skill_info_id` (`skill_info_id`,`user_id`),
  key `user_id` (`user_id`)
) engine=innodb auto_increment=7287 default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_stages_0`
--

drop table if exists `op_users_stages_0`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_stages_0` (
  `stage_id` int(11) not null,
  `user_id` int(11) not null,
  `clear_type` tinyint(4) not null,
  `best_score` int(11) not null default '0',
  `clear_count` int(11) not null default '0',
  `create_date` varchar(40) not null,
  `update_date` varchar(40) default null,
  `perfect` tinyint(1) default null,
  unique key `stage_id` (`stage_id`,`user_id`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_stages_1`
--

drop table if exists `op_users_stages_1`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_stages_1` (
  `stage_id` int(11) not null,
  `user_id` int(11) not null,
  `clear_type` tinyint(4) not null,
  `best_score` int(11) not null default '0',
  `clear_count` int(11) not null default '0',
  `create_date` varchar(40) not null,
  `update_date` varchar(40) default null,
  `perfect` tinyint(1) default null,
  unique key `stage_id` (`stage_id`,`user_id`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_stages_2`
--

drop table if exists `op_users_stages_2`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_stages_2` (
  `stage_id` int(11) not null,
  `user_id` int(11) not null,
  `clear_type` tinyint(4) not null,
  `best_score` int(11) not null default '0',
  `clear_count` int(11) not null default '0',
  `create_date` varchar(40) not null,
  `update_date` varchar(40) default null,
  `perfect` tinyint(1) default null,
  unique key `stage_id` (`stage_id`,`user_id`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_stages_3`
--

drop table if exists `op_users_stages_3`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_stages_3` (
  `stage_id` int(11) not null,
  `user_id` int(11) not null,
  `clear_type` tinyint(4) not null,
  `best_score` int(11) not null default '0',
  `clear_count` int(11) not null default '0',
  `create_date` varchar(40) not null,
  `update_date` varchar(40) default null,
  `perfect` tinyint(1) default null,
  unique key `stage_id` (`stage_id`,`user_id`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_stages_4`
--

drop table if exists `op_users_stages_4`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_stages_4` (
  `stage_id` int(11) not null,
  `user_id` int(11) not null,
  `clear_type` tinyint(4) not null,
  `best_score` int(11) not null default '0',
  `clear_count` int(11) not null default '0',
  `create_date` varchar(40) not null,
  `update_date` varchar(40) default null,
  `perfect` tinyint(1) default null,
  unique key `stage_id` (`stage_id`,`user_id`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_stages_5`
--

drop table if exists `op_users_stages_5`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_stages_5` (
  `stage_id` int(11) not null,
  `user_id` int(11) not null,
  `clear_type` tinyint(4) not null,
  `best_score` int(11) not null default '0',
  `clear_count` int(11) not null default '0',
  `create_date` varchar(40) not null,
  `update_date` varchar(40) default null,
  `perfect` tinyint(1) default null,
  unique key `stage_id` (`stage_id`,`user_id`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_stages_6`
--

drop table if exists `op_users_stages_6`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_stages_6` (
  `stage_id` int(11) not null,
  `user_id` int(11) not null,
  `clear_type` tinyint(4) not null,
  `best_score` int(11) not null default '0',
  `clear_count` int(11) not null default '0',
  `create_date` varchar(40) not null,
  `update_date` varchar(40) default null,
  `perfect` tinyint(1) default null,
  unique key `stage_id` (`stage_id`,`user_id`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_stages_7`
--

drop table if exists `op_users_stages_7`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_stages_7` (
  `stage_id` int(11) not null,
  `user_id` int(11) not null,
  `clear_type` tinyint(4) not null,
  `best_score` int(11) not null default '0',
  `clear_count` int(11) not null default '0',
  `create_date` varchar(40) not null,
  `update_date` varchar(40) default null,
  `perfect` tinyint(1) default null,
  unique key `stage_id` (`stage_id`,`user_id`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_stages_8`
--

drop table if exists `op_users_stages_8`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_stages_8` (
  `stage_id` int(11) not null,
  `user_id` int(11) not null,
  `clear_type` tinyint(4) not null,
  `best_score` int(11) not null default '0',
  `clear_count` int(11) not null default '0',
  `create_date` varchar(40) not null,
  `update_date` varchar(40) default null,
  `perfect` tinyint(1) default null,
  unique key `stage_id` (`stage_id`,`user_id`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_stages_9`
--

drop table if exists `op_users_stages_9`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_stages_9` (
  `stage_id` int(11) not null,
  `user_id` int(11) not null,
  `clear_type` tinyint(4) not null,
  `best_score` int(11) not null default '0',
  `clear_count` int(11) not null default '0',
  `create_date` varchar(40) not null,
  `update_date` varchar(40) default null,
  `perfect` tinyint(1) default null,
  unique key `stage_id` (`stage_id`,`user_id`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;

--
-- table structure for table `op_users_treasures`
--

drop table if exists `op_users_treasures`;
/*!40101 set @saved_cs_client     = @@character_set_client */;
/*!40101 set character_set_client = utf8 */;
create table `op_users_treasures` (
  `treasure_id` bigint(20) not null auto_increment,
  `treasure_info_id` int(11) not null,
  `user_id` int(11) not null,
  `level` int(11) not null,
  `slot_number` tinyint(4) default null,
  `create_date` varchar(40) not null,
  `delete_date` varchar(40) default null,
  `is_delete` tinyint(4) default null,
  primary key (`treasure_id`),
  key `user_id` (`user_id`)
) engine=innodb auto_increment=17420 default charset=utf8;
/*!40101 set character_set_client = @saved_cs_client */;
/*!40103 set time_zone=@old_time_zone */;

/*!40101 set sql_mode=@old_sql_mode */;
/*!40014 set foreign_key_checks=@old_foreign_key_checks */;
/*!40014 set unique_checks=@old_unique_checks */;
/*!40101 set character_set_client=@old_character_set_client */;
/*!40101 set character_set_results=@old_character_set_results */;
/*!40101 set collation_connection=@old_collation_connection */;
/*!40111 set sql_notes=@old_sql_notes */;

-- dump completed on 2015-11-17 15:21:26
