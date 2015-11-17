-- MySQL dump 10.13  Distrib 5.5.46, for Linux (x86_64)
--
-- Host: localhost    Database: ofdp_360
-- ------------------------------------------------------
-- Server version	5.5.46

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
-- Table structure for table `op_banners`
--

DROP TABLE IF EXISTS `op_banners`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_banners` (
  `BANNER_ID` int(11) NOT NULL AUTO_INCREMENT,
  `NAME` varchar(50) NOT NULL,
  `IMAGE_URL` varchar(2000) NOT NULL,
  `LINK_URL` varchar(2000) NOT NULL,
  `CALLBACK_URL` varchar(2000) NOT NULL,
  `START_DATE` datetime NOT NULL,
  `END_DATE` datetime NOT NULL,
  `REWARD_ACTION` tinyint(4) NOT NULL COMMENT '1:Click, 2:Join',
  `EVENT_ID` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  `DELETE_DATE` datetime DEFAULT NULL,
  `IS_DELETE` tinyint(4) NOT NULL,
  PRIMARY KEY (`BANNER_ID`),
  KEY `START_DATE` (`START_DATE`,`END_DATE`,`IS_DELETE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_banners_users`
--

DROP TABLE IF EXISTS `op_banners_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_banners_users` (
  `USER_ID` int(11) NOT NULL,
  `BANNER_ID` int(11) NOT NULL,
  `STATUS` tinyint(4) NOT NULL COMMENT '0:Click, 1:Reward Done',
  `CREATE_DATE` datetime NOT NULL,
  `REWARD_DATE` datetime DEFAULT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`BANNER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_buy`
--

DROP TABLE IF EXISTS `op_buy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_buy` (
  `BUY_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `USER_ID` int(11) NOT NULL,
  `IS_FINISH` tinyint(4) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  `FINISH_DATE` datetime DEFAULT NULL,
  PRIMARY KEY (`BUY_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=6224 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_events`
--

DROP TABLE IF EXISTS `op_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_events` (
  `EVENT_ID` int(11) NOT NULL AUTO_INCREMENT,
  `PROCESS_CODE` double NOT NULL,
  `TITLE` varchar(200) NOT NULL,
  `EVENT_DETAIL` varchar(2000) NOT NULL,
  `START_DATE` datetime NOT NULL,
  `END_DATE` datetime NOT NULL,
  `USER_COUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  `DELETE_DATE` datetime DEFAULT NULL,
  `IS_DELETE` tinyint(4) NOT NULL,
  PRIMARY KEY (`EVENT_ID`),
  KEY `MENU_CODE` (`PROCESS_CODE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_events_users`
--

DROP TABLE IF EXISTS `op_events_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_events_users` (
  `EVENT_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  KEY `EVENT_ID` (`EVENT_ID`,`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_game_item`
--

DROP TABLE IF EXISTS `op_game_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_game_item` (
  `ITEM_INFO_ID` int(11) NOT NULL,
  `ITEM_TYPE` tinyint(4) NOT NULL COMMENT '1:Character, 2:Skill, 3:Treasure',
  `NAME` varchar(40) NOT NULL,
  `GRADE` char(1) DEFAULT NULL,
  `BUY` text,
  `SELL` text,
  `UPGRADE` text,
  PRIMARY KEY (`ITEM_INFO_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_invites`
--

DROP TABLE IF EXISTS `op_invites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_invites` (
  `USER_ID` int(11) NOT NULL,
  `INVITE_USER_ID` bigint(20) NOT NULL,
  `INVITE_DATE` datetime NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`INVITE_USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_leagues_ranking_20150625`
--

DROP TABLE IF EXISTS `op_leagues_ranking_20150625`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_leagues_ranking_20150625` (
  `USER_ID` int(11) NOT NULL,
  `GRADE` int(11) NOT NULL,
  `GROUP_ID` int(11) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`GRADE`,`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_leagues_ranking_20150626`
--

DROP TABLE IF EXISTS `op_leagues_ranking_20150626`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_leagues_ranking_20150626` (
  `USER_ID` int(11) NOT NULL,
  `GRADE` int(11) NOT NULL,
  `GROUP_ID` int(11) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`GRADE`,`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_leagues_ranking_20150627`
--

DROP TABLE IF EXISTS `op_leagues_ranking_20150627`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_leagues_ranking_20150627` (
  `USER_ID` int(11) NOT NULL,
  `GRADE` int(11) NOT NULL,
  `GROUP_ID` int(11) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`GRADE`,`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_leagues_ranking_20150628`
--

DROP TABLE IF EXISTS `op_leagues_ranking_20150628`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_leagues_ranking_20150628` (
  `USER_ID` int(11) NOT NULL,
  `GRADE` int(11) NOT NULL,
  `GROUP_ID` int(11) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`GRADE`,`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_leagues_ranking_20150629`
--

DROP TABLE IF EXISTS `op_leagues_ranking_20150629`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_leagues_ranking_20150629` (
  `USER_ID` int(11) NOT NULL,
  `GRADE` int(11) NOT NULL,
  `GROUP_ID` int(11) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`GRADE`,`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_leagues_ranking_20150630`
--

DROP TABLE IF EXISTS `op_leagues_ranking_20150630`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_leagues_ranking_20150630` (
  `USER_ID` int(11) NOT NULL,
  `GRADE` int(11) NOT NULL,
  `GROUP_ID` int(11) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`GRADE`,`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_leagues_ranking_20150701`
--

DROP TABLE IF EXISTS `op_leagues_ranking_20150701`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_leagues_ranking_20150701` (
  `USER_ID` int(11) NOT NULL,
  `GRADE` int(11) NOT NULL,
  `GROUP_ID` int(11) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`GRADE`,`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_leagues_ranking_20150702`
--

DROP TABLE IF EXISTS `op_leagues_ranking_20150702`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_leagues_ranking_20150702` (
  `USER_ID` int(11) NOT NULL,
  `GRADE` int(11) NOT NULL,
  `GROUP_ID` int(11) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`GRADE`,`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_leagues_ranking_20150703`
--

DROP TABLE IF EXISTS `op_leagues_ranking_20150703`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_leagues_ranking_20150703` (
  `USER_ID` int(11) NOT NULL,
  `GRADE` int(11) NOT NULL,
  `GROUP_ID` int(11) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`GRADE`,`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_leagues_ranking_20150814`
--

DROP TABLE IF EXISTS `op_leagues_ranking_20150814`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_leagues_ranking_20150814` (
  `USER_ID` int(11) NOT NULL,
  `GRADE` int(11) NOT NULL,
  `GROUP_ID` int(11) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`GRADE`,`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_leagues_ranking_20150815`
--

DROP TABLE IF EXISTS `op_leagues_ranking_20150815`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_leagues_ranking_20150815` (
  `USER_ID` int(11) NOT NULL,
  `GRADE` int(11) NOT NULL,
  `GROUP_ID` int(11) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`GRADE`,`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_leagues_ranking_20150816`
--

DROP TABLE IF EXISTS `op_leagues_ranking_20150816`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_leagues_ranking_20150816` (
  `USER_ID` int(11) NOT NULL,
  `GRADE` int(11) NOT NULL,
  `GROUP_ID` int(11) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`GRADE`,`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_leagues_ranking_20151111`
--

DROP TABLE IF EXISTS `op_leagues_ranking_20151111`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_leagues_ranking_20151111` (
  `USER_ID` int(11) NOT NULL,
  `GRADE` int(11) NOT NULL,
  `GROUP_ID` int(11) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`GRADE`,`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_leagues_ranking_20151112`
--

DROP TABLE IF EXISTS `op_leagues_ranking_20151112`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_leagues_ranking_20151112` (
  `USER_ID` int(11) NOT NULL,
  `GRADE` int(11) NOT NULL,
  `GROUP_ID` int(11) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`GRADE`,`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_leagues_ranking_20151113`
--

DROP TABLE IF EXISTS `op_leagues_ranking_20151113`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_leagues_ranking_20151113` (
  `USER_ID` int(11) NOT NULL,
  `GRADE` int(11) NOT NULL,
  `GROUP_ID` int(11) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`GRADE`,`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_leagues_ranking_20151114`
--

DROP TABLE IF EXISTS `op_leagues_ranking_20151114`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_leagues_ranking_20151114` (
  `USER_ID` int(11) NOT NULL,
  `GRADE` int(11) NOT NULL,
  `GROUP_ID` int(11) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`GRADE`,`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_leagues_ranking_20151115`
--

DROP TABLE IF EXISTS `op_leagues_ranking_20151115`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_leagues_ranking_20151115` (
  `USER_ID` int(11) NOT NULL,
  `GRADE` int(11) NOT NULL,
  `GROUP_ID` int(11) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`GRADE`,`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_leagues_ranking_20151116`
--

DROP TABLE IF EXISTS `op_leagues_ranking_20151116`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_leagues_ranking_20151116` (
  `USER_ID` int(11) NOT NULL,
  `GRADE` int(11) NOT NULL,
  `GROUP_ID` int(11) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`GRADE`,`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_leagues_ranking_20151117`
--

DROP TABLE IF EXISTS `op_leagues_ranking_20151117`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_leagues_ranking_20151117` (
  `USER_ID` int(11) NOT NULL,
  `GRADE` int(11) NOT NULL,
  `GROUP_ID` int(11) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`GRADE`,`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_leagues_ranking_20151118`
--

DROP TABLE IF EXISTS `op_leagues_ranking_20151118`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_leagues_ranking_20151118` (
  `USER_ID` int(11) NOT NULL,
  `GRADE` int(11) NOT NULL,
  `GROUP_ID` int(11) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`GRADE`,`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_leagues_ranking_20151119`
--

DROP TABLE IF EXISTS `op_leagues_ranking_20151119`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_leagues_ranking_20151119` (
  `USER_ID` int(11) NOT NULL,
  `GRADE` int(11) NOT NULL,
  `GROUP_ID` int(11) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`GRADE`,`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_end_20150701`
--

DROP TABLE IF EXISTS `op_log_game_end_20150701`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_end_20150701` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `MAX_COMBO` int(11) NOT NULL,
  `GAIN_MONEY` int(11) NOT NULL,
  `GAIN_EXP_POINT` int(11) NOT NULL,
  `END_DATE` datetime NOT NULL,
  `KILL_COUNT` int(11) NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_end_20150702`
--

DROP TABLE IF EXISTS `op_log_game_end_20150702`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_end_20150702` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `MAX_COMBO` int(11) NOT NULL,
  `GAIN_MONEY` int(11) NOT NULL,
  `GAIN_EXP_POINT` int(11) NOT NULL,
  `END_DATE` datetime NOT NULL,
  `KILL_COUNT` int(11) NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_end_20150703`
--

DROP TABLE IF EXISTS `op_log_game_end_20150703`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_end_20150703` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `MAX_COMBO` int(11) NOT NULL,
  `GAIN_MONEY` int(11) NOT NULL,
  `GAIN_EXP_POINT` int(11) NOT NULL,
  `END_DATE` datetime NOT NULL,
  `KILL_COUNT` int(11) NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_end_20150704`
--

DROP TABLE IF EXISTS `op_log_game_end_20150704`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_end_20150704` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `MAX_COMBO` int(11) NOT NULL,
  `GAIN_MONEY` int(11) NOT NULL,
  `GAIN_EXP_POINT` int(11) NOT NULL,
  `END_DATE` datetime NOT NULL,
  `KILL_COUNT` int(11) NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_end_20150915`
--

DROP TABLE IF EXISTS `op_log_game_end_20150915`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_end_20150915` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `MAX_COMBO` int(11) NOT NULL,
  `GAIN_MONEY` int(11) NOT NULL,
  `GAIN_EXP_POINT` int(11) NOT NULL,
  `END_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_end_20150922`
--

DROP TABLE IF EXISTS `op_log_game_end_20150922`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_end_20150922` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `MAX_COMBO` int(11) NOT NULL,
  `GAIN_MONEY` int(11) NOT NULL,
  `GAIN_EXP_POINT` int(11) NOT NULL,
  `END_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_end_20151103`
--

DROP TABLE IF EXISTS `op_log_game_end_20151103`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_end_20151103` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `MAX_COMBO` int(11) NOT NULL,
  `GAIN_MONEY` int(11) NOT NULL,
  `GAIN_EXP_POINT` int(11) NOT NULL,
  `END_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_end_20151104`
--

DROP TABLE IF EXISTS `op_log_game_end_20151104`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_end_20151104` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `MAX_COMBO` int(11) NOT NULL,
  `GAIN_MONEY` int(11) NOT NULL,
  `GAIN_EXP_POINT` int(11) NOT NULL,
  `END_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_end_20151105`
--

DROP TABLE IF EXISTS `op_log_game_end_20151105`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_end_20151105` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `MAX_COMBO` int(11) NOT NULL,
  `GAIN_MONEY` int(11) NOT NULL,
  `GAIN_EXP_POINT` int(11) NOT NULL,
  `END_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_end_20151117`
--

DROP TABLE IF EXISTS `op_log_game_end_20151117`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_end_20151117` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `MAX_COMBO` int(11) NOT NULL,
  `GAIN_MONEY` int(11) NOT NULL,
  `GAIN_EXP_POINT` int(11) NOT NULL,
  `END_DATE` datetime NOT NULL,
  `KILL_COUNT` int(11) NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_end_20151118`
--

DROP TABLE IF EXISTS `op_log_game_end_20151118`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_end_20151118` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `MAX_COMBO` int(11) NOT NULL,
  `GAIN_MONEY` int(11) NOT NULL,
  `GAIN_EXP_POINT` int(11) NOT NULL,
  `END_DATE` datetime NOT NULL,
  `KILL_COUNT` int(11) NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_end_20151119`
--

DROP TABLE IF EXISTS `op_log_game_end_20151119`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_end_20151119` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `MAX_COMBO` int(11) NOT NULL,
  `GAIN_MONEY` int(11) NOT NULL,
  `GAIN_EXP_POINT` int(11) NOT NULL,
  `END_DATE` datetime NOT NULL,
  `KILL_COUNT` int(11) NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_end_20151120`
--

DROP TABLE IF EXISTS `op_log_game_end_20151120`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_end_20151120` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `SCORE` int(11) NOT NULL,
  `MAX_COMBO` int(11) NOT NULL,
  `GAIN_MONEY` int(11) NOT NULL,
  `GAIN_EXP_POINT` int(11) NOT NULL,
  `END_DATE` datetime NOT NULL,
  `KILL_COUNT` int(11) NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_start_20150701`
--

DROP TABLE IF EXISTS `op_log_game_start_20150701`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_start_20150701` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL COMMENT '0:Survival',
  `LEVEL` int(11) NOT NULL,
  `CHARACTER` varchar(4000) NOT NULL,
  `SKILLS` varchar(4000) NOT NULL,
  `TREASURES` varchar(4000) NOT NULL,
  `ITEMS` varchar(4000) NOT NULL,
  `START_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_start_20150702`
--

DROP TABLE IF EXISTS `op_log_game_start_20150702`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_start_20150702` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL COMMENT '0:Survival',
  `LEVEL` int(11) NOT NULL,
  `CHARACTER` varchar(4000) NOT NULL,
  `SKILLS` varchar(4000) NOT NULL,
  `TREASURES` varchar(4000) NOT NULL,
  `ITEMS` varchar(4000) NOT NULL,
  `START_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_start_20150703`
--

DROP TABLE IF EXISTS `op_log_game_start_20150703`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_start_20150703` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL COMMENT '0:Survival',
  `LEVEL` int(11) NOT NULL,
  `CHARACTER` varchar(4000) NOT NULL,
  `SKILLS` varchar(4000) NOT NULL,
  `TREASURES` varchar(4000) NOT NULL,
  `ITEMS` varchar(4000) NOT NULL,
  `START_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_start_20150704`
--

DROP TABLE IF EXISTS `op_log_game_start_20150704`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_start_20150704` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL COMMENT '0:Survival',
  `LEVEL` int(11) NOT NULL,
  `CHARACTER` varchar(4000) NOT NULL,
  `SKILLS` varchar(4000) NOT NULL,
  `TREASURES` varchar(4000) NOT NULL,
  `ITEMS` varchar(4000) NOT NULL,
  `START_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_start_20150915`
--

DROP TABLE IF EXISTS `op_log_game_start_20150915`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_start_20150915` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL COMMENT '0:Survival',
  `LEVEL` int(11) NOT NULL,
  `CHARACTER` varchar(4000) NOT NULL,
  `SKILLS` varchar(4000) NOT NULL,
  `TREASURES` varchar(4000) NOT NULL,
  `ITEMS` varchar(4000) NOT NULL,
  `START_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_start_20150922`
--

DROP TABLE IF EXISTS `op_log_game_start_20150922`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_start_20150922` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL COMMENT '0:Survival',
  `LEVEL` int(11) NOT NULL,
  `CHARACTER` varchar(4000) NOT NULL,
  `SKILLS` varchar(4000) NOT NULL,
  `TREASURES` varchar(4000) NOT NULL,
  `ITEMS` varchar(4000) NOT NULL,
  `START_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_start_20151103`
--

DROP TABLE IF EXISTS `op_log_game_start_20151103`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_start_20151103` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL COMMENT '0:Survival',
  `LEVEL` int(11) NOT NULL,
  `CHARACTER` varchar(4000) NOT NULL,
  `SKILLS` varchar(4000) NOT NULL,
  `TREASURES` varchar(4000) NOT NULL,
  `ITEMS` varchar(4000) NOT NULL,
  `START_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_start_20151104`
--

DROP TABLE IF EXISTS `op_log_game_start_20151104`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_start_20151104` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL COMMENT '0:Survival',
  `LEVEL` int(11) NOT NULL,
  `CHARACTER` varchar(4000) NOT NULL,
  `SKILLS` varchar(4000) NOT NULL,
  `TREASURES` varchar(4000) NOT NULL,
  `ITEMS` varchar(4000) NOT NULL,
  `START_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_start_20151105`
--

DROP TABLE IF EXISTS `op_log_game_start_20151105`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_start_20151105` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL COMMENT '0:Survival',
  `LEVEL` int(11) NOT NULL,
  `CHARACTER` varchar(4000) NOT NULL,
  `SKILLS` varchar(4000) NOT NULL,
  `TREASURES` varchar(4000) NOT NULL,
  `ITEMS` varchar(4000) NOT NULL,
  `START_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_start_20151117`
--

DROP TABLE IF EXISTS `op_log_game_start_20151117`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_start_20151117` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL COMMENT '0:Survival',
  `LEVEL` int(11) NOT NULL,
  `CHARACTER` varchar(4000) NOT NULL,
  `SKILLS` varchar(4000) NOT NULL,
  `TREASURES` varchar(4000) NOT NULL,
  `ITEMS` varchar(4000) NOT NULL,
  `START_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_start_20151118`
--

DROP TABLE IF EXISTS `op_log_game_start_20151118`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_start_20151118` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL COMMENT '0:Survival',
  `LEVEL` int(11) NOT NULL,
  `CHARACTER` varchar(4000) NOT NULL,
  `SKILLS` varchar(4000) NOT NULL,
  `TREASURES` varchar(4000) NOT NULL,
  `ITEMS` varchar(4000) NOT NULL,
  `START_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_start_20151119`
--

DROP TABLE IF EXISTS `op_log_game_start_20151119`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_start_20151119` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL COMMENT '0:Survival',
  `LEVEL` int(11) NOT NULL,
  `CHARACTER` varchar(4000) NOT NULL,
  `SKILLS` varchar(4000) NOT NULL,
  `TREASURES` varchar(4000) NOT NULL,
  `ITEMS` varchar(4000) NOT NULL,
  `START_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_game_start_20151120`
--

DROP TABLE IF EXISTS `op_log_game_start_20151120`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_game_start_20151120` (
  `PLAY_CODE` bigint(20) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL COMMENT '0:Survival',
  `LEVEL` int(11) NOT NULL,
  `CHARACTER` varchar(4000) NOT NULL,
  `SKILLS` varchar(4000) NOT NULL,
  `TREASURES` varchar(4000) NOT NULL,
  `ITEMS` varchar(4000) NOT NULL,
  `START_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_login_20150701`
--

DROP TABLE IF EXISTS `op_log_login_20150701`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_login_20150701` (
  `USER_ID` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_login_20150702`
--

DROP TABLE IF EXISTS `op_log_login_20150702`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_login_20150702` (
  `USER_ID` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_login_20150703`
--

DROP TABLE IF EXISTS `op_log_login_20150703`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_login_20150703` (
  `USER_ID` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_login_20150704`
--

DROP TABLE IF EXISTS `op_log_login_20150704`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_login_20150704` (
  `USER_ID` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_login_20150915`
--

DROP TABLE IF EXISTS `op_log_login_20150915`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_login_20150915` (
  `USER_ID` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_login_20150922`
--

DROP TABLE IF EXISTS `op_log_login_20150922`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_login_20150922` (
  `USER_ID` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_login_20151103`
--

DROP TABLE IF EXISTS `op_log_login_20151103`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_login_20151103` (
  `USER_ID` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_login_20151104`
--

DROP TABLE IF EXISTS `op_log_login_20151104`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_login_20151104` (
  `USER_ID` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_login_20151105`
--

DROP TABLE IF EXISTS `op_log_login_20151105`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_login_20151105` (
  `USER_ID` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_login_20151117`
--

DROP TABLE IF EXISTS `op_log_login_20151117`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_login_20151117` (
  `USER_ID` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_login_20151118`
--

DROP TABLE IF EXISTS `op_log_login_20151118`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_login_20151118` (
  `USER_ID` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_login_20151119`
--

DROP TABLE IF EXISTS `op_log_login_20151119`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_login_20151119` (
  `USER_ID` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_login_20151120`
--

DROP TABLE IF EXISTS `op_log_login_20151120`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_login_20151120` (
  `USER_ID` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_lottery_20150701`
--

DROP TABLE IF EXISTS `op_log_lottery_20150701`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_lottery_20150701` (
  `USER_ID` int(11) NOT NULL,
  `LOTTERY_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_ID` int(11) DEFAULT NULL,
  `PRODUCT_AMOUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_lottery_20150702`
--

DROP TABLE IF EXISTS `op_log_lottery_20150702`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_lottery_20150702` (
  `USER_ID` int(11) NOT NULL,
  `LOTTERY_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_ID` int(11) DEFAULT NULL,
  `PRODUCT_AMOUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_lottery_20150703`
--

DROP TABLE IF EXISTS `op_log_lottery_20150703`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_lottery_20150703` (
  `USER_ID` int(11) NOT NULL,
  `LOTTERY_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_ID` int(11) DEFAULT NULL,
  `PRODUCT_AMOUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_lottery_20150704`
--

DROP TABLE IF EXISTS `op_log_lottery_20150704`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_lottery_20150704` (
  `USER_ID` int(11) NOT NULL,
  `LOTTERY_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_ID` int(11) DEFAULT NULL,
  `PRODUCT_AMOUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_lottery_20150915`
--

DROP TABLE IF EXISTS `op_log_lottery_20150915`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_lottery_20150915` (
  `USER_ID` int(11) NOT NULL,
  `LOTTERY_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_ID` int(11) DEFAULT NULL,
  `PRODUCT_AMOUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_lottery_20150922`
--

DROP TABLE IF EXISTS `op_log_lottery_20150922`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_lottery_20150922` (
  `USER_ID` int(11) NOT NULL,
  `LOTTERY_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_ID` int(11) DEFAULT NULL,
  `PRODUCT_AMOUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_lottery_20151103`
--

DROP TABLE IF EXISTS `op_log_lottery_20151103`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_lottery_20151103` (
  `USER_ID` int(11) NOT NULL,
  `LOTTERY_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_ID` int(11) DEFAULT NULL,
  `PRODUCT_AMOUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_lottery_20151104`
--

DROP TABLE IF EXISTS `op_log_lottery_20151104`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_lottery_20151104` (
  `USER_ID` int(11) NOT NULL,
  `LOTTERY_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_ID` int(11) DEFAULT NULL,
  `PRODUCT_AMOUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_lottery_20151105`
--

DROP TABLE IF EXISTS `op_log_lottery_20151105`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_lottery_20151105` (
  `USER_ID` int(11) NOT NULL,
  `LOTTERY_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_ID` int(11) DEFAULT NULL,
  `PRODUCT_AMOUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_lottery_20151117`
--

DROP TABLE IF EXISTS `op_log_lottery_20151117`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_lottery_20151117` (
  `USER_ID` int(11) NOT NULL,
  `LOTTERY_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_ID` int(11) DEFAULT NULL,
  `PRODUCT_AMOUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_lottery_20151118`
--

DROP TABLE IF EXISTS `op_log_lottery_20151118`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_lottery_20151118` (
  `USER_ID` int(11) NOT NULL,
  `LOTTERY_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_ID` int(11) DEFAULT NULL,
  `PRODUCT_AMOUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_lottery_20151119`
--

DROP TABLE IF EXISTS `op_log_lottery_20151119`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_lottery_20151119` (
  `USER_ID` int(11) NOT NULL,
  `LOTTERY_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_ID` int(11) DEFAULT NULL,
  `PRODUCT_AMOUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_lottery_20151120`
--

DROP TABLE IF EXISTS `op_log_lottery_20151120`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_lottery_20151120` (
  `USER_ID` int(11) NOT NULL,
  `LOTTERY_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_TYPE` tinyint(4) NOT NULL,
  `PRODUCT_ID` int(11) DEFAULT NULL,
  `PRODUCT_AMOUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_point_20150701`
--

DROP TABLE IF EXISTS `op_log_point_20150701`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_point_20150701` (
  `USER_ID` int(11) NOT NULL,
  `POINT_TYPE` tinyint(4) NOT NULL,
  `CATEGORY` int(11) NOT NULL,
  `POINT` int(11) NOT NULL,
  `CURRENT_POINT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_point_20150702`
--

DROP TABLE IF EXISTS `op_log_point_20150702`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_point_20150702` (
  `USER_ID` int(11) NOT NULL,
  `POINT_TYPE` tinyint(4) NOT NULL,
  `CATEGORY` int(11) NOT NULL,
  `POINT` int(11) NOT NULL,
  `CURRENT_POINT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_point_20150703`
--

DROP TABLE IF EXISTS `op_log_point_20150703`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_point_20150703` (
  `USER_ID` int(11) NOT NULL,
  `POINT_TYPE` tinyint(4) NOT NULL,
  `CATEGORY` int(11) NOT NULL,
  `POINT` int(11) NOT NULL,
  `CURRENT_POINT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_point_20150704`
--

DROP TABLE IF EXISTS `op_log_point_20150704`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_point_20150704` (
  `USER_ID` int(11) NOT NULL,
  `POINT_TYPE` tinyint(4) NOT NULL,
  `CATEGORY` int(11) NOT NULL,
  `POINT` int(11) NOT NULL,
  `CURRENT_POINT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_point_20150915`
--

DROP TABLE IF EXISTS `op_log_point_20150915`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_point_20150915` (
  `USER_ID` int(11) NOT NULL,
  `POINT_TYPE` tinyint(4) NOT NULL,
  `CATEGORY` int(11) NOT NULL,
  `POINT` int(11) NOT NULL,
  `CURRENT_POINT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_point_20150922`
--

DROP TABLE IF EXISTS `op_log_point_20150922`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_point_20150922` (
  `USER_ID` int(11) NOT NULL,
  `POINT_TYPE` tinyint(4) NOT NULL,
  `CATEGORY` int(11) NOT NULL,
  `POINT` int(11) NOT NULL,
  `CURRENT_POINT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_point_20151103`
--

DROP TABLE IF EXISTS `op_log_point_20151103`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_point_20151103` (
  `USER_ID` int(11) NOT NULL,
  `POINT_TYPE` tinyint(4) NOT NULL,
  `CATEGORY` int(11) NOT NULL,
  `POINT` int(11) NOT NULL,
  `CURRENT_POINT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_point_20151104`
--

DROP TABLE IF EXISTS `op_log_point_20151104`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_point_20151104` (
  `USER_ID` int(11) NOT NULL,
  `POINT_TYPE` tinyint(4) NOT NULL,
  `CATEGORY` int(11) NOT NULL,
  `POINT` int(11) NOT NULL,
  `CURRENT_POINT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_point_20151105`
--

DROP TABLE IF EXISTS `op_log_point_20151105`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_point_20151105` (
  `USER_ID` int(11) NOT NULL,
  `POINT_TYPE` tinyint(4) NOT NULL,
  `CATEGORY` int(11) NOT NULL,
  `POINT` int(11) NOT NULL,
  `CURRENT_POINT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_point_20151117`
--

DROP TABLE IF EXISTS `op_log_point_20151117`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_point_20151117` (
  `USER_ID` int(11) NOT NULL,
  `POINT_TYPE` tinyint(4) NOT NULL,
  `CATEGORY` int(11) NOT NULL,
  `POINT` int(11) NOT NULL,
  `CURRENT_POINT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_point_20151118`
--

DROP TABLE IF EXISTS `op_log_point_20151118`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_point_20151118` (
  `USER_ID` int(11) NOT NULL,
  `POINT_TYPE` tinyint(4) NOT NULL,
  `CATEGORY` int(11) NOT NULL,
  `POINT` int(11) NOT NULL,
  `CURRENT_POINT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_point_20151119`
--

DROP TABLE IF EXISTS `op_log_point_20151119`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_point_20151119` (
  `USER_ID` int(11) NOT NULL,
  `POINT_TYPE` tinyint(4) NOT NULL,
  `CATEGORY` int(11) NOT NULL,
  `POINT` int(11) NOT NULL,
  `CURRENT_POINT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_point_20151120`
--

DROP TABLE IF EXISTS `op_log_point_20151120`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_point_20151120` (
  `USER_ID` int(11) NOT NULL,
  `POINT_TYPE` tinyint(4) NOT NULL,
  `CATEGORY` int(11) NOT NULL,
  `POINT` int(11) NOT NULL,
  `CURRENT_POINT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_upgrade_20150701`
--

DROP TABLE IF EXISTS `op_log_upgrade_20150701`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_upgrade_20150701` (
  `USER_ID` int(11) NOT NULL,
  `ITEM_TYPE` int(11) NOT NULL COMMENT '0:Character, 1:Skill, 2, Treasure',
  `ITEM_ID` bigint(20) NOT NULL,
  `ITEM_INFO_ID` int(11) NOT NULL,
  `IS_SUCCESS` tinyint(4) NOT NULL COMMENT '0:Fail, 1:Success',
  `LEVEL` int(11) NOT NULL,
  `PRICE_TYPE` tinyint(4) NOT NULL COMMENT '1:Money, 2:Cash',
  `PRICE` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_upgrade_20150702`
--

DROP TABLE IF EXISTS `op_log_upgrade_20150702`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_upgrade_20150702` (
  `USER_ID` int(11) NOT NULL,
  `ITEM_TYPE` int(11) NOT NULL COMMENT '0:Character, 1:Skill, 2, Treasure',
  `ITEM_ID` bigint(20) NOT NULL,
  `ITEM_INFO_ID` int(11) NOT NULL,
  `IS_SUCCESS` tinyint(4) NOT NULL COMMENT '0:Fail, 1:Success',
  `LEVEL` int(11) NOT NULL,
  `PRICE_TYPE` tinyint(4) NOT NULL COMMENT '1:Money, 2:Cash',
  `PRICE` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_upgrade_20150703`
--

DROP TABLE IF EXISTS `op_log_upgrade_20150703`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_upgrade_20150703` (
  `USER_ID` int(11) NOT NULL,
  `ITEM_TYPE` int(11) NOT NULL COMMENT '0:Character, 1:Skill, 2, Treasure',
  `ITEM_ID` bigint(20) NOT NULL,
  `ITEM_INFO_ID` int(11) NOT NULL,
  `IS_SUCCESS` tinyint(4) NOT NULL COMMENT '0:Fail, 1:Success',
  `LEVEL` int(11) NOT NULL,
  `PRICE_TYPE` tinyint(4) NOT NULL COMMENT '1:Money, 2:Cash',
  `PRICE` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_upgrade_20150704`
--

DROP TABLE IF EXISTS `op_log_upgrade_20150704`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_upgrade_20150704` (
  `USER_ID` int(11) NOT NULL,
  `ITEM_TYPE` int(11) NOT NULL COMMENT '0:Character, 1:Skill, 2, Treasure',
  `ITEM_ID` bigint(20) NOT NULL,
  `ITEM_INFO_ID` int(11) NOT NULL,
  `IS_SUCCESS` tinyint(4) NOT NULL COMMENT '0:Fail, 1:Success',
  `LEVEL` int(11) NOT NULL,
  `PRICE_TYPE` tinyint(4) NOT NULL COMMENT '1:Money, 2:Cash',
  `PRICE` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_upgrade_20150915`
--

DROP TABLE IF EXISTS `op_log_upgrade_20150915`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_upgrade_20150915` (
  `USER_ID` int(11) NOT NULL,
  `ITEM_TYPE` int(11) NOT NULL COMMENT '0:Character, 1:Skill, 2, Treasure',
  `ITEM_ID` bigint(20) NOT NULL,
  `ITEM_INFO_ID` int(11) NOT NULL,
  `IS_SUCCESS` tinyint(4) NOT NULL COMMENT '0:Fail, 1:Success',
  `LEVEL` int(11) NOT NULL,
  `PRICE_TYPE` tinyint(4) NOT NULL COMMENT '1:Money, 2:Cash',
  `PRICE` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_upgrade_20150922`
--

DROP TABLE IF EXISTS `op_log_upgrade_20150922`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_upgrade_20150922` (
  `USER_ID` int(11) NOT NULL,
  `ITEM_TYPE` int(11) NOT NULL COMMENT '0:Character, 1:Skill, 2, Treasure',
  `ITEM_ID` bigint(20) NOT NULL,
  `ITEM_INFO_ID` int(11) NOT NULL,
  `IS_SUCCESS` tinyint(4) NOT NULL COMMENT '0:Fail, 1:Success',
  `LEVEL` int(11) NOT NULL,
  `PRICE_TYPE` tinyint(4) NOT NULL COMMENT '1:Money, 2:Cash',
  `PRICE` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_upgrade_20151103`
--

DROP TABLE IF EXISTS `op_log_upgrade_20151103`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_upgrade_20151103` (
  `USER_ID` int(11) NOT NULL,
  `ITEM_TYPE` int(11) NOT NULL COMMENT '0:Character, 1:Skill, 2, Treasure',
  `ITEM_ID` bigint(20) NOT NULL,
  `ITEM_INFO_ID` int(11) NOT NULL,
  `IS_SUCCESS` tinyint(4) NOT NULL COMMENT '0:Fail, 1:Success',
  `LEVEL` int(11) NOT NULL,
  `PRICE_TYPE` tinyint(4) NOT NULL COMMENT '1:Money, 2:Cash',
  `PRICE` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_upgrade_20151104`
--

DROP TABLE IF EXISTS `op_log_upgrade_20151104`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_upgrade_20151104` (
  `USER_ID` int(11) NOT NULL,
  `ITEM_TYPE` int(11) NOT NULL COMMENT '0:Character, 1:Skill, 2, Treasure',
  `ITEM_ID` bigint(20) NOT NULL,
  `ITEM_INFO_ID` int(11) NOT NULL,
  `IS_SUCCESS` tinyint(4) NOT NULL COMMENT '0:Fail, 1:Success',
  `LEVEL` int(11) NOT NULL,
  `PRICE_TYPE` tinyint(4) NOT NULL COMMENT '1:Money, 2:Cash',
  `PRICE` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_upgrade_20151105`
--

DROP TABLE IF EXISTS `op_log_upgrade_20151105`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_upgrade_20151105` (
  `USER_ID` int(11) NOT NULL,
  `ITEM_TYPE` int(11) NOT NULL COMMENT '0:Character, 1:Skill, 2, Treasure',
  `ITEM_ID` bigint(20) NOT NULL,
  `ITEM_INFO_ID` int(11) NOT NULL,
  `IS_SUCCESS` tinyint(4) NOT NULL COMMENT '0:Fail, 1:Success',
  `LEVEL` int(11) NOT NULL,
  `PRICE_TYPE` tinyint(4) NOT NULL COMMENT '1:Money, 2:Cash',
  `PRICE` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_upgrade_20151117`
--

DROP TABLE IF EXISTS `op_log_upgrade_20151117`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_upgrade_20151117` (
  `USER_ID` int(11) NOT NULL,
  `ITEM_TYPE` int(11) NOT NULL COMMENT '0:Character, 1:Skill, 2, Treasure',
  `ITEM_ID` bigint(20) NOT NULL,
  `ITEM_INFO_ID` int(11) NOT NULL,
  `IS_SUCCESS` tinyint(4) NOT NULL COMMENT '0:Fail, 1:Success',
  `LEVEL` int(11) NOT NULL,
  `PRICE_TYPE` tinyint(4) NOT NULL COMMENT '1:Money, 2:Cash',
  `PRICE` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_upgrade_20151118`
--

DROP TABLE IF EXISTS `op_log_upgrade_20151118`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_upgrade_20151118` (
  `USER_ID` int(11) NOT NULL,
  `ITEM_TYPE` int(11) NOT NULL COMMENT '0:Character, 1:Skill, 2, Treasure',
  `ITEM_ID` bigint(20) NOT NULL,
  `ITEM_INFO_ID` int(11) NOT NULL,
  `IS_SUCCESS` tinyint(4) NOT NULL COMMENT '0:Fail, 1:Success',
  `LEVEL` int(11) NOT NULL,
  `PRICE_TYPE` tinyint(4) NOT NULL COMMENT '1:Money, 2:Cash',
  `PRICE` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_upgrade_20151119`
--

DROP TABLE IF EXISTS `op_log_upgrade_20151119`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_upgrade_20151119` (
  `USER_ID` int(11) NOT NULL,
  `ITEM_TYPE` int(11) NOT NULL COMMENT '0:Character, 1:Skill, 2, Treasure',
  `ITEM_ID` bigint(20) NOT NULL,
  `ITEM_INFO_ID` int(11) NOT NULL,
  `IS_SUCCESS` tinyint(4) NOT NULL COMMENT '0:Fail, 1:Success',
  `LEVEL` int(11) NOT NULL,
  `PRICE_TYPE` tinyint(4) NOT NULL COMMENT '1:Money, 2:Cash',
  `PRICE` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_log_upgrade_20151120`
--

DROP TABLE IF EXISTS `op_log_upgrade_20151120`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_log_upgrade_20151120` (
  `USER_ID` int(11) NOT NULL,
  `ITEM_TYPE` int(11) NOT NULL COMMENT '0:Character, 1:Skill, 2, Treasure',
  `ITEM_ID` bigint(20) NOT NULL,
  `ITEM_INFO_ID` int(11) NOT NULL,
  `IS_SUCCESS` tinyint(4) NOT NULL COMMENT '0:Fail, 1:Success',
  `LEVEL` int(11) NOT NULL,
  `PRICE_TYPE` tinyint(4) NOT NULL COMMENT '1:Money, 2:Cash',
  `PRICE` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_managers`
--

DROP TABLE IF EXISTS `op_managers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_managers` (
  `MANAGER_ID` int(11) NOT NULL AUTO_INCREMENT,
  `EMAIL` varchar(200) NOT NULL,
  `PASSWORD` varchar(40) NOT NULL,
  `NAME` varchar(40) NOT NULL,
  `LEVEL` tinyint(4) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  `LOGIN_DATE` datetime DEFAULT NULL,
  `CREATE_IP` varchar(20) NOT NULL,
  `UPDATE_IP` varchar(20) DEFAULT NULL,
  `LOGIN_IP` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`MANAGER_ID`),
  UNIQUE KEY `EMAIL` (`EMAIL`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_market_order`
--

DROP TABLE IF EXISTS `op_market_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_market_order` (
  `USER_ID` int(11) NOT NULL,
  `PRODUCT_ID` varchar(100) NOT NULL,
  `ORDER_ID` varchar(100) NOT NULL,
  `PURCHASE_TOKEN` varchar(500) NOT NULL,
  `SIGNATURE` varchar(500) NOT NULL,
  `RECEIPT` text,
  `CREATE_DATE` datetime NOT NULL,
  UNIQUE KEY `ORDER_ID` (`ORDER_ID`),
  KEY `USER_ID` (`USER_ID`),
  KEY `PRODUCT_ID` (`PRODUCT_ID`),
  KEY `CREATE_DATE` (`CREATE_DATE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_messages`
--

DROP TABLE IF EXISTS `op_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_messages` (
  `MESSAGE_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `SEND_USER_ID` int(11) NOT NULL,
  `RECIEVE_USER_ID` int(11) NOT NULL,
  `EVENT_ID` int(11) DEFAULT NULL,
  `TEXT_ID` int(11) DEFAULT NULL,
  `GIFT` varchar(4000) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  `DELETE_DATE` datetime DEFAULT NULL,
  `CREATE_IP` varchar(40) NOT NULL,
  `DELETE_IP` varchar(40) DEFAULT NULL,
  `IS_DELETE` tinyint(4) NOT NULL DEFAULT '0',
  `MSG_TITLE` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`MESSAGE_ID`),
  KEY `SEND_USER_ID` (`SEND_USER_ID`,`RECIEVE_USER_ID`),
  KEY `RECIEVE_USER_ID` (`RECIEVE_USER_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=22287 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_notices`
--

DROP TABLE IF EXISTS `op_notices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_notices` (
  `NOTICE_ID` int(11) NOT NULL AUTO_INCREMENT,
  `TITLE` varchar(255) NOT NULL,
  `CONTENT` text NOT NULL,
  `MANAGER_ID` int(11) NOT NULL,
  `START_DATE` datetime NOT NULL,
  `END_DATE` datetime NOT NULL,
  `IS_SHOW` tinyint(4) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  PRIMARY KEY (`NOTICE_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_play_code_20150630`
--

DROP TABLE IF EXISTS `op_play_code_20150630`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_play_code_20150630` (
  `PLAY_CODE` bigint(20) NOT NULL AUTO_INCREMENT,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL,
  `FRIEND_USER_ID` int(11) DEFAULT NULL,
  `IS_FINISH` tinyint(4) NOT NULL,
  `CONTINUE_COUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  PRIMARY KEY (`PLAY_CODE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_play_code_20150701`
--

DROP TABLE IF EXISTS `op_play_code_20150701`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_play_code_20150701` (
  `PLAY_CODE` bigint(20) NOT NULL AUTO_INCREMENT,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL,
  `FRIEND_USER_ID` int(11) DEFAULT NULL,
  `IS_FINISH` tinyint(4) NOT NULL,
  `CONTINUE_COUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  PRIMARY KEY (`PLAY_CODE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_play_code_20150702`
--

DROP TABLE IF EXISTS `op_play_code_20150702`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_play_code_20150702` (
  `PLAY_CODE` bigint(20) NOT NULL AUTO_INCREMENT,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL,
  `FRIEND_USER_ID` int(11) DEFAULT NULL,
  `IS_FINISH` tinyint(4) NOT NULL,
  `CONTINUE_COUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  PRIMARY KEY (`PLAY_CODE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_play_code_20150703`
--

DROP TABLE IF EXISTS `op_play_code_20150703`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_play_code_20150703` (
  `PLAY_CODE` bigint(20) NOT NULL AUTO_INCREMENT,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL,
  `FRIEND_USER_ID` int(11) DEFAULT NULL,
  `IS_FINISH` tinyint(4) NOT NULL,
  `CONTINUE_COUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  PRIMARY KEY (`PLAY_CODE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_play_code_20150704`
--

DROP TABLE IF EXISTS `op_play_code_20150704`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_play_code_20150704` (
  `PLAY_CODE` bigint(20) NOT NULL AUTO_INCREMENT,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL,
  `FRIEND_USER_ID` int(11) DEFAULT NULL,
  `IS_FINISH` tinyint(4) NOT NULL,
  `CONTINUE_COUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  PRIMARY KEY (`PLAY_CODE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_play_code_20151116`
--

DROP TABLE IF EXISTS `op_play_code_20151116`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_play_code_20151116` (
  `PLAY_CODE` bigint(20) NOT NULL AUTO_INCREMENT,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL,
  `FRIEND_USER_ID` int(11) DEFAULT NULL,
  `IS_FINISH` tinyint(4) NOT NULL,
  `CONTINUE_COUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  PRIMARY KEY (`PLAY_CODE`)
) ENGINE=InnoDB AUTO_INCREMENT=271 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_play_code_20151117`
--

DROP TABLE IF EXISTS `op_play_code_20151117`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_play_code_20151117` (
  `PLAY_CODE` bigint(20) NOT NULL AUTO_INCREMENT,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL,
  `FRIEND_USER_ID` int(11) DEFAULT NULL,
  `IS_FINISH` tinyint(4) NOT NULL,
  `CONTINUE_COUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  PRIMARY KEY (`PLAY_CODE`)
) ENGINE=InnoDB AUTO_INCREMENT=149 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_play_code_20151118`
--

DROP TABLE IF EXISTS `op_play_code_20151118`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_play_code_20151118` (
  `PLAY_CODE` bigint(20) NOT NULL AUTO_INCREMENT,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL,
  `FRIEND_USER_ID` int(11) DEFAULT NULL,
  `IS_FINISH` tinyint(4) NOT NULL,
  `CONTINUE_COUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  PRIMARY KEY (`PLAY_CODE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_play_code_20151119`
--

DROP TABLE IF EXISTS `op_play_code_20151119`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_play_code_20151119` (
  `PLAY_CODE` bigint(20) NOT NULL AUTO_INCREMENT,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL,
  `FRIEND_USER_ID` int(11) DEFAULT NULL,
  `IS_FINISH` tinyint(4) NOT NULL,
  `CONTINUE_COUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  PRIMARY KEY (`PLAY_CODE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_play_code_20151120`
--

DROP TABLE IF EXISTS `op_play_code_20151120`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_play_code_20151120` (
  `PLAY_CODE` bigint(20) NOT NULL AUTO_INCREMENT,
  `USER_ID` int(11) NOT NULL,
  `STAGE_ID` int(11) NOT NULL,
  `FRIEND_USER_ID` int(11) DEFAULT NULL,
  `IS_FINISH` tinyint(4) NOT NULL,
  `CONTINUE_COUNT` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  PRIMARY KEY (`PLAY_CODE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_push_messages`
--

DROP TABLE IF EXISTS `op_push_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_push_messages` (
  `MESSAGE_ID` int(11) NOT NULL AUTO_INCREMENT,
  `TITLE` varchar(255) NOT NULL,
  `MESSAGE` varchar(255) NOT NULL,
  `SEND_DATE` date NOT NULL,
  `SEND_TIME` tinyint(4) NOT NULL,
  `FINISH_DATE` datetime DEFAULT NULL,
  `OS_TYPE` tinyint(4) NOT NULL COMMENT '1:Android, 2:iOS',
  `TOTAL_USER_COUNT` int(11) NOT NULL,
  `SUCCESS_COUNT` int(11) DEFAULT NULL,
  `CREATE_DATE` datetime NOT NULL,
  `DELETE_DATE` datetime DEFAULT NULL,
  `IS_DELETE` tinyint(4) NOT NULL,
  PRIMARY KEY (`MESSAGE_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users`
--

DROP TABLE IF EXISTS `op_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users` (
  `USER_ID` int(11) NOT NULL AUTO_INCREMENT,
  `EMAIL` varchar(200) NOT NULL,
  `PASSWORD` varchar(40) NOT NULL,
  `NICKNAME` varchar(100) NOT NULL,
  `LEVEL` int(11) NOT NULL,
  `EXP_POINT` int(11) NOT NULL,
  `MONEY` int(11) NOT NULL,
  `CASH` int(11) NOT NULL,
  `HEART` int(11) NOT NULL,
  `HEART_TIME` datetime DEFAULT NULL,
  `LOTTERY_POINT` int(11) NOT NULL,
  `LOTTERY_HIGH_COUPON` int(11) NOT NULL,
  `LOTTERY_COUPON` int(11) NOT NULL,
  `CHARACTER_ID` bigint(20) NOT NULL,
  `SKILL_SLOT` tinyint(4) NOT NULL DEFAULT '1',
  `TREASURE_SLOT` tinyint(4) NOT NULL DEFAULT '1',
  `TREASURE_INVENTORY` mediumint(9) NOT NULL,
  `BEST_SCORE` int(11) NOT NULL,
  `INVITE_COUNT` int(11) NOT NULL DEFAULT '0',
  `REVIEW` tinyint(4) NOT NULL DEFAULT '0',
  `AGREE_MESSAGE` tinyint(4) NOT NULL DEFAULT '1' COMMENT '0:Disagree, 1:Agree',
  `STATUS` tinyint(4) NOT NULL COMMENT '0:INACTIVE, 1:ACTIVE, 9:BLOCK',
  `DEVICE` varchar(200) DEFAULT NULL,
  `OS_TYPE` tinyint(4) NOT NULL,
  `OS_VERSION` varchar(50) NOT NULL,
  `MARKET_TYPE` tinyint(4) NOT NULL,
  `TUTORIAL` tinyint(4) NOT NULL DEFAULT '0',
  `ATTENDANCE_COUNT` tinyint(4) NOT NULL,
  `ATTENDANCE_DATE` date NOT NULL,
  `PUSH_ID` varchar(400) NOT NULL,
  `CELLPHONE` varchar(40) DEFAULT NULL,
  `CREATE_DATE` datetime NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  `DELETE_DATE` datetime DEFAULT NULL,
  `LOGIN_DATE` datetime DEFAULT NULL,
  `CREATE_IP` varchar(40) NOT NULL,
  `UPDATE_IP` varchar(40) DEFAULT NULL,
  `DELETE_IP` varchar(40) DEFAULT NULL,
  `LOGIN_IP` varchar(40) DEFAULT NULL,
  `HACK_COUNT` int(11) DEFAULT '0',
  `VIDEO_REBORN_TIMES` int(11) DEFAULT '0',
  `WATCH_VIDEO_TIMES` int(11) DEFAULT '0',
  `VIP_END_DATE` datetime DEFAULT NULL,
  `VERSION` int(11) NOT NULL DEFAULT '20',
  PRIMARY KEY (`USER_ID`),
  KEY `EMAIL` (`EMAIL`),
  KEY `NICKNAME` (`NICKNAME`)
) ENGINE=InnoDB AUTO_INCREMENT=5831 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_achievements_0`
--

DROP TABLE IF EXISTS `op_users_achievements_0`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_achievements_0` (
  `ACHIEVEMENT_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `PROGRESS` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  UNIQUE KEY `ACHIEVEMENT_INFO_ID` (`ACHIEVEMENT_INFO_ID`,`USER_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_achievements_1`
--

DROP TABLE IF EXISTS `op_users_achievements_1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_achievements_1` (
  `ACHIEVEMENT_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `PROGRESS` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  UNIQUE KEY `ACHIEVEMENT_INFO_ID` (`ACHIEVEMENT_INFO_ID`,`USER_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_achievements_2`
--

DROP TABLE IF EXISTS `op_users_achievements_2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_achievements_2` (
  `ACHIEVEMENT_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `PROGRESS` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  UNIQUE KEY `ACHIEVEMENT_INFO_ID` (`ACHIEVEMENT_INFO_ID`,`USER_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_achievements_3`
--

DROP TABLE IF EXISTS `op_users_achievements_3`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_achievements_3` (
  `ACHIEVEMENT_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `PROGRESS` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  UNIQUE KEY `ACHIEVEMENT_INFO_ID` (`ACHIEVEMENT_INFO_ID`,`USER_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_achievements_4`
--

DROP TABLE IF EXISTS `op_users_achievements_4`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_achievements_4` (
  `ACHIEVEMENT_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `PROGRESS` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  UNIQUE KEY `ACHIEVEMENT_INFO_ID` (`ACHIEVEMENT_INFO_ID`,`USER_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_achievements_5`
--

DROP TABLE IF EXISTS `op_users_achievements_5`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_achievements_5` (
  `ACHIEVEMENT_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `PROGRESS` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  UNIQUE KEY `ACHIEVEMENT_INFO_ID` (`ACHIEVEMENT_INFO_ID`,`USER_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_achievements_6`
--

DROP TABLE IF EXISTS `op_users_achievements_6`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_achievements_6` (
  `ACHIEVEMENT_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `PROGRESS` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  UNIQUE KEY `ACHIEVEMENT_INFO_ID` (`ACHIEVEMENT_INFO_ID`,`USER_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_achievements_7`
--

DROP TABLE IF EXISTS `op_users_achievements_7`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_achievements_7` (
  `ACHIEVEMENT_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `PROGRESS` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  UNIQUE KEY `ACHIEVEMENT_INFO_ID` (`ACHIEVEMENT_INFO_ID`,`USER_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_achievements_8`
--

DROP TABLE IF EXISTS `op_users_achievements_8`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_achievements_8` (
  `ACHIEVEMENT_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `PROGRESS` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  UNIQUE KEY `ACHIEVEMENT_INFO_ID` (`ACHIEVEMENT_INFO_ID`,`USER_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_achievements_9`
--

DROP TABLE IF EXISTS `op_users_achievements_9`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_achievements_9` (
  `ACHIEVEMENT_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `PROGRESS` int(11) NOT NULL,
  `REWARD_OK` tinyint(4) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  UNIQUE KEY `ACHIEVEMENT_INFO_ID` (`ACHIEVEMENT_INFO_ID`,`USER_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_characters`
--

DROP TABLE IF EXISTS `op_users_characters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_characters` (
  `CHARACTER_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `CHARACTER_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `LEVEL` int(11) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  PRIMARY KEY (`CHARACTER_ID`),
  UNIQUE KEY `CHARACTER_INFO_ID` (`CHARACTER_INFO_ID`,`USER_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=6024 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_friends`
--

DROP TABLE IF EXISTS `op_users_friends`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_friends` (
  `USER_ID` int(11) NOT NULL,
  `FRIEND_USER_ID` bigint(20) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  `DELETE_DATE` datetime DEFAULT NULL,
  `PLAY_DATE` datetime DEFAULT NULL,
  `STATUS` tinyint(4) NOT NULL COMMENT '0:수락대기, 1:친구, 2:요청대기, 3:삭제, 4:거부',
  UNIQUE KEY `USER_ID` (`USER_ID`,`FRIEND_USER_ID`),
  KEY `USER_ID_2` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_instant_items`
--

DROP TABLE IF EXISTS `op_users_instant_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_instant_items` (
  `USER_ID` int(11) NOT NULL,
  `INSTANT_ITEM_ID` int(11) NOT NULL,
  `AMOUNT` int(11) NOT NULL,
  UNIQUE KEY `USER_ID` (`USER_ID`,`INSTANT_ITEM_ID`),
  KEY `USER_ID_2` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_missions_20150701`
--

DROP TABLE IF EXISTS `op_users_missions_20150701`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_missions_20150701` (
  `MISSION_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `MISSION_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `IS_CLEAR` tinyint(4) NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  PRIMARY KEY (`MISSION_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_missions_20150702`
--

DROP TABLE IF EXISTS `op_users_missions_20150702`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_missions_20150702` (
  `MISSION_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `MISSION_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `IS_CLEAR` tinyint(4) NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  PRIMARY KEY (`MISSION_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_missions_20150703`
--

DROP TABLE IF EXISTS `op_users_missions_20150703`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_missions_20150703` (
  `MISSION_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `MISSION_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `IS_CLEAR` tinyint(4) NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  PRIMARY KEY (`MISSION_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_missions_20150704`
--

DROP TABLE IF EXISTS `op_users_missions_20150704`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_missions_20150704` (
  `MISSION_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `MISSION_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `IS_CLEAR` tinyint(4) NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  PRIMARY KEY (`MISSION_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_missions_20150915`
--

DROP TABLE IF EXISTS `op_users_missions_20150915`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_missions_20150915` (
  `MISSION_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `MISSION_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `IS_CLEAR` tinyint(4) NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  PRIMARY KEY (`MISSION_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_missions_20150922`
--

DROP TABLE IF EXISTS `op_users_missions_20150922`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_missions_20150922` (
  `MISSION_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `MISSION_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `IS_CLEAR` tinyint(4) NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  PRIMARY KEY (`MISSION_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_missions_20151103`
--

DROP TABLE IF EXISTS `op_users_missions_20151103`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_missions_20151103` (
  `MISSION_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `MISSION_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `IS_CLEAR` tinyint(4) NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  PRIMARY KEY (`MISSION_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_missions_20151104`
--

DROP TABLE IF EXISTS `op_users_missions_20151104`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_missions_20151104` (
  `MISSION_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `MISSION_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `IS_CLEAR` tinyint(4) NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  PRIMARY KEY (`MISSION_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_missions_20151105`
--

DROP TABLE IF EXISTS `op_users_missions_20151105`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_missions_20151105` (
  `MISSION_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `MISSION_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `IS_CLEAR` tinyint(4) NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  PRIMARY KEY (`MISSION_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_missions_20151117`
--

DROP TABLE IF EXISTS `op_users_missions_20151117`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_missions_20151117` (
  `MISSION_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `MISSION_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `IS_CLEAR` tinyint(4) NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  PRIMARY KEY (`MISSION_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=163 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_missions_20151118`
--

DROP TABLE IF EXISTS `op_users_missions_20151118`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_missions_20151118` (
  `MISSION_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `MISSION_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `IS_CLEAR` tinyint(4) NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  PRIMARY KEY (`MISSION_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_missions_20151119`
--

DROP TABLE IF EXISTS `op_users_missions_20151119`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_missions_20151119` (
  `MISSION_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `MISSION_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `IS_CLEAR` tinyint(4) NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  PRIMARY KEY (`MISSION_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_missions_20151120`
--

DROP TABLE IF EXISTS `op_users_missions_20151120`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_missions_20151120` (
  `MISSION_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `MISSION_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `IS_CLEAR` tinyint(4) NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  PRIMARY KEY (`MISSION_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_skills`
--

DROP TABLE IF EXISTS `op_users_skills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_skills` (
  `SKILL_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `SKILL_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `LEVEL` int(11) NOT NULL,
  `SLOT_NUMBER` tinyint(4) DEFAULT NULL,
  `CREATE_DATE` datetime NOT NULL,
  PRIMARY KEY (`SKILL_ID`),
  UNIQUE KEY `SKILL_INFO_ID` (`SKILL_INFO_ID`,`USER_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=7287 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_stages_0`
--

DROP TABLE IF EXISTS `op_users_stages_0`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_stages_0` (
  `STAGE_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `BEST_SCORE` int(11) NOT NULL DEFAULT '0',
  `CLEAR_COUNT` int(11) NOT NULL DEFAULT '0',
  `CREATE_DATE` datetime NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  `PERFECT` tinyint(1) DEFAULT NULL,
  UNIQUE KEY `STAGE_ID` (`STAGE_ID`,`USER_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_stages_1`
--

DROP TABLE IF EXISTS `op_users_stages_1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_stages_1` (
  `STAGE_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `BEST_SCORE` int(11) NOT NULL DEFAULT '0',
  `CLEAR_COUNT` int(11) NOT NULL DEFAULT '0',
  `CREATE_DATE` datetime NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  `PERFECT` tinyint(1) DEFAULT NULL,
  UNIQUE KEY `STAGE_ID` (`STAGE_ID`,`USER_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_stages_2`
--

DROP TABLE IF EXISTS `op_users_stages_2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_stages_2` (
  `STAGE_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `BEST_SCORE` int(11) NOT NULL DEFAULT '0',
  `CLEAR_COUNT` int(11) NOT NULL DEFAULT '0',
  `CREATE_DATE` datetime NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  `PERFECT` tinyint(1) DEFAULT NULL,
  UNIQUE KEY `STAGE_ID` (`STAGE_ID`,`USER_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_stages_3`
--

DROP TABLE IF EXISTS `op_users_stages_3`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_stages_3` (
  `STAGE_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `BEST_SCORE` int(11) NOT NULL DEFAULT '0',
  `CLEAR_COUNT` int(11) NOT NULL DEFAULT '0',
  `CREATE_DATE` datetime NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  `PERFECT` tinyint(1) DEFAULT NULL,
  UNIQUE KEY `STAGE_ID` (`STAGE_ID`,`USER_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_stages_4`
--

DROP TABLE IF EXISTS `op_users_stages_4`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_stages_4` (
  `STAGE_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `BEST_SCORE` int(11) NOT NULL DEFAULT '0',
  `CLEAR_COUNT` int(11) NOT NULL DEFAULT '0',
  `CREATE_DATE` datetime NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  `PERFECT` tinyint(1) DEFAULT NULL,
  UNIQUE KEY `STAGE_ID` (`STAGE_ID`,`USER_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_stages_5`
--

DROP TABLE IF EXISTS `op_users_stages_5`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_stages_5` (
  `STAGE_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `BEST_SCORE` int(11) NOT NULL DEFAULT '0',
  `CLEAR_COUNT` int(11) NOT NULL DEFAULT '0',
  `CREATE_DATE` datetime NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  `PERFECT` tinyint(1) DEFAULT NULL,
  UNIQUE KEY `STAGE_ID` (`STAGE_ID`,`USER_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_stages_6`
--

DROP TABLE IF EXISTS `op_users_stages_6`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_stages_6` (
  `STAGE_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `BEST_SCORE` int(11) NOT NULL DEFAULT '0',
  `CLEAR_COUNT` int(11) NOT NULL DEFAULT '0',
  `CREATE_DATE` datetime NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  `PERFECT` tinyint(1) DEFAULT NULL,
  UNIQUE KEY `STAGE_ID` (`STAGE_ID`,`USER_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_stages_7`
--

DROP TABLE IF EXISTS `op_users_stages_7`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_stages_7` (
  `STAGE_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `BEST_SCORE` int(11) NOT NULL DEFAULT '0',
  `CLEAR_COUNT` int(11) NOT NULL DEFAULT '0',
  `CREATE_DATE` datetime NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  `PERFECT` tinyint(1) DEFAULT NULL,
  UNIQUE KEY `STAGE_ID` (`STAGE_ID`,`USER_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_stages_8`
--

DROP TABLE IF EXISTS `op_users_stages_8`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_stages_8` (
  `STAGE_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `BEST_SCORE` int(11) NOT NULL DEFAULT '0',
  `CLEAR_COUNT` int(11) NOT NULL DEFAULT '0',
  `CREATE_DATE` datetime NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  `PERFECT` tinyint(1) DEFAULT NULL,
  UNIQUE KEY `STAGE_ID` (`STAGE_ID`,`USER_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_stages_9`
--

DROP TABLE IF EXISTS `op_users_stages_9`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_stages_9` (
  `STAGE_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `CLEAR_TYPE` tinyint(4) NOT NULL,
  `BEST_SCORE` int(11) NOT NULL DEFAULT '0',
  `CLEAR_COUNT` int(11) NOT NULL DEFAULT '0',
  `CREATE_DATE` datetime NOT NULL,
  `UPDATE_DATE` datetime DEFAULT NULL,
  `PERFECT` tinyint(1) DEFAULT NULL,
  UNIQUE KEY `STAGE_ID` (`STAGE_ID`,`USER_ID`),
  KEY `USER_ID` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `op_users_treasures`
--

DROP TABLE IF EXISTS `op_users_treasures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `op_users_treasures` (
  `TREASURE_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `TREASURE_INFO_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `LEVEL` int(11) NOT NULL,
  `SLOT_NUMBER` tinyint(4) DEFAULT NULL,
  `CREATE_DATE` datetime NOT NULL,
  `DELETE_DATE` datetime DEFAULT NULL,
  `IS_DELETE` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`TREASURE_ID`),
  KEY `USER_ID` (`USER_ID`)
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

-- Dump completed on 2015-11-17 15:21:26
