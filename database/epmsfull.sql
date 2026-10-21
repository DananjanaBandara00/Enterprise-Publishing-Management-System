-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: epms
-- ------------------------------------------------------
-- Server version	8.0.43

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `announcements`
--

DROP TABLE IF EXISTS `announcements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `announcements` (
  `announcement_id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_by` bigint NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `audience` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ALL',
  PRIMARY KEY (`announcement_id`),
  KEY `fk_announcements_user` (`created_by`),
  CONSTRAINT `fk_announcements_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `announcements`
--

LOCK TABLES `announcements` WRITE;
/*!40000 ALTER TABLE `announcements` DISABLE KEYS */;
INSERT INTO `announcements` VALUES (1,'Test','test','2026-09-25 18:30:00','2026-10-01 18:29:59',4,'2026-09-26 12:47:12','2026-09-26 12:47:12','ALL'),(2,'New Book Collection Available','Our new fiction collection is now available.','2026-10-01 18:30:00','2026-11-02 18:29:59',4,'2026-10-02 17:59:53','2026-10-02 17:59:53','CUSTOMER'),(3,'maintaing 8.30 am - 17.00 pm','can\'t use site','2026-10-10 18:30:00','2026-10-11 18:29:59',4,'2026-10-03 11:47:14','2026-10-03 11:47:14','SALES_STAFF'),(5,'Readers Months','Readers Months sales','2026-10-02 18:30:00','2026-10-31 18:29:59',4,'2026-10-03 12:05:41','2026-10-03 12:05:41','ALL');
/*!40000 ALTER TABLE `announcements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_logs` (
  `audit_log_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint DEFAULT NULL,
  `action` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_id` bigint DEFAULT NULL,
  `details` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`audit_log_id`),
  KEY `fk_audit_logs_user` (`user_id`),
  CONSTRAINT `fk_audit_logs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=80 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
INSERT INTO `audit_logs` VALUES (1,9002,'MANUSCRIPT_SUBMITTED','Manuscript',2,'MS-2026-00002',NULL,'2026-09-27 11:28:13'),(2,9018,'MANUSCRIPT_SUBMITTED','Manuscript',3,'MS-2026-00003 → PENDING_SUPER_ADMIN_REVIEW',NULL,'2026-10-02 14:48:19'),(3,9018,'MANUSCRIPT_SUBMITTED','Manuscript',4,'MS-2026-00004 → PENDING_SUPER_ADMIN_REVIEW',NULL,'2026-10-02 14:49:10'),(4,9003,'SUPER_ADMIN_ACCEPT','Manuscript',4,'MS-2026-00004 accepted → SUBMITTED',NULL,'2026-10-02 14:51:40'),(5,9003,'SUPER_ADMIN_ACCEPT','Manuscript',3,'MS-2026-00003 accepted → SUBMITTED',NULL,'2026-10-02 14:51:44'),(6,9004,'MANUSCRIPT_ASSIGNED','Manuscript',3,'Assigned to Kamala Fernando: demo',NULL,'2026-10-02 14:53:31'),(7,9012,'EDITORIAL_DECISION','Manuscript',3,'ACCEPT (round 1)',NULL,'2026-10-02 14:56:53'),(8,9007,'BOOK_READY_FOR_PRINTING','Book',1,'MS-2026-00003',NULL,'2026-10-02 15:11:41'),(9,9009,'ORDER_CONFIRMED','CustomerOrder',3,'CO-2026-00003',NULL,'2026-10-02 17:26:30'),(10,9009,'ORDER_CONFIRMED','CustomerOrder',2,'CO-2026-00002',NULL,'2026-10-02 17:26:37'),(11,9009,'ORDER_CONFIRMED','CustomerOrder',1,'CO-2026-00001',NULL,'2026-10-02 17:26:41'),(12,9009,'ORDER_CONFIRMED','CustomerOrder',4,'CO-2026-00004',NULL,'2026-10-02 17:30:34'),(13,4,'SETTING_CHANGED','SystemSetting',4,'royaltyPaymentThreshold: 1000.00 -> 2000.00',NULL,'2026-10-02 17:57:14'),(14,4,'SETTING_CHANGED','SystemSetting',7,'Company Name: (not set) -> Reading Planet Publishers',NULL,'2026-10-02 17:57:50'),(15,5,'INVOICE_ISSUED','FinancialInvoice',2,'INV-2026-00002',NULL,'2026-10-02 18:29:49'),(16,5,'INVOICE_CANCELLED','FinancialInvoice',2,'INV-2026-00002: due to payment problem',NULL,'2026-10-02 18:30:08'),(17,5,'INVOICE_ISSUED','FinancialInvoice',1,'INV-2026-00001',NULL,'2026-10-02 18:30:57'),(18,5,'INVOICE_PAYMENT_RECORDED','FinancialInvoice',1,'4000.00 by BANK_TRANSFER, reference Bank',NULL,'2026-10-02 18:31:12'),(19,5,'INVOICE_ISSUED','FinancialInvoice',3,'INV-2026-00003',NULL,'2026-10-02 18:32:38'),(20,5,'INVOICE_PAYMENT_RECORDED','FinancialInvoice',3,'25000.00 by BANK_TRANSFER, reference Boc',NULL,'2026-10-02 18:32:57'),(21,5,'REPORT_GENERATED','FinancialReport',1,'REVENUE 2025-11-01 to 2026-10-03',NULL,'2026-10-02 18:34:00'),(22,5,'REPORT_FINALIZED','FinancialReport',1,'REVENUE 2025-11-01 to 2026-10-03',NULL,'2026-10-02 18:35:09'),(23,5,'ROYALTY_CALCULATED','RoyaltyCalculation',1,'Agreement RA-299963B7, 2026-08-03 to 2026-10-03, gross royalty 5500.00, payable 5500.00',NULL,'2026-10-02 18:39:44'),(24,5,'ROYALTY_CANCELLED','RoyaltyCalculation',1,'Recalculated',NULL,'2026-10-02 18:39:53'),(25,5,'ROYALTY_CALCULATED','RoyaltyCalculation',2,'Agreement RA-299963B7, 2026-08-03 to 2026-10-03, gross royalty 5500.00, payable 5500.00',NULL,'2026-10-02 18:39:53'),(26,5,'ROYALTY_STATEMENT_ISSUED','RoyaltyCalculation',2,'Statement RS-2026-00001',NULL,'2026-10-02 18:39:56'),(27,5,'ROYALTY_APPROVED','RoyaltyCalculation',2,'Payable 5500.00 approved for payment',NULL,'2026-10-02 18:40:16'),(28,5,'ROYALTY_PAID','RoyaltyPayment',1,'Paid 5500.00 by BANK_TRANSFER, reference boc',NULL,'2026-10-02 18:40:26'),(29,5,'REPORT_GENERATED','FinancialReport',2,'EXPENSE 2025-11-01 to 2026-10-03',NULL,'2026-10-02 19:00:50'),(30,5,'REPORT_GENERATED','FinancialReport',3,'PROFIT_AND_LOSS 2025-11-01 to 2026-10-03',NULL,'2026-10-03 04:48:54'),(31,5,'REPORT_GENERATED','FinancialReport',4,'EXPENSE 2025-11-01 to 2026-10-03',NULL,'2026-10-03 05:02:59'),(32,5,'REPORT_FINALIZED','FinancialReport',4,'EXPENSE 2025-11-01 to 2026-10-03',NULL,'2026-10-03 05:05:17'),(33,5,'ROYALTY_AGREEMENT_SENT','RoyaltyAgreement',2,'Sent to Udula Hettiarachchi for signature',NULL,'2026-10-03 05:09:17'),(34,9018,'ROYALTY_AGREEMENT_SIGNED','RoyaltyAgreement',2,'Signed by the author: RA-5549709F',NULL,'2026-10-03 05:11:13'),(35,9003,'PUBLISHING_APPLICATION_APPROVED','PublishingApplication',1,'nenulagunasekare@gmail.com',NULL,'2026-10-03 05:44:48'),(36,9024,'MANUSCRIPT_SUBMITTED','Manuscript',6,'MS-2026-00006 → PENDING_SUPER_ADMIN_REVIEW',NULL,'2026-10-03 06:04:42'),(37,9003,'PUBLISHING_APPLICATION_APPROVED','PublishingApplication',2,'randika@gmail.com',NULL,'2026-10-03 06:09:39'),(38,9025,'MANUSCRIPT_SUBMITTED','Manuscript',7,'MS-2026-00007 → PENDING_SUPER_ADMIN_REVIEW',NULL,'2026-10-03 06:16:25'),(39,9025,'MANUSCRIPT_SUBMITTED','Manuscript',8,'MS-2026-00008 → PENDING_SUPER_ADMIN_REVIEW',NULL,'2026-10-03 06:19:08'),(40,9026,'MANUSCRIPT_SUBMITTED','Manuscript',10,'MS-2026-00010 → PENDING_SUPER_ADMIN_REVIEW',NULL,'2026-10-03 06:41:01'),(41,9003,'PUBLISHING_APPLICATION_APPROVED','PublishingApplication',3,'nisalmamandini@gmail.com',NULL,'2026-10-03 07:46:21'),(42,9026,'MANUSCRIPT_SUBMITTED','Manuscript',11,'MS-2026-00011 → PENDING_SUPER_ADMIN_REVIEW',NULL,'2026-10-03 07:53:14'),(43,9003,'SUPER_ADMIN_ACCEPT','Manuscript',6,'MS-2026-00006 accepted → SUBMITTED',NULL,'2026-10-03 07:57:45'),(44,9003,'SUPER_ADMIN_ACCEPT','Manuscript',7,'MS-2026-00007 accepted → SUBMITTED',NULL,'2026-10-03 07:57:48'),(45,9003,'SUPER_ADMIN_ACCEPT','Manuscript',8,'MS-2026-00008 accepted → SUBMITTED',NULL,'2026-10-03 07:57:50'),(46,9003,'SUPER_ADMIN_ACCEPT','Manuscript',10,'MS-2026-00010 accepted → SUBMITTED',NULL,'2026-10-03 07:57:52'),(47,9003,'SUPER_ADMIN_ACCEPT','Manuscript',11,'MS-2026-00011 accepted → SUBMITTED',NULL,'2026-10-03 07:57:55'),(48,9004,'MANUSCRIPT_ASSIGNED','Manuscript',11,'Assigned to Anusha Jayasinghe: demo',NULL,'2026-10-03 07:58:38'),(49,9013,'EDITORIAL_DECISION','Manuscript',11,'ACCEPT (round 1)',NULL,'2026-10-03 08:00:35'),(50,9007,'BOOK_READY_FOR_PRINTING','Book',2,'MS-2026-00011',NULL,'2026-10-03 08:05:41'),(51,9009,'ORDER_CONFIRMED','CustomerOrder',5,'CO-2026-00005',NULL,'2026-10-03 08:11:06'),(52,9004,'MANUSCRIPT_ASSIGNED','Manuscript',10,'Assigned to Kamala Fernando: demo',NULL,'2026-10-03 08:54:02'),(53,9004,'MANUSCRIPT_ASSIGNED','Manuscript',8,'Assigned to Ruwan Perera: demo',NULL,'2026-10-03 08:54:34'),(54,9004,'MANUSCRIPT_ASSIGNED','Manuscript',6,'Assigned to Anusha Jayasinghe: demo',NULL,'2026-10-03 08:54:49'),(55,9004,'MANUSCRIPT_ASSIGNED','Manuscript',2,'Assigned to Kamala Fernando: demo',NULL,'2026-10-03 08:56:58'),(56,9012,'EDITORIAL_DECISION','Manuscript',10,'ACCEPT (round 1)',NULL,'2026-10-03 08:59:37'),(57,9012,'EDITORIAL_DECISION','Manuscript',2,'ACCEPT (round 1)',NULL,'2026-10-03 08:59:55'),(58,9013,'EDITORIAL_DECISION','Manuscript',6,'ACCEPT (round 1)',NULL,'2026-10-03 09:02:13'),(59,9014,'EDITORIAL_DECISION','Manuscript',8,'ACCEPT (round 1)',NULL,'2026-10-03 09:05:21'),(60,9007,'BOOK_READY_FOR_PRINTING','Book',3,'MS-2026-00010',NULL,'2026-10-03 09:22:18'),(61,9007,'BOOK_READY_FOR_PRINTING','Book',4,'MS-2026-00006',NULL,'2026-10-03 09:39:50'),(62,9007,'BOOK_READY_FOR_PRINTING','Book',5,'MS-2026-00008',NULL,'2026-10-03 09:41:04'),(63,9007,'BOOK_READY_FOR_PRINTING','Book',6,'MS-2026-00002',NULL,'2026-10-03 09:42:05'),(64,9009,'ORDER_CONFIRMED','CustomerOrder',8,'CO-2026-00008',NULL,'2026-10-03 10:00:09'),(65,9009,'ORDER_CONFIRMED','CustomerOrder',7,'CO-2026-00007',NULL,'2026-10-03 10:00:12'),(66,9009,'ORDER_CONFIRMED','CustomerOrder',6,'CO-2026-00006',NULL,'2026-10-03 10:00:16'),(67,9003,'PUBLISHING_APPLICATION_APPROVED','PublishingApplication',4,'harshani@gmail.com',NULL,'2026-10-03 10:28:50'),(68,9027,'MANUSCRIPT_SUBMITTED','Manuscript',12,'MS-2026-00012 → PENDING_SUPER_ADMIN_REVIEW',NULL,'2026-10-03 10:33:00'),(69,9003,'SUPER_ADMIN_ACCEPT','Manuscript',12,'MS-2026-00012 accepted → SUBMITTED',NULL,'2026-10-03 10:34:33'),(70,9004,'MANUSCRIPT_ASSIGNED','Manuscript',12,'Assigned to Kamala Fernando: Please conduct the initial editorial review of the submitted manuscript. Assess the structure, character development, narrative consistency, pacing, and overall suitability for publication, and provide your editorial recommendations after completing the review.',NULL,'2026-10-03 10:37:19'),(71,9004,'MANUSCRIPT_ASSIGNED','Manuscript',12,'Reassigned to Anusha Jayasinghe',NULL,'2026-10-03 10:37:57'),(72,9004,'MANUSCRIPT_UNASSIGNED','Manuscript',12,'Assignment cancelled (previous editor userId=9013)',NULL,'2026-10-03 10:38:02'),(73,9004,'MANUSCRIPT_ASSIGNED','Manuscript',12,'Assigned to Kamala Fernando: Please conduct the initial editorial review of the submitted manuscript. Assess the structure, character development, narrative consistency, pacing, and overall suitability for publication, and provide your editorial recommendations after completing the review.',NULL,'2026-10-03 10:38:12'),(74,9012,'EDITORIAL_DECISION','Manuscript',12,'REVISION_REQUIRED (round 1)',NULL,'2026-10-03 10:42:14'),(75,9012,'EDITORIAL_DECISION','Manuscript',12,'ACCEPT (round 2)',NULL,'2026-10-03 10:48:01'),(76,9007,'BOOK_READY_FOR_PRINTING','Book',7,'MS-2026-00012',NULL,'2026-10-03 11:20:26'),(77,4,'SETTING_CHANGED','SystemSetting',7,'Company Name: Reading Planet Publishers -> Reading Planet',NULL,'2026-10-03 11:36:24'),(78,4,'SETTING_CHANGED','SystemSetting',1,'currency: LKR -> GBP',NULL,'2026-10-03 11:38:42'),(79,4,'SETTING_CHANGED','SystemSetting',1,'currency: GBP -> LKR',NULL,'2026-10-03 11:39:32');
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `author_approvals`
--

DROP TABLE IF EXISTS `author_approvals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `author_approvals` (
  `approval_id` bigint NOT NULL AUTO_INCREMENT,
  `design_id` bigint NOT NULL,
  `author_id` bigint NOT NULL,
  `approval_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `comments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `reviewed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`approval_id`),
  KEY `fk_author_approvals_design` (`design_id`),
  KEY `fk_author_approvals_author` (`author_id`),
  CONSTRAINT `fk_author_approvals_author` FOREIGN KEY (`author_id`) REFERENCES `authors` (`author_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_author_approvals_design` FOREIGN KEY (`design_id`) REFERENCES `book_designs` (`design_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `author_approvals`
--

LOCK TABLES `author_approvals` WRITE;
/*!40000 ALTER TABLE `author_approvals` DISABLE KEYS */;
INSERT INTO `author_approvals` VALUES (1,1,2,'APPROVED','demo','2026-10-02 15:06:40','2026-10-02 15:06:40'),(2,2,5,'APPROVED','all good','2026-10-03 08:04:27','2026-10-03 08:04:27'),(3,3,5,'APPROVED','All good','2026-10-03 09:15:44','2026-10-03 09:15:44'),(4,7,3,'APPROVED','All good','2026-10-03 09:16:47','2026-10-03 09:16:47'),(5,6,4,'APPROVED','All good','2026-10-03 09:17:41','2026-10-03 09:17:41'),(6,5,1,'APPROVED','All good','2026-10-03 09:19:49','2026-10-03 09:19:49'),(7,8,6,'REJECTED','The overall design is promising, but the cover does not match the atmosphere of the manuscript as expected. The interior layout also needs adjustments to the chapter spacing and text presentation.','2026-10-03 10:56:37','2026-10-03 10:56:37'),(8,9,6,'APPROVED',NULL,'2026-10-03 11:00:36','2026-10-03 11:00:36');
/*!40000 ALTER TABLE `author_approvals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `author_bank_details`
--

DROP TABLE IF EXISTS `author_bank_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `author_bank_details` (
  `bank_detail_id` bigint NOT NULL AUTO_INCREMENT,
  `author_id` bigint NOT NULL,
  `account_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `bank_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `account_number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `branch` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`bank_detail_id`),
  UNIQUE KEY `uq_author_bank_author` (`author_id`),
  CONSTRAINT `fk_author_bank_author` FOREIGN KEY (`author_id`) REFERENCES `authors` (`author_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `author_bank_details`
--

LOCK TABLES `author_bank_details` WRITE;
/*!40000 ALTER TABLE `author_bank_details` DISABLE KEYS */;
INSERT INTO `author_bank_details` VALUES (1,2,'Udula Hettiarachchi','BOC','1111','mathugama','2026-10-02 18:45:24'),(2,4,'Randia Kadawathaarachchi','BOC','154328','Ampe','2026-10-03 06:25:17'),(3,5,'Nisalma Werake','BOC','315624','Balummahara','2026-10-03 06:44:37');
/*!40000 ALTER TABLE `author_bank_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `author_finance_notifications`
--

DROP TABLE IF EXISTS `author_finance_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `author_finance_notifications` (
  `notification_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`),
  KEY `idx_author_notifications_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `author_finance_notifications`
--

LOCK TABLES `author_finance_notifications` WRITE;
/*!40000 ALTER TABLE `author_finance_notifications` DISABLE KEYS */;
INSERT INTO `author_finance_notifications` VALUES (1,9018,'STATEMENT_ISSUED','Royalty statement RS-2026-00001 issued','Your royalty statement for 2026-08-03 to 2026-10-03 is ready. Payable: 5500.00.',0,'2026-10-02 18:39:56'),(2,9018,'ROYALTY_PAID','Royalty payment made','5500.00 was paid for statement RS-2026-00001 by bank transfer (reference boc).',0,'2026-10-02 18:40:26'),(3,9018,'BANK_DETAILS_UPDATED','Bank details updated','Your bank details were updated. Future royalty payments will be made to BOC.',0,'2026-10-02 18:45:24'),(4,9018,'BANK_DETAILS_UPDATED','Bank details updated','Your bank details were updated. Future royalty payments will be made to BOC.',0,'2026-10-02 18:49:11'),(5,9018,'BANK_DETAILS_UPDATED','Bank details updated','Your bank details were updated. Future royalty payments will be made to BOC.',0,'2026-10-03 04:45:46'),(6,9018,'AGREEMENT_SENT','New agreement RA-5549709F to sign','A publishing & royalty agreement for Ikigai (7.00% royalty) is waiting for your review and signature under Contracts & Royalties.',0,'2026-10-03 05:09:17'),(7,9018,'AGREEMENT_SIGNED','Agreement RA-5549709F signed','Thank you. Finance will now activate the agreement; you will be notified when it is active.',0,'2026-10-03 05:11:13'),(8,9025,'BANK_DETAILS_UPDATED','Bank details updated','Your bank details were updated. Future royalty payments will be made to BOC.',0,'2026-10-03 06:25:17'),(9,9026,'BANK_DETAILS_UPDATED','Bank details updated','Your bank details were updated. Future royalty payments will be made to BOC.',0,'2026-10-03 06:44:37');
/*!40000 ALTER TABLE `author_finance_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `authors`
--

DROP TABLE IF EXISTS `authors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `authors` (
  `author_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `author_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `pen_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `biography` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `date_of_birth` date DEFAULT NULL,
  `nationality` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `website` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`author_id`),
  UNIQUE KEY `uq_authors_user` (`user_id`),
  UNIQUE KEY `uq_authors_author_code` (`author_code`),
  CONSTRAINT `fk_authors_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `authors`
--

LOCK TABLES `authors` WRITE;
/*!40000 ALTER TABLE `authors` DISABLE KEYS */;
INSERT INTO `authors` VALUES (1,9002,'AUT-2026-00001','manjula dissanayke','huhuswhsjjkhn','1957-10-21','Sri lankan',NULL,'ACTIVE','2026-09-27 11:15:46','2026-09-27 11:27:43'),(2,9018,'AUT-2026-00002','Udula Hettiarachchi','demo','2004-10-23','Sri lankan',NULL,'ACTIVE','2026-10-02 14:43:12','2026-10-02 14:43:55'),(3,9024,'AUT-2026-00003','Sahas Gunasekare','Sahas Gunasekare is an Information Technology graduate from the University of Colombo and a digital content creator. Specializing in young adult fiction, fantasy, and Sinhala translations, her work introduces fresh narrative styles tailored to the modern reader. His notable translation Shadows of Midnight received widespread appreciation. She is an avid traveler, book reviewer, and resides in Gampaha.','2003-02-27','Sri lankan',NULL,'ACTIVE','2026-10-03 05:46:15','2026-10-03 06:03:06'),(4,9025,'AUT-2026-00004','Randika Kadawathaarachchi','Randika Kadawathaarachchi is the Sri Lankan bestselling author of the Detective Clara King mystery series. Known for her sharp dialogue, intricate plotting, and atmospheric settings,Randika has published six psychological thrillers that have been translated into 12 languages worldwide. His breakout novel, Before the Fog Clears, won the 2024 Silver Dagger Award for Best Crime Novel.','1995-03-14','Sri lankan',NULL,'ACTIVE','2026-10-03 06:10:47','2026-10-03 06:13:49'),(5,9026,'AUT-2026-00005','Nisalma Werake','Nisalma is a passionate advocate for workplace gender equity and sits on the advisory board of Women in Tech International. When she isn\'t writing or teaching, she is an avid long-distance runner and amateur ceramicist. She currently lives in Balummahara, with her partner and their two golden retrievers.','2003-08-14','Sri lankan',NULL,'ACTIVE','2026-10-03 06:33:16','2026-10-03 06:39:13'),(6,9027,'AUT-2026-00006','Hrshani Abeysinghe','HOUPIxghoigo','2002-07-22','Sri lankan',NULL,'ACTIVE','2026-10-03 10:30:07','2026-10-03 10:31:24');
/*!40000 ALTER TABLE `authors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `book_designs`
--

DROP TABLE IF EXISTS `book_designs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `book_designs` (
  `design_id` bigint NOT NULL AUTO_INCREMENT,
  `manuscript_id` bigint NOT NULL,
  `designer_id` bigint NOT NULL,
  `design_version` int NOT NULL,
  `cover_file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `layout_file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `design_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `design_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DRAFT',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `print_file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `submitted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`design_id`),
  UNIQUE KEY `uq_book_design_version` (`manuscript_id`,`design_version`),
  KEY `fk_book_designs_designer` (`designer_id`),
  CONSTRAINT `fk_book_designs_designer` FOREIGN KEY (`designer_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_book_designs_manuscript` FOREIGN KEY (`manuscript_id`) REFERENCES `manuscripts` (`manuscript_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `book_designs`
--

LOCK TABLES `book_designs` WRITE;
/*!40000 ALTER TABLE `book_designs` DISABLE KEYS */;
INSERT INTO `book_designs` VALUES (1,3,9016,1,'designs/3/4161517e-c28.jpg','designs/3/23f65f5c-a05.pdf','demo','APPROVED','2026-10-02 15:05:30','2026-10-02 15:06:40','designs/3/914d6f66-96e.pdf','2026-10-02 15:05:48'),(2,11,9017,1,'designs/11/7b3e954c-66b.png','designs/11/8fcf0a7f-729.pdf','check everything. no changes will accepted later','APPROVED','2026-10-03 08:03:42','2026-10-03 08:04:27','designs/11/c4737602-c5d.pdf','2026-10-03 08:03:45'),(3,10,9017,1,'designs/10/33b9fc90-c82.jpg','designs/10/10300183-085.pdf','Check everything. no changes will accepted later','APPROVED','2026-10-03 09:09:16','2026-10-03 09:15:44','designs/10/0ad0f6bb-3f6.pdf','2026-10-03 09:09:22'),(4,2,9017,1,'designs/2/b2b904d0-ea1.jpg','designs/2/f1bcb369-618.pdf','Check everything. no changes will accepted later','SUPERSEDED','2026-10-03 09:11:41','2026-10-03 09:12:19','designs/2/b5456887-9c6.pdf',NULL),(5,2,9017,2,'designs/2/27807aa9-02d.png','designs/2/7eb1993d-c7c.pdf','Check everything. no changes will accepted later','APPROVED','2026-10-03 09:12:19','2026-10-03 09:19:49','designs/2/f7c2e5fb-e28.pdf','2026-10-03 09:12:31'),(6,8,9017,1,'designs/8/810c9bfc-905.jpg','designs/8/084f54a2-83b.pdf','Check everything. no changes will accepted later','APPROVED','2026-10-03 09:14:08','2026-10-03 09:17:41','designs/8/0d9792f6-3f0.pdf','2026-10-03 09:14:11'),(7,6,9017,1,'designs/6/fce3b537-dab.jpg','designs/6/fd268713-33d.pdf','Check everything. no changes will accepted later','APPROVED','2026-10-03 09:14:57','2026-10-03 09:16:47','designs/6/c58c686b-6b3.pdf','2026-10-03 09:15:01'),(8,12,9017,1,'designs/12/4114d14d-578.png','designs/12/2fde9ea7-43e.pdf',NULL,'REJECTED','2026-10-03 10:52:46','2026-10-03 10:56:37','designs/12/d9f0d51a-e7d.pdf','2026-10-03 10:53:39'),(9,12,9017,2,'designs/12/7eae7dc7-3e0.png','designs/12/2fc7c51a-35a.pdf',NULL,'SUPERSEDED','2026-10-03 10:58:50','2026-10-03 11:05:00','designs/12/994e43f5-a55.pdf','2026-10-03 10:59:49'),(10,12,9017,3,'designs/12/0e171f22-2bc.png','designs/12/028c1a2b-a83.pdf',NULL,'APPROVED','2026-10-03 11:03:19','2026-10-03 11:05:00','designs/12/92f2653c-0f9.pdf','2026-10-03 11:05:00');
/*!40000 ALTER TABLE `book_designs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `books`
--

DROP TABLE IF EXISTS `books`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `books` (
  `book_id` bigint NOT NULL AUTO_INCREMENT,
  `manuscript_id` bigint NOT NULL,
  `category_id` bigint NOT NULL,
  `genre_id` bigint NOT NULL,
  `isbn` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `edition` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cover_image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `publication_date` date DEFAULT NULL,
  `price` decimal(12,2) NOT NULL,
  `total_pages` int DEFAULT NULL,
  `language` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `book_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PUBLISHED',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`book_id`),
  UNIQUE KEY `uq_books_isbn` (`isbn`),
  UNIQUE KEY `uq_books_manuscript` (`manuscript_id`),
  KEY `fk_books_category` (`category_id`),
  KEY `fk_books_genre` (`genre_id`),
  CONSTRAINT `fk_books_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_books_genre` FOREIGN KEY (`genre_id`) REFERENCES `genres` (`genre_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_books_manuscript` FOREIGN KEY (`manuscript_id`) REFERENCES `manuscripts` (`manuscript_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `books`
--

LOCK TABLES `books` WRITE;
/*!40000 ALTER TABLE `books` DISABLE KEYS */;
INSERT INTO `books` VALUES (1,3,1,1,'978-955-000001-2','Ikigai','1st','designs/3/4161517e-c28.jpg','2026-10-14',2500.00,16,'English','PUBLISHED','2026-10-02 15:11:41','2026-10-02 16:57:27'),(2,11,5,7,'978-955-000002-9','I don\'t love you anymore','1st','designs/11/7b3e954c-66b.png','2026-10-03',2500.00,1,'English','PUBLISHED','2026-10-03 08:05:41','2026-10-03 08:08:39'),(3,10,1,4,'978-955-000003-6','Healing Is The New High','1st','designs/10/33b9fc90-c82.jpg','2026-10-04',3200.00,19,'Sinhala','PUBLISHED','2026-10-03 09:22:18','2026-10-03 09:53:04'),(4,6,1,7,'978-955-000004-3','Radalathanna Walawwa','1st','designs/6/fce3b537-dab.jpg','2026-10-03',2500.00,21,'Sinhala','PUBLISHED','2026-10-03 09:39:50','2026-10-03 09:53:20'),(5,8,7,7,'978-955-000005-0','Magart','1st','designs/8/810c9bfc-905.jpg','2026-10-03',2100.00,23,'Sinhala','PUBLISHED','2026-10-03 09:41:04','2026-10-03 09:52:21'),(6,2,6,2,'978-955-000006-7','Amazonia','1st','designs/2/27807aa9-02d.png','2026-10-03',550.00,67,'Sinhala','PUBLISHED','2026-10-03 09:42:05','2026-10-03 09:51:59'),(7,12,2,1,'978-955-000007-4','The Last Light of Galle','1st','designs/12/0e171f22-2bc.png','2026-10-21',550.00,10,'Sinhala','READY_FOR_PRINTING','2026-10-03 11:20:26','2026-10-03 11:20:26');
/*!40000 ALTER TABLE `books` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bookstore_order_items`
--

DROP TABLE IF EXISTS `bookstore_order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bookstore_order_items` (
  `bookstore_order_item_id` bigint NOT NULL AUTO_INCREMENT,
  `bookstore_order_id` bigint NOT NULL,
  `book_id` bigint NOT NULL,
  `quantity` int NOT NULL,
  `unit_price` decimal(12,2) NOT NULL,
  `subtotal` decimal(12,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`bookstore_order_item_id`),
  KEY `fk_bookstore_order_items_order` (`bookstore_order_id`),
  KEY `fk_bookstore_order_items_book` (`book_id`),
  CONSTRAINT `fk_bookstore_order_items_book` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_bookstore_order_items_order` FOREIGN KEY (`bookstore_order_id`) REFERENCES `bookstore_orders` (`bookstore_order_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bookstore_order_items`
--

LOCK TABLES `bookstore_order_items` WRITE;
/*!40000 ALTER TABLE `bookstore_order_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `bookstore_order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bookstore_orders`
--

DROP TABLE IF EXISTS `bookstore_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bookstore_orders` (
  `bookstore_order_id` bigint NOT NULL AUTO_INCREMENT,
  `bookstore_id` bigint NOT NULL,
  `order_number` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `order_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `total_amount` decimal(12,2) NOT NULL,
  `order_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` bigint DEFAULT NULL,
  `approved_by` bigint DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shipping_provider` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dispatched_at` timestamp NULL DEFAULT NULL,
  `delivered_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`bookstore_order_id`),
  UNIQUE KEY `uq_bookstore_order_number` (`order_number`),
  KEY `fk_bookstore_orders_bookstore` (`bookstore_id`),
  CONSTRAINT `fk_bookstore_orders_bookstore` FOREIGN KEY (`bookstore_id`) REFERENCES `bookstores` (`bookstore_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bookstore_orders`
--

LOCK TABLES `bookstore_orders` WRITE;
/*!40000 ALTER TABLE `bookstore_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `bookstore_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bookstores`
--

DROP TABLE IF EXISTS `bookstores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bookstores` (
  `bookstore_id` bigint NOT NULL AUTO_INCREMENT,
  `bookstore_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_person` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`bookstore_id`),
  UNIQUE KEY `uq_bookstores_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bookstores`
--

LOCK TABLES `bookstores` WRITE;
/*!40000 ALTER TABLE `bookstores` DISABLE KEYS */;
/*!40000 ALTER TABLE `bookstores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cart_items`
--

DROP TABLE IF EXISTS `cart_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart_items` (
  `cart_item_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `catalog_book_id` bigint NOT NULL,
  `quantity` int NOT NULL,
  `added_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`cart_item_id`),
  UNIQUE KEY `uq_cart_user_book` (`user_id`,`catalog_book_id`),
  KEY `fk_cart_book` (`catalog_book_id`),
  CONSTRAINT `fk_cart_book` FOREIGN KEY (`catalog_book_id`) REFERENCES `catalog_books` (`book_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart_items`
--

LOCK TABLES `cart_items` WRITE;
/*!40000 ALTER TABLE `cart_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `cart_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `catalog_books`
--

DROP TABLE IF EXISTS `catalog_books`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `catalog_books` (
  `book_id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `author_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `author_id` bigint DEFAULT NULL,
  `category_id` bigint DEFAULT NULL,
  `genre_id` bigint DEFAULT NULL,
  `price` decimal(12,2) NOT NULL,
  `isbn` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cover_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `new_arrival` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `stock_book_id` bigint DEFAULT NULL,
  PRIMARY KEY (`book_id`),
  KEY `fk_catalog_books_category` (`category_id`),
  KEY `fk_catalog_books_genre` (`genre_id`),
  KEY `idx_catalog_books_stock` (`stock_book_id`),
  CONSTRAINT `fk_catalog_books_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_catalog_books_genre` FOREIGN KEY (`genre_id`) REFERENCES `genres` (`genre_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `catalog_books`
--

LOCK TABLES `catalog_books` WRITE;
/*!40000 ALTER TABLE `catalog_books` DISABLE KEYS */;
INSERT INTO `catalog_books` VALUES (1,'Amasonia','Manjula Dissanayake',1,1,NULL,2100.00,'978-3-16-148410-0',NULL,NULL,1,'2026-09-23 12:04:04','2026-09-23 12:04:04',NULL),(4,'1984','George Orwell',NULL,3,2,1950.00,NULL,'Winston Smith struggles against a totalitarian regime that controls truth itself.',NULL,1,'2026-09-26 12:35:55','2026-09-26 12:35:55',NULL),(5,'The Adventures of Sherlock Holmes','Arthur Conan Doyle',NULL,4,3,2200.00,NULL,'Twelve classic cases solved by the world\'s most famous detective and his companion Dr. Watson.',NULL,0,'2026-09-26 12:35:55','2026-09-26 12:35:55',NULL),(6,'Moby-Dick','Herman Melville',NULL,6,5,2400.00,NULL,'Captain Ahab\'s obsessive hunt for the great white whale, narrated by the sailor Ishmael.',NULL,0,'2026-09-26 12:35:55','2026-09-26 12:35:55',NULL),(7,'Wuthering Heights','Emily Bronte',NULL,2,1,1700.00,NULL,'A tale of passion and revenge on the Yorkshire moors between Heathcliff and Catherine.',NULL,0,'2026-09-26 12:35:55','2026-09-26 12:35:55',NULL),(8,'Gulliver\'s Travels','Jonathan Swift',NULL,2,NULL,1500.00,NULL,'Lemuel Gulliver\'s satirical voyages to the fantastical lands of Lilliput, Brobdingnag and beyond.',NULL,0,'2026-09-26 12:35:55','2026-10-02 17:55:55',NULL),(9,'Ikigai','Udula Hettiarachchi',2,1,1,2500.00,'978-955-000001-2','Be Positive','book-9-55571101.jpg',1,'2026-10-02 16:57:27','2026-10-02 16:57:27',1),(10,'I don\'t love you anymore','Nisalma Werake',5,5,7,2500.00,'978-955-000002-9','signs to glow up','book-10-c55c9be0.png',1,'2026-10-03 08:08:39','2026-10-03 08:08:39',2),(11,'Amazonia','manjula dissanayke',1,6,2,550.00,'978-955-000006-7','Hi dilumika','book-11-7eecf4f2.png',1,'2026-10-03 09:51:59','2026-10-03 09:51:59',6),(12,'Magart','Randika Kadawathaarachchi',4,7,7,2100.00,'978-955-000005-0','These books present a warm collection of animal tales, family anecdotes, and creative non-fiction spanning five generations of a ranching family. Spanning from the wild banks of the Big Salmon River in Central Idaho to the southern deserts, the stories explore the deep, humorous, and sometimes poignant bonds between country folk and the animals they rescue, inherit, and raise—from a toy poodle that believes it is a sheepdog to stubborn barnyard ewes.','book-12-cad5564c.jpg',1,'2026-10-03 09:52:21','2026-10-03 09:52:21',5),(13,'Healing Is The New High','Nisalma Werake',5,1,4,3200.00,'978-955-000003-6','Drawing heavily from his personal history of overcoming trauma, family turmoil, and financial hardship, Vex King argues that many individuals routinely suppress their emotional pain rather than processing it, which inadvertently lets past trauma dictate their adult lives, behaviors, and relationships. The book acts as a practical roadmap to help readers confront their deep-seated wounds, break free from negative cycles, and actively become their own healers.\nInstead of treating mental wellness as a purely intellectual exercise, King introduces a holistic approach that blends modern psychology with ancient yogic principles. He explains that unresolved trauma does not just stay in our thoughts; it settles across seven interconnected layers of the self (the physical, etheric, astral, mental, spiritual, cosmic, and nirvanic bodies). True healing requires working through these layers sequentially, starting with physical wellness and body awareness to safely discharge stored stress','book-13-0d22a04b.jpg',1,'2026-10-03 09:53:04','2026-10-03 09:53:04',3),(14,'Radalathanna Walawwa','Sahas Gunasekare',3,1,7,2500.00,'978-955-000004-3','The story transitions from the claustrophobic, noisy, and artificial \"concrete hills\" of urban city life to the serene, natural heart of Sri Lanka. Set against a breathtaking backdrop of majestic mountains and flowing waterfalls, the narrative follows a female protagonist who escapes to this pristine paradise to find freedom and a sense of fresh renewal. Central to the plot is the Walawwa—a traditional ancestral manor house—which harbors its own distinct history, social dynamics, and secrets intertwined with the natural landscape. The novel captures her emotional journey of self-discovery, peace, and liberation away from the chaos of modern civilization.','book-14-75606ed5.jpg',1,'2026-10-03 09:53:20','2026-10-03 09:53:20',4);
/*!40000 ALTER TABLE `catalog_books` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `category_id` bigint NOT NULL AUTO_INCREMENT,
  `category_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `uq_categories_category_name` (`category_name`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,'history','indian','2026-09-23 11:54:16','2026-09-23 11:54:16'),(2,'Classic Literature','Enduring novels from the 19th and early 20th centuries','2026-09-26 12:34:59','2026-09-26 12:34:59'),(3,'Science Fiction','Speculative and futuristic fiction','2026-09-26 12:34:59','2026-09-26 12:34:59'),(4,'Mystery & Detective','Crime, detective and mystery fiction','2026-09-26 12:34:59','2026-09-26 12:34:59'),(5,'Romance','Romantic fiction','2026-09-26 12:34:59','2026-09-26 12:34:59'),(6,'Adventure','Adventure and action fiction','2026-09-26 12:34:59','2026-09-26 12:34:59'),(7,'Fiction','Fiction, novels and creative literature','2026-10-02 17:53:39','2026-10-02 17:54:32'),(9,'Fantasy','Stories with magics','2026-10-03 11:31:26','2026-10-03 11:31:38');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer_order_items`
--

DROP TABLE IF EXISTS `customer_order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_order_items` (
  `customer_order_item_id` bigint NOT NULL AUTO_INCREMENT,
  `customer_order_id` bigint NOT NULL,
  `book_id` bigint NOT NULL,
  `quantity` int NOT NULL,
  `unit_price` decimal(12,2) NOT NULL,
  `subtotal` decimal(12,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`customer_order_item_id`),
  KEY `fk_customer_order_items_order` (`customer_order_id`),
  KEY `fk_customer_order_items_book` (`book_id`),
  CONSTRAINT `fk_customer_order_items_book` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_customer_order_items_order` FOREIGN KEY (`customer_order_id`) REFERENCES `customer_orders` (`customer_order_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_order_items`
--

LOCK TABLES `customer_order_items` WRITE;
/*!40000 ALTER TABLE `customer_order_items` DISABLE KEYS */;
INSERT INTO `customer_order_items` VALUES (1,1,1,3,2500.00,7500.00,'2026-10-02 17:15:09'),(2,2,1,4,2500.00,10000.00,'2026-10-02 17:22:02'),(3,3,1,2,2500.00,5000.00,'2026-10-02 17:25:19'),(4,4,1,13,2500.00,32500.00,'2026-10-02 17:30:09'),(5,5,2,1,2500.00,2500.00,'2026-10-03 08:10:27'),(6,6,4,1,2500.00,2500.00,'2026-10-03 09:55:21'),(7,6,3,1,3200.00,3200.00,'2026-10-03 09:55:21'),(8,6,5,1,2100.00,2100.00,'2026-10-03 09:55:21'),(9,6,6,1,550.00,550.00,'2026-10-03 09:55:21'),(10,6,2,1,2500.00,2500.00,'2026-10-03 09:55:22'),(11,6,1,1,2500.00,2500.00,'2026-10-03 09:55:22'),(12,7,4,10,2500.00,25000.00,'2026-10-03 09:57:31'),(13,7,3,10,3200.00,32000.00,'2026-10-03 09:57:31'),(14,7,2,10,2500.00,25000.00,'2026-10-03 09:57:31'),(15,8,5,1,2100.00,2100.00,'2026-10-03 09:59:46'),(16,8,3,1,3200.00,3200.00,'2026-10-03 09:59:46'),(17,8,4,1,2500.00,2500.00,'2026-10-03 09:59:46'),(18,8,1,1,2500.00,2500.00,'2026-10-03 09:59:46');
/*!40000 ALTER TABLE `customer_order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer_orders`
--

DROP TABLE IF EXISTS `customer_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_orders` (
  `customer_order_id` bigint NOT NULL AUTO_INCREMENT,
  `customer_id` bigint NOT NULL,
  `order_number` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `order_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `total_amount` decimal(12,2) NOT NULL,
  `order_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `shipping_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payment_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `recipient_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `recipient_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `cancel_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `packed_at` timestamp NULL DEFAULT NULL,
  `dispatched_at` timestamp NULL DEFAULT NULL,
  `delivered_at` timestamp NULL DEFAULT NULL,
  `is_wholesale` tinyint(1) NOT NULL DEFAULT '0',
  `business_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `wholesale_status` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `wholesale_reviewed_by` bigint DEFAULT NULL,
  `wholesale_reviewed_at` timestamp NULL DEFAULT NULL,
  `wholesale_reject_reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`customer_order_id`),
  UNIQUE KEY `uq_customer_order_number` (`order_number`),
  KEY `fk_customer_orders_customer` (`customer_id`),
  KEY `idx_customer_orders_wholesale` (`is_wholesale`,`wholesale_status`),
  CONSTRAINT `fk_customer_orders_customer` FOREIGN KEY (`customer_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_orders`
--

LOCK TABLES `customer_orders` WRITE;
/*!40000 ALTER TABLE `customer_orders` DISABLE KEYS */;
INSERT INTO `customer_orders` VALUES (1,9020,'CO-2026-00001','2026-10-02 17:15:09',7500.00,'DELIVERED','Malabe, Colombo 2, Colombo, `12100, Sri Lanka, (Koombiyo Courier)','PAID','Jaliya Hettiarachchi','0717505548','2026-10-02 17:15:09','2026-10-02 17:32:18',NULL,'2026-10-02 17:32:08','2026-10-02 17:32:17','2026-10-02 17:32:18',0,NULL,NULL,NULL,NULL,NULL),(2,9021,'CO-2026-00002','2026-10-02 17:22:02',10000.00,'DELIVERED','Kaduwela, Christopher Road, Colombo 5, Colombo, 1100, Sri Lanka, (Koombiyo Courier)','PAID','Maheesha Ashinshani','0778825325','2026-10-02 17:22:02','2026-10-02 17:32:15',NULL,'2026-10-02 17:32:07','2026-10-02 17:32:15','2026-10-02 17:32:15',0,NULL,NULL,NULL,NULL,NULL),(3,9022,'CO-2026-00003','2026-10-02 17:25:19',5000.00,'DELIVERED','Dehiwala, wirasooriya mawath, Colombo 2, Colombo, 400, Sri Lanka, (Koombiyo Courier)','PAID','Menura Hettiarachchi','0772740485','2026-10-02 17:25:19','2026-10-02 17:32:13',NULL,'2026-10-02 17:32:05','2026-10-02 17:32:13','2026-10-02 17:32:13',0,NULL,NULL,NULL,NULL,NULL),(4,9023,'CO-2026-00004','2026-10-02 17:30:09',32500.00,'DELIVERED','nittabuwe, wirasooriya mawata, Colombo 5, Colombo, 12100, Sri Lanka, (Koombiyo Courier)','PAID','Maleesha Bandara','0775070556','2026-10-02 17:30:09','2026-10-02 17:32:11',NULL,'2026-10-02 17:32:03','2026-10-02 17:32:09','2026-10-02 17:32:11',0,NULL,NULL,NULL,NULL,NULL),(5,9022,'CO-2026-00005','2026-10-03 08:10:27',2500.00,'DELIVERED','330/2A Nelum Mawatha, Sumathipala Shopping Complex, Panchikawatta Road, Battaramulla, Colombo, `12100, Sri Lanka, (Koombiyo Courier)','PAID','Maheesha Ashinshani','+94778825325','2026-10-03 08:10:27','2026-10-03 08:12:14',NULL,'2026-10-03 08:11:56','2026-10-03 08:12:05','2026-10-03 08:12:14',0,NULL,NULL,NULL,NULL,NULL),(6,9022,'CO-2026-00006','2026-10-03 09:55:21',13350.00,'DELIVERED','330/2A Nelum Mawatha, Sumathipala Shopping Complex, Panchikawatta Road, Kiribathgoda, Gampaha, 12100, Sri Lanka, (Koombiyo Courier)','PAID','Maheesha Ashinshani','+94778825325','2026-10-03 09:55:21','2026-10-03 10:00:42',NULL,'2026-10-03 10:00:40','2026-10-03 10:00:41','2026-10-03 10:00:42',0,NULL,NULL,NULL,NULL,NULL),(7,9023,'CO-2026-00007','2026-10-03 09:57:31',82000.00,'DELIVERED','[WHOLESALE: Maleesha Stores] nittabuwe, wirasooriya mawata, Nittambuwa, Gampaha, 12100, Sri Lanka, (Koombiyo Courier)','PAID','Maleesha Bandara','+94775070556','2026-10-03 09:57:31','2026-10-03 10:00:39',NULL,'2026-10-03 10:00:37','2026-10-03 10:00:38','2026-10-03 10:00:39',1,'Maleesha Stores','APPROVED',9009,'2026-10-03 10:00:12',NULL),(8,9020,'CO-2026-00008','2026-10-03 09:59:46',10300.00,'DELIVERED','43/5, Christopher Road, Akurana, Kandy, 1100, Sri Lanka, (Koombiyo Courier)','PAID','Jaliya Hettiarachchi','+94812388462','2026-10-03 09:59:46','2026-10-03 10:00:35',NULL,'2026-10-03 10:00:34','2026-10-03 10:00:35','2026-10-03 10:00:35',0,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `customer_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `design_assignments`
--

DROP TABLE IF EXISTS `design_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `design_assignments` (
  `assignment_id` bigint NOT NULL AUTO_INCREMENT,
  `manuscript_id` bigint NOT NULL,
  `designer_id` bigint NOT NULL,
  `assigned_by` bigint NOT NULL,
  `assignment_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `remarks` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`assignment_id`),
  KEY `idx_design_assign_manuscript` (`manuscript_id`),
  KEY `idx_design_assign_designer` (`designer_id`),
  CONSTRAINT `fk_design_assign_manuscript` FOREIGN KEY (`manuscript_id`) REFERENCES `manuscripts` (`manuscript_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `design_assignments`
--

LOCK TABLES `design_assignments` WRITE;
/*!40000 ALTER TABLE `design_assignments` DISABLE KEYS */;
INSERT INTO `design_assignments` VALUES (1,3,9016,9007,'COMPLETED',NULL,'2026-10-02 15:03:23','2026-10-02 15:06:40','2026-10-02 15:03:23','2026-10-02 15:06:40'),(2,11,9017,9007,'COMPLETED',NULL,'2026-10-03 08:01:02','2026-10-03 08:04:27','2026-10-03 08:01:02','2026-10-03 08:04:27'),(3,10,9017,9007,'COMPLETED',NULL,'2026-10-03 09:06:13','2026-10-03 09:15:44','2026-10-03 09:06:13','2026-10-03 09:15:44'),(4,2,9017,9007,'COMPLETED',NULL,'2026-10-03 09:06:23','2026-10-03 09:19:49','2026-10-03 09:06:23','2026-10-03 09:19:49'),(5,6,9017,9007,'COMPLETED',NULL,'2026-10-03 09:06:53','2026-10-03 09:16:47','2026-10-03 09:06:53','2026-10-03 09:16:47'),(6,8,9017,9007,'COMPLETED',NULL,'2026-10-03 09:06:57','2026-10-03 09:17:41','2026-10-03 09:06:57','2026-10-03 09:17:41'),(7,12,9017,9007,'CANCELLED',NULL,'2026-10-03 10:49:20','2026-10-03 10:49:23','2026-10-03 10:49:20','2026-10-03 10:49:23'),(8,12,9017,9007,'COMPLETED',NULL,'2026-10-03 10:49:28','2026-10-03 11:00:36','2026-10-03 10:49:28','2026-10-03 11:00:36');
/*!40000 ALTER TABLE `design_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `document_sequences`
--

DROP TABLE IF EXISTS `document_sequences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `document_sequences` (
  `sequence_key` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `next_value` bigint NOT NULL,
  PRIMARY KEY (`sequence_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `document_sequences`
--

LOCK TABLES `document_sequences` WRITE;
/*!40000 ALTER TABLE `document_sequences` DISABLE KEYS */;
INSERT INTO `document_sequences` VALUES ('AUTHOR-2026',7),('CUSTOMER_ORDER-2026',9),('INVOICE-2026',4),('MANUSCRIPT-2026',13),('ROYALTY_PAYMENT-2026',2),('ROYALTY_STATEMENT-2026',2);
/*!40000 ALTER TABLE `document_sequences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `editorial_reviews`
--

DROP TABLE IF EXISTS `editorial_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `editorial_reviews` (
  `review_id` bigint NOT NULL AUTO_INCREMENT,
  `manuscript_id` bigint NOT NULL,
  `reviewer_id` bigint NOT NULL,
  `review_round` int NOT NULL,
  `review_comments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `decision` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `reviewed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  UNIQUE KEY `uq_editorial_review_round` (`manuscript_id`,`review_round`),
  KEY `fk_editorial_reviews_reviewer` (`reviewer_id`),
  CONSTRAINT `fk_editorial_reviews_manuscript` FOREIGN KEY (`manuscript_id`) REFERENCES `manuscripts` (`manuscript_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_editorial_reviews_reviewer` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `editorial_reviews`
--

LOCK TABLES `editorial_reviews` WRITE;
/*!40000 ALTER TABLE `editorial_reviews` DISABLE KEYS */;
INSERT INTO `editorial_reviews` VALUES (1,3,9012,1,'demo','ACCEPT','2026-10-02 14:56:53','2026-10-02 14:56:53','2026-10-02 14:56:53'),(2,11,9013,1,'Good one.','ACCEPT','2026-10-03 08:00:35','2026-10-03 08:00:35','2026-10-03 08:00:35'),(3,10,9012,1,'Good one.','ACCEPT','2026-10-03 08:59:37','2026-10-03 08:59:37','2026-10-03 08:59:37'),(4,2,9012,1,'Good','ACCEPT','2026-10-03 08:59:55','2026-10-03 08:59:55','2026-10-03 08:59:55'),(5,6,9013,1,'Good','ACCEPT','2026-10-03 09:02:13','2026-10-03 09:02:13','2026-10-03 09:02:13'),(6,8,9014,1,'Good','ACCEPT','2026-10-03 09:05:21','2026-10-03 09:05:21','2026-10-03 09:05:21'),(7,12,9012,1,'The manuscript has a strong community-focused storyline, but some character motivations and connections between past and present events need further development. Please strengthen Sena\'s relationship with her aunt\'s history and provide more detail around the discovery of the hidden classroom. Review the pacing leading into the storm and the final resolution.','REVISION_REQUIRED','2026-10-03 10:42:14','2026-10-03 10:42:14','2026-10-03 10:42:14'),(8,12,9012,2,'The revised manuscript successfully addresses the key editorial concerns and provides stronger character development and narrative transitions. The manuscript is suitable to proceed to the next stage of production.','ACCEPT','2026-10-03 10:48:01','2026-10-03 10:48:01','2026-10-03 10:48:01');
/*!40000 ALTER TABLE `editorial_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expenses`
--

DROP TABLE IF EXISTS `expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `expenses` (
  `expense_id` bigint NOT NULL AUTO_INCREMENT,
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount` decimal(12,2) NOT NULL,
  `expense_date` date NOT NULL,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'RECORDED',
  `approved_by` bigint DEFAULT NULL,
  `created_by` bigint NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `reviewed_by` bigint DEFAULT NULL,
  `rejection_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `receipt_file` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `receipt_content_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `source_reference` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`expense_id`),
  KEY `fk_expenses_approver` (`approved_by`),
  KEY `fk_expenses_creator` (`created_by`),
  CONSTRAINT `fk_expenses_approver` FOREIGN KEY (`approved_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_expenses_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expenses`
--

LOCK TABLES `expenses` WRITE;
/*!40000 ALTER TABLE `expenses` DISABLE KEYS */;
INSERT INTO `expenses` VALUES (1,'PRINTING','Printing cost for fiction books',16000.00,'2026-10-02','POSTED',5,5,'2026-10-02 18:16:57','2026-10-02 18:18:29',5,NULL,'expense-1-1790965017467.jpg','image/jpeg',NULL),(2,'SALARIES','for spt',120000.00,'2026-10-02','POSTED',5,5,'2026-10-02 18:17:56','2026-10-02 18:18:12',NULL,NULL,'expense-2-1790965076174.jpg','image/jpeg',NULL),(3,'ROYALTY','Royalty payment RP-2026-00001 for statement RS-2026-00001 (ref boc)',5500.00,'2026-10-03','POSTED',5,5,'2026-10-02 18:40:26','2026-10-02 18:40:26',NULL,NULL,NULL,NULL,'ROYALTY_PAYMENT:1');
/*!40000 ALTER TABLE `expenses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_invoice_lines`
--

DROP TABLE IF EXISTS `financial_invoice_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_invoice_lines` (
  `line_id` bigint NOT NULL AUTO_INCREMENT,
  `invoice_id` bigint NOT NULL,
  `line_no` int NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity` int NOT NULL,
  `unit_price` decimal(12,2) NOT NULL,
  `line_total` decimal(12,2) NOT NULL,
  PRIMARY KEY (`line_id`),
  KEY `idx_invoice_lines_invoice` (`invoice_id`),
  CONSTRAINT `fk_invoice_lines_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `financial_invoices` (`invoice_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_invoice_lines`
--

LOCK TABLES `financial_invoice_lines` WRITE;
/*!40000 ALTER TABLE `financial_invoice_lines` DISABLE KEYS */;
INSERT INTO `financial_invoice_lines` VALUES (1,1,1,'The Last Promise - Book Sale',2,2000.00,4000.00),(2,2,1,'Ikigai -  Book Sale',3,2500.00,7500.00),(3,3,1,'Ikigai - Book Sale',10,2500.00,25000.00);
/*!40000 ALTER TABLE `financial_invoice_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_invoices`
--

DROP TABLE IF EXISTS `financial_invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_invoices` (
  `invoice_id` bigint NOT NULL AUTO_INCREMENT,
  `invoice_number` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `reference_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `reference_id` bigint DEFAULT NULL,
  `amount` decimal(12,2) NOT NULL,
  `tax_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `total_amount` decimal(12,2) NOT NULL,
  `invoice_date` date NOT NULL,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `customer_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currency` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'LKR',
  `tax_rate` decimal(5,2) NOT NULL DEFAULT '0.00',
  `amount_paid` decimal(12,2) NOT NULL DEFAULT '0.00',
  `due_date` date DEFAULT NULL,
  `notes` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` bigint DEFAULT NULL,
  `issued_at` timestamp NULL DEFAULT NULL,
  `cancel_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `version` bigint NOT NULL DEFAULT '0',
  PRIMARY KEY (`invoice_id`),
  UNIQUE KEY `uq_financial_invoice_number` (`invoice_number`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_invoices`
--

LOCK TABLES `financial_invoices` WRITE;
/*!40000 ALTER TABLE `financial_invoices` DISABLE KEYS */;
INSERT INTO `financial_invoices` VALUES (1,'INV-2026-00001','GENERAL',NULL,4000.00,0.00,4000.00,'2026-10-02','PAID',NULL,'2026-10-02 18:21:56','2026-10-02 18:31:12','Maheesha Ashinshani','maheesha.ashinshani@gmail.com','330/2A Nelum Mawatha','LKR',0.00,4000.00,'2026-10-31','demo',5,'2026-10-02 18:30:57',NULL,2),(2,'INV-2026-00002','GENERAL',NULL,7500.00,0.00,7500.00,'2026-10-02','CANCELLED',NULL,'2026-10-02 18:26:25','2026-10-02 18:30:08','Jaliya Hettiarachchi','jaliyathegreat@gmail.com','Malabe','LKR',0.00,0.00,NULL,'Invoice for completed book sale - October 2026',5,'2026-10-02 18:29:49','due to payment problem',2),(3,'INV-2026-00003','GENERAL',NULL,25000.00,0.00,25000.00,'2026-10-03','PAID',NULL,'2026-10-02 18:32:15','2026-10-02 18:32:57','Maleesha Bandara','maleesha@gmail.com','nittabuwe','LKR',0.00,25000.00,NULL,'Ikigai - Book Sale',5,'2026-10-02 18:32:38',NULL,2);
/*!40000 ALTER TABLE `financial_invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_payments`
--

DROP TABLE IF EXISTS `financial_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_payments` (
  `payment_id` bigint NOT NULL AUTO_INCREMENT,
  `reference_number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payment_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `payment_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `payment_method` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `invoice_id` bigint DEFAULT NULL,
  `recorded_by` bigint DEFAULT NULL,
  PRIMARY KEY (`payment_id`),
  UNIQUE KEY `uq_financial_payment_reference` (`reference_number`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_payments`
--

LOCK TABLES `financial_payments` WRITE;
/*!40000 ALTER TABLE `financial_payments` DISABLE KEYS */;
INSERT INTO `financial_payments` VALUES (1,'Bank','INVOICE',4000.00,'2026-10-02 18:30:00','BANK_TRANSFER','COMPLETED','Payment for invoice INV-2026-00001','2026-10-02 18:31:12','2026-10-02 18:31:12',1,5),(2,'Boc','INVOICE',25000.00,'2026-10-02 18:30:00','BANK_TRANSFER','COMPLETED','Payment for invoice INV-2026-00003','2026-10-02 18:32:57','2026-10-02 18:32:57',3,5);
/*!40000 ALTER TABLE `financial_payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_reports`
--

DROP TABLE IF EXISTS `financial_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_reports` (
  `report_id` bigint NOT NULL AUTO_INCREMENT,
  `report_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `generated_by` bigint NOT NULL,
  `generated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'GENERATED',
  `report_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `snapshot_json` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `currency` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reviewed_by` bigint DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `finalized_by` bigint DEFAULT NULL,
  `finalized_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`report_id`),
  KEY `fk_financial_reports_user` (`generated_by`),
  CONSTRAINT `fk_financial_reports_user` FOREIGN KEY (`generated_by`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_reports`
--

LOCK TABLES `financial_reports` WRITE;
/*!40000 ALTER TABLE `financial_reports` DISABLE KEYS */;
INSERT INTO `financial_reports` VALUES (1,'REVENUE','2025-11-01','2026-10-03',5,'2026-10-02 18:34:51','FINALIZED',NULL,'2026-10-02 18:34:00','2026-10-02 18:35:09','{\"grossRevenue\":55000.00,\"discounts\":0.00,\"netRevenue\":55000.00,\"completedSales\":4,\"booksSold\":22,\"averageSaleValue\":13750.00,\"revenueByChannel\":{\"CUSTOMER\":55000.00},\"revenueByMonth\":{\"2025-11\":0.00,\"2025-12\":0.00,\"2026-01\":0.00,\"2026-02\":0.00,\"2026-03\":0.00,\"2026-04\":0.00,\"2026-05\":0.00,\"2026-06\":0.00,\"2026-07\":0.00,\"2026-08\":0.00,\"2026-09\":0.00,\"2026-10\":55000.00},\"topBooks\":{\"Ikigai\":55000.00},\"cancelledExcluded\":0.00,\"returnedExcluded\":0.00}','LKR',5,'2026-10-02 18:35:05',5,'2026-10-02 18:35:09'),(2,'EXPENSE','2025-11-01','2026-10-03',5,'2026-10-02 19:00:50','REVIEWED',NULL,'2026-10-02 19:00:50','2026-10-02 19:01:12','{\"totalExpenses\":141500.00,\"expenseCount\":3,\"byCategory\":{\"PRINTING\":16000.00,\"ROYALTY\":5500.00,\"SALARIES\":120000.00},\"byMonth\":{\"2026-10\":141500.00},\"note\":\"Only APPROVED and POSTED expenses are counted.\"}','LKR',5,'2026-10-02 19:01:12',NULL,NULL),(3,'PROFIT_AND_LOSS','2025-11-01','2026-10-03',5,'2026-10-03 04:48:54','GENERATED',NULL,'2026-10-03 04:48:54','2026-10-03 04:48:54','{\"grossRevenue\":55000.00,\"discounts\":0.00,\"netRevenue\":55000.00,\"operatingExpenses\":136000.00,\"royaltiesPaid\":5500.00,\"profit\":-86500.00,\"operatingExpensesByCategory\":{\"PRINTING\":16000.00,\"SALARIES\":120000.00},\"note\":\"Profit = net revenue - approved/posted expenses (excluding ROYALTY) - royalties paid. Paid royalties are also posted as ROYALTY expenses, so they are counted once.\"}','LKR',NULL,NULL,NULL,NULL),(4,'EXPENSE','2025-11-01','2026-10-03',5,'2026-10-03 05:02:59','FINALIZED',NULL,'2026-10-03 05:02:59','2026-10-03 05:05:17','{\"totalExpenses\":141500.00,\"expenseCount\":3,\"byCategory\":{\"PRINTING\":16000.00,\"ROYALTY\":5500.00,\"SALARIES\":120000.00},\"byMonth\":{\"2026-10\":141500.00},\"note\":\"Only APPROVED and POSTED expenses are counted.\"}','LKR',NULL,NULL,5,'2026-10-03 05:05:17');
/*!40000 ALTER TABLE `financial_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `flyway_schema_history`
--

DROP TABLE IF EXISTS `flyway_schema_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flyway_schema_history` (
  `installed_rank` int NOT NULL,
  `version` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `script` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `checksum` int DEFAULT NULL,
  `installed_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `installed_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `execution_time` int NOT NULL,
  `success` tinyint(1) NOT NULL,
  PRIMARY KEY (`installed_rank`),
  KEY `flyway_schema_history_s_idx` (`success`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `flyway_schema_history`
--

LOCK TABLES `flyway_schema_history` WRITE;
/*!40000 ALTER TABLE `flyway_schema_history` DISABLE KEYS */;
INSERT INTO `flyway_schema_history` VALUES (1,'1','<< Flyway Baseline >>','BASELINE','<< Flyway Baseline >>',NULL,'root','2026-09-26 12:21:39',0,1),(2,'100','Epic1 authors and manuscripts','JDBC','db.migration.V100__Epic1_authors_and_manuscripts',NULL,'root','2026-09-26 12:21:39',451,1),(3,'101','Epic1 applications bank details','JDBC','db.migration.V101__Epic1_applications_bank_details',NULL,'root','2026-09-26 12:21:40',213,1),(4,'200','Epic2 editorial and production','JDBC','db.migration.V200__Epic2_editorial_and_production',NULL,'root','2026-09-26 12:21:40',882,1),(5,'201','Epic2 design assignments','JDBC','db.migration.V201__Epic2_design_assignments',NULL,'root','2026-09-26 12:21:41',52,1),(6,'300','Epic3 publishing operations','JDBC','db.migration.V300__Epic3_publishing_operations',NULL,'root','2026-09-26 12:21:42',1202,1),(7,'400','Epic4 finance and royalty','JDBC','db.migration.V400__Epic4_finance_and_royalty',NULL,'root','2026-09-26 12:21:46',3989,1),(8,'401','Epic4 author signature','JDBC','db.migration.V401__Epic4_author_signature',NULL,'root','2026-09-26 12:21:46',66,1),(9,'202','Epic2 manuscript assignments','JDBC','db.migration.V202__Epic2_manuscript_assignments',NULL,'root','2026-10-02 13:47:05',15,1),(10,'203','Epic2 assignment remarks','JDBC','db.migration.V203__Epic2_assignment_remarks',NULL,'root','2026-10-02 13:47:05',71,1),(11,'301','Wholesale requests on customer orders','JDBC','db.migration.V301__Wholesale_requests_on_customer_orders',NULL,'root','2026-10-02 13:47:06',513,1),(12,'402','Epic4 agreement sent to author','JDBC','db.migration.V402__Epic4_agreement_sent_to_author',NULL,'root','2026-10-03 04:34:32',133,1);
/*!40000 ALTER TABLE `flyway_schema_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `genres`
--

DROP TABLE IF EXISTS `genres`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `genres` (
  `genre_id` bigint NOT NULL AUTO_INCREMENT,
  `category_id` bigint DEFAULT NULL,
  `genre_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`genre_id`),
  UNIQUE KEY `uq_genres_genre_name` (`genre_name`),
  KEY `fk_genres_category` (`category_id`),
  CONSTRAINT `fk_genres_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `genres`
--

LOCK TABLES `genres` WRITE;
/*!40000 ALTER TABLE `genres` DISABLE KEYS */;
INSERT INTO `genres` VALUES (1,NULL,'Gothic Fiction','Dark, atmospheric fiction with romantic and horror elements','2026-09-26 12:35:13','2026-09-26 12:35:13'),(2,NULL,'Dystopian','Fiction depicting a bleak, oppressive future society','2026-09-26 12:35:13','2026-09-26 12:35:13'),(3,NULL,'Detective Fiction','Fiction centered on solving a crime','2026-09-26 12:35:13','2026-09-26 12:35:13'),(4,NULL,'Historical Romance','Romance set against a historical backdrop','2026-09-26 12:35:13','2026-09-26 12:35:13'),(5,NULL,'Epic Adventure','Long-form adventure fiction with a sweeping scope','2026-09-26 12:35:13','2026-09-26 12:35:13'),(7,NULL,'Romance','Romance and relationship fictions','2026-10-02 17:55:30','2026-10-02 17:55:45');
/*!40000 ALTER TABLE `genres` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory`
--

DROP TABLE IF EXISTS `inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory` (
  `inventory_id` bigint NOT NULL AUTO_INCREMENT,
  `book_id` bigint NOT NULL,
  `quantity_in_stock` int NOT NULL DEFAULT '0',
  `reorder_level` int NOT NULL DEFAULT '10',
  `warehouse_location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_stock_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `quantity_reserved` int NOT NULL DEFAULT '0',
  `version` bigint NOT NULL DEFAULT '0',
  PRIMARY KEY (`inventory_id`),
  UNIQUE KEY `uq_inventory_book` (`book_id`),
  CONSTRAINT `fk_inventory_book` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory`
--

LOCK TABLES `inventory` WRITE;
/*!40000 ALTER TABLE `inventory` DISABLE KEYS */;
INSERT INTO `inventory` VALUES (1,1,96,10,'ABC company','2026-10-03 10:00:41','2026-10-02 16:57:27',0,15),(2,2,48,10,'bravo B','2026-10-03 10:00:41','2026-10-03 08:08:39',0,7),(3,6,29,10,'ABC company','2026-10-03 10:00:41','2026-10-03 09:51:59',0,3),(4,5,38,10,'ABC company','2026-10-03 10:00:41','2026-10-03 09:52:21',0,5),(5,3,48,10,'ABC company','2026-10-03 10:00:41','2026-10-03 09:53:04',0,7),(6,4,88,10,'bravo B','2026-10-03 10:00:41','2026-10-03 09:53:20',0,7);
/*!40000 ALTER TABLE `inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_transactions`
--

DROP TABLE IF EXISTS `inventory_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_transactions` (
  `transaction_id` bigint NOT NULL AUTO_INCREMENT,
  `inventory_id` bigint NOT NULL,
  `performed_by` bigint NOT NULL,
  `transaction_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity` int NOT NULL,
  `reference_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reference_id` bigint DEFAULT NULL,
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `transaction_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`transaction_id`),
  KEY `fk_inventory_transactions_inventory` (`inventory_id`),
  KEY `fk_inventory_transactions_user` (`performed_by`),
  CONSTRAINT `fk_inventory_transactions_inventory` FOREIGN KEY (`inventory_id`) REFERENCES `inventory` (`inventory_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_inventory_transactions_user` FOREIGN KEY (`performed_by`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_transactions`
--

LOCK TABLES `inventory_transactions` WRITE;
/*!40000 ALTER TABLE `inventory_transactions` DISABLE KEYS */;
INSERT INTO `inventory_transactions` VALUES (1,1,9008,'RECEIPT',55,'PRINT_ORDER',2,'demo','2026-10-02 16:57:27','2026-10-02 16:57:27'),(2,1,9020,'RESERVED',3,'CUSTOMER_ORDER',1,NULL,'2026-10-02 17:15:09','2026-10-02 17:15:09'),(3,1,9021,'RESERVED',4,'CUSTOMER_ORDER',2,NULL,'2026-10-02 17:22:02','2026-10-02 17:22:02'),(4,1,9022,'RESERVED',2,'CUSTOMER_ORDER',3,NULL,'2026-10-02 17:25:19','2026-10-02 17:25:19'),(5,1,9023,'RESERVED',13,'CUSTOMER_ORDER',4,NULL,'2026-10-02 17:30:09','2026-10-02 17:30:09'),(6,1,9008,'SALE_OUT',13,'CUSTOMER_ORDER',4,NULL,'2026-10-02 17:32:09','2026-10-02 17:32:09'),(7,1,9008,'SALE_OUT',2,'CUSTOMER_ORDER',3,NULL,'2026-10-02 17:32:13','2026-10-02 17:32:13'),(8,1,9008,'SALE_OUT',4,'CUSTOMER_ORDER',2,NULL,'2026-10-02 17:32:15','2026-10-02 17:32:15'),(9,1,9008,'SALE_OUT',3,'CUSTOMER_ORDER',1,NULL,'2026-10-02 17:32:17','2026-10-02 17:32:17'),(10,2,9008,'RECEIPT',60,'PRINT_ORDER',3,NULL,'2026-10-03 08:08:39','2026-10-03 08:08:39'),(11,2,9022,'RESERVED',1,'CUSTOMER_ORDER',5,NULL,'2026-10-03 08:10:27','2026-10-03 08:10:27'),(12,2,9008,'SALE_OUT',1,'CUSTOMER_ORDER',5,NULL,'2026-10-03 08:12:05','2026-10-03 08:12:05'),(13,3,9008,'RECEIPT',30,'PRINT_ORDER',7,NULL,'2026-10-03 09:51:59','2026-10-03 09:51:59'),(14,4,9008,'RECEIPT',40,'PRINT_ORDER',6,NULL,'2026-10-03 09:52:21','2026-10-03 09:52:21'),(15,5,9008,'RECEIPT',60,'PRINT_ORDER',5,NULL,'2026-10-03 09:53:04','2026-10-03 09:53:04'),(16,6,9008,'RECEIPT',100,'PRINT_ORDER',4,NULL,'2026-10-03 09:53:20','2026-10-03 09:53:20'),(17,1,9008,'RECEIPT',5,'PRINT_ORDER',2,NULL,'2026-10-03 09:53:33','2026-10-03 09:53:33'),(18,1,9008,'RECEIPT',60,'PRINT_ORDER',1,NULL,'2026-10-03 09:53:48','2026-10-03 09:53:48'),(19,6,9022,'RESERVED',1,'CUSTOMER_ORDER',6,NULL,'2026-10-03 09:55:21','2026-10-03 09:55:21'),(20,5,9022,'RESERVED',1,'CUSTOMER_ORDER',6,NULL,'2026-10-03 09:55:21','2026-10-03 09:55:21'),(21,4,9022,'RESERVED',1,'CUSTOMER_ORDER',6,NULL,'2026-10-03 09:55:21','2026-10-03 09:55:21'),(22,3,9022,'RESERVED',1,'CUSTOMER_ORDER',6,NULL,'2026-10-03 09:55:21','2026-10-03 09:55:21'),(23,2,9022,'RESERVED',1,'CUSTOMER_ORDER',6,NULL,'2026-10-03 09:55:22','2026-10-03 09:55:22'),(24,1,9022,'RESERVED',1,'CUSTOMER_ORDER',6,NULL,'2026-10-03 09:55:22','2026-10-03 09:55:22'),(25,6,9023,'RESERVED',10,'CUSTOMER_ORDER',7,NULL,'2026-10-03 09:57:31','2026-10-03 09:57:31'),(26,5,9023,'RESERVED',10,'CUSTOMER_ORDER',7,NULL,'2026-10-03 09:57:31','2026-10-03 09:57:31'),(27,2,9023,'RESERVED',10,'CUSTOMER_ORDER',7,NULL,'2026-10-03 09:57:31','2026-10-03 09:57:31'),(28,4,9020,'RESERVED',1,'CUSTOMER_ORDER',8,NULL,'2026-10-03 09:59:46','2026-10-03 09:59:46'),(29,5,9020,'RESERVED',1,'CUSTOMER_ORDER',8,NULL,'2026-10-03 09:59:46','2026-10-03 09:59:46'),(30,6,9020,'RESERVED',1,'CUSTOMER_ORDER',8,NULL,'2026-10-03 09:59:46','2026-10-03 09:59:46'),(31,1,9020,'RESERVED',1,'CUSTOMER_ORDER',8,NULL,'2026-10-03 09:59:46','2026-10-03 09:59:46'),(32,4,9008,'SALE_OUT',1,'CUSTOMER_ORDER',8,NULL,'2026-10-03 10:00:34','2026-10-03 10:00:34'),(33,5,9008,'SALE_OUT',1,'CUSTOMER_ORDER',8,NULL,'2026-10-03 10:00:34','2026-10-03 10:00:34'),(34,6,9008,'SALE_OUT',1,'CUSTOMER_ORDER',8,NULL,'2026-10-03 10:00:34','2026-10-03 10:00:34'),(35,1,9008,'SALE_OUT',1,'CUSTOMER_ORDER',8,NULL,'2026-10-03 10:00:34','2026-10-03 10:00:34'),(36,6,9008,'SALE_OUT',10,'CUSTOMER_ORDER',7,NULL,'2026-10-03 10:00:38','2026-10-03 10:00:38'),(37,5,9008,'SALE_OUT',10,'CUSTOMER_ORDER',7,NULL,'2026-10-03 10:00:38','2026-10-03 10:00:38'),(38,2,9008,'SALE_OUT',10,'CUSTOMER_ORDER',7,NULL,'2026-10-03 10:00:38','2026-10-03 10:00:38'),(39,6,9008,'SALE_OUT',1,'CUSTOMER_ORDER',6,NULL,'2026-10-03 10:00:41','2026-10-03 10:00:41'),(40,5,9008,'SALE_OUT',1,'CUSTOMER_ORDER',6,NULL,'2026-10-03 10:00:41','2026-10-03 10:00:41'),(41,4,9008,'SALE_OUT',1,'CUSTOMER_ORDER',6,NULL,'2026-10-03 10:00:41','2026-10-03 10:00:41'),(42,3,9008,'SALE_OUT',1,'CUSTOMER_ORDER',6,NULL,'2026-10-03 10:00:41','2026-10-03 10:00:41'),(43,2,9008,'SALE_OUT',1,'CUSTOMER_ORDER',6,NULL,'2026-10-03 10:00:41','2026-10-03 10:00:41'),(44,1,9008,'SALE_OUT',1,'CUSTOMER_ORDER',6,NULL,'2026-10-03 10:00:41','2026-10-03 10:00:41');
/*!40000 ALTER TABLE `inventory_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoices` (
  `invoice_id` bigint NOT NULL AUTO_INCREMENT,
  `customer_order_id` bigint NOT NULL,
  `invoice_number` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `invoice_date` date NOT NULL,
  `subtotal` decimal(12,2) NOT NULL,
  `tax_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `discount_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `total_amount` decimal(12,2) NOT NULL,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`invoice_id`),
  UNIQUE KEY `uq_invoice_number` (`invoice_number`),
  KEY `fk_invoice_customer_order` (`customer_order_id`),
  CONSTRAINT `fk_invoice_customer_order` FOREIGN KEY (`customer_order_id`) REFERENCES `customer_orders` (`customer_order_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `manuscript_assignments`
--

DROP TABLE IF EXISTS `manuscript_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `manuscript_assignments` (
  `assignment_id` bigint NOT NULL AUTO_INCREMENT,
  `manuscript_id` bigint NOT NULL,
  `editor_id` bigint NOT NULL,
  `assigned_by` bigint NOT NULL,
  `assignment_status` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `remarks` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ended_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`assignment_id`),
  KEY `idx_ma_manuscript` (`manuscript_id`),
  KEY `idx_ma_editor` (`editor_id`),
  KEY `idx_ma_status` (`assignment_status`),
  CONSTRAINT `fk_ma_manuscript` FOREIGN KEY (`manuscript_id`) REFERENCES `manuscripts` (`manuscript_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `manuscript_assignments`
--

LOCK TABLES `manuscript_assignments` WRITE;
/*!40000 ALTER TABLE `manuscript_assignments` DISABLE KEYS */;
/*!40000 ALTER TABLE `manuscript_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `manuscript_files`
--

DROP TABLE IF EXISTS `manuscript_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `manuscript_files` (
  `manuscript_file_id` bigint NOT NULL AUTO_INCREMENT,
  `manuscript_id` bigint NOT NULL,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_size` bigint DEFAULT NULL,
  `file_version` int NOT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `file_category` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'MANUSCRIPT',
  `uploaded_by` bigint DEFAULT NULL,
  `notes` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`manuscript_file_id`),
  UNIQUE KEY `uq_manuscript_version` (`manuscript_id`,`file_version`),
  CONSTRAINT `fk_manuscript_files_manuscript` FOREIGN KEY (`manuscript_id`) REFERENCES `manuscripts` (`manuscript_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `manuscript_files`
--

LOCK TABLES `manuscript_files` WRITE;
/*!40000 ALTER TABLE `manuscript_files` DISABLE KEYS */;
INSERT INTO `manuscript_files` VALUES (2,2,'2026-IE3121-Labsheet-07.pdf','manuscripts/2/b76334eb-94b.pdf','application/pdf',1819769,1,'2026-09-27 11:28:13','MANUSCRIPT',9002,NULL),(3,3,'IE3151_Lecture 01.pdf','manuscripts/3/28e9deb9-ad6.pdf','application/pdf',3307635,1,'2026-10-02 14:48:19','MANUSCRIPT',9018,NULL),(4,3,'IE3151_Lecture 01.pdf','manuscripts/3/5c212609-381.pdf','application/pdf',3307635,2,'2026-10-02 14:48:19','SUPPORTING',9018,NULL),(5,4,'IE3151_ Lecture03.pdf','manuscripts/4/d20267da-5f9.pdf','application/pdf',3015153,1,'2026-10-02 14:49:10','MANUSCRIPT',9018,NULL),(7,6,'Radalathanna Walawwa.pdf','manuscripts/6/221caf8d-95c.pdf','application/pdf',4043334,1,'2026-10-03 06:04:42','MANUSCRIPT',9024,NULL),(8,7,'Badra.pdf','manuscripts/7/8c60f5bf-f25.pdf','application/pdf',4043334,1,'2026-10-03 06:16:24','MANUSCRIPT',9025,NULL),(9,8,'Magart.pdf','manuscripts/8/59dcfda1-83f.pdf','application/pdf',4043334,1,'2026-10-03 06:19:08','MANUSCRIPT',9025,NULL),(11,10,'Healing Is The New High.pdf','manuscripts/10/acd2171c-a84.pdf','application/pdf',4043334,1,'2026-10-03 06:41:01','MANUSCRIPT',9026,NULL),(12,11,'IE3151_Lecture 01.pdf','manuscripts/11/4fc91223-96a.pdf','application/pdf',3307635,1,'2026-10-03 07:53:14','MANUSCRIPT',9026,NULL),(13,12,'The Last Light of Galle.pdf','manuscripts/12/38cfa514-9f5.pdf','application/pdf',36176,1,'2026-10-03 10:33:00','MANUSCRIPT',9027,NULL),(14,12,'The Last Light of Galle_revised.pdf','manuscripts/12/3468b22a-e23.pdf','application/pdf',36188,2,'2026-10-03 10:44:36','REVISION',9027,NULL);
/*!40000 ALTER TABLE `manuscript_files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `manuscript_revisions`
--

DROP TABLE IF EXISTS `manuscript_revisions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `manuscript_revisions` (
  `revision_id` bigint NOT NULL AUTO_INCREMENT,
  `manuscript_id` bigint NOT NULL,
  `reviewer_id` bigint NOT NULL,
  `revision_round` int NOT NULL,
  `editor_comments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `response_deadline` date DEFAULT NULL,
  `responded_at` timestamp NULL DEFAULT NULL,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `response_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `response_file_id` bigint DEFAULT NULL,
  PRIMARY KEY (`revision_id`),
  UNIQUE KEY `uq_revision_round` (`manuscript_id`,`revision_round`),
  KEY `fk_revision_reviewer` (`reviewer_id`),
  CONSTRAINT `fk_revision_manuscript` FOREIGN KEY (`manuscript_id`) REFERENCES `manuscripts` (`manuscript_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_revision_reviewer` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `manuscript_revisions`
--

LOCK TABLES `manuscript_revisions` WRITE;
/*!40000 ALTER TABLE `manuscript_revisions` DISABLE KEYS */;
INSERT INTO `manuscript_revisions` VALUES (1,12,9012,1,'The manuscript has a strong community-focused storyline, but some character motivations and connections between past and present events need further development. Please strengthen Sena\'s relationship with her aunt\'s history and provide more detail around the discovery of the hidden classroom. Review the pacing leading into the storm and the final resolution.','2026-10-17','2026-10-03 10:44:36','RESPONDED','2026-10-03 10:42:14','2026-10-03 10:44:36',NULL,14);
/*!40000 ALTER TABLE `manuscript_revisions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `manuscript_status_history`
--

DROP TABLE IF EXISTS `manuscript_status_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `manuscript_status_history` (
  `history_id` bigint NOT NULL AUTO_INCREMENT,
  `manuscript_id` bigint NOT NULL,
  `from_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `to_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `changed_by` bigint DEFAULT NULL,
  `remarks` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `changed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`history_id`),
  KEY `idx_ms_history_manuscript` (`manuscript_id`),
  CONSTRAINT `fk_ms_history_manuscript` FOREIGN KEY (`manuscript_id`) REFERENCES `manuscripts` (`manuscript_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=102 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `manuscript_status_history`
--

LOCK TABLES `manuscript_status_history` WRITE;
/*!40000 ALTER TABLE `manuscript_status_history` DISABLE KEYS */;
INSERT INTO `manuscript_status_history` VALUES (2,2,'DRAFT','DRAFT',9002,'Draft created','2026-09-27 11:28:13'),(3,2,'DRAFT','SUBMITTED',9002,'Submitted by the author','2026-09-27 11:28:13'),(4,3,'DRAFT','DRAFT',9018,'Draft created','2026-10-02 14:48:18'),(5,3,'DRAFT','PENDING_SUPER_ADMIN_REVIEW',9018,'Submitted by the author; awaiting Super Admin review','2026-10-02 14:48:19'),(6,4,'DRAFT','DRAFT',9018,'Draft created','2026-10-02 14:49:09'),(7,4,'DRAFT','PENDING_SUPER_ADMIN_REVIEW',9018,'Submitted by the author; awaiting Super Admin review','2026-10-02 14:49:10'),(8,4,'PENDING_SUPER_ADMIN_REVIEW','SUBMITTED',9003,'Accepted by Super Admin; released to Chief Editor','2026-10-02 14:51:40'),(9,3,'PENDING_SUPER_ADMIN_REVIEW','SUBMITTED',9003,'Accepted by Super Admin; released to Chief Editor','2026-10-02 14:51:44'),(10,3,'SUBMITTED','UNDER_REVIEW',9004,'Assigned to Kamala Fernando: demo','2026-10-02 14:53:31'),(11,3,'UNDER_REVIEW','EDITORIALLY_ACCEPTED',9012,'Editorially accepted in review round 1','2026-10-02 14:56:53'),(12,3,'EDITORIALLY_ACCEPTED','EDITORIALLY_ACCEPTED',9007,'Designer assigned: Saman Dias','2026-10-02 15:03:23'),(13,3,'EDITORIALLY_ACCEPTED','IN_DESIGN',9016,'Design version 1 uploaded','2026-10-02 15:05:30'),(14,3,'IN_DESIGN','AWAITING_AUTHOR_APPROVAL',9016,'Design v1 sent to the author','2026-10-02 15:05:48'),(15,3,'AWAITING_AUTHOR_APPROVAL','DESIGN_APPROVED',9018,'Author approved design v1','2026-10-02 15:06:40'),(16,3,'DESIGN_APPROVED','QC_PASSED',9007,'Quality check passed: demo','2026-10-02 15:09:00'),(17,3,'QC_PASSED','READY_FOR_PRINTING',9007,'Ready for printing as book #1, ISBN 978-955-000001-2','2026-10-02 15:11:41'),(18,3,'READY_FOR_PRINTING','PUBLISHED',9008,'First stock received; book is on sale','2026-10-02 16:57:27'),(20,6,'DRAFT','DRAFT',9024,'Draft created','2026-10-03 06:04:42'),(21,6,'DRAFT','PENDING_SUPER_ADMIN_REVIEW',9024,'Submitted by the author; awaiting Super Admin review','2026-10-03 06:04:42'),(22,7,'DRAFT','DRAFT',9025,'Draft created','2026-10-03 06:16:24'),(23,7,'DRAFT','PENDING_SUPER_ADMIN_REVIEW',9025,'Submitted by the author; awaiting Super Admin review','2026-10-03 06:16:25'),(24,8,'DRAFT','DRAFT',9025,'Draft created','2026-10-03 06:19:08'),(25,8,'DRAFT','PENDING_SUPER_ADMIN_REVIEW',9025,'Submitted by the author; awaiting Super Admin review','2026-10-03 06:19:08'),(27,10,'DRAFT','DRAFT',9026,'Draft created','2026-10-03 06:41:01'),(28,10,'DRAFT','PENDING_SUPER_ADMIN_REVIEW',9026,'Submitted by the author; awaiting Super Admin review','2026-10-03 06:41:01'),(29,11,'DRAFT','DRAFT',9026,'Draft created','2026-10-03 07:53:14'),(30,11,'DRAFT','PENDING_SUPER_ADMIN_REVIEW',9026,'Submitted by the author; awaiting Super Admin review','2026-10-03 07:53:14'),(31,6,'PENDING_SUPER_ADMIN_REVIEW','SUBMITTED',9003,'Accepted by Super Admin; released to Chief Editor','2026-10-03 07:57:45'),(32,7,'PENDING_SUPER_ADMIN_REVIEW','SUBMITTED',9003,'Accepted by Super Admin; released to Chief Editor','2026-10-03 07:57:48'),(33,8,'PENDING_SUPER_ADMIN_REVIEW','SUBMITTED',9003,'Accepted by Super Admin; released to Chief Editor','2026-10-03 07:57:50'),(34,10,'PENDING_SUPER_ADMIN_REVIEW','SUBMITTED',9003,'Accepted by Super Admin; released to Chief Editor','2026-10-03 07:57:52'),(35,11,'PENDING_SUPER_ADMIN_REVIEW','SUBMITTED',9003,'Accepted by Super Admin; released to Chief Editor','2026-10-03 07:57:55'),(36,11,'SUBMITTED','UNDER_REVIEW',9004,'Assigned to Anusha Jayasinghe: demo','2026-10-03 07:58:38'),(37,11,'UNDER_REVIEW','EDITORIALLY_ACCEPTED',9013,'Editorially accepted in review round 1','2026-10-03 08:00:35'),(38,11,'EDITORIALLY_ACCEPTED','EDITORIALLY_ACCEPTED',9007,'Designer assigned: Dilani Wickramasinghe','2026-10-03 08:01:02'),(39,11,'EDITORIALLY_ACCEPTED','IN_DESIGN',9017,'Design version 1 uploaded','2026-10-03 08:03:42'),(40,11,'IN_DESIGN','AWAITING_AUTHOR_APPROVAL',9017,'Design v1 sent to the author','2026-10-03 08:03:45'),(41,11,'AWAITING_AUTHOR_APPROVAL','DESIGN_APPROVED',9026,'Author approved design v1','2026-10-03 08:04:27'),(42,11,'DESIGN_APPROVED','QC_PASSED',9007,'Quality check passed: All good','2026-10-03 08:05:08'),(43,11,'QC_PASSED','READY_FOR_PRINTING',9007,'Ready for printing as book #2, ISBN 978-955-000002-9','2026-10-03 08:05:41'),(44,11,'READY_FOR_PRINTING','PUBLISHED',9008,'First stock received; book is on sale','2026-10-03 08:08:39'),(45,10,'SUBMITTED','UNDER_REVIEW',9004,'Assigned to Kamala Fernando: demo','2026-10-03 08:54:02'),(46,8,'SUBMITTED','UNDER_REVIEW',9004,'Assigned to Ruwan Perera: demo','2026-10-03 08:54:34'),(47,6,'SUBMITTED','UNDER_REVIEW',9004,'Assigned to Anusha Jayasinghe: demo','2026-10-03 08:54:49'),(48,2,'SUBMITTED','UNDER_REVIEW',9004,'Assigned to Kamala Fernando: demo','2026-10-03 08:56:58'),(49,10,'UNDER_REVIEW','EDITORIALLY_ACCEPTED',9012,'Editorially accepted in review round 1','2026-10-03 08:59:37'),(50,2,'UNDER_REVIEW','EDITORIALLY_ACCEPTED',9012,'Editorially accepted in review round 1','2026-10-03 08:59:55'),(51,6,'UNDER_REVIEW','EDITORIALLY_ACCEPTED',9013,'Editorially accepted in review round 1','2026-10-03 09:02:13'),(52,8,'UNDER_REVIEW','EDITORIALLY_ACCEPTED',9014,'Editorially accepted in review round 1','2026-10-03 09:05:21'),(53,10,'EDITORIALLY_ACCEPTED','EDITORIALLY_ACCEPTED',9007,'Designer assigned: Dilani Wickramasinghe','2026-10-03 09:06:13'),(54,2,'EDITORIALLY_ACCEPTED','EDITORIALLY_ACCEPTED',9007,'Designer assigned: Dilani Wickramasinghe','2026-10-03 09:06:23'),(55,6,'EDITORIALLY_ACCEPTED','EDITORIALLY_ACCEPTED',9007,'Designer assigned: Dilani Wickramasinghe','2026-10-03 09:06:53'),(56,8,'EDITORIALLY_ACCEPTED','EDITORIALLY_ACCEPTED',9007,'Designer assigned: Dilani Wickramasinghe','2026-10-03 09:06:57'),(57,10,'EDITORIALLY_ACCEPTED','IN_DESIGN',9017,'Design version 1 uploaded','2026-10-03 09:09:16'),(58,10,'IN_DESIGN','AWAITING_AUTHOR_APPROVAL',9017,'Design v1 sent to the author','2026-10-03 09:09:22'),(59,2,'EDITORIALLY_ACCEPTED','IN_DESIGN',9017,'Design version 1 uploaded','2026-10-03 09:11:41'),(60,2,'IN_DESIGN','AWAITING_AUTHOR_APPROVAL',9017,'Design v2 sent to the author','2026-10-03 09:12:31'),(61,8,'EDITORIALLY_ACCEPTED','IN_DESIGN',9017,'Design version 1 uploaded','2026-10-03 09:14:08'),(62,8,'IN_DESIGN','AWAITING_AUTHOR_APPROVAL',9017,'Design v1 sent to the author','2026-10-03 09:14:11'),(63,6,'EDITORIALLY_ACCEPTED','IN_DESIGN',9017,'Design version 1 uploaded','2026-10-03 09:14:57'),(64,6,'IN_DESIGN','AWAITING_AUTHOR_APPROVAL',9017,'Design v1 sent to the author','2026-10-03 09:15:01'),(65,10,'AWAITING_AUTHOR_APPROVAL','DESIGN_APPROVED',9026,'Author approved design v1','2026-10-03 09:15:44'),(66,6,'AWAITING_AUTHOR_APPROVAL','DESIGN_APPROVED',9024,'Author approved design v1','2026-10-03 09:16:47'),(67,8,'AWAITING_AUTHOR_APPROVAL','DESIGN_APPROVED',9025,'Author approved design v1','2026-10-03 09:17:41'),(68,2,'AWAITING_AUTHOR_APPROVAL','DESIGN_APPROVED',9002,'Author approved design v2','2026-10-03 09:19:49'),(69,10,'DESIGN_APPROVED','QC_PASSED',9007,'Quality check passed: Demo','2026-10-03 09:21:44'),(70,10,'QC_PASSED','READY_FOR_PRINTING',9007,'Ready for printing as book #3, ISBN 978-955-000003-6','2026-10-03 09:22:18'),(71,6,'DESIGN_APPROVED','QC_PASSED',9007,'Quality check passed: good','2026-10-03 09:39:04'),(72,6,'QC_PASSED','READY_FOR_PRINTING',9007,'Ready for printing as book #4, ISBN 978-955-000004-3','2026-10-03 09:39:50'),(73,8,'DESIGN_APPROVED','QC_PASSED',9007,'Quality check passed: Good','2026-10-03 09:40:32'),(74,8,'QC_PASSED','READY_FOR_PRINTING',9007,'Ready for printing as book #5, ISBN 978-955-000005-0','2026-10-03 09:41:04'),(75,2,'DESIGN_APPROVED','QC_PASSED',9007,'Quality check passed: Good','2026-10-03 09:41:30'),(76,2,'QC_PASSED','READY_FOR_PRINTING',9007,'Ready for printing as book #6, ISBN 978-955-000006-7','2026-10-03 09:42:05'),(77,2,'READY_FOR_PRINTING','PUBLISHED',9008,'First stock received; book is on sale','2026-10-03 09:51:59'),(78,8,'READY_FOR_PRINTING','PUBLISHED',9008,'First stock received; book is on sale','2026-10-03 09:52:21'),(79,10,'READY_FOR_PRINTING','PUBLISHED',9008,'First stock received; book is on sale','2026-10-03 09:53:04'),(80,6,'READY_FOR_PRINTING','PUBLISHED',9008,'First stock received; book is on sale','2026-10-03 09:53:20'),(81,12,'DRAFT','DRAFT',9027,'Draft created','2026-10-03 10:33:00'),(82,12,'DRAFT','PENDING_SUPER_ADMIN_REVIEW',9027,'Submitted by the author; awaiting Super Admin review','2026-10-03 10:33:00'),(83,12,'PENDING_SUPER_ADMIN_REVIEW','SUBMITTED',9003,'Accepted by Super Admin; released to Chief Editor','2026-10-03 10:34:33'),(84,12,'SUBMITTED','UNDER_REVIEW',9004,'Assigned to Kamala Fernando: Please conduct the initial editorial review of the submitted manuscript. Assess the structure, character development, narrative consistency, pacing, and overall suitability for publication, and provide your editorial recommendations after completing the review.','2026-10-03 10:37:19'),(85,12,'UNDER_REVIEW','UNDER_REVIEW',9004,'Reassigned to Anusha Jayasinghe','2026-10-03 10:37:57'),(86,12,'UNDER_REVIEW','SUBMITTED',9004,'Assignment cancelled (previous editor userId=9013)','2026-10-03 10:38:02'),(87,12,'SUBMITTED','UNDER_REVIEW',9004,'Assigned to Kamala Fernando: Please conduct the initial editorial review of the submitted manuscript. Assess the structure, character development, narrative consistency, pacing, and overall suitability for publication, and provide your editorial recommendations after completing the review.','2026-10-03 10:38:12'),(88,12,'UNDER_REVIEW','REVISION_REQUESTED',9012,'Revision round 1 requested, due 2026-10-17','2026-10-03 10:42:14'),(89,12,'REVISION_REQUESTED','RESUBMITTED',9027,'Revision round 1 uploaded','2026-10-03 10:44:36'),(90,12,'RESUBMITTED','EDITORIALLY_ACCEPTED',9012,'Editorially accepted in review round 2','2026-10-03 10:48:01'),(91,12,'EDITORIALLY_ACCEPTED','EDITORIALLY_ACCEPTED',9007,'Designer assigned: Dilani Wickramasinghe','2026-10-03 10:49:20'),(92,12,'EDITORIALLY_ACCEPTED','EDITORIALLY_ACCEPTED',9007,'Designer assigned: Dilani Wickramasinghe','2026-10-03 10:49:28'),(93,12,'EDITORIALLY_ACCEPTED','IN_DESIGN',9017,'Design version 1 uploaded','2026-10-03 10:52:46'),(94,12,'IN_DESIGN','AWAITING_AUTHOR_APPROVAL',9017,'Design v1 sent to the author','2026-10-03 10:53:39'),(95,12,'AWAITING_AUTHOR_APPROVAL','IN_DESIGN',9027,'Author rejected design v1','2026-10-03 10:56:37'),(96,12,'IN_DESIGN','AWAITING_AUTHOR_APPROVAL',9017,'Design v2 sent to the author','2026-10-03 10:59:49'),(97,12,'AWAITING_AUTHOR_APPROVAL','DESIGN_APPROVED',9027,'Author approved design v2','2026-10-03 11:00:36'),(98,12,'DESIGN_APPROVED','QC_FAILED',9007,'Quality check failed: Quality check failed because the required production checks have not all been completed. Please address the unchecked items, Once all requirements are satisfied, please upload the corrected files for QC review. — returned to designer for fixes, then resubmit to QC','2026-10-03 11:02:22'),(99,12,'QC_FAILED','DESIGN_APPROVED',9017,'Design v3 resubmitted for quality check after QC fail','2026-10-03 11:05:00'),(100,12,'DESIGN_APPROVED','QC_PASSED',9007,'Quality check passed','2026-10-03 11:05:27'),(101,12,'QC_PASSED','READY_FOR_PRINTING',9007,'Ready for printing as book #7, ISBN 978-955-000007-4','2026-10-03 11:20:26');
/*!40000 ALTER TABLE `manuscript_status_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `manuscripts`
--

DROP TABLE IF EXISTS `manuscripts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `manuscripts` (
  `manuscript_id` bigint NOT NULL AUTO_INCREMENT,
  `author_id` bigint NOT NULL,
  `genre_id` bigint NOT NULL,
  `manuscript_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `synopsis` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `language` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `word_count` int DEFAULT NULL,
  `submitted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'SUBMITTED',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `assigned_editor_id` bigint DEFAULT NULL,
  `assigned_by` bigint DEFAULT NULL,
  `assigned_at` timestamp NULL DEFAULT NULL,
  `assignment_remarks` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`manuscript_id`),
  UNIQUE KEY `uq_manuscripts_code` (`manuscript_code`),
  KEY `fk_manuscripts_author` (`author_id`),
  KEY `fk_manuscripts_genre` (`genre_id`),
  KEY `idx_manuscripts_editor` (`assigned_editor_id`),
  CONSTRAINT `fk_manuscripts_author` FOREIGN KEY (`author_id`) REFERENCES `authors` (`author_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_manuscripts_genre` FOREIGN KEY (`genre_id`) REFERENCES `genres` (`genre_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `manuscripts`
--

LOCK TABLES `manuscripts` WRITE;
/*!40000 ALTER TABLE `manuscripts` DISABLE KEYS */;
INSERT INTO `manuscripts` VALUES (2,1,2,'MS-2026-00002','Amazonia','Hi dilumika','Sinhala',1500,'2026-09-27 11:28:13','PUBLISHED','2026-09-27 11:28:13','2026-10-03 09:51:59',9012,9004,'2026-10-03 08:56:58','demo'),(3,2,1,'MS-2026-00003','Ikigai','Be Positive','English',541,'2026-10-02 14:48:19','PUBLISHED','2026-10-02 14:48:18','2026-10-02 16:57:27',9012,9004,'2026-10-02 14:53:31','demo'),(4,2,1,'MS-2026-00004','Good Life Good Vibe','Law of attraction','English',600,'2026-10-02 14:49:10','SUBMITTED','2026-10-02 14:49:09','2026-10-02 14:51:40',NULL,NULL,NULL,NULL),(6,3,7,'MS-2026-00006','Radalathanna Walawwa','The story transitions from the claustrophobic, noisy, and artificial \"concrete hills\" of urban city life to the serene, natural heart of Sri Lanka. Set against a breathtaking backdrop of majestic mountains and flowing waterfalls, the narrative follows a female protagonist who escapes to this pristine paradise to find freedom and a sense of fresh renewal. Central to the plot is the Walawwa—a traditional ancestral manor house—which harbors its own distinct history, social dynamics, and secrets intertwined with the natural landscape. The novel captures her emotional journey of self-discovery, peace, and liberation away from the chaos of modern civilization.','Sinhala',NULL,'2026-10-03 06:04:42','PUBLISHED','2026-10-03 06:04:42','2026-10-03 09:53:20',9013,9004,'2026-10-03 08:54:49','demo'),(7,4,4,'MS-2026-00007','Badra','The story spans 204 pages and acts as an emotional and dramatic narrative focused on the life, internal conflicts, and interpersonal relationships of its titular character, Bhadra. It delves into themes of personal choices, family expectations, and the unexpected twists that permanently alter the course of a person\'s life journey.','Sinhala',NULL,'2026-10-03 06:16:25','SUBMITTED','2026-10-03 06:16:24','2026-10-03 07:57:48',NULL,NULL,NULL,NULL),(8,4,7,'MS-2026-00008','Magart','These books present a warm collection of animal tales, family anecdotes, and creative non-fiction spanning five generations of a ranching family. Spanning from the wild banks of the Big Salmon River in Central Idaho to the southern deserts, the stories explore the deep, humorous, and sometimes poignant bonds between country folk and the animals they rescue, inherit, and raise—from a toy poodle that believes it is a sheepdog to stubborn barnyard ewes.','Sinhala',NULL,'2026-10-03 06:19:08','PUBLISHED','2026-10-03 06:19:08','2026-10-03 09:52:21',9014,9004,'2026-10-03 08:54:34','demo'),(10,5,4,'MS-2026-00010','Healing Is The New High','Drawing heavily from his personal history of overcoming trauma, family turmoil, and financial hardship, Vex King argues that many individuals routinely suppress their emotional pain rather than processing it, which inadvertently lets past trauma dictate their adult lives, behaviors, and relationships. The book acts as a practical roadmap to help readers confront their deep-seated wounds, break free from negative cycles, and actively become their own healers.\nInstead of treating mental wellness as a purely intellectual exercise, King introduces a holistic approach that blends modern psychology with ancient yogic principles. He explains that unresolved trauma does not just stay in our thoughts; it settles across seven interconnected layers of the self (the physical, etheric, astral, mental, spiritual, cosmic, and nirvanic bodies). True healing requires working through these layers sequentially, starting with physical wellness and body awareness to safely discharge stored stress','Sinhala',NULL,'2026-10-03 06:41:01','PUBLISHED','2026-10-03 06:41:01','2026-10-03 09:53:04',9012,9004,'2026-10-03 08:54:02','demo'),(11,5,7,'MS-2026-00011','I don\'t love you anymore','signs to glow up','English',300,'2026-10-03 07:53:14','PUBLISHED','2026-10-03 07:53:14','2026-10-03 08:08:39',9013,9004,'2026-10-03 07:58:38','demo'),(12,6,1,'MS-2026-00012','The Last Light of Galle','The Last Light of Galle follows Nadee, who inherits an old house near the coast and discovers a forgotten lantern connected to the history of her town. An old map leads her to abandoned houses and records describing a lantern network once used by residents to guide people to safety during storms and floods. As Nadee investigates, she uncovers her grandmother\'s records about a devastating storm and the families who depended on the system. With another severe storm approaching, she discovers that most of the lanterns have disappeared and the tradition has nearly been forgotten. Nadee works with the community to restore the lanterns and identify safe routes. When the storm arrives, the restored lights guide residents through the flooded streets, turning an old tradition into a renewed community emergency system.','Sinhala',NULL,'2026-10-03 10:33:00','READY_FOR_PRINTING','2026-10-03 10:33:00','2026-10-03 11:20:26',9012,9004,'2026-10-03 10:38:12','Please conduct the initial editorial review of the submitted manuscript. Assess the structure, character development, narrative consistency, pacing, and overall suitability for publication, and provide your editorial recommendations after completing the review.');
/*!40000 ALTER TABLE `manuscripts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `notification_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `title` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `notification_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `related_entity_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `related_entity_id` bigint DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`),
  KEY `fk_notifications_user` (`user_id`),
  CONSTRAINT `fk_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `token_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` timestamp NOT NULL,
  `used_at` timestamp NULL DEFAULT NULL,
  `is_used` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`token_id`),
  UNIQUE KEY `uq_password_reset_token` (`token`),
  KEY `fk_password_reset_tokens_user` (`user_id`),
  CONSTRAINT `fk_password_reset_tokens_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_methods`
--

DROP TABLE IF EXISTS `payment_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_methods` (
  `payment_method_id` bigint NOT NULL AUTO_INCREMENT,
  `method_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`payment_method_id`),
  UNIQUE KEY `uq_payment_methods_name` (`method_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_methods`
--

LOCK TABLES `payment_methods` WRITE;
/*!40000 ALTER TABLE `payment_methods` DISABLE KEYS */;
/*!40000 ALTER TABLE `payment_methods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `payment_id` bigint NOT NULL AUTO_INCREMENT,
  `invoice_id` bigint NOT NULL,
  `payment_method_id` bigint NOT NULL,
  `payment_reference` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount_paid` decimal(12,2) NOT NULL,
  `paid_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `payment_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'SUCCESS',
  `processed_by` bigint DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`payment_id`),
  KEY `fk_payments_invoice` (`invoice_id`),
  KEY `fk_payments_method` (`payment_method_id`),
  KEY `fk_payments_user` (`processed_by`),
  CONSTRAINT `fk_payments_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`invoice_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_payments_method` FOREIGN KEY (`payment_method_id`) REFERENCES `payment_methods` (`payment_method_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_payments_user` FOREIGN KEY (`processed_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `print_orders`
--

DROP TABLE IF EXISTS `print_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `print_orders` (
  `print_order_id` bigint NOT NULL AUTO_INCREMENT,
  `book_id` bigint NOT NULL,
  `requested_by` bigint NOT NULL,
  `quantity` int NOT NULL,
  `printing_company` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `order_date` date NOT NULL,
  `expected_completion_date` date DEFAULT NULL,
  `completed_date` date DEFAULT NULL,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `quantity_received` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`print_order_id`),
  KEY `fk_print_orders_book` (`book_id`),
  KEY `fk_print_orders_requested_by` (`requested_by`),
  CONSTRAINT `fk_print_orders_book` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_print_orders_requested_by` FOREIGN KEY (`requested_by`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `print_orders`
--

LOCK TABLES `print_orders` WRITE;
/*!40000 ALTER TABLE `print_orders` DISABLE KEYS */;
INSERT INTO `print_orders` VALUES (1,1,9007,60,'Gunasena','2026-10-02','2026-11-02','2026-10-03','COMPLETED','2026-10-02 15:12:50','2026-10-03 09:53:48',60),(2,1,9007,60,'Gunasena','2026-10-02','2026-11-02','2026-10-02','COMPLETED','2026-10-02 15:26:28','2026-10-03 09:53:33',60),(3,2,9007,60,'Gunasena','2026-10-03','2026-10-06','2026-10-03','COMPLETED','2026-10-03 08:07:39','2026-10-03 08:08:39',60),(4,4,9007,100,'Sarasavi','2026-10-03','2026-11-03','2026-10-03','COMPLETED','2026-10-03 09:44:20','2026-10-03 09:53:20',100),(5,3,9007,60,'Reading planet','2026-10-03','2026-10-04','2026-10-03','COMPLETED','2026-10-03 09:47:33','2026-10-03 09:53:04',60),(6,5,9007,40,'Reading planet','2026-10-03','2026-10-04','2026-10-03','COMPLETED','2026-10-03 09:48:47','2026-10-03 09:52:21',40),(7,6,9007,30,'Reading planet','2026-10-03','2026-10-11','2026-10-03','COMPLETED','2026-10-03 09:49:52','2026-10-03 09:51:59',30);
/*!40000 ALTER TABLE `print_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `production_quality_checks`
--

DROP TABLE IF EXISTS `production_quality_checks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `production_quality_checks` (
  `qc_id` bigint NOT NULL AUTO_INCREMENT,
  `manuscript_id` bigint NOT NULL,
  `design_id` bigint NOT NULL,
  `checked_by` bigint NOT NULL,
  `result` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `checklist` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `checked_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`qc_id`),
  KEY `idx_qc_manuscript` (`manuscript_id`),
  KEY `fk_qc_design` (`design_id`),
  CONSTRAINT `fk_qc_design` FOREIGN KEY (`design_id`) REFERENCES `book_designs` (`design_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_qc_manuscript` FOREIGN KEY (`manuscript_id`) REFERENCES `manuscripts` (`manuscript_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `production_quality_checks`
--

LOCK TABLES `production_quality_checks` WRITE;
/*!40000 ALTER TABLE `production_quality_checks` DISABLE KEYS */;
INSERT INTO `production_quality_checks` VALUES (1,3,1,9007,'PASSED','{\"coverResolution\":true,\"layoutMatchesManuscript\":true,\"printFileValid\":true,\"metadataCorrect\":true,\"proofread\":true}','demo','2026-10-02 15:09:00'),(2,11,2,9007,'PASSED','{\"coverResolution\":true,\"layoutMatchesManuscript\":true,\"printFileValid\":true,\"metadataCorrect\":true,\"proofread\":true}','All good','2026-10-03 08:05:08'),(3,10,3,9007,'PASSED','{\"coverResolution\":true,\"layoutMatchesManuscript\":true,\"printFileValid\":true,\"metadataCorrect\":true,\"proofread\":true}','Demo','2026-10-03 09:21:44'),(4,6,7,9007,'PASSED','{\"coverResolution\":true,\"layoutMatchesManuscript\":true,\"printFileValid\":true,\"metadataCorrect\":true,\"proofread\":true}','good','2026-10-03 09:39:04'),(5,8,6,9007,'PASSED','{\"coverResolution\":true,\"layoutMatchesManuscript\":true,\"printFileValid\":true,\"metadataCorrect\":true,\"proofread\":true}','Good','2026-10-03 09:40:32'),(6,2,5,9007,'PASSED','{\"coverResolution\":true,\"layoutMatchesManuscript\":true,\"printFileValid\":true,\"metadataCorrect\":true,\"proofread\":true}','Good','2026-10-03 09:41:30'),(7,12,9,9007,'FAILED','{\"coverResolution\":true,\"layoutMatchesManuscript\":true,\"printFileValid\":false,\"metadataCorrect\":false,\"proofread\":false}','Quality check failed because the required production checks have not all been completed. Please address the unchecked items, Once all requirements are satisfied, please upload the corrected files for QC review.','2026-10-03 11:02:22'),(8,12,10,9007,'PASSED','{\"coverResolution\":true,\"layoutMatchesManuscript\":true,\"printFileValid\":true,\"metadataCorrect\":true,\"proofread\":true}',NULL,'2026-10-03 11:05:27');
/*!40000 ALTER TABLE `production_quality_checks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `production_tasks`
--

DROP TABLE IF EXISTS `production_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `production_tasks` (
  `task_id` bigint NOT NULL AUTO_INCREMENT,
  `manuscript_id` bigint NOT NULL,
  `assigned_to` bigint NOT NULL,
  `assigned_by` bigint NOT NULL,
  `task_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `priority` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'MEDIUM',
  `task_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `due_date` date DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`task_id`),
  KEY `fk_production_tasks_manuscript` (`manuscript_id`),
  KEY `fk_production_tasks_assigned_to` (`assigned_to`),
  KEY `fk_production_tasks_assigned_by` (`assigned_by`),
  CONSTRAINT `fk_production_tasks_assigned_by` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_production_tasks_assigned_to` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_production_tasks_manuscript` FOREIGN KEY (`manuscript_id`) REFERENCES `manuscripts` (`manuscript_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `production_tasks`
--

LOCK TABLES `production_tasks` WRITE;
/*!40000 ALTER TABLE `production_tasks` DISABLE KEYS */;
/*!40000 ALTER TABLE `production_tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `publishing_applications`
--

DROP TABLE IF EXISTS `publishing_applications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `publishing_applications` (
  `application_id` bigint NOT NULL AUTO_INCREMENT,
  `author_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_information` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `manuscript_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `book_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `short_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_type` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_size` bigint DEFAULT NULL,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `submitted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `approved_at` timestamp NULL DEFAULT NULL,
  `reviewed_by` bigint DEFAULT NULL,
  `author_user_id` bigint DEFAULT NULL,
  `rejection_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`application_id`),
  KEY `idx_pub_app_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `publishing_applications`
--

LOCK TABLES `publishing_applications` WRITE;
/*!40000 ALTER TABLE `publishing_applications` DISABLE KEYS */;
INSERT INTO `publishing_applications` VALUES (1,'Sahas Gunasekare','11/22, Gampaha Road,Yakkala','0772991447','nenulagunasekare@gmail.com','Depression','Thriller',NULL,'Epic3_Entities.pdf','applications/c1dfd8da-2f4.pdf','application/pdf',50179,'APPROVED','2026-10-03 05:35:13','2026-10-03 05:44:48',9003,9024,NULL),(2,'Randika Kadawathaarachchi','45/E, Ampe','077 6544390','randika@gmail.com','Pushparagha','Fiction',NULL,'Pushparagha.pdf','applications/c9017856-cbb.pdf','application/pdf',4043334,'APPROVED','2026-10-03 06:08:59','2026-10-03 06:09:39',9003,9025,NULL),(3,'Nisalma Werake','263/1,Balummahara','077 654231','nisalmamandini@gmail.com','Good Wife Good Life','Fiction',NULL,'Good Wife Good Life.pdf','applications/2b011ea5-c26.pdf','application/pdf',4043334,'APPROVED','2026-10-03 06:32:29','2026-10-03 07:46:21',9003,NULL,NULL),(4,'Harshani Abeysinghe','56/12,Colombo','077 3427410','harshani@gmail.com','The Last Light of Galle','Fiction',NULL,'The Last Light of Galle.pdf','applications/baec7193-065.pdf','application/pdf',36176,'APPROVED','2026-10-03 10:28:22','2026-10-03 10:28:50',9003,9027,NULL);
/*!40000 ALTER TABLE `publishing_applications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `role_id` bigint NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `uq_roles_role_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'ADMIN','ADMIN role','2026-09-15 08:49:17','2026-09-15 08:49:17'),(2,'AUTHOR','AUTHOR role','2026-09-15 08:49:17','2026-09-15 08:49:17'),(3,'EDITOR','EDITOR role','2026-09-15 08:49:17','2026-09-15 08:49:17'),(4,'PROOFREADER','PROOFREADER role','2026-09-15 08:49:17','2026-09-15 08:49:17'),(5,'DESIGNER','DESIGNER role','2026-09-15 08:49:17','2026-09-15 08:49:17'),(6,'PRODUCTION_MANAGER','PRODUCTION MANAGER role','2026-09-15 08:49:17','2026-09-15 08:49:17'),(7,'INVENTORY_STAFF','INVENTORY STAFF role','2026-09-15 08:49:17','2026-09-15 08:49:17'),(8,'SALES_STAFF','SALES STAFF role','2026-09-15 08:49:18','2026-09-15 08:49:18'),(9,'FINANCE_STAFF','FINANCE STAFF role','2026-09-15 08:49:18','2026-09-15 08:49:18'),(10,'CUSTOMER','CUSTOMER role','2026-09-15 08:49:18','2026-09-15 08:49:18'),(11,'CHIEF_EDITOR','CHIEF EDITOR role','2026-09-26 12:21:54','2026-09-26 12:21:54'),(12,'EXECUTIVE','EXECUTIVE role','2026-09-26 12:21:54','2026-09-26 12:21:54');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `royalty_agreements`
--

DROP TABLE IF EXISTS `royalty_agreements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `royalty_agreements` (
  `royalty_agreement_id` bigint NOT NULL AUTO_INCREMENT,
  `author_id` bigint NOT NULL,
  `book_id` bigint NOT NULL,
  `agreement_number` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `royalty_percentage` decimal(5,2) NOT NULL,
  `effective_date` date NOT NULL,
  `expiry_date` date DEFAULT NULL,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `basis` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'NET_SALES',
  `wholesale_royalty_percentage` decimal(5,2) DEFAULT NULL,
  `advance_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `advance_recouped` decimal(12,2) NOT NULL DEFAULT '0.00',
  `payment_frequency` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'QUARTERLY',
  `version` bigint NOT NULL DEFAULT '0',
  `author_signed_at` timestamp NULL DEFAULT NULL,
  `sent_to_author_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`royalty_agreement_id`),
  UNIQUE KEY `uq_agreement_number` (`agreement_number`),
  KEY `fk_royalty_author` (`author_id`),
  KEY `fk_royalty_book` (`book_id`),
  CONSTRAINT `fk_royalty_author` FOREIGN KEY (`author_id`) REFERENCES `authors` (`author_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_royalty_book` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `royalty_agreements`
--

LOCK TABLES `royalty_agreements` WRITE;
/*!40000 ALTER TABLE `royalty_agreements` DISABLE KEYS */;
INSERT INTO `royalty_agreements` VALUES (1,2,1,'RA-299963B7',10.00,'2026-08-03','2027-01-03','ACTIVE','2026-10-02 18:37:16','2026-10-03 04:34:32','NET_SALES',NULL,0.00,0.00,'QUARTERLY',3,'2026-10-02 18:44:15','2026-10-02 18:44:15'),(2,2,1,'RA-5549709F',7.00,'2026-06-30','2026-10-30','DRAFT','2026-10-03 05:08:49','2026-10-03 05:11:13','NET_SALES',5.00,10000.00,0.00,'BIANNUAL',2,'2026-10-03 05:11:13','2026-10-03 05:09:17');
/*!40000 ALTER TABLE `royalty_agreements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `royalty_calculation_lines`
--

DROP TABLE IF EXISTS `royalty_calculation_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `royalty_calculation_lines` (
  `line_id` bigint NOT NULL AUTO_INCREMENT,
  `calculation_id` bigint NOT NULL,
  `sale_id` bigint DEFAULT NULL,
  `sale_reference` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sale_date` date NOT NULL,
  `channel` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `line_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity` int NOT NULL,
  `unit_price` decimal(12,2) NOT NULL,
  `discount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `base_amount` decimal(14,2) NOT NULL,
  `rate_applied` decimal(5,2) NOT NULL,
  `royalty_amount` decimal(14,2) NOT NULL,
  PRIMARY KEY (`line_id`),
  KEY `idx_royalty_lines_calc` (`calculation_id`),
  CONSTRAINT `fk_royalty_lines_calc` FOREIGN KEY (`calculation_id`) REFERENCES `royalty_calculations` (`calculation_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `royalty_calculation_lines`
--

LOCK TABLES `royalty_calculation_lines` WRITE;
/*!40000 ALTER TABLE `royalty_calculation_lines` DISABLE KEYS */;
INSERT INTO `royalty_calculation_lines` VALUES (1,1,1,'CO-2026-00004-1','2026-10-02','CUSTOMER','SALE',13,2500.00,0.00,32500.00,10.00,3250.00),(2,1,2,'CO-2026-00003-1','2026-10-02','CUSTOMER','SALE',2,2500.00,0.00,5000.00,10.00,500.00),(3,1,3,'CO-2026-00002-1','2026-10-02','CUSTOMER','SALE',4,2500.00,0.00,10000.00,10.00,1000.00),(4,1,4,'CO-2026-00001-1','2026-10-02','CUSTOMER','SALE',3,2500.00,0.00,7500.00,10.00,750.00),(5,2,1,'CO-2026-00004-1','2026-10-02','CUSTOMER','SALE',13,2500.00,0.00,32500.00,10.00,3250.00),(6,2,2,'CO-2026-00003-1','2026-10-02','CUSTOMER','SALE',2,2500.00,0.00,5000.00,10.00,500.00),(7,2,3,'CO-2026-00002-1','2026-10-02','CUSTOMER','SALE',4,2500.00,0.00,10000.00,10.00,1000.00),(8,2,4,'CO-2026-00001-1','2026-10-02','CUSTOMER','SALE',3,2500.00,0.00,7500.00,10.00,750.00);
/*!40000 ALTER TABLE `royalty_calculation_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `royalty_calculations`
--

DROP TABLE IF EXISTS `royalty_calculations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `royalty_calculations` (
  `calculation_id` bigint NOT NULL AUTO_INCREMENT,
  `royalty_agreement_id` bigint NOT NULL,
  `sales_period_start` date NOT NULL,
  `sales_period_end` date NOT NULL,
  `books_sold` int NOT NULL DEFAULT '0',
  `gross_sales` decimal(14,2) NOT NULL DEFAULT '0.00',
  `deductions` decimal(14,2) NOT NULL DEFAULT '0.00',
  `royalty_base` decimal(14,2) NOT NULL DEFAULT '0.00',
  `royalty_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'CALCULATED',
  `calculated_by` bigint DEFAULT NULL,
  `calculated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `basis` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `royalty_rate` decimal(5,2) DEFAULT NULL,
  `wholesale_rate` decimal(5,2) DEFAULT NULL,
  `units_returned` int NOT NULL DEFAULT '0',
  `returns_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `advance_recouped` decimal(14,2) NOT NULL DEFAULT '0.00',
  `carried_forward_in` decimal(14,2) NOT NULL DEFAULT '0.00',
  `payable_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `carried_into_calculation_id` bigint DEFAULT NULL,
  `statement_number` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `statement_issued_by` bigint DEFAULT NULL,
  `statement_issued_at` timestamp NULL DEFAULT NULL,
  `approved_by` bigint DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cancel_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cancelled_by` bigint DEFAULT NULL,
  `cancelled_at` timestamp NULL DEFAULT NULL,
  `version` bigint NOT NULL DEFAULT '0',
  `period_lock` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`calculation_id`),
  UNIQUE KEY `uq_royalty_calc_active_period` (`royalty_agreement_id`,`sales_period_start`,`sales_period_end`,`period_lock`),
  UNIQUE KEY `uq_royalty_statement_number` (`statement_number`),
  KEY `fk_royalty_calc_user` (`calculated_by`),
  CONSTRAINT `fk_royalty_calc_agreement` FOREIGN KEY (`royalty_agreement_id`) REFERENCES `royalty_agreements` (`royalty_agreement_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_royalty_calc_user` FOREIGN KEY (`calculated_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `royalty_calculations`
--

LOCK TABLES `royalty_calculations` WRITE;
/*!40000 ALTER TABLE `royalty_calculations` DISABLE KEYS */;
INSERT INTO `royalty_calculations` VALUES (1,1,'2026-08-03','2026-10-03',22,55000.00,0.00,55000.00,5500.00,'CANCELLED',5,'2026-10-02 18:39:44','2026-10-02 18:39:44','2026-10-02 18:39:53','NET_SALES',10.00,NULL,0,0.00,0.00,0.00,5500.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Recalculated',5,'2026-10-02 18:39:53',1,NULL),(2,1,'2026-08-03','2026-10-03',22,55000.00,0.00,55000.00,5500.00,'PAID',5,'2026-10-02 18:39:53','2026-10-02 18:39:53','2026-10-02 18:40:26','NET_SALES',10.00,NULL,0,0.00,0.00,0.00,5500.00,NULL,'RS-2026-00001',5,'2026-10-02 18:39:56',5,'2026-10-02 18:40:16',NULL,NULL,NULL,NULL,3,1);
/*!40000 ALTER TABLE `royalty_calculations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `royalty_payments`
--

DROP TABLE IF EXISTS `royalty_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `royalty_payments` (
  `royalty_payment_id` bigint NOT NULL AUTO_INCREMENT,
  `royalty_agreement_id` bigint NOT NULL,
  `calculation_id` bigint DEFAULT NULL,
  `payment_reference` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `payment_method` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_date` date NOT NULL,
  `payment_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `approved_by` bigint DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `paid_at` timestamp NULL DEFAULT NULL,
  `processed_by` bigint DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `transaction_reference` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `version` bigint NOT NULL DEFAULT '0',
  PRIMARY KEY (`royalty_payment_id`),
  UNIQUE KEY `uq_royalty_payment_reference` (`payment_reference`),
  UNIQUE KEY `uq_royalty_payment_txn_reference` (`transaction_reference`),
  KEY `fk_royalty_payment_agreement` (`royalty_agreement_id`),
  KEY `fk_royalty_payment_user` (`processed_by`),
  KEY `fk_royalty_payment_calculation` (`calculation_id`),
  KEY `fk_royalty_payment_approver` (`approved_by`),
  CONSTRAINT `fk_royalty_payment_agreement` FOREIGN KEY (`royalty_agreement_id`) REFERENCES `royalty_agreements` (`royalty_agreement_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_royalty_payment_approver` FOREIGN KEY (`approved_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_royalty_payment_calculation` FOREIGN KEY (`calculation_id`) REFERENCES `royalty_calculations` (`calculation_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_royalty_payment_user` FOREIGN KEY (`processed_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `royalty_payments`
--

LOCK TABLES `royalty_payments` WRITE;
/*!40000 ALTER TABLE `royalty_payments` DISABLE KEYS */;
INSERT INTO `royalty_payments` VALUES (1,1,2,'RP-2026-00001',5500.00,'BANK_TRANSFER','2026-10-03','PAID',5,'2026-10-02 18:40:16','2026-10-02 18:40:26',5,'2026-10-02 18:40:16','2026-10-02 18:40:26','boc',1);
/*!40000 ALTER TABLE `royalty_payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sales_records`
--

DROP TABLE IF EXISTS `sales_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sales_records` (
  `sale_id` bigint NOT NULL AUTO_INCREMENT,
  `sale_reference` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `channel` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `book_id` bigint NOT NULL,
  `book_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity` int NOT NULL,
  `unit_price` decimal(12,2) NOT NULL,
  `sale_amount` decimal(12,2) NOT NULL,
  `sale_date` date NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'COMPLETED',
  `received_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `discount` decimal(12,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`sale_id`),
  UNIQUE KEY `uq_sales_records_reference` (`sale_reference`),
  KEY `idx_sales_records_book_date` (`book_id`,`status`,`sale_date`),
  KEY `idx_sales_records_date` (`sale_date`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sales_records`
--

LOCK TABLES `sales_records` WRITE;
/*!40000 ALTER TABLE `sales_records` DISABLE KEYS */;
INSERT INTO `sales_records` VALUES (1,'CO-2026-00004-1','CUSTOMER',1,'Ikigai',13,2500.00,32500.00,'2026-10-02','COMPLETED','2026-10-02 17:32:11',0.00),(2,'CO-2026-00003-1','CUSTOMER',1,'Ikigai',2,2500.00,5000.00,'2026-10-02','COMPLETED','2026-10-02 17:32:13',0.00),(3,'CO-2026-00002-1','CUSTOMER',1,'Ikigai',4,2500.00,10000.00,'2026-10-02','COMPLETED','2026-10-02 17:32:15',0.00),(4,'CO-2026-00001-1','CUSTOMER',1,'Ikigai',3,2500.00,7500.00,'2026-10-02','COMPLETED','2026-10-02 17:32:18',0.00),(5,'CO-2026-00005-1','CUSTOMER',2,'I don\'t love you anymore',1,2500.00,2500.00,'2026-10-03','COMPLETED','2026-10-03 08:12:14',0.00),(6,'CO-2026-00008-1','CUSTOMER',5,'Magart',1,2100.00,2100.00,'2026-10-03','COMPLETED','2026-10-03 10:00:35',0.00),(7,'CO-2026-00008-2','CUSTOMER',3,'Healing Is The New High',1,3200.00,3200.00,'2026-10-03','COMPLETED','2026-10-03 10:00:35',0.00),(8,'CO-2026-00008-3','CUSTOMER',4,'Radalathanna Walawwa',1,2500.00,2500.00,'2026-10-03','COMPLETED','2026-10-03 10:00:35',0.00),(9,'CO-2026-00008-4','CUSTOMER',1,'Ikigai',1,2500.00,2500.00,'2026-10-03','COMPLETED','2026-10-03 10:00:35',0.00),(10,'CO-2026-00007-1','BOOKSTORE',4,'Radalathanna Walawwa',10,2500.00,25000.00,'2026-10-03','COMPLETED','2026-10-03 10:00:39',0.00),(11,'CO-2026-00007-2','BOOKSTORE',3,'Healing Is The New High',10,3200.00,32000.00,'2026-10-03','COMPLETED','2026-10-03 10:00:39',0.00),(12,'CO-2026-00007-3','BOOKSTORE',2,'I don\'t love you anymore',10,2500.00,25000.00,'2026-10-03','COMPLETED','2026-10-03 10:00:39',0.00),(13,'CO-2026-00006-1','CUSTOMER',4,'Radalathanna Walawwa',1,2500.00,2500.00,'2026-10-03','COMPLETED','2026-10-03 10:00:42',0.00),(14,'CO-2026-00006-2','CUSTOMER',3,'Healing Is The New High',1,3200.00,3200.00,'2026-10-03','COMPLETED','2026-10-03 10:00:42',0.00),(15,'CO-2026-00006-3','CUSTOMER',5,'Magart',1,2100.00,2100.00,'2026-10-03','COMPLETED','2026-10-03 10:00:42',0.00),(16,'CO-2026-00006-4','CUSTOMER',6,'Amazonia',1,550.00,550.00,'2026-10-03','COMPLETED','2026-10-03 10:00:42',0.00),(17,'CO-2026-00006-5','CUSTOMER',2,'I don\'t love you anymore',1,2500.00,2500.00,'2026-10-03','COMPLETED','2026-10-03 10:00:42',0.00),(18,'CO-2026-00006-6','CUSTOMER',1,'Ikigai',1,2500.00,2500.00,'2026-10-03','COMPLETED','2026-10-03 10:00:42',0.00);
/*!40000 ALTER TABLE `sales_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shipments`
--

DROP TABLE IF EXISTS `shipments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shipments` (
  `shipment_id` bigint NOT NULL AUTO_INCREMENT,
  `customer_order_id` bigint NOT NULL,
  `tracking_number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shipping_provider` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shipped_date` date DEFAULT NULL,
  `delivered_date` date DEFAULT NULL,
  `shipment_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `shipping_cost` decimal(12,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`shipment_id`),
  UNIQUE KEY `uq_shipments_tracking` (`tracking_number`),
  KEY `fk_shipments_customer_order` (`customer_order_id`),
  CONSTRAINT `fk_shipments_customer_order` FOREIGN KEY (`customer_order_id`) REFERENCES `customer_orders` (`customer_order_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shipments`
--

LOCK TABLES `shipments` WRITE;
/*!40000 ALTER TABLE `shipments` DISABLE KEYS */;
INSERT INTO `shipments` VALUES (1,4,NULL,NULL,'2026-10-02','2026-10-02','DELIVERED',NULL,'2026-10-02 17:32:09','2026-10-02 17:32:11'),(2,3,NULL,NULL,'2026-10-02','2026-10-02','DELIVERED',NULL,'2026-10-02 17:32:13','2026-10-02 17:32:13'),(3,2,NULL,NULL,'2026-10-02','2026-10-02','DELIVERED',NULL,'2026-10-02 17:32:15','2026-10-02 17:32:15'),(4,1,NULL,NULL,'2026-10-02','2026-10-02','DELIVERED',NULL,'2026-10-02 17:32:17','2026-10-02 17:32:18'),(5,5,NULL,NULL,'2026-10-03','2026-10-03','DELIVERED',NULL,'2026-10-03 08:12:05','2026-10-03 08:12:14'),(6,8,NULL,NULL,'2026-10-03','2026-10-03','DELIVERED',NULL,'2026-10-03 10:00:35','2026-10-03 10:00:35'),(7,7,NULL,NULL,'2026-10-03','2026-10-03','DELIVERED',NULL,'2026-10-03 10:00:38','2026-10-03 10:00:39'),(8,6,NULL,NULL,'2026-10-03','2026-10-03','DELIVERED',NULL,'2026-10-03 10:00:41','2026-10-03 10:00:42');
/*!40000 ALTER TABLE `shipments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_settings`
--

DROP TABLE IF EXISTS `system_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_settings` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `setting_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_by` bigint DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `uq_system_settings_key` (`setting_key`),
  KEY `fk_system_settings_user` (`updated_by`),
  CONSTRAINT `fk_system_settings_user` FOREIGN KEY (`updated_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_settings`
--

LOCK TABLES `system_settings` WRITE;
/*!40000 ALTER TABLE `system_settings` DISABLE KEYS */;
INSERT INTO `system_settings` VALUES (1,'currency','LKR','For overseas',4,'2026-10-03 11:39:32'),(2,'taxRatePercent','0.00','Tax rate (%) applied to new invoices',NULL,'2026-09-26 12:21:54'),(3,'invoicePrefix','INV-','Prefix of generated invoice numbers',NULL,'2026-09-26 12:21:54'),(4,'royaltyPaymentThreshold','2000.00','Royalty payable below this amount is carried forward instead of approved',4,'2026-10-02 17:57:14'),(5,'companyName','Reading Planet','Company name printed on invoices and statements',NULL,'2026-09-26 12:21:54'),(6,'companyAddress','1470/1F, Delgahawaththa Road, Pannipitiya','Company address printed on invoices and statements',NULL,'2026-09-26 12:21:54');
/*!40000 ALTER TABLE `system_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_roles` (
  `user_role_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `role_id` bigint NOT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_role_id`),
  UNIQUE KEY `uq_user_role` (`user_id`,`role_id`),
  KEY `fk_user_roles_role` (`role_id`),
  CONSTRAINT `fk_user_roles_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_user_roles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_roles`
--

LOCK TABLES `user_roles` WRITE;
/*!40000 ALTER TABLE `user_roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_sessions`
--

DROP TABLE IF EXISTS `user_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_sessions` (
  `session_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `session_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_agent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `login_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_activity_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NOT NULL,
  `logout_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`session_id`),
  UNIQUE KEY `uq_user_sessions_token` (`session_token`),
  KEY `fk_user_sessions_user` (`user_id`),
  CONSTRAINT `fk_user_sessions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=169 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_sessions`
--

LOCK TABLES `user_sessions` WRITE;
/*!40000 ALTER TABLE `user_sessions` DISABLE KEYS */;
INSERT INTO `user_sessions` VALUES (1,4,'a54eac562a6143038660ef0d9a494f15','0:0:0:0:0:0:0:1','curl/8.12.1','2026-09-26 12:25:14','2026-09-26 12:25:14','2026-09-27 12:25:14',NULL,1),(2,4,'d6e7a33d3d784bc8ae8966746fcc4243','0:0:0:0:0:0:0:1','curl/8.12.1','2026-09-26 12:25:23','2026-09-26 12:25:23','2026-09-27 12:25:23',NULL,1),(3,4,'528e820935614b3f91243368eed3d266','0:0:0:0:0:0:0:1','curl/8.12.1','2026-09-26 12:34:51','2026-09-26 12:34:51','2026-09-27 12:34:51',NULL,1),(4,4,'e23552c63e4443499a841fdda43786f0','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-26 12:42:43','2026-09-26 12:42:43','2026-09-27 12:42:43',NULL,1),(5,5,'1d9f4bb85945424e9ea89c325e4f3e92','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-26 12:49:42','2026-09-26 12:49:42','2026-09-27 12:49:42',NULL,1),(6,9002,'d01ff167ea224e269fd1cc51b95a4604','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 11:16:09','2026-09-27 11:16:09','2026-09-28 11:16:09',NULL,1),(7,9002,'7fef2f29e86841b4a1f1136ee7245fbf','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 11:18:31','2026-09-27 11:18:31','2026-09-28 11:18:31',NULL,1),(8,9002,'17fb0bdc2eba4cc8b4d52c979c2570af','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 11:20:08','2026-09-27 11:20:08','2026-09-28 11:20:08',NULL,1),(9,4,'d2e297b3053b4e5f95ec31a02e805a86','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 11:33:43','2026-09-27 11:33:43','2026-09-28 11:33:43',NULL,1),(10,5,'669806a26e0e4b34aa484ddbd48fe801','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 11:45:40','2026-09-27 11:45:40','2026-09-28 11:45:40',NULL,1),(11,5,'2206c7dfee7840429d0b32451d256621','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 11:48:53','2026-09-27 11:48:53','2026-09-28 11:48:53',NULL,1),(12,9003,'1b081a4decc94078b2b64ca3cb7ceff6','0:0:0:0:0:0:0:1','curl/8.12.1','2026-09-27 12:05:47','2026-09-27 12:05:47','2026-09-28 12:05:47',NULL,1),(13,9004,'1bfc2605c4694462a992f8b4ee9368a3','0:0:0:0:0:0:0:1','curl/8.12.1','2026-09-27 12:05:47','2026-09-27 12:05:47','2026-09-28 12:05:47',NULL,1),(14,9005,'e1172ed35e0040eaa2aa91fbd4fd1272','0:0:0:0:0:0:0:1','curl/8.12.1','2026-09-27 12:05:47','2026-09-27 12:05:47','2026-09-28 12:05:47',NULL,1),(15,9006,'a00fd1db99a44bf1a4d7b02d134da2f2','0:0:0:0:0:0:0:1','curl/8.12.1','2026-09-27 12:05:48','2026-09-27 12:05:48','2026-09-28 12:05:48',NULL,1),(16,9007,'e0f72992cfa14de49a6b2873e2ce92c5','0:0:0:0:0:0:0:1','curl/8.12.1','2026-09-27 12:05:48','2026-09-27 12:05:48','2026-09-28 12:05:48',NULL,1),(17,9008,'d49853f2dcef48508bf098406e82ed55','0:0:0:0:0:0:0:1','curl/8.12.1','2026-09-27 12:05:48','2026-09-27 12:05:48','2026-09-28 12:05:48',NULL,1),(18,9009,'121517af9b154a89affb370ea3e61328','0:0:0:0:0:0:0:1','curl/8.12.1','2026-09-27 12:05:48','2026-09-27 12:05:48','2026-09-28 12:05:48',NULL,1),(19,9010,'66a4a14b4c474a9ea62147c4d630c219','0:0:0:0:0:0:0:1','curl/8.12.1','2026-09-27 12:05:48','2026-09-27 12:05:48','2026-09-28 12:05:48',NULL,1),(20,9011,'f4348127200f4b17a6438e8afb8e504a','0:0:0:0:0:0:0:1','curl/8.12.1','2026-09-27 12:05:48','2026-09-27 12:05:48','2026-09-28 12:05:48',NULL,1),(21,9003,'8d72b9f3a38144d1a8d48fab2eb22534','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 12:09:13','2026-09-27 12:09:13','2026-09-28 12:09:13',NULL,1),(22,9004,'fe98d77d9c404c3395ce19cb2eb2c72f','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 12:33:17','2026-09-27 12:33:17','2026-09-28 12:33:17',NULL,1),(23,9007,'173e73f56ad340559849ad8a46c7f81a','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 12:34:19','2026-09-27 12:34:19','2026-09-28 12:34:19',NULL,1),(24,9008,'a93bd777fee943a9a78094cb629b74b6','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 12:34:55','2026-09-27 12:34:55','2026-09-28 12:34:55',NULL,1),(25,9009,'231712df9b8249c182c0a834b915cf7b','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 12:35:20','2026-09-27 12:35:20','2026-09-28 12:35:20',NULL,1),(26,9010,'169ca463b20248cca433eb50902868b6','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 12:36:07','2026-09-27 12:36:07','2026-09-28 12:36:07',NULL,1),(27,9010,'92f16cede51c4aecab5d3480b40352dc','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 12:36:39','2026-09-27 12:36:39','2026-09-28 12:36:39',NULL,1),(28,9006,'7be7aecfe3584adab6f1e89ea2ebdea4','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 12:37:41','2026-09-27 12:37:41','2026-09-28 12:37:41',NULL,1),(29,9003,'6cde58bea8ae4c88bae023c3b4d353ce','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 12:44:54','2026-09-27 12:44:54','2026-09-28 12:44:54',NULL,1),(30,9004,'d0e2c6e77109429fb88b3cbdcfb9173e','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 12:47:27','2026-09-27 12:47:27','2026-09-28 12:47:27',NULL,1),(31,9005,'7c8a5d1052d44fa4b565f182ed572898','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 13:07:41','2026-09-27 13:07:41','2026-09-28 13:07:41',NULL,1),(32,9006,'59caf72a549e4bc38b210797673212d6','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 13:08:25','2026-09-27 13:08:25','2026-09-28 13:08:25',NULL,1),(33,9006,'d79bc834a96940a383c1c9403a592433','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 15:49:06','2026-09-27 15:49:06','2026-09-28 15:49:06',NULL,1),(34,9006,'c76873922fd7464aa180f62d1a63ba29','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 15:49:12','2026-09-27 15:49:12','2026-09-28 15:49:12',NULL,1),(35,9006,'4b99d5365c0544cd8007c2ed109e9a45','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 15:50:36','2026-09-27 15:50:36','2026-09-28 15:50:36',NULL,1),(36,9006,'04f43a874401499698fe5904599b2087','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 15:50:44','2026-09-27 15:50:44','2026-09-28 15:50:44',NULL,1),(37,9003,'926f46ca167040959572830bdb491e6b','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36','2026-09-27 15:53:52','2026-09-27 15:53:52','2026-09-28 15:53:52',NULL,1),(38,9003,'7e4e67b96f2b4978ba350fc9e7579791','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 14:25:12','2026-10-02 14:25:12','2026-10-03 14:25:12',NULL,1),(39,9018,'9f95cc584d03409b999f14560f826320','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 14:43:17','2026-10-02 14:43:17','2026-10-03 14:43:17',NULL,1),(40,9018,'d9e38d7bd3ec4fd7b1478da1d18983ec','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 14:47:15','2026-10-02 14:47:15','2026-10-03 14:47:15',NULL,1),(41,9003,'78f4f4f0fe6a476f9fc65f4d3b789d70','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 14:49:38','2026-10-02 14:49:38','2026-10-03 14:49:38',NULL,1),(42,9004,'ae8bd22b7fcb4baa9e957585ecf5e20f','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 14:52:01','2026-10-02 14:52:01','2026-10-03 14:52:01',NULL,1),(43,9003,'b86d86fcab1b4f59879383cd7df7e42c','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 14:55:16','2026-10-02 14:55:16','2026-10-03 14:55:16',NULL,1),(44,9012,'bd1c7fc0d3de4c7c9b4e70b058e1cbc4','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 14:55:47','2026-10-02 14:55:47','2026-10-03 14:55:47',NULL,1),(45,9018,'9823ef33ef3f459bbc6786bafa0a91fe','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 15:01:54','2026-10-02 15:01:54','2026-10-03 15:01:54',NULL,1),(46,9007,'d6874efc33d847f381338bf98e25323a','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 15:03:06','2026-10-02 15:03:06','2026-10-03 15:03:06',NULL,1),(47,9018,'b00beaf4dcde4285a71cd5fca0db97ed','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 15:03:53','2026-10-02 15:03:53','2026-10-03 15:03:53',NULL,1),(48,9003,'072204d6b2e34a64842d2802fed2e202','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 15:04:28','2026-10-02 15:04:28','2026-10-03 15:04:28',NULL,1),(49,9016,'e22787a710334abca961974cff3dbddb','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 15:04:49','2026-10-02 15:04:49','2026-10-03 15:04:49',NULL,1),(50,9018,'a11a2c53bcd444e98865e03e9ad4665f','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 15:06:07','2026-10-02 15:06:07','2026-10-03 15:06:07',NULL,1),(51,9007,'9c9e2120af7b42888770b06be67ec8d9','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 15:07:21','2026-10-02 15:07:21','2026-10-03 15:07:21',NULL,1),(52,9003,'730277d856834784b057705e8b27ea3a','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 15:13:55','2026-10-02 15:13:55','2026-10-03 15:13:55',NULL,1),(53,9007,'eea39fc1dd2b47278f54cf1e19968b92','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 15:20:23','2026-10-02 15:20:23','2026-10-03 15:20:23',NULL,1),(54,9008,'9cb8e20995e54134af3cd1fcae3b86b0','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 15:21:00','2026-10-02 15:21:00','2026-10-03 15:21:00',NULL,1),(55,9020,'868b6ab6931d4cc4a9d234a7bcec9a78','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 15:25:17','2026-10-02 15:25:17','2026-10-03 15:25:17',NULL,1),(56,9007,'d62698822cf247bbacba09251724ec5b','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 15:25:40','2026-10-02 15:25:40','2026-10-03 15:25:40',NULL,1),(57,9008,'d3973ae5e0214745917d3fe34383facb','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 16:56:25','2026-10-02 16:56:25','2026-10-03 16:56:25',NULL,1),(58,9018,'3d7223a1482a4bee8124f14e19f935a1','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 17:08:52','2026-10-02 17:08:52','2026-10-03 17:08:52',NULL,1),(59,9021,'508c5e543ed445b5b79a9fe296a5f9f0','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 17:17:33','2026-10-02 17:17:33','2026-10-03 17:17:33',NULL,1),(60,9022,'b890aae4373443e580701913f2eb4cd9','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 17:23:16','2026-10-02 17:23:16','2026-10-03 17:23:16',NULL,1),(61,9009,'d892824659a243789aa18bb636393f98','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 17:26:00','2026-10-02 17:26:00','2026-10-03 17:26:00',NULL,1),(62,9023,'d65ac2a3a6f142b5a243ea15ba00a376','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 17:28:36','2026-10-02 17:28:36','2026-10-03 17:28:36',NULL,1),(63,9008,'c59551d120114822997120371d1461e2','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 17:31:11','2026-10-02 17:31:11','2026-10-03 17:31:11',NULL,1),(64,9003,'fc5a9889e2e24bc583eaed346caaee86','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 17:34:23','2026-10-02 17:34:23','2026-10-03 17:34:23',NULL,1),(65,9003,'f24a6c5a01b043c8a537b08f857854fd','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 17:36:12','2026-10-02 17:36:12','2026-10-03 17:36:12',NULL,1),(66,4,'b06f5329094e4ac8b273e4526accc997','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 17:45:39','2026-10-02 17:45:39','2026-10-03 17:45:39',NULL,1),(67,5,'e8c2781c1a8b4587b0f17f6a7796329c','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 18:04:30','2026-10-02 18:04:30','2026-10-03 18:04:30',NULL,1),(68,9018,'2a65e841d6944821bf65ac856b25933e','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 18:41:42','2026-10-02 18:41:42','2026-10-03 18:41:42',NULL,1),(69,5,'db14dbe2adba47179fbd9541c81f8629','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 18:47:29','2026-10-02 18:47:29','2026-10-03 18:47:29',NULL,1),(70,9018,'670fc054607c4fd1a2e27d687c2c7d56','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 18:49:01','2026-10-02 18:49:01','2026-10-03 18:49:01',NULL,1),(71,5,'a0f39fb485984799b021e77fe18162c5','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 18:57:15','2026-10-02 18:57:15','2026-10-03 18:57:15',NULL,1),(72,9018,'ff86b4d014b84a6f9380327d708f1a3c','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 19:03:56','2026-10-02 19:03:56','2026-10-03 19:03:56',NULL,1),(73,9010,'a07232091e564d08b8bba0c6767f5926','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 19:05:53','2026-10-02 19:05:53','2026-10-03 19:05:53',NULL,1),(74,9010,'9313e40ef8774a919817371e2d714cff','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-02 19:06:43','2026-10-02 19:06:43','2026-10-03 19:06:43',NULL,1),(75,9018,'72abb4f3230044c3abbbcf4dab2db49d','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 04:11:41','2026-10-03 04:11:41','2026-10-04 04:11:41',NULL,1),(76,9018,'dc09921bcadf459fad149ba57e6caeb4','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 04:39:49','2026-10-03 04:39:49','2026-10-04 04:39:49',NULL,1),(77,5,'fd862f3a81c146968c07de713f2dff33','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 04:46:28','2026-10-03 04:46:28','2026-10-04 04:46:28',NULL,1),(78,9018,'6dfd93ea2bb14fe884f9d3c2a1fae4b3','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 05:10:56','2026-10-03 05:10:56','2026-10-04 05:10:56',NULL,1),(79,5,'f81bb950999247e6849339214c790b0e','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 05:11:56','2026-10-03 05:11:56','2026-10-04 05:11:56',NULL,1),(80,9003,'34ab88b8afa9417e9429bb75c118e343','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 05:36:55','2026-10-03 05:36:55','2026-10-04 05:36:55',NULL,1),(81,9024,'ca55d5c819104db781e033033f9be2ed','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 05:46:31','2026-10-03 05:46:31','2026-10-04 05:46:31',NULL,1),(82,9003,'f42d10f3ad6e4a74a45c0def7b2f0ebd','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 06:09:22','2026-10-03 06:09:22','2026-10-04 06:09:22',NULL,1),(83,9025,'2d78cc34505c4945905eb947804590f0','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 06:11:08','2026-10-03 06:11:08','2026-10-04 06:11:08',NULL,1),(84,9026,'b369be7faa5444778663a204c3bc5f7e','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 06:33:37','2026-10-03 06:33:37','2026-10-04 06:33:37',NULL,1),(85,9003,'c8df1f1dfcc3412ab44e4794db71eabb','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 07:45:58','2026-10-03 07:45:58','2026-10-04 07:45:58',NULL,1),(86,9004,'58bb2c20cab2487192e501058da64c52','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 07:46:34','2026-10-03 07:46:34','2026-10-04 07:46:34',NULL,1),(87,9026,'e8fa1473eaf346af8cba64b04cfdcb97','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 07:47:10','2026-10-03 07:47:10','2026-10-04 07:47:10',NULL,1),(88,9003,'85322c104c6f4e20ac13cd75da3a5d62','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 07:47:50','2026-10-03 07:47:50','2026-10-04 07:47:50',NULL,1),(89,9004,'71601ec8f7c7428fb2508e4a2f4c0942','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 07:48:50','2026-10-03 07:48:50','2026-10-04 07:48:50',NULL,1),(90,9026,'0b49bcfd71ad4fd592f8555c60a99fb0','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 07:50:25','2026-10-03 07:50:25','2026-10-04 07:50:25',NULL,1),(91,9003,'998093b4e3794f4199647a0c14c3eb26','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 07:53:43','2026-10-03 07:53:43','2026-10-04 07:53:43',NULL,1),(92,9003,'e8aea43a93f643b2aee36b30139c5c61','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 07:56:25','2026-10-03 07:56:25','2026-10-04 07:56:25',NULL,1),(93,9026,'7cbde900eb4d4e6f91b639e8f80241c3','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 07:56:50','2026-10-03 07:56:50','2026-10-04 07:56:50',NULL,1),(94,9003,'4fb071a713034fe48ee49fab034e10e0','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 07:57:19','2026-10-03 07:57:19','2026-10-04 07:57:19',NULL,1),(95,9004,'3413eb5507b345859b5fd87c184563c2','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 07:58:17','2026-10-03 07:58:17','2026-10-04 07:58:17',NULL,1),(96,9003,'d49bfe5431ad4fdaae93a7714bc6cbaf','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 07:59:35','2026-10-03 07:59:35','2026-10-04 07:59:35',NULL,1),(97,9013,'bd5c228211914e2d97c35ec310df1709','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 08:00:12','2026-10-03 08:00:12','2026-10-04 08:00:12',NULL,1),(98,9007,'a46cea24b37440e9a17535bd4380fb5a','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 08:00:48','2026-10-03 08:00:48','2026-10-04 08:00:48',NULL,1),(99,9003,'b24cdc70649a4dd6a68f544ee1315ca9','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 08:01:11','2026-10-03 08:01:11','2026-10-04 08:01:11',NULL,1),(100,9017,'a1a895207be64021bd1a579d1d59ea5f','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 08:01:39','2026-10-03 08:01:39','2026-10-04 08:01:39',NULL,1),(101,9026,'e18665ce1e1c4501a530147413cf410e','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 08:04:09','2026-10-03 08:04:09','2026-10-04 08:04:09',NULL,1),(102,9007,'7a7a29cef8464615b0c8b667a6703591','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 08:04:39','2026-10-03 08:04:39','2026-10-04 08:04:39',NULL,1),(103,9002,'190158e6320a417dba8befa786702a0a','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 08:06:11','2026-10-03 08:06:11','2026-10-04 08:06:11',NULL,1),(104,9022,'5a4f2375cc4c4257afe45f46722d71ae','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 08:06:53','2026-10-03 08:06:53','2026-10-04 08:06:53',NULL,1),(105,9007,'cadeae4dca484cf39610c6e4cb22eb6b','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 08:07:16','2026-10-03 08:07:16','2026-10-04 08:07:16',NULL,1),(106,9008,'7ca817d4262840f8a791941b8757b1f8','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 08:08:18','2026-10-03 08:08:18','2026-10-04 08:08:18',NULL,1),(107,9022,'8e3b306ac4c64897a616adda6e0766b1','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 08:09:05','2026-10-03 08:09:05','2026-10-04 08:09:05',NULL,1),(108,9009,'fbed1e346f774ab3b9281453d85e8505','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 08:11:00','2026-10-03 08:11:00','2026-10-04 08:11:00',NULL,1),(109,9022,'a3aa4d6173ad40aab39090cf06e24f44','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 08:11:30','2026-10-03 08:11:30','2026-10-04 08:11:30',NULL,1),(110,9008,'684bb1372b4849f3a7952326df757b5a','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 08:11:51','2026-10-03 08:11:51','2026-10-04 08:11:51',NULL,1),(111,9004,'6bc8076df670419fbe24b40d2cade6b5','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 08:12:50','2026-10-03 08:12:50','2026-10-04 08:12:50',NULL,1),(112,9003,'d0b53bd89d9d4a6a82abb30e6c24845b','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 08:57:26','2026-10-03 08:57:26','2026-10-04 08:57:26',NULL,1),(113,9012,'3b4af989142e4a7f82f5a10272756295','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 08:59:14','2026-10-03 08:59:14','2026-10-04 08:59:14',NULL,1),(114,9003,'90ed72b1fd3c4410aaf2a84b4510738d','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 09:00:40','2026-10-03 09:00:40','2026-10-04 09:00:40',NULL,1),(115,9013,'700effdebea542f6a2870a52502258cf','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 09:01:54','2026-10-03 09:01:54','2026-10-04 09:01:54',NULL,1),(116,9003,'9e66c97e1a5a4c528c3a96248bb8d7ed','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 09:02:33','2026-10-03 09:02:33','2026-10-04 09:02:33',NULL,1),(117,9003,'f33e9ac8735843b893699bcab35e2211','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 09:04:35','2026-10-03 09:04:35','2026-10-04 09:04:35',NULL,1),(118,9014,'a2549fe7727045c4bad4d762730072ab','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 09:05:03','2026-10-03 09:05:03','2026-10-04 09:05:03',NULL,1),(119,9007,'1190d15059ae446595b79cf83b75bfaa','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 09:05:42','2026-10-03 09:05:42','2026-10-04 09:05:42',NULL,1),(120,9017,'9ca2f531bcfc46f1b4e1b9efb6fe188e','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 09:07:11','2026-10-03 09:07:11','2026-10-04 09:07:11',NULL,1),(121,9026,'0720e9166888435ca7edbd32dca584c7','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 09:15:22','2026-10-03 09:15:22','2026-10-04 09:15:22',NULL,1),(122,9024,'862f30032eb842798d423be8cbe04984','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 09:16:24','2026-10-03 09:16:24','2026-10-04 09:16:24',NULL,1),(123,9017,'636c0d95ac354d54a3bbe39321706a14','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 09:17:05','2026-10-03 09:17:05','2026-10-04 09:17:05',NULL,1),(124,9025,'c77a99f2dbc7451da3bed8bf867ceb34','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 09:17:27','2026-10-03 09:17:27','2026-10-04 09:17:27',NULL,1),(125,9002,'faa4df3f0f6a4d0e8c5a795c2c022c84','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 09:19:31','2026-10-03 09:19:31','2026-10-04 09:19:31',NULL,1),(126,9017,'1a68a0d579fc4504a24054e14fa586c3','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 09:21:03','2026-10-03 09:21:03','2026-10-04 09:21:03',NULL,1),(127,9007,'94eaab69b1664e1b84a7dbcbb4b7a838','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 09:21:17','2026-10-03 09:21:17','2026-10-04 09:21:17',NULL,1),(128,9008,'8e0d402684354e53a5255c62caaf8f52','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 09:45:56','2026-10-03 09:45:56','2026-10-04 09:45:56',NULL,1),(129,9007,'f64d31204a124d50b879e606aa8dd586','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 09:46:25','2026-10-03 09:46:25','2026-10-04 09:46:25',NULL,1),(130,9008,'6f3896dc447248dd9875d3f06dc05497','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 09:50:38','2026-10-03 09:50:38','2026-10-04 09:50:38',NULL,1),(131,9022,'38624bdf140e4b99b9673fb4a2450c6b','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 09:54:09','2026-10-03 09:54:09','2026-10-04 09:54:09',NULL,1),(132,9023,'4fbdddbd5286490f96eb24aa1715e244','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 09:56:15','2026-10-03 09:56:15','2026-10-04 09:56:15',NULL,1),(133,9020,'5b2580e40caf46df9810d71a2c6a1ddb','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 09:58:35','2026-10-03 09:58:35','2026-10-04 09:58:35',NULL,1),(134,9009,'d52a364a8efa4facab32d3639e8e44bf','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 09:59:58','2026-10-03 09:59:58','2026-10-04 09:59:58',NULL,1),(135,9008,'fa2e7aedb345491b94133759d109d876','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 10:00:27','2026-10-03 10:00:27','2026-10-04 10:00:27',NULL,1),(136,9003,'1244043cdea14a3a9cc78cc261343eba','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 10:28:42','2026-10-03 10:28:42','2026-10-04 10:28:42',NULL,1),(137,9027,'ceb5670e94ae460385b64f512da4c3dc','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 10:30:16','2026-10-03 10:30:16','2026-10-04 10:30:16',NULL,1),(138,9003,'393ec9b4956a46f884cea2c8a953aab4','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 10:33:52','2026-10-03 10:33:52','2026-10-04 10:33:52',NULL,1),(139,9027,'50f8613266514b90ada0daf2275ffc2c','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 10:35:09','2026-10-03 10:35:09','2026-10-04 10:35:09',NULL,1),(140,9004,'04e296de642f45d6afcd7be520493092','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 10:36:46','2026-10-03 10:36:46','2026-10-04 10:36:46',NULL,1),(141,9012,'8c40266167bc489fb2977d585667a3b1','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 10:39:45','2026-10-03 10:39:45','2026-10-04 10:39:45',NULL,1),(142,9004,'867d2797415c41058ed777f0d9e910f7','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 10:42:46','2026-10-03 10:42:46','2026-10-04 10:42:46',NULL,1),(143,9027,'bfe77f5b01e745c8b38d1418414be812','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 10:43:43','2026-10-03 10:43:43','2026-10-04 10:43:43',NULL,1),(144,9012,'84e15a232669401daa39127bf53bcd9d','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 10:45:23','2026-10-03 10:45:23','2026-10-04 10:45:23',NULL,1),(145,9027,'1fa0a49f2f5940a6bebc1d52e35b2240','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 10:48:28','2026-10-03 10:48:28','2026-10-04 10:48:28',NULL,1),(146,9007,'933fa37ce5824333a69b9796bdb4c12a','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 10:49:10','2026-10-03 10:49:10','2026-10-04 10:49:10',NULL,1),(147,9017,'d202a851b625499ea594526bde7a565c','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 10:51:17','2026-10-03 10:51:17','2026-10-04 10:51:17',NULL,1),(148,9004,'a551b33d454c4faba8464762d6f064c6','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 10:54:00','2026-10-03 10:54:00','2026-10-04 10:54:00',NULL,1),(149,9027,'c60739924939431695d61141a9344514','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 10:55:28','2026-10-03 10:55:28','2026-10-04 10:55:28',NULL,1),(150,9017,'7e5daf2d626f46b199ef12c670a672ba','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 10:56:52','2026-10-03 10:56:52','2026-10-04 10:56:52',NULL,1),(151,9027,'4fb0e0d8b84a4711ab09dafdd736e0ef','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 10:59:08','2026-10-03 10:59:08','2026-10-04 10:59:08',NULL,1),(152,9017,'a3830b7e2a6a43ae9f0e2fa2fe8afb3b','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 10:59:42','2026-10-03 10:59:42','2026-10-04 10:59:42',NULL,1),(153,9027,'9118ff1e939a4cf09e895ebe1fd5d5f8','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 11:00:15','2026-10-03 11:00:15','2026-10-04 11:00:15',NULL,1),(154,9004,'3a8bbd431dbc4f089dae259e437227aa','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 11:00:54','2026-10-03 11:00:54','2026-10-04 11:00:54',NULL,1),(155,9007,'79f2b4e638304556b3883589040370ce','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 11:01:13','2026-10-03 11:01:13','2026-10-04 11:01:13',NULL,1),(156,9027,'10ddbefda9b94491aa44c99a67fdf194','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 11:02:43','2026-10-03 11:02:43','2026-10-04 11:02:43',NULL,1),(157,9017,'1f2355f7b5cd413fa00122057c721685','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 11:02:56','2026-10-03 11:02:56','2026-10-04 11:02:56',NULL,1),(158,9007,'02eb39faf1ad4ec1a05e91bdec0752a7','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 11:03:35','2026-10-03 11:03:35','2026-10-04 11:03:35',NULL,1),(159,9027,'341aca350c2a41ccb566035aaec1567d','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 11:04:12','2026-10-03 11:04:12','2026-10-04 11:04:12',NULL,1),(160,9017,'e7d37d449cec47f5ae40951277dcd329','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 11:04:26','2026-10-03 11:04:26','2026-10-04 11:04:26',NULL,1),(161,9007,'72b0486a31dc47bbbf1aadd7a64c5c6d','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 11:05:12','2026-10-03 11:05:12','2026-10-04 11:05:12',NULL,1),(162,9018,'a4954fbe79d74228bae86ed9293b7047','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 11:21:37','2026-10-03 11:21:37','2026-10-04 11:21:37',NULL,1),(163,4,'9d2df3b1df124bff907c5ec741825b7c','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 11:28:34','2026-10-03 11:28:34','2026-10-04 11:28:34',NULL,1),(164,9022,'120fea77810c44f59de52c89bcc4865f','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 11:50:50','2026-10-03 11:50:50','2026-10-04 11:50:50',NULL,1),(165,9018,'1ed3ff94c7dc428fa9a1ee49761f6d46','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 12:06:26','2026-10-03 12:06:26','2026-10-04 12:06:26',NULL,1),(166,4,'b474cc4c531f4870a8de474251e99489','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 12:07:28','2026-10-03 12:07:28','2026-10-04 12:07:28',NULL,1),(167,9010,'98d914350d114eb59c52adc61ad56996','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 12:07:58','2026-10-03 12:07:58','2026-10-04 12:07:58',NULL,1),(168,5,'e787a295494a4d23aba03f6a25442344','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36','2026-10-03 12:54:14','2026-10-03 12:54:14','2026-10-04 12:54:14',NULL,1);
/*!40000 ALTER TABLE `user_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profile_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `account_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uq_users_username` (`username`),
  UNIQUE KEY `uq_users_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=9028 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (4,'admin','admin@readingplanet.com','$2a$10$t0/SyMqr1/BGBbM9gfmALe0GNCCXmJFF6lFoVRm6YJTpiP5q7sDWi','$2a$10$t0/SyMqr1/BGBbM9gfmALe0GNCCXmJFF6lFoVRm6YJTpiP5q7sDWi','Admin Account','ADMIN','Admin','Account',NULL,NULL,'ACTIVE',NULL,'2026-09-26 05:11:34','2026-09-26 05:15:33'),(5,'finance','finance@readingplanet.com','$2a$10$YRboVUNeFZ7EgXHWfZeOq.wgbwXeB68r4XL.oP/nmuIGjXpeDeCpm','$2a$10$YRboVUNeFZ7EgXHWfZeOq.wgbwXeB68r4XL.oP/nmuIGjXpeDeCpm','Finance Account','FINANCE_STAFF','Finance','Account',NULL,NULL,'ACTIVE',NULL,'2026-09-26 05:11:34','2026-09-26 05:15:33'),(9002,'Maheesha','maheesha.ashinshani@gmail.com','$2a$10$NZlC4AegLgatDs5NfcrpK.2pKNWOKhrDMfOvGd1CxYlMBlpfIrU/.','$2a$10$NZlC4AegLgatDs5NfcrpK.2pKNWOKhrDMfOvGd1CxYlMBlpfIrU/.','Maheesha Ashinshani','AUTHOR','Maheesha','Ashinshani','0717505548',NULL,'ACTIVE',NULL,'2026-09-27 11:15:45','2026-09-27 11:27:43'),(9003,'superadmin','superadmin@readingplanet.lk','$2a$10$JdCTYLR/qEgMbTyQO1AAeO0kPSFu64lmUwLkZotvsa6OeZigXFWJy','$2a$10$JdCTYLR/qEgMbTyQO1AAeO0kPSFu64lmUwLkZotvsa6OeZigXFWJy','Super Admin','ADMIN','Super','Admin',NULL,NULL,'ACTIVE',NULL,'2026-09-27 12:04:47','2026-09-27 12:04:47'),(9004,'chiefeditor','chiefeditor@readingplanet.lk','$2a$10$SKQ1.TZO73QNSMClMxCij.famGrzSocYhN4eQEHmQYXHYk93YL8/e','$2a$10$SKQ1.TZO73QNSMClMxCij.famGrzSocYhN4eQEHmQYXHYk93YL8/e','Chief Editor','CHIEF_EDITOR','Chief','Editor',NULL,NULL,'ACTIVE',NULL,'2026-09-27 12:04:47','2026-09-27 12:04:47'),(9005,'editor','editor@readingplanet.lk','$2a$10$h99b099qZPGHkDK9pusud.W.94gi4kXCtx0CgVZFpmZqscC9j61iq','$2a$10$h99b099qZPGHkDK9pusud.W.94gi4kXCtx0CgVZFpmZqscC9j61iq','Staff Editor','EDITOR','Staff','Editor',NULL,NULL,'ACTIVE',NULL,'2026-09-27 12:04:47','2026-09-27 12:04:47'),(9006,'designer','designer@readingplanet.lk','$2a$10$d/0E7EqQYTRpMH.W6WSLieKbmTn/n/40rNvyqyTz7n07i0RB4GLhe','$2a$10$d/0E7EqQYTRpMH.W6WSLieKbmTn/n/40rNvyqyTz7n07i0RB4GLhe','Staff Designer','DESIGNER','Staff','Designer',NULL,NULL,'ACTIVE',NULL,'2026-09-27 12:04:47','2026-09-27 12:04:47'),(9007,'production','production@readingplanet.lk','$2a$10$QlYPGS.hk/9qDUt1zxEttuvfHTntei.bgEz3Jq7lBBgaVcKneTa/a','$2a$10$QlYPGS.hk/9qDUt1zxEttuvfHTntei.bgEz3Jq7lBBgaVcKneTa/a','Production Staff','PRODUCTION_MANAGER','Production','Staff',NULL,NULL,'ACTIVE',NULL,'2026-09-27 12:04:47','2026-09-27 12:04:47'),(9008,'warehouse','warehouse@readingplanet.lk','$2a$10$f0kg9/Z7YtQXvVs9nTH1R.UjSo3Oezg5y3rHbr812RLCC3/hIvAYG','$2a$10$f0kg9/Z7YtQXvVs9nTH1R.UjSo3Oezg5y3rHbr812RLCC3/hIvAYG','Warehouse Staff','INVENTORY_STAFF','Warehouse','Staff',NULL,NULL,'ACTIVE',NULL,'2026-09-27 12:04:48','2026-09-27 12:04:48'),(9009,'sales','sales@readingplanet.lk','$2a$10$QVCosnOc9kDQhFwzttnra.h/lFm.wmlb/qQNq8rq3X3DXe/HifvZi','$2a$10$QVCosnOc9kDQhFwzttnra.h/lFm.wmlb/qQNq8rq3X3DXe/HifvZi','Sales Manager','SALES_STAFF','Sales','Manager',NULL,NULL,'ACTIVE',NULL,'2026-09-27 12:04:48','2026-09-27 12:04:48'),(9010,'executive','executive@readingplanet.lk','$2a$10$eobNNilCVc7NR8SsFSzyFe3M5sVdIeDUcPS9UHHUf8SE3mG5TY73a','$2a$10$eobNNilCVc7NR8SsFSzyFe3M5sVdIeDUcPS9UHHUf8SE3mG5TY73a','Staff Executive','EXECUTIVE','Staff','Executive',NULL,NULL,'ACTIVE',NULL,'2026-09-27 12:04:48','2026-09-27 12:04:48'),(9011,'financemanager','financemanager@readingplanet.lk','$2a$10$Vds9r1FBbbmoXeiqLdflVucbEoevyksSi1KyXIlwmxwaviWdb.STm','$2a$10$Vds9r1FBbbmoXeiqLdflVucbEoevyksSi1KyXIlwmxwaviWdb.STm','Finance Manager','FINANCE_STAFF','Finance','Manager',NULL,NULL,'ACTIVE',NULL,'2026-09-27 12:05:40','2026-09-27 12:05:40'),(9012,'kamala.fernando','kamala.fernando.e@readingplanet.lk','$2a$10$1pIUeZouN4I4rLSVtAElIOSucHkc3Z72udFskPVPkD4xWPnnLK36m','$2a$10$1pIUeZouN4I4rLSVtAElIOSucHkc3Z72udFskPVPkD4xWPnnLK36m','Kamala Fernando','EDITOR','Kamala','Fernando',NULL,NULL,'ACTIVE','2026-10-02 13:46:41','2026-10-02 13:46:41','2026-10-02 13:46:41'),(9013,'anusha.jayasinghe','anusha.jayasinghe.e@readingplanet.lk','$2a$10$1pIUeZouN4I4rLSVtAElIOSucHkc3Z72udFskPVPkD4xWPnnLK36m','$2a$10$1pIUeZouN4I4rLSVtAElIOSucHkc3Z72udFskPVPkD4xWPnnLK36m','Anusha Jayasinghe','EDITOR','Anusha','Jayasinghe',NULL,NULL,'ACTIVE','2026-10-02 13:46:41','2026-10-02 13:46:41','2026-10-02 13:46:41'),(9014,'ruwan.perera','ruwan.perera.e@readingplanet.lk','$2a$10$1pIUeZouN4I4rLSVtAElIOSucHkc3Z72udFskPVPkD4xWPnnLK36m','$2a$10$1pIUeZouN4I4rLSVtAElIOSucHkc3Z72udFskPVPkD4xWPnnLK36m','Ruwan Perera','EDITOR','Ruwan','Perera',NULL,NULL,'ACTIVE','2026-10-02 13:46:41','2026-10-02 13:46:41','2026-10-02 13:46:41'),(9015,'nimal.silva','nimal.silva.d@readingplanet.lk','$2a$10$1pIUeZouN4I4rLSVtAElIOSucHkc3Z72udFskPVPkD4xWPnnLK36m','$2a$10$1pIUeZouN4I4rLSVtAElIOSucHkc3Z72udFskPVPkD4xWPnnLK36m','Nimal Silva','DESIGNER','Nimal','Silva',NULL,NULL,'ACTIVE','2026-10-02 13:46:41','2026-10-02 13:46:41','2026-10-02 13:46:41'),(9016,'saman.dias','saman.dias.d@readingplanet.lk','$2a$10$1pIUeZouN4I4rLSVtAElIOSucHkc3Z72udFskPVPkD4xWPnnLK36m','$2a$10$1pIUeZouN4I4rLSVtAElIOSucHkc3Z72udFskPVPkD4xWPnnLK36m','Saman Dias','DESIGNER','Saman','Dias',NULL,NULL,'ACTIVE','2026-10-02 13:46:41','2026-10-02 13:46:41','2026-10-02 13:46:41'),(9017,'dilani.wickramasinghe','dilani.wickramasinghe.d@readingplanet.lk','$2a$10$1pIUeZouN4I4rLSVtAElIOSucHkc3Z72udFskPVPkD4xWPnnLK36m','$2a$10$1pIUeZouN4I4rLSVtAElIOSucHkc3Z72udFskPVPkD4xWPnnLK36m','Dilani Wickramasinghe','DESIGNER','Dilani','Wickramasinghe',NULL,NULL,'ACTIVE','2026-10-02 13:46:41','2026-10-02 13:46:41','2026-10-02 13:46:41'),(9018,'Udula_11','udulathegreate@gmail.com','$2a$10$sk6VS2Grddzx9.0kqW7ATuqMARbKZMdNc03SoheCd9TD1tREtDEG2','$2a$10$sk6VS2Grddzx9.0kqW7ATuqMARbKZMdNc03SoheCd9TD1tREtDEG2','Udula Hettiarachchi','AUTHOR','Udula','Hettiarachchi','0769066322',NULL,'ACTIVE',NULL,'2026-10-02 14:43:12','2026-10-02 14:43:55'),(9019,'Production_1','productionj_@gmailcom','$2a$10$h2X9uF7LmnuwES0djx5PJ.PlErn/oQ5983rBH.3dGfQjwM1bkC4bq','$2a$10$h2X9uF7LmnuwES0djx5PJ.PlErn/oQ5983rBH.3dGfQjwM1bkC4bq','jaliya Hettiarachchi','PRODUCTION_MANAGER','jaliya','Hettiarachchi',NULL,NULL,'ACTIVE',NULL,'2026-10-02 15:18:50','2026-10-02 15:18:50'),(9020,'Jaliya_11','jaliyathegreat@gmail.com','$2a$10$Vxx75Fe3ftMeDD8ThmsJDOyRQjlh8nxlqlZrVSUpWgK1qsh.00gXe','$2a$10$Vxx75Fe3ftMeDD8ThmsJDOyRQjlh8nxlqlZrVSUpWgK1qsh.00gXe','Jaliya Hettiarachchi','CUSTOMER','Jaliya','Hettiarachchi',NULL,NULL,'ACTIVE',NULL,'2026-10-02 15:25:17','2026-10-02 15:25:17'),(9021,'Maheesha_11','maheesha@gmail.com','$2a$10$ZWZWV2hyBOxhHUOvL6G50OmrCJVUZ3KVWKBcP1b1mY45VCGYdH7vu','$2a$10$ZWZWV2hyBOxhHUOvL6G50OmrCJVUZ3KVWKBcP1b1mY45VCGYdH7vu','Maheesha Ashinshani','CUSTOMER','Maheesha','Ashinshani',NULL,NULL,'ACTIVE',NULL,'2026-10-02 17:17:33','2026-10-02 17:17:33'),(9022,'Menura_11','menura@gmail.com','$2a$10$QUnB1xVArFpSYwgQiHaqC.jZKbKrgi2W4qplIWj2ACGquVX3ihW/K','$2a$10$QUnB1xVArFpSYwgQiHaqC.jZKbKrgi2W4qplIWj2ACGquVX3ihW/K','Menura Hettiarachchi','CUSTOMER','Menura','Hettiarachchi',NULL,NULL,'ACTIVE',NULL,'2026-10-02 17:23:16','2026-10-02 17:23:16'),(9023,'Maleesha_11','maleesha@gmail.com','$2a$10$gIJcqViRLw0YhiU54wlGgeSMc28Y2DkWBF.//GJXgX279RXi84EMm','$2a$10$gIJcqViRLw0YhiU54wlGgeSMc28Y2DkWBF.//GJXgX279RXi84EMm','Maleesha Bandara','CUSTOMER','Maleesha','Bandara',NULL,NULL,'ACTIVE',NULL,'2026-10-02 17:28:36','2026-10-02 17:28:36'),(9024,'Sahas Gunasekare','nenulagunasekare@gmail.com','$2a$10$3yIH5g8aPUU77ZnrckeuU.xCYLPF/yPyVZpIY9up6Z8uT21TncfUO','$2a$10$3yIH5g8aPUU77ZnrckeuU.xCYLPF/yPyVZpIY9up6Z8uT21TncfUO','Sahas Gunasekare','AUTHOR','Sahas','Gunasekare','0772991447',NULL,'ACTIVE',NULL,'2026-10-03 05:46:15','2026-10-03 05:49:33'),(9025,'Randika Kadawathaarachchi','randika@gmail.com','$2a$10$S/Eisd3oje6sUTnXIXt04uY9At4qw8KvjCKobt37hiqQf.Xzj7mQO','$2a$10$S/Eisd3oje6sUTnXIXt04uY9At4qw8KvjCKobt37hiqQf.Xzj7mQO','Randika Kadawathaarachchi','AUTHOR','Randika','Kadawathaarachchi','0769066322',NULL,'ACTIVE',NULL,'2026-10-03 06:10:47','2026-10-03 06:13:49'),(9026,'Nisalma Werake','nisalmamandini@gmail.com','$2a$10$Q6W1503ImBibSkP22ZeCReCNigZ7puWSFcKrXxnOZEdP1M1pxPl5e','$2a$10$Q6W1503ImBibSkP22ZeCReCNigZ7puWSFcKrXxnOZEdP1M1pxPl5e','Nisalma Werake','AUTHOR','Nisalma','Werake','077 5478512',NULL,'ACTIVE',NULL,'2026-10-03 06:33:16','2026-10-03 06:39:13'),(9027,'Harshani Abeysinghe','harshani@gmail.com','$2a$10$uQTLvQ4Ql43mvYzcrIC31ODbo9ipgjVUe2NopuuyeRyE6xjieUoiS','$2a$10$uQTLvQ4Ql43mvYzcrIC31ODbo9ipgjVUe2NopuuyeRyE6xjieUoiS','Harshani Abeysinghe','AUTHOR','Harshani','Abeysinghe','077 4563160',NULL,'ACTIVE',NULL,'2026-10-03 10:30:07','2026-10-03 10:31:24');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-03 18:36:58
