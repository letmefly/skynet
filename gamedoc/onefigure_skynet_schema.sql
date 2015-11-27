-- MySQL dump 10.13  Distrib 5.6.24, for osx10.10 (x86_64)
--
-- Host: localhost    Database: onefigure_skynet
-- ------------------------------------------------------
-- Server version	5.6.24

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `op_events`
--

DROP TABLE IF EXISTS `op_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_events` (
  `event_id` int(11) NOT NULL AUTO_INCREMENT,
  `process_code` double NOT NULL,
  `title` varchar(200) NOT NULL,
  `event_detail` varchar(2000) NOT NULL,
  `start_date` varchar(40) NOT NULL,
  `end_date` varchar(40) NOT NULL,
  `user_count` int(11) NOT NULL,
  `create_date` varchar(40) NOT NULL,
  `update_date` varchar(40) DEFAULT NULL,
  `delete_date` varchar(40) DEFAULT NULL,
  `is_delete` tinyint(4) NOT NULL,
  PRIMARY KEY (`event_id`),
  KEY `menu_code` (`process_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_messages`
--

DROP TABLE IF EXISTS `op_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_messages` (
  `message_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `send_user_id` int(11) NOT NULL,
  `recieve_user_id` int(11) NOT NULL,
  `event_id` int(11) DEFAULT NULL,
  `text_id` int(11) DEFAULT NULL,
  `gift` varchar(4000) NOT NULL,
  `create_date` varchar(40) NOT NULL,
  `delete_date` varchar(40) DEFAULT NULL,
  `create_ip` varchar(40) NOT NULL,
  `delete_ip` varchar(40) DEFAULT NULL,
  `is_delete` tinyint(4) NOT NULL DEFAULT '0',
  `msg_title` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`message_id`),
  KEY `send_user_id` (`send_user_id`,`recieve_user_id`),
  KEY `recieve_user_id` (`recieve_user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22287 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_notices`
--

DROP TABLE IF EXISTS `op_notices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_notices` (
  `notice_id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `manager_id` int(11) NOT NULL,
  `start_date` varchar(40) NOT NULL,
  `end_date` varchar(40) NOT NULL,
  `is_show` tinyint(4) NOT NULL,
  `create_date` varchar(40) NOT NULL,
  `update_date` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`notice_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users`
--

DROP TABLE IF EXISTS `op_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(200) NOT NULL,
  `password` varchar(40) NOT NULL,
  `nickname` varchar(100) NOT NULL,
  `level` int(11) DEFAULT '0',
  `exp_point` int(11) DEFAULT '0',
  `money` int(11) DEFAULT '0',
  `cash` int(11) DEFAULT '0',
  `heart` int(11) DEFAULT '0',
  `heart_time` varchar(50) DEFAULT NULL,
  `lottery_point` int(11) DEFAULT '0',
  `lottery_high_coupon` int(11) DEFAULT '0',
  `lottery_coupon` int(11) DEFAULT '0',
  `character_id` bigint(20) DEFAULT '0',
  `skill_slot` tinyint(4) NOT NULL DEFAULT '1',
  `treasure_slot` tinyint(4) NOT NULL DEFAULT '1',
  `treasure_inventory` mediumint(9) NOT NULL,
  `best_score` int(11) DEFAULT '0',
  `invite_count` int(11) NOT NULL DEFAULT '0',
  `review` tinyint(4) NOT NULL DEFAULT '0',
  `agree_message` tinyint(4) NOT NULL DEFAULT '1' COMMENT '0:Disagree, 1:Agree',
  `status` tinyint(4) NOT NULL COMMENT '0:INACTIVE, 1:ACTIVE, 9:BLOCK',
  `device` varchar(200) DEFAULT NULL,
  `os_type` tinyint(4) DEFAULT '0',
  `os_version` varchar(50) NOT NULL,
  `market_type` tinyint(4) DEFAULT '0',
  `tutorial` tinyint(4) NOT NULL DEFAULT '0',
  `attendance_count` tinyint(4) DEFAULT '0',
  `attendance_date` varchar(40) DEFAULT NULL,
  `push_id` varchar(400) DEFAULT NULL,
  `cellphone` varchar(40) DEFAULT NULL,
  `create_date` varchar(50) DEFAULT NULL,
  `update_date` varchar(50) DEFAULT NULL,
  `delete_date` varchar(50) DEFAULT NULL,
  `login_date` varchar(50) DEFAULT NULL,
  `create_ip` varchar(40) DEFAULT NULL,
  `update_ip` varchar(40) DEFAULT NULL,
  `delete_ip` varchar(40) DEFAULT NULL,
  `login_ip` varchar(40) DEFAULT NULL,
  `hack_count` int(11) DEFAULT '0',
  `video_reborn_times` int(11) DEFAULT '0',
  `watch_video_times` int(11) DEFAULT '0',
  `vip_end_date` datetime DEFAULT NULL,
  `version` int(11) NOT NULL DEFAULT '20',
  PRIMARY KEY (`user_id`),
  KEY `email` (`email`),
  KEY `nickname` (`nickname`)
) ENGINE=InnoDB AUTO_INCREMENT=5839 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_achievements_0`
--

DROP TABLE IF EXISTS `op_users_achievements_0`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_achievements_0` (
  `achievement_info_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `progress` int(11) NOT NULL,
  `reward_ok` tinyint(4) NOT NULL,
  `create_date` varchar(40) NOT NULL,
  UNIQUE KEY `achievement_info_id` (`achievement_info_id`,`user_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_achievements_1`
--

DROP TABLE IF EXISTS `op_users_achievements_1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_achievements_1` (
  `achievement_info_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `progress` int(11) NOT NULL,
  `reward_ok` tinyint(4) NOT NULL,
  `create_date` varchar(40) NOT NULL,
  UNIQUE KEY `achievement_info_id` (`achievement_info_id`,`user_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_achievements_2`
--

DROP TABLE IF EXISTS `op_users_achievements_2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_achievements_2` (
  `achievement_info_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `progress` int(11) NOT NULL,
  `reward_ok` tinyint(4) NOT NULL,
  `create_date` varchar(40) NOT NULL,
  UNIQUE KEY `achievement_info_id` (`achievement_info_id`,`user_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_achievements_3`
--

DROP TABLE IF EXISTS `op_users_achievements_3`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_achievements_3` (
  `achievement_info_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `progress` int(11) NOT NULL,
  `reward_ok` tinyint(4) NOT NULL,
  `create_date` varchar(40) NOT NULL,
  UNIQUE KEY `achievement_info_id` (`achievement_info_id`,`user_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_achievements_4`
--

DROP TABLE IF EXISTS `op_users_achievements_4`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_achievements_4` (
  `achievement_info_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `progress` int(11) NOT NULL,
  `reward_ok` tinyint(4) NOT NULL,
  `create_date` varchar(40) NOT NULL,
  UNIQUE KEY `achievement_info_id` (`achievement_info_id`,`user_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_achievements_5`
--

DROP TABLE IF EXISTS `op_users_achievements_5`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_achievements_5` (
  `achievement_info_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `progress` int(11) NOT NULL,
  `reward_ok` tinyint(4) NOT NULL,
  `create_date` varchar(40) NOT NULL,
  UNIQUE KEY `achievement_info_id` (`achievement_info_id`,`user_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_achievements_6`
--

DROP TABLE IF EXISTS `op_users_achievements_6`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_achievements_6` (
  `achievement_info_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `progress` int(11) NOT NULL,
  `reward_ok` tinyint(4) NOT NULL,
  `create_date` varchar(40) NOT NULL,
  UNIQUE KEY `achievement_info_id` (`achievement_info_id`,`user_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_achievements_7`
--

DROP TABLE IF EXISTS `op_users_achievements_7`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_achievements_7` (
  `achievement_info_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `progress` int(11) NOT NULL,
  `reward_ok` tinyint(4) NOT NULL,
  `create_date` varchar(40) NOT NULL,
  UNIQUE KEY `achievement_info_id` (`achievement_info_id`,`user_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_achievements_8`
--

DROP TABLE IF EXISTS `op_users_achievements_8`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_achievements_8` (
  `achievement_info_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `progress` int(11) NOT NULL,
  `reward_ok` tinyint(4) NOT NULL,
  `create_date` varchar(40) NOT NULL,
  UNIQUE KEY `achievement_info_id` (`achievement_info_id`,`user_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_achievements_9`
--

DROP TABLE IF EXISTS `op_users_achievements_9`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_achievements_9` (
  `achievement_info_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `progress` int(11) NOT NULL,
  `reward_ok` tinyint(4) NOT NULL,
  `create_date` varchar(40) NOT NULL,
  UNIQUE KEY `achievement_info_id` (`achievement_info_id`,`user_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_characters`
--

DROP TABLE IF EXISTS `op_users_characters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_characters` (
  `character_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `character_info_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  `create_date` varchar(40) NOT NULL,
  PRIMARY KEY (`character_id`),
  UNIQUE KEY `character_info_id` (`character_info_id`,`user_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6024 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_friends`
--

DROP TABLE IF EXISTS `op_users_friends`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_friends` (
  `user_id` int(11) NOT NULL,
  `friend_user_id` bigint(20) NOT NULL,
  `create_date` varchar(40) NOT NULL,
  `delete_date` varchar(40) DEFAULT NULL,
  `play_date` varchar(40) DEFAULT NULL,
  `status` tinyint(4) NOT NULL,
  UNIQUE KEY `user_id` (`user_id`,`friend_user_id`),
  KEY `user_id_2` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_instant_items`
--

DROP TABLE IF EXISTS `op_users_instant_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_instant_items` (
  `user_id` int(11) NOT NULL,
  `instant_item_id` int(11) NOT NULL,
  `amount` int(11) NOT NULL,
  UNIQUE KEY `user_id` (`user_id`,`instant_item_id`),
  KEY `user_id_2` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_skills`
--

DROP TABLE IF EXISTS `op_users_skills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_skills` (
  `skill_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `skill_info_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  `slot_number` tinyint(4) DEFAULT NULL,
  `create_date` varchar(40) NOT NULL,
  PRIMARY KEY (`skill_id`),
  UNIQUE KEY `skill_info_id` (`skill_info_id`,`user_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7287 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_treasures`
--

DROP TABLE IF EXISTS `op_users_treasures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_treasures` (
  `treasure_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `treasure_info_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  `slot_number` tinyint(4) DEFAULT NULL,
  `create_date` varchar(40) NOT NULL,
  `delete_date` varchar(40) DEFAULT NULL,
  `is_delete` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`treasure_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17420 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-11-27 16:53:35
