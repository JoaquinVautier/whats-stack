-- phpMyAdmin SQL Dump
-- version 5.2.1deb3
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost:3306
-- Tiempo de generación: 20-04-2025 a las 07:31:21
-- Versión del servidor: 8.0.41-0ubuntu0.24.04.1
-- Versión de PHP: 8.3.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `wpp_db`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `campaigns`
--

CREATE TABLE `campaigns` (
  `campaign_id` int NOT NULL,
  `campaign_name` varchar(100) NOT NULL,
  `group_id` int NOT NULL,
  `advanced_config` json DEFAULT NULL,
  `send_start_time` time DEFAULT NULL,
  `send_end_time` time DEFAULT NULL,
  `daily_limit` int DEFAULT '0',
  `status` enum('pending','running','paused','finished','error') DEFAULT 'pending',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `campaigns`
--

INSERT INTO `campaigns` (`campaign_id`, `campaign_name`, `group_id`, `advanced_config`, `send_start_time`, `send_end_time`, `daily_limit`, `status`, `created_at`) VALUES
(1, 'CampañaTest', 1, '{\"parts\": {\"body\": {\"spintax\": \"{¿Cómo estás?|¿Qué tal?}\"}, \"head\": {\"spintax\": \"Hola {amigo|colega}\"}}, \"timeConstraints\": {\"endHour\": 18, \"startHour\": 9}}', '09:00:00', '18:00:00', 50, 'paused', '2025-04-15 05:26:32');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `campaign_sends`
--

CREATE TABLE `campaign_sends` (
  `send_id` int NOT NULL,
  `campaign_id` int NOT NULL,
  `contact_id` int NOT NULL,
  `channel_id` int DEFAULT NULL,
  `message_text` text,
  `status` enum('pending','sending','sent','delivered','read','failed') DEFAULT 'pending',
  `send_attempts` int DEFAULT '0',
  `last_attempt_at` datetime DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL,
  `ack` int DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `campaign_sends`
--

INSERT INTO `campaign_sends` (`send_id`, `campaign_id`, `contact_id`, `channel_id`, `message_text`, `status`, `send_attempts`, `last_attempt_at`, `sent_at`, `ack`, `created_at`) VALUES
(1, 1, 1, NULL, NULL, 'pending', 0, NULL, NULL, 0, '2025-04-15 05:28:32');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `channels`
--

CREATE TABLE `channels` (
  `channel_id` int NOT NULL,
  `phone_number` varchar(50) DEFAULT NULL,
  `display_name` varchar(100) DEFAULT NULL,
  `session_name` varchar(100) NOT NULL,
  `session_token` varchar(255) DEFAULT NULL,
  `status` varchar(32) DEFAULT NULL,
  `status_updated_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `warmup_status` enum('none','in_progress','paused','done') DEFAULT 'none',
  `warmup_updated_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `qr_code` text,
  `qr_expires_at` datetime DEFAULT NULL,
  `last_error` text,
  `proxy_ip` varchar(50) DEFAULT NULL,
  `proxy_port` int DEFAULT NULL,
  `proxy_user` varchar(50) DEFAULT NULL,
  `proxy_pass` varchar(50) DEFAULT NULL,
  `use_proxy` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `warmup_config` text,
  `phone_code` varchar(16) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `channels`
--

INSERT INTO `channels` (`channel_id`, `phone_number`, `display_name`, `session_name`, `session_token`, `status`, `status_updated_at`, `warmup_status`, `warmup_updated_at`, `qr_code`, `qr_expires_at`, `last_error`, `proxy_ip`, `proxy_port`, `proxy_user`, `proxy_pass`, `use_proxy`, `created_at`, `updated_at`, `warmup_config`, `phone_code`) VALUES
(23, '5492646303453', '', 'TestN8N2', '$2b$10$IMFFzOZGbV6L4RpTy5NuO.l1YGxh0jgtfNatsKhXmwmS7GV3085g2', 'connected', '2025-04-20 03:37:51', 'none', '2025-04-16 13:37:18', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-16 13:37:18', '2025-04-20 03:37:51', NULL, NULL),
(30, '5492234978199', '', 'NuevoTest', '$2b$10$fz1QA3aYxYiv2mIKO357WOoBDqYeoQBK9VMNMEK399FqaiRyVQe5i', 'connected', '2025-04-20 03:37:55', 'none', '2025-04-19 22:57:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-19 22:57:00', '2025-04-20 03:37:55', NULL, NULL),
(39, NULL, '', 'dwqdqwd', '$2b$10$J99Q6X1juraKPq5smPblbuNwe6ammOn9Lq3US2PqU.UNhUvYg3hM2', 'qrreaderror', '2025-04-20 04:57:18', 'none', '2025-04-20 04:56:05', 'data:image/png;base64,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', NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-20 04:56:05', '2025-04-20 04:57:18', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `channel_logs`
--

CREATE TABLE `channel_logs` (
  `log_id` bigint NOT NULL,
  `channel_id` int NOT NULL,
  `event_type` enum('state_change','error','info','warmup_change','other') DEFAULT 'info',
  `old_value` varchar(50) DEFAULT NULL,
  `new_value` varchar(50) DEFAULT NULL,
  `description` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `contacts`
--

CREATE TABLE `contacts` (
  `contact_id` int NOT NULL,
  `phone_number` varchar(30) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `field1` varchar(100) DEFAULT NULL,
  `field2` varchar(100) DEFAULT NULL,
  `field3` varchar(100) DEFAULT NULL,
  `field4` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `contacts`
--

INSERT INTO `contacts` (`contact_id`, `phone_number`, `name`, `field1`, `field2`, `field3`, `field4`, `created_at`) VALUES
(1, '5491112345678', 'Juan Perez', 'Argentina', 'VIP', NULL, NULL, '2025-04-15 05:22:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `groups`
--

CREATE TABLE `groups` (
  `group_id` int NOT NULL,
  `group_name` varchar(100) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `groups`
--

INSERT INTO `groups` (`group_id`, `group_name`, `created_at`) VALUES
(1, 'GrupoClientes', '2025-04-15 05:24:56');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `group_contacts`
--

CREATE TABLE `group_contacts` (
  `gc_id` int NOT NULL,
  `group_id` int NOT NULL,
  `contact_id` int NOT NULL,
  `added_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `group_contacts`
--

INSERT INTO `group_contacts` (`gc_id`, `group_id`, `contact_id`, `added_at`) VALUES
(1, 1, 1, '2025-04-15 05:25:02');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `messages`
--

CREATE TABLE `messages` (
  `message_id` bigint NOT NULL,
  `channel_id` int NOT NULL,
  `wpp_message_id` varchar(255) DEFAULT NULL,
  `from_number` varchar(64) DEFAULT NULL,
  `to_number` varchar(64) DEFAULT NULL,
  `direction` enum('IN','OUT') NOT NULL,
  `message_type` enum('text','image','audio','document','other','chat') DEFAULT 'text',
  `message_content` text,
  `media_url` text,
  `status` enum('pending','sent','delivered','read','failed') DEFAULT 'pending',
  `ack` int DEFAULT '0',
  `status_reason` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `messages`
--

INSERT INTO `messages` (`message_id`, `channel_id`, `wpp_message_id`, `from_number`, `to_number`, `direction`, `message_type`, `message_content`, `media_url`, `status`, `ack`, `status_reason`, `created_at`, `updated_at`) VALUES
(78, 23, 'true_5492646303453@c.us_3EB0CC88719BD3C1D59C4D_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Hola che, ¿cómo estás? y me acordé de vos por algo gracioso, quería compartirlo.', NULL, 'read', 3, NULL, '2025-04-17 22:25:23', '2025-04-17 22:25:23'),
(79, 23, 'true_5492646303453@c.us_3EB05B796CE92BBF1277C6_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Hola che, ¿cómo va eso? y no sabés lo que fue el día de hoy, quería compartirlo.', NULL, 'read', 3, NULL, '2025-04-17 22:28:39', '2025-04-17 22:28:39'),
(80, 23, 'true_5492646303453@c.us_3EB019FB9FC2EACB33651A_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Qué tal loco, ¿cómo estás? y no sabés lo que fue el día de hoy, después contame vos.', NULL, 'read', 3, NULL, '2025-04-17 22:28:43', '2025-04-17 22:28:43'),
(81, 23, 'true_5492646303453@c.us_3EB0F65289B0E4CD4D6A61_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Hola bro, ¿cómo va eso? y me pasó algo impresionante, quería compartirlo.', NULL, 'read', 3, NULL, '2025-04-17 22:28:46', '2025-04-17 22:28:46'),
(82, 23, 'true_5492646303453@c.us_3EB00187852AD36467BE37_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Ey loco, ¿qué contás? y me acordé de vos por una historia, jajaja posta.', NULL, 'read', 3, NULL, '2025-04-17 22:28:50', '2025-04-17 22:28:50'),
(83, 23, 'true_5492646303453@c.us_3EB060FF7AB8240DBB7C22_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Ey capo, ¿qué contás? y me pasó algo impresionante, te juro que no lo vas a creer.', NULL, 'read', 3, NULL, '2025-04-17 22:28:52', '2025-04-17 22:28:52'),
(84, 23, 'true_5492646303453@c.us_3EB09961BC8DC7DF670653_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Cómo va capo, ¿todo bien? y me pasó algo impresionante, ¿tenés un minuto?.', NULL, 'read', 3, NULL, '2025-04-17 22:28:55', '2025-04-17 22:28:55'),
(85, 23, 'true_5492646303453@c.us_3EB0F5CE9E5BFEA229F73F_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Ey che, ¿todo bien? y vi algo que me shockeó, jajaja posta.', NULL, 'read', 3, NULL, '2025-04-17 22:28:59', '2025-04-17 22:28:59'),
(86, 23, 'true_5492646303453@c.us_3EB050BBEA0FB88F59773D_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Buenas loco, ¿andás bien? y me acordé de vos por un meme, jajaja posta.', NULL, 'read', 3, NULL, '2025-04-17 22:29:01', '2025-04-17 22:29:01'),
(87, 23, 'true_5492646303453@c.us_3EB0EF8E16272E3C676834_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Ey capo, ¿cómo estás? y me pasó algo raro, después contame vos.', NULL, 'read', 3, NULL, '2025-04-17 22:29:03', '2025-04-17 22:29:03'),
(88, 23, 'true_5492646303453@c.us_3EB06DEEB70287B5D4AFA3_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Buenas amigo, ¿andás bien? y vi algo que me shockeó, jajaja posta.', NULL, 'read', 3, NULL, '2025-04-17 22:29:09', '2025-04-17 22:29:09'),
(89, 23, 'true_5492646303453@c.us_3EB05F30AE160D8BF3F58D_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Cómo va loco, ¿todo bien? y no sabés lo que fue el día de hoy, después contame vos.', NULL, 'read', 3, NULL, '2025-04-17 22:29:13', '2025-04-17 22:29:13'),
(90, 23, 'true_5492646303453@c.us_3EB005D0FB6C941CB887A1_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Cómo va che, ¿todo bien? y no sabés lo que fue el día de hoy, después contame vos.', NULL, 'read', 3, NULL, '2025-04-17 22:29:16', '2025-04-17 22:29:16'),
(91, 23, 'true_5492646303453@c.us_3EB09FE30DC357EC17CB03_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Ey capo, ¿todo bien? y no sabés lo que fue el día de hoy, ¿tenés un minuto?.', NULL, 'read', 3, NULL, '2025-04-17 22:29:18', '2025-04-17 22:29:18'),
(92, 23, 'true_5492646303453@c.us_3EB0F8055EDA0478C84B30_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Hola amigo, ¿cómo estás? y me pasó algo raro, después contame vos.', NULL, 'read', 3, NULL, '2025-04-17 22:29:20', '2025-04-17 22:29:20'),
(93, 23, 'true_5492646303453@c.us_3EB0255D6BED3A6FBA02C8_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Cómo va bro, ¿todo bien? y no sabés lo que fue el día de hoy, te juro que no lo vas a creer.', NULL, 'read', 3, NULL, '2025-04-17 22:29:22', '2025-04-17 22:29:22'),
(94, 23, 'true_5492646303453@c.us_3EB090E6FC817529E91C87_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Qué tal amigo, ¿todo bien? y no sabés lo que fue el día de hoy, te juro que no lo vas a creer.', NULL, 'read', 3, NULL, '2025-04-17 22:29:24', '2025-04-17 22:29:24'),
(95, 23, 'true_5492646303453@c.us_3EB00862391D09FA1F1A11_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Qué tal capo, ¿cómo estás? y no sabés lo que fue el día de hoy, quería compartirlo.', NULL, 'read', 3, NULL, '2025-04-17 22:29:27', '2025-04-17 22:29:27'),
(96, 23, 'true_5492646303453@c.us_3EB04A7B4B058FA8FC6195_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Cómo va bro, ¿cómo va eso? y vi algo que te hubiese encantado, jajaja posta.', NULL, 'read', 3, NULL, '2025-04-17 22:29:29', '2025-04-17 22:29:29'),
(97, 23, 'true_5492646303453@c.us_3EB0075C0C56762F864B9A_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Buenas loco, ¿andás bien? y me acordé de vos por un meme, ¿tenés un minuto?.', NULL, 'read', 3, NULL, '2025-04-17 22:29:32', '2025-04-17 22:29:32'),
(98, 23, 'true_5492646303453@c.us_3EB0ACFA1C562B881B7869_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Ey capo, ¿cómo va eso? y vi algo que te hubiese encantado, ¿tenés un minuto?.', NULL, 'read', 3, NULL, '2025-04-17 22:29:34', '2025-04-17 22:29:34'),
(99, 23, 'true_5492646303453@c.us_3EB03611E030168C5D83A7_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Cómo va amigo, ¿todo bien? y me pasó algo increíble, ¿tenés un minuto?.', NULL, 'read', 3, NULL, '2025-04-17 22:29:36', '2025-04-17 22:29:36'),
(100, 23, 'true_5492646303453@c.us_3EB0B0190D2818DAA02757_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Buenas bro, ¿cómo va eso? y no sabés lo que fue el día de hoy, después contame vos.', NULL, 'read', 3, NULL, '2025-04-17 22:29:39', '2025-04-17 22:29:39'),
(101, 23, 'true_5492646303453@c.us_3EB011062040069D57E111_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Ey loco, ¿cómo va eso? y me acordé de vos por algo gracioso, después contame vos.', NULL, 'read', 3, NULL, '2025-04-17 22:29:43', '2025-04-17 22:29:43'),
(102, 23, 'true_5492646303453@c.us_3EB0B7BC89FF6C83BC36F5_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Ey amigo, ¿todo bien? y vi algo que te hubiese encantado, ¿tenés un minuto?.', NULL, 'read', 3, NULL, '2025-04-17 22:29:45', '2025-04-17 22:29:45'),
(103, 23, 'true_5492646303453@c.us_3EB003E1A90FAD84D04D38_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Hola bro, ¿cómo va eso? y me acordé de vos por un meme, después contame vos.', NULL, 'read', 3, NULL, '2025-04-17 22:29:47', '2025-04-17 22:29:47'),
(104, 23, 'true_5492646303453@c.us_3EB059593280D8B4341935_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Qué tal bro, ¿cómo va eso? y me acordé de vos por una historia, después contame vos.', NULL, 'read', 3, NULL, '2025-04-17 22:29:49', '2025-04-17 22:29:49'),
(105, 23, 'true_5492646303453@c.us_3EB0CF4ADFEC8E8FAA17D3_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Hola amigo, ¿cómo estás? y me acordé de vos por una historia, ¿tenés un minuto?.', NULL, 'read', 3, NULL, '2025-04-17 22:29:51', '2025-04-17 22:29:51'),
(106, 23, 'true_5492646303453@c.us_3EB0918465802333027018_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Qué tal che, ¿cómo estás? y me pasó algo increíble, te juro que no lo vas a creer.', NULL, 'read', 3, NULL, '2025-04-17 22:29:54', '2025-04-17 22:29:54'),
(107, 23, 'true_5492646303453@c.us_3EB04ECE65092B972C8F47_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Cómo va amigo, ¿qué contás? y me acordé de vos por un meme, jajaja posta.', NULL, 'read', 3, NULL, '2025-04-17 22:29:55', '2025-04-17 22:29:55'),
(108, 23, 'true_5492646303453@c.us_3EB0655F789CF17ABEF58E_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Ey che, ¿andás bien? y me pasó algo impresionante, ¿tenés un minuto?.', NULL, 'read', 3, NULL, '2025-04-17 22:30:00', '2025-04-17 22:30:00'),
(109, 23, 'true_5492646303453@c.us_3EB09D4D0877EC6BE23932_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Qué tal amigo, ¿cómo va eso? y me acordé de vos por un meme, te juro que no lo vas a creer.', NULL, 'read', 3, NULL, '2025-04-17 22:30:02', '2025-04-17 22:30:02'),
(110, 23, 'true_5492646303453@c.us_3EB0513F194FE67199EEB7_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Buenas amigo, ¿andás bien? y me pasó algo raro, ¿tenés un minuto?.', NULL, 'read', 3, NULL, '2025-04-17 22:30:18', '2025-04-17 22:30:18'),
(111, 23, 'true_5492646303453@c.us_3EB0863DB7FD314E8E03E0_out', '5492646303453', '5492646303453', 'OUT', 'text', 'Buenas loco, ¿cómo estás? y vi algo que me shockeó, ¿tenés un minuto?.', NULL, 'read', 3, NULL, '2025-04-17 22:30:21', '2025-04-17 22:30:21'),
(425, 23, 'false_5492233038780@c.us_3A6784FBBCA6D587E8ED', '5492233038780', '5492646303453', 'IN', 'text', 'buen dia', NULL, 'delivered', 1, NULL, '2025-04-19 14:03:12', '2025-04-19 14:03:12'),
(426, 23, 'false_5492616373034@c.us_5CB4D8309DEB891D2CED5900340A188E', '5492616373034', '5492646303453', 'IN', 'text', 'Hola', NULL, 'delivered', 1, NULL, '2025-04-19 14:10:50', '2025-04-19 14:10:50'),
(427, 23, 'false_5492616373034@c.us_3EF8EB0C5F380E28C8428BB5DC511574', '5492616373034', '5492646303453', 'IN', 'text', 'Hola que tal pascual ?', NULL, 'delivered', 1, NULL, '2025-04-19 14:13:55', '2025-04-19 14:13:55'),
(428, 23, 'false_5492616373034@c.us_489C194B9FCE398D561796D4EF0E470A', '5492616373034', '5492646303453', 'IN', 'text', 'Hola', NULL, 'delivered', 1, NULL, '2025-04-19 14:20:23', '2025-04-19 14:20:23'),
(429, 23, 'false_5492616373034@c.us_3E13CD75CFAEF725862A957F0F8EA406', '5492616373034', '5492646303453', 'IN', 'text', 'Buen día', NULL, 'delivered', 1, NULL, '2025-04-19 14:21:30', '2025-04-19 14:21:30'),
(430, 23, 'false_5492616373034@c.us_1FC72DB8F175304DAF08332F094E5704', '5492616373034', '5492646303453', 'IN', 'text', 'Que tal', NULL, 'delivered', 1, NULL, '2025-04-19 14:21:51', '2025-04-19 14:21:51'),
(431, 23, 'false_5492233038780@c.us_3ACD93A886BBEE9C0C27', '5492233038780', '5492646303453', 'IN', 'text', 'hola', NULL, 'delivered', 1, NULL, '2025-04-19 14:22:38', '2025-04-19 14:22:38'),
(432, 23, 'false_5492616373034@c.us_3AEDBF53C078753D3F86D82614DE72FA', '5492616373034', '5492646303453', 'IN', 'text', 'Soy yo', NULL, 'delivered', 1, NULL, '2025-04-19 14:22:44', '2025-04-19 14:22:44'),
(433, 30, 'false_120363182515258561@newsletter_3A9E02692A321BB249E1', '120363182515258561@newsletter', '5492234978199', 'IN', 'image', '/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDABsSFBcUERsXFhceHBsgKEIrKCUlKFE6PTBCYFVlZF9VXVtqeJmBanGQc1tdhbWGkJ6jq62rZ4C8ybqmx5moq6T/2wBDARweHigjKE4rK06kbl1upKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKT/wgARCABIAEgDASIAAhEBAxEB/8QAGQAAAwEBAQAAAAAAAAAAAAAAAAIDAQQF/8QAGQEAAwEBAQAAAAAAAAAAAAAAAAEDAgQF/9oADAMBAAIQAxAAAADx2H64bWep9M51y5p1IjmLEyD5tNbqPWZprMogFznMNHhWNSi4j0G5bw2+YyMADyhKdc8pW0dct2MbbSSVSIzz2Dql29oef0I4T1zcYdcWArn/xAAeEQEAAgICAwEAAAAAAAAAAAABAAIDERJBEDFRYf/aAAgBAgEBPwCNBjjIgdTnK30QR9eWhPUY7m07nK32alstB0scuN7gljZOPjPQ2v7DHvRMFQpNT//EABsRAAMBAQEBAQAAAAAAAAAAAAABEQIQIRIx/9oACAEDAQE/ABM+uQeaNTt7PKREXFhtCW5B1fpeY15B6Nusp//EACgQAAICAQMCBgIDAAAAAAAAAAECABESAyExBEETIlFSYYEQkSAycf/aAAgBAQABPwACARDj2sekGJNg0fmKchV7iajMuwX7mTdzUb/TMCw2gEAlSoCVNiLre4TDT1RsaMPT4/MKkTAqRsYIP4DbiLrMOd5mjjfmMX39I6WAQaI7QMw/sPuDcfij+TF1DgFaDdlB3uOCWI9DOmcAlXAo8QBeyiAL7RCiHlRPC0/aJ4On7RABe9xLyHxC3N7kxhv5d7nTu1Yt9S4Gn3CYDf6nAswE8gbQG/MNq7RNUo2YHHaaesdTcjmXUymUVgrDvGbJa7TpNJtRSysBjF6ZhRLDfbiN0xAZcx+ovTOi+VxsbqaoZEBY3czmcFXuZYNzo9Xw+nc/PEDAqpuOwyY36TNQpJIqdfqY6S0eTF1LEzn//gADAP/Z', NULL, 'delivered', 1, NULL, '2025-04-19 23:30:45', '2025-04-19 23:30:45'),
(434, 30, 'false_120363389891865625@newsletter_15F4641C9D5561BE9CBED8ABBEB97BF4', '120363389891865625@newsletter', '5492234978199', 'IN', 'text', 'no gana patronato mañana y me cagan toda la semana 🥲', NULL, 'delivered', 1, NULL, '2025-04-19 23:34:03', '2025-04-19 23:34:03'),
(435, 30, 'false_120363389891865625@newsletter_3ACA5BFCDC5DD198AE11', '120363389891865625@newsletter', '5492234978199', 'IN', 'text', 'eso es lo malo de jugar en la b', NULL, 'delivered', 1, NULL, '2025-04-19 23:41:07', '2025-04-19 23:41:07'),
(436, 30, 'false_120363389891865625@newsletter_3AEC8016890ABA5A9C24', '120363389891865625@newsletter', '5492234978199', 'IN', 'text', 'que jugas una vez por semana', NULL, 'delivered', 1, NULL, '2025-04-19 23:41:10', '2025-04-19 23:41:10'),
(437, 30, 'false_120363389891865625@newsletter_E628764169A6672EBC1096901A422FA3', '120363389891865625@newsletter', '5492234978199', 'IN', 'text', 'peor es jugar 2 veces por semana y perder las 2 veces', NULL, 'delivered', 1, NULL, '2025-04-19 23:43:00', '2025-04-19 23:43:00'),
(438, 30, 'false_120363389891865625@newsletter_3AA7E7BAC28C49DD3F93', '120363389891865625@newsletter', '5492234978199', 'IN', 'text', 'amigo cuando te bardee', NULL, 'delivered', 1, NULL, '2025-04-19 23:43:30', '2025-04-19 23:43:30'),
(439, 30, 'false_120363389891865625@newsletter_3A6A015C9347ED7DE4E2', '120363389891865625@newsletter', '5492234978199', 'IN', 'text', 'pelotudo', NULL, 'delivered', 1, NULL, '2025-04-19 23:43:32', '2025-04-19 23:43:32'),
(440, 30, 'false_120363389891865625@newsletter_150DB03E8C2A84ED69F3248525D00552', '120363389891865625@newsletter', '5492234978199', 'IN', 'text', 'JAJAJAJAJJAAJ', NULL, 'delivered', 1, NULL, '2025-04-19 23:43:52', '2025-04-19 23:43:52'),
(441, 30, 'false_120363389891865625@newsletter_BA11C35011375721FC54A63B8A56D068', '120363389891865625@newsletter', '5492234978199', 'IN', 'text', 'es joda bld', NULL, 'delivered', 1, NULL, '2025-04-19 23:43:55', '2025-04-19 23:43:55'),
(442, 30, 'false_120363389891865625@newsletter_4BCCAB244D4FF6BD2C7C4E5B8CF52385', '120363389891865625@newsletter', '5492234978199', 'IN', 'text', 'si estan re bien', NULL, 'delivered', 1, NULL, '2025-04-19 23:43:59', '2025-04-19 23:43:59'),
(443, 30, 'false_120363389891865625@newsletter_3A9A3F1AA6FACEAA7988', '120363389891865625@newsletter', '5492234978199', 'IN', 'text', 'ya te mande 2 audios puteando al priv', NULL, 'delivered', 1, NULL, '2025-04-19 23:44:05', '2025-04-19 23:44:05'),
(444, 30, 'false_120363389891865625@newsletter_CC8FF5E115885A61668A0FE7A8A77A33', '120363389891865625@newsletter', '5492234978199', 'IN', 'text', 'nooooo', NULL, 'delivered', 1, NULL, '2025-04-19 23:44:21', '2025-04-19 23:44:21'),
(445, 30, 'false_120363389891865625@newsletter_FE66608DF5FA7691A6EFD5AB503178DF', '120363389891865625@newsletter', '5492234978199', 'IN', 'text', 'se aloko mi prima', NULL, 'delivered', 1, NULL, '2025-04-19 23:49:54', '2025-04-19 23:49:54'),
(446, 30, 'false_120363389891865625@newsletter_3A4CCC9D30F315E07354', '120363389891865625@newsletter', '5492234978199', 'IN', 'text', 'me aloque', NULL, 'delivered', 1, NULL, '2025-04-19 23:50:13', '2025-04-19 23:50:13'),
(447, 30, 'false_120363182515258561@newsletter_3AEA468BA165ED5D50C9', '120363182515258561@newsletter', '5492234978199', 'IN', 'image', '/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDABsSFBcUERsXFhceHBsgKEIrKCUlKFE6PTBCYFVlZF9VXVtqeJmBanGQc1tdhbWGkJ6jq62rZ4C8ybqmx5moq6T/2wBDARweHigjKE4rK06kbl1upKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKT/wgARCABIAEgDASIAAhEBAxEB/8QAGQAAAwEBAQAAAAAAAAAAAAAAAAEDAgQF/8QAGQEAAwEBAQAAAAAAAAAAAAAAAAEDAgQF/9oADAMBAAIQAxAAAADw0NhlsFns5U8jbWDYxuwiKv2BrzevI+TNwUCxpVRrGn6Hn9+58Fo3N851ziQMFV16qc3qzLw3DG8XbytqVucsU5+lhz8QAFZhVJBFgCP/xAAcEQACAgMBAQAAAAAAAAAAAAAAAQIRAxAhMRL/2gAIAQIBAT8AWk9JXuKi26ekWQ6zJBJn2roiWiMq8JzfjZwhJIoS6ZYrj3//xAAfEQABBAICAwAAAAAAAAAAAAABAAIDERASIGEhIjH/2gAIAQMBAT8AxXEk4OHpp8YKqHpSCMk1XxQsi1srWHpStjv15f/EACQQAAICAQQCAgMBAAAAAAAAAAECABEDBBIhMRNBIlEQMnFh/9oACAEBAAE/AL+NDv3KF/cJI4E2mMvq4QYpow8i/cIoAzGwQEkWTOvUarNXAT0INFkfHvFUBc4LfyEEfyBgD+vYgALUTKM9gxvkN0BIAIH9mnzHwlT7FAzLhONzcUG6vibLJHRmyDCG4Ukzw1wTBgHRaYdMPEy7bscXMumyLjFEX65irk1CEMRuWeHn9uZ4iPcOAhbBl+MCu4zsq2w4itW1gLuYGtP9PU1ubLjyV9zQHxYmzueWHUyZQpPxomN8UUnox3Cpf3PmzjihMqsoIu5p1tlBBAm4Y8gWqrmZNubUb8htb6muJR1x41+FXx6mmRCgL49xv3Nfh8RHjFq3qMrbRY6nhG7dZuNiDezAu0cHqahWy1zR6jaZcQVV5vm5lTyGySIpKqAD1MxbL2ajptxtZueNvqeNvqJhJPy4E1YbHiZgOpo2yZse5jddTxt9Txt9Q42vqPiZkIrv8C5RnjGUbH/U9zT6HFixFcbH/Lh4NS/z//4AAwD/2Q==', NULL, 'delivered', 1, NULL, '2025-04-20 00:17:38', '2025-04-20 00:17:38'),
(448, 30, 'false_120363182515258561@newsletter_3AE68F625225531ECA02', '120363182515258561@newsletter', '5492234978199', 'IN', 'image', '/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDABsSFBcUERsXFhceHBsgKEIrKCUlKFE6PTBCYFVlZF9VXVtqeJmBanGQc1tdhbWGkJ6jq62rZ4C8ybqmx5moq6T/2wBDARweHigjKE4rK06kbl1upKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKT/wgARCABIAEgDASIAAhEBAxEB/8QAGgAAAgMBAQAAAAAAAAAAAAAAAAECBAUDBv/EABcBAAMBAAAAAAAAAAAAAAAAAAABAgP/2gAMAwEAAhADEAAAAMeUGA4zAhoVU+DmOYjGMYm10YRagMVmuJkgR23Xnv597ufSwbpz2zuU9XIwu4cyctd13jfeuoWWK1gh86qv3NQsilAQdJBYkGZFhSiAn//EAB4RAQACAgMAAwAAAAAAAAAAAAEAAhESECExIDJB/9oACAECAQE/AMTEq5+G2PJW1n7E9YxGUMvcyKgyr6Sxl9mzKiiwsjFa9n7N3gu1MHG3WOP/xAAgEQEAAgAGAwEAAAAAAAAAAAABAAIDEBESEyAhMUFR/9oACAEDAQE/AMk06aRD5ntrLBU8RqgLMSu0H9y5LTktHFsmjLXbe+//xAApEAACAgEDAgYBBQAAAAAAAAABAgARAwQSITFBEyIyUWFxIwUQFVKB/9oACAEBAAE/AEUWbMJI8o6TYDZuLjs8nmDHkW/LCNw+YBz8Q1djrLIHS5zUvjmWb4iqbDdB8zB+RSp4B7zLibC3Ise83L7Tgc0ZRI46QElaqdTKAgXdmCG6rtPyLatYWYNUDjbDkF36TAvP1HbcOeJjFrApr2MogXMe12FkCP5Mu4RtWjDm/qYzvzb17dLmdNmRWI9QuZgLJExGk4gXMuS9hIiqz5uUISo+EpkGxSRczIRflJ+o3WaFN6mqsdprw4ZSF4AmPzK+6YMK7VYH/I2JCCAonhIVoKOk8NdwTwwVI6zWI24piWlA6zDojmVmuvaIzafOFIogzK/iacsfaY+A0x4nOLejkfE8WwBZni8VZqHMAtWQJjy48uQjdY9pSj0ihNXplyDeo8w5i7MmmCqaJFVP49v7CLpMiClyfvlJGNqHafp+hygNlZaJ7SiODKio2DXACyrdIWl3OZzMYU3umPUujVtNRmLMTXWEmXTBgBYjcmx3h+p///4AAwD/2Q==', NULL, 'delivered', 1, NULL, '2025-04-20 00:37:44', '2025-04-20 00:37:44'),
(449, 30, 'false_5492235779695-1597974062@g.us_82D3E8F5FAD73888A695E6880E883FF0_5492235807170@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'Boke boke', NULL, 'delivered', 1, NULL, '2025-04-20 00:41:26', '2025-04-20 00:41:26'),
(450, 30, 'false_120363181354467218@newsletter_3EB05C877CC2A6B9F0808F', '120363181354467218@newsletter', '5492234978199', 'IN', 'image', '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', NULL, 'delivered', 1, NULL, '2025-04-20 00:50:35', '2025-04-20 00:50:35'),
(451, 30, 'false_120363181354467218@newsletter_3EB0836B6A18832A14EC0B', '120363181354467218@newsletter', '5492234978199', 'IN', 'image', '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', NULL, 'delivered', 1, NULL, '2025-04-20 00:52:37', '2025-04-20 00:52:37'),
(452, 30, 'false_5492236015184@c.us_6C69F0537EF40B9996DF830E08503904', '5492236015184', '5492234978199', 'IN', 'text', 'Q onda? Parejo? Fueron todos?', NULL, 'delivered', 1, NULL, '2025-04-20 00:53:17', '2025-04-20 00:53:17'),
(453, 30, 'false_5492236015184@c.us_7948289166501A085F943178D29CA380', '5492236015184', '5492234978199', 'IN', 'text', 'Tranquiloooo jajajajaa', NULL, 'delivered', 1, NULL, '2025-04-20 00:54:18', '2025-04-20 00:54:18'),
(454, 30, 'false_5492235931101@c.us_3AA9F4340B41EC7C5986', '5492235931101', '5492234978199', 'IN', 'text', 'Joaco', NULL, 'delivered', 1, NULL, '2025-04-20 01:03:16', '2025-04-20 01:03:16'),
(455, 30, 'false_120363181354467218@newsletter_3EB03F7513F33AEE031087', '120363181354467218@newsletter', '5492234978199', 'IN', 'image', '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', NULL, 'delivered', 1, NULL, '2025-04-20 01:05:04', '2025-04-20 01:05:04'),
(456, 30, 'false_5492235779695-1597974062@g.us_3AA6731FFC88A00D9828_5492236697890@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'Jajajaja', NULL, 'delivered', 1, NULL, '2025-04-20 01:15:13', '2025-04-20 01:15:13'),
(457, 30, 'false_5492235779695-1597974062@g.us_3A547D107E33D6745173_5492236697890@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'Como vaaaaa', NULL, 'delivered', 1, NULL, '2025-04-20 01:15:18', '2025-04-20 01:15:18'),
(458, 30, 'false_5492235779695-1597974062@g.us_3ADAB8DA84C4AD596C28_5492236697890@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'No tengo como verlo acá', NULL, 'delivered', 1, NULL, '2025-04-20 01:15:22', '2025-04-20 01:15:22'),
(459, 30, 'false_5492235779695-1597974062@g.us_3AD7B047398A0A5BF732_5492236697890@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'Me muerooo', NULL, 'delivered', 1, NULL, '2025-04-20 01:15:25', '2025-04-20 01:15:25'),
(460, 30, 'false_120363182515258561@newsletter_3AF81B4FC44FA396ACA0', '120363182515258561@newsletter', '5492234978199', 'IN', 'image', '/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDABsSFBcUERsXFhceHBsgKEIrKCUlKFE6PTBCYFVlZF9VXVtqeJmBanGQc1tdhbWGkJ6jq62rZ4C8ybqmx5moq6T/2wBDARweHigjKE4rK06kbl1upKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKT/wgARCABIAEgDASIAAhEBAxEB/8QAGgAAAgMBAQAAAAAAAAAAAAAAAAMBAgQFBv/EABgBAAMBAQAAAAAAAAAAAAAAAAECAwAE/9oADAMBAAIQAxAAAADMu9CKU3ydimxOmMeqk6Eg2uUPxhNoBRe1VL75ui2SUALtjNVcyfQc6bY+hk9aNyldHlk4C5lc9FKpr5t4m+qapsOhXNrgyzOLs8hRcrgbPqFNscHK+IB0/8QAIREAAgIBBAIDAAAAAAAAAAAAAQIAETEDEBIhE0EiMlH/2gAIAQIBAT8AmZfco7GBiMQMPyHoXVQA1Aqn7TyJdLHbgL9wapI+cuLxdCJ4VQWDcQezNVQWgoZmEJi9io7FVJEJ5Czt/8QAHhEAAwACAwADAAAAAAAAAAAAAAERAiEQEjETQVH/2gAIAQMBAT8AIanKIQSrhl7or+jq5sSp1nnD7Y5U+R5ag/xGLcMnWesYlRaZD//EACcQAAICAQMDBQEAAwAAAAAAAAECAAMRBBIhBTFBEyIyUWEUI3Gh/9oACAEBAAE/AG5jDJjDA5gHfiUUhlL3ZwDxNZXWgUoMTGYRzDgcTOeI35NMlSpvs55wJqP53Q+n7TFssrHpjB8y4XXUBmHAMbTuEDYMK7e4hEZ8nMUF+BxLFNQBDnP1CWZsjsY9zq5z3EGpsI5PH1E6iVABAYSmxLWy6+1jwJrdKlRUp2PgzMrDFd5+IhdbXJbOPER1VcZGI/psfcB/sRVp7HMupDlRWhCjufuaDRjK2HlROoXmzUEDgLxNJpfVBdviJbcprNYUbBLQyE7R7YPawMuQjDDsROn9MtsrFrLkHsDG0DlyGYKAJvbT1ud/xONsd97MxHJmjcmooOOJXu9cKy55h0a3HL4rX6E1tWnpfbXyR3mkq9bUIuCQT2jGvS1KuQoA4EZhYgYHOeZqKGfNznAY4xHrKNtIxNM21SMcxDlhnA/RLL61GGtmosFj4QEA+Z0zNB9Zl3Y4AmrvtvvPqZH5On3g/wCI+O06hqAuqrrb4Dk/s1ttVlQdANwi1lGLA8Yn9SqcGNqUPZBBqlB9yRbya+AVBjMc98k+ZSChFv7gD7nX61amm5FwQOZoKxehTnJ7ExN28e44l9Pv3Y4Hmcg58GIucZjPgdpRvutCqpJlxbT21rgHaMkSvWV6io1ORjyDDeK7Aal2hf8As//+AAMA/9k=', NULL, 'delivered', 1, NULL, '2025-04-20 01:25:36', '2025-04-20 01:25:36'),
(461, 30, 'false_120363181354467218@newsletter_3EB01E1AEF2872DB64B4BD', '120363181354467218@newsletter', '5492234978199', 'IN', 'image', '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', NULL, 'delivered', 1, NULL, '2025-04-20 01:29:48', '2025-04-20 01:29:48'),
(462, 30, 'false_5492235779695-1597974062@g.us_164F45045D9295E172C4D7B9BC756255_5492235807170@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'Jajajaja', NULL, 'delivered', 1, NULL, '2025-04-20 01:52:09', '2025-04-20 01:52:09'),
(463, 30, 'false_5492235779695-1597974062@g.us_51760489F7A3CF06632822BCEB40A878_5492235807170@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'Se va a hacer fanático de otro equipo para tener la escusa', NULL, 'delivered', 1, NULL, '2025-04-20 01:52:27', '2025-04-20 01:52:27');
INSERT INTO `messages` (`message_id`, `channel_id`, `wpp_message_id`, `from_number`, `to_number`, `direction`, `message_type`, `message_content`, `media_url`, `status`, `ack`, `status_reason`, `created_at`, `updated_at`) VALUES
(464, 30, 'false_5492235779695-1597974062@g.us_3A062AF7AAB15B4B5415_5492235293655@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'Le llegamos a ganar el domingo a river y salgo un mes entero jajajaja', NULL, 'delivered', 1, NULL, '2025-04-20 01:52:58', '2025-04-20 01:52:58'),
(465, 30, 'false_5491151801300-1561404994@g.us_3A8B09360200025CF43B_5492235376030@c.us', '5491151801300-1561404994@g.us', '5492234978199', 'IN', 'text', 'Jajajaja', NULL, 'delivered', 1, NULL, '2025-04-20 02:05:12', '2025-04-20 02:05:12'),
(466, 30, 'false_5492235779695-1597974062@g.us_E74319BBCAA77CCD712F7AF7C798C2ED_5492235161596@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'estas viendo el gol de leo messi?', NULL, 'delivered', 1, NULL, '2025-04-20 02:44:27', '2025-04-20 02:44:27'),
(467, 30, 'false_5492235779695-1597974062@g.us_5ACAC40591E7673A730125220B32992B_5492235161596@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'digo mastantuono?', NULL, 'delivered', 1, NULL, '2025-04-20 02:44:32', '2025-04-20 02:44:32'),
(468, 30, 'false_5492235779695-1597974062@g.us_EEC33F60D963CB61D7684AB1CB51541E_5492235161596@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', '🥵🥵🥵', NULL, 'delivered', 1, NULL, '2025-04-20 02:44:36', '2025-04-20 02:44:36'),
(469, 30, 'false_120363181354467218@newsletter_3EB0B23776398F1CFB78A8', '120363181354467218@newsletter', '5492234978199', 'IN', 'image', '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', NULL, 'delivered', 1, NULL, '2025-04-20 02:45:59', '2025-04-20 02:45:59'),
(470, 30, 'false_5492235779695-1597974062@g.us_90ADB63BBA5DEF6C772476E3F61B2844_5492235161596@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'que meada le pegó seba', NULL, 'delivered', 1, NULL, '2025-04-20 02:49:15', '2025-04-20 02:49:15'),
(471, 30, 'false_5492236824550@c.us_3A063CC2A2D021FCA8CF', '5492236824550', '5492234978199', 'IN', 'text', 'Jajaja', NULL, 'delivered', 1, NULL, '2025-04-20 02:49:19', '2025-04-20 02:49:19'),
(472, 30, 'false_5492236824550@c.us_3ACC047B1F8765D3013D', '5492236824550', '5492234978199', 'IN', 'text', 'Sii puede ser q se sella', NULL, 'delivered', 1, NULL, '2025-04-20 02:49:22', '2025-04-20 02:49:22'),
(473, 30, 'false_5492236824550@c.us_3AEBA2A2546D765A0CB8', '5492236824550', '5492234978199', 'IN', 'text', 'Un frío hace', NULL, 'delivered', 1, NULL, '2025-04-20 02:49:31', '2025-04-20 02:49:31'),
(474, 30, 'false_5492236824550@c.us_3A68C7B6BC9D5C2255E2', '5492236824550', '5492234978199', 'IN', 'text', 'Fuiste caminando ??', NULL, 'delivered', 1, NULL, '2025-04-20 02:49:35', '2025-04-20 02:49:35'),
(475, 30, 'false_5492235779695-1597974062@g.us_3A4B6F67B473A21C85C6_5492233543626@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'Hermoso', NULL, 'delivered', 1, NULL, '2025-04-20 02:49:39', '2025-04-20 02:49:39'),
(476, 30, 'false_5492236824550@c.us_3ACBC50EE14CC0E98901', '5492236824550', '5492234978199', 'IN', 'text', 'Raroo', NULL, 'delivered', 1, NULL, '2025-04-20 02:49:40', '2025-04-20 02:49:40'),
(477, 30, 'false_5492235779695-1597974062@g.us_3AE8678B1BC11D03BA0F_5492233543626@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'Se murió ya ?', NULL, 'delivered', 1, NULL, '2025-04-20 02:49:53', '2025-04-20 02:49:53'),
(478, 30, 'false_5491151801300-1561404994@g.us_3A0C4C56B364EC5DE32F_5492235376030@c.us', '5491151801300-1561404994@g.us', '5492234978199', 'IN', 'text', 'La mica se metió al poco', NULL, 'delivered', 1, NULL, '2025-04-20 02:53:19', '2025-04-20 02:53:19'),
(479, 30, 'false_5491151801300-1561404994@g.us_3A08AF75D673B7134758_5492235376030@c.us', '5491151801300-1561404994@g.us', '5492234978199', 'IN', 'text', 'Pogo', NULL, 'delivered', 1, NULL, '2025-04-20 02:53:23', '2025-04-20 02:53:23'),
(480, 30, 'false_5491151801300-1561404994@g.us_3A864E54EF8A7FA7CA56_5492235376030@c.us', '5491151801300-1561404994@g.us', '5492234978199', 'IN', 'text', 'La tuve que acompañar', NULL, 'delivered', 1, NULL, '2025-04-20 02:53:52', '2025-04-20 02:53:52'),
(481, 30, 'false_5491151801300-1561404994@g.us_B6F6FCB0E2E958ECA46498EC2947CA6D_5492235626236@c.us', '5491151801300-1561404994@g.us', '5492234978199', 'IN', 'text', 'JAJAJAJAJAJA', NULL, 'delivered', 1, NULL, '2025-04-20 02:54:15', '2025-04-20 02:54:15'),
(482, 30, 'false_5491151801300-1561404994@g.us_3A9DDCA96398ABB2E734_5492235376030@c.us', '5491151801300-1561404994@g.us', '5492234978199', 'IN', 'text', 'Felices pascuas 🐰', NULL, 'delivered', 1, NULL, '2025-04-20 03:00:25', '2025-04-20 03:00:25'),
(483, 30, 'false_5492235626236@c.us_FE9CB61C4DD49F586C2CAB8012B54B9E', '5492235626236', '5492234978199', 'IN', 'text', 'Gracias Joaco 🫶🏻', NULL, 'delivered', 1, NULL, '2025-04-20 03:08:37', '2025-04-20 03:08:37'),
(484, 30, 'false_5492235626236@c.us_95120A854702A1A31EE3B4897C059A7A', '5492235626236', '5492234978199', 'IN', 'text', 'Acabamos de volver', NULL, 'delivered', 1, NULL, '2025-04-20 03:08:41', '2025-04-20 03:08:41'),
(485, 30, 'false_5491151801300-1561404994@g.us_6D9BF20B78A76EF9C83947AAE6C855C7_5492235626236@c.us', '5491151801300-1561404994@g.us', '5492234978199', 'IN', 'text', 'Felices Pascuas!!', NULL, 'delivered', 1, NULL, '2025-04-20 03:11:57', '2025-04-20 03:11:57'),
(486, 30, 'false_5491151801300-1561404994@g.us_4A88235A9F4DA31F11353C089E054564_5492235626236@c.us', '5491151801300-1561404994@g.us', '5492234978199', 'IN', 'text', 'Jajaja plata y vergüenza nunca tuvo', NULL, 'delivered', 1, NULL, '2025-04-20 03:12:14', '2025-04-20 03:12:14'),
(487, 30, 'false_5491151801300-1561404994@g.us_9C342BC6B78A9DE4A5D17D352C23BFCD_5492235626236@c.us', '5491151801300-1561404994@g.us', '5492234978199', 'IN', 'text', '🤣🤣🤣', NULL, 'delivered', 1, NULL, '2025-04-20 03:12:16', '2025-04-20 03:12:16'),
(488, 30, 'false_5491151801300-1561404994@g.us_3AE6C83A4703128D5EC3_5492235376030@c.us', '5491151801300-1561404994@g.us', '5492234978199', 'IN', 'text', 'Terrible', NULL, 'delivered', 1, NULL, '2025-04-20 03:12:26', '2025-04-20 03:12:26'),
(489, 30, 'false_5491151801300-1561404994@g.us_3A048FBEB8C8584D576E_5492235376030@c.us', '5491151801300-1561404994@g.us', '5492234978199', 'IN', 'text', 'Nacho Hacete famoso', NULL, 'delivered', 1, NULL, '2025-04-20 03:12:32', '2025-04-20 03:12:32'),
(490, 30, 'false_5492235779695-1597974062@g.us_3DF162CDB7A37B94B960BD8ED7C79BEA_5492235807170@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'JAJAJAJJAJA', NULL, 'delivered', 1, NULL, '2025-04-20 03:33:40', '2025-04-20 03:33:40'),
(491, 30, 'false_120363182515258561@newsletter_3A0071CBB65D97F1A96C', '120363182515258561@newsletter', '5492234978199', 'IN', 'image', '/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDABsSFBcUERsXFhceHBsgKEIrKCUlKFE6PTBCYFVlZF9VXVtqeJmBanGQc1tdhbWGkJ6jq62rZ4C8ybqmx5moq6T/2wBDARweHigjKE4rK06kbl1upKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKT/wgARCABIAEcDASIAAhEBAxEB/8QAGgAAAgMBAQAAAAAAAAAAAAAAAAQCAwUBBv/EABcBAQEBAQAAAAAAAAAAAAAAAAEAAgP/2gAMAwEAAhADEAAAAM3tEBbivCG69XKzVTYc3Zh0ayvapzZnHOKLODnsLGDWYehAzlEGtzVdUdnoEFlMtu7gMIyYhzb7KpbLWKjLBd2NcONTjlhm0FgmyoLN1YbuzCkQM6//xAAgEQACAgEEAwEAAAAAAAAAAAAAAQIRIRASMkEDEyIx/9oACAECAQE/AK7GrIycno0WJ2KDX4h3FXRGTkrSIrBGFKxeKuTscLVJiwLGTdLieyXaFNr6LIzclkcmsl4s3Pdp/8QAHhEAAwABBAMAAAAAAAAAAAAAAAEREAISITEgQVH/2gAIAQMBAT8ApfDsmJTrDZu+FzF2bSeiD0pMlJyTgTP/xAAnEAACAgEEAQQCAwEAAAAAAAABAgADEQQSIUExEyJRYQUUMkJxUv/aAAgBAQABPwCpEWxBaMriNXVbdtTC5M1VKpYFJyAJp662rs3HGORE0ttqhkTg9yzT7RjOG+ItZLFe/iKpUbHUjPzAgwApxmWnD454hYgjoyx2Z/c2fuZMqJXRq5OPb4j2KwJGdxPM0dRv1FRA57n5dV9NWwMqcSu0Vj+IJli7rN4U5lle98tkEw0qAODHqUKAQR9wahv1xVtyMYzEoDNgnAmnuGn4UD4zL3fUDZ/LnPEGlb/gwgb9qquOziWmse7g9cCNSbGBLECHT7n9zEnoRdOanFpOQOpWtfqlwSc/1hZFtBavH1NKKv2hYpAB4xNU61oNoGTBqqG9pfOYzjY27wDmLf7K8kBYlnq63buwp7jJp66DkjBErbTFeUOejmXsTqeCcfEop09mkXGM48/BlurQttNgO3iaYZsz8TUqVRQeCeY7gooHjErXBJHmC/Fe0jP3K2JY8mFCWDSq8ohXqWDNjH7n45Qbst4E129Xw5znxLNO36yuvJA5E0VamsFuC/HMvpsrt9NhibWRsY5zGq9NULnsZE1FTV2FVHnkRs7iO5pnerI28GWn1G32HxKbg1YrOf8AfqXXqFVEU7l8GavUNZRWHHuH9o759NtoJHkzUeozhmPBjEtowX4I4B+o9YJLKeMz9UgkZ74i6VrrgOgeZqan067l/wAlC2XHcRyDzNS9jIayBgcjiUqWqbnwMylDcxUnwuZcj1BeSQRN2CQejP/+AAMA/9k=', NULL, 'delivered', 1, NULL, '2025-04-20 03:34:26', '2025-04-20 03:34:26'),
(492, 30, 'false_5492235779695-1597974062@g.us_3AD23D6ADEA440FE2AFC_5492235293655@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'No puedo creer que tengo que salir', NULL, 'delivered', 1, NULL, '2025-04-20 03:34:39', '2025-04-20 03:34:39'),
(493, 30, 'false_5492235779695-1597974062@g.us_3AC9B71E99119FF2048C_5492235293655@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'LAS COSAS QUE HAGO POR VOS BOCA JUNIORS QUERIDO', NULL, 'delivered', 1, NULL, '2025-04-20 03:34:48', '2025-04-20 03:34:48'),
(494, 30, 'false_5492235779695-1597974062@g.us_ADF473AE0DA77B0D5C76EBF38CCF6F60_5492235807170@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'Q onda', NULL, 'delivered', 1, NULL, '2025-04-20 04:01:43', '2025-04-20 04:01:43'),
(495, 30, 'false_5492235779695-1597974062@g.us_3A552CBA3C2D8E2BF5B8_5492235293655@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'Todo bruto con el Mendo', NULL, 'delivered', 1, NULL, '2025-04-20 04:02:51', '2025-04-20 04:02:51'),
(496, 30, 'false_5492235779695-1597974062@g.us_3A02658D1737DF36E4DE_5492235293655@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'No se yo estoy yendo para normandina tengo que hacer pasar unas pibitas y de ahí quedo libre', NULL, 'delivered', 1, NULL, '2025-04-20 04:03:33', '2025-04-20 04:03:33'),
(497, 30, 'false_5492235779695-1597974062@g.us_52EF3EB0AC2B9F1EB82157CEA8F9BEF7_5492235807170@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'Mira vo', NULL, 'delivered', 1, NULL, '2025-04-20 04:05:45', '2025-04-20 04:05:45'),
(498, 30, 'false_5492235779695-1597974062@g.us_3A1518EAB24B5DA3AF4E_5492235293655@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'Vos amigo ??', NULL, 'delivered', 1, NULL, '2025-04-20 04:05:54', '2025-04-20 04:05:54'),
(499, 30, 'false_5492235779695-1597974062@g.us_3AB8582A8643A5D7FA68_5492235293655@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'Salís ?', NULL, 'delivered', 1, NULL, '2025-04-20 04:05:56', '2025-04-20 04:05:56'),
(500, 30, 'false_5492235779695-1597974062@g.us_3ADD204A383791FD2020_5492235293655@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'Los reyes de la noche no dijeron nada todavía', NULL, 'delivered', 1, NULL, '2025-04-20 04:06:18', '2025-04-20 04:06:18'),
(501, 30, 'false_5492235779695-1597974062@g.us_3A7417934B9C28B6EA96_5492235293655@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'Qué raro', NULL, 'delivered', 1, NULL, '2025-04-20 04:06:20', '2025-04-20 04:06:20'),
(502, 30, 'false_5492235779695-1597974062@g.us_13591BE0D101017F534D92F8882FB04A_5492235807170@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'Capa', NULL, 'delivered', 1, NULL, '2025-04-20 04:08:54', '2025-04-20 04:08:54'),
(503, 30, 'false_120363360808094299@g.us_B1664228E7F0768AE28AD0BC5B029BBD_5492291449720@c.us', '120363360808094299@g.us', '5492234978199', 'IN', 'text', 'hola! Perdón la hora pero así están al tanto: entramos con la camioneta y otra vez el portón no se cerró y quedó el puente abajo. Ya dejé WhatsApp al número de Sotelo', NULL, 'delivered', 1, NULL, '2025-04-20 04:25:10', '2025-04-20 04:25:10'),
(504, 30, 'false_5492235779695-1597974062@g.us_3AB07A7F67FA805FA849_5492235800395@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'Está lucho caparroz ahí?', NULL, 'delivered', 1, NULL, '2025-04-20 04:27:20', '2025-04-20 04:27:20'),
(505, 30, 'false_5492235779695-1597974062@g.us_C8815DC9A5715122E56BE4CABBE116D9_5492235807170@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'Laburando', NULL, 'delivered', 1, NULL, '2025-04-20 04:29:54', '2025-04-20 04:29:54'),
(506, 30, 'false_5492235779695-1597974062@g.us_0F3D3AF5E7E152BAF496CAEFB9DD99DA_5492235161596@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'JAJAJAJAJA muy bien borra controlando a sus empleados', NULL, 'delivered', 1, NULL, '2025-04-20 04:29:58', '2025-04-20 04:29:58'),
(507, 30, 'false_5492235779695-1597974062@g.us_3AD19E3472DCB8923759_5492235293655@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'Borra de joda y lucho acá laburando', NULL, 'delivered', 1, NULL, '2025-04-20 04:32:25', '2025-04-20 04:32:25'),
(508, 30, 'false_5492235779695-1597974062@g.us_FF3C9EED271238BDAB5020D07AEA5A8C_5492235161596@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'cómo debe seeer', NULL, 'delivered', 1, NULL, '2025-04-20 04:32:56', '2025-04-20 04:32:56'),
(509, 30, 'false_5492235779695-1597974062@g.us_41B77DD6485CF69531F8496094927C32_5492235807170@c.us', '5492235779695-1597974062@g.us', '5492234978199', 'IN', 'text', 'Para q el chino esté contento', NULL, 'delivered', 1, NULL, '2025-04-20 05:05:25', '2025-04-20 05:05:25'),
(510, 30, 'false_5491151801300-1561404994@g.us_3AA1076332A6627D3490_5492235376030@c.us', '5491151801300-1561404994@g.us', '5492234978199', 'IN', 'text', 'Tremendo', NULL, 'delivered', 1, NULL, '2025-04-20 05:06:47', '2025-04-20 05:06:47'),
(511, 30, 'false_5491151801300-1561404994@g.us_3A3418F9BE81826A7FE5_5492235376030@c.us', '5491151801300-1561404994@g.us', '5492234978199', 'IN', 'text', 'La mica se cantó todo', NULL, 'delivered', 1, NULL, '2025-04-20 05:06:57', '2025-04-20 05:06:57'),
(512, 30, 'false_5492235293655@c.us_3A034A61E688B1437318', '5492235293655', '5492234978199', 'IN', 'text', 'Borra bajando col Ornella', NULL, 'delivered', 1, NULL, '2025-04-20 05:09:02', '2025-04-20 05:09:02'),
(513, 30, 'false_5492235293655@c.us_3A6D76788C9843D36DBD', '5492235293655', '5492234978199', 'IN', 'text', '🤨', NULL, 'delivered', 1, NULL, '2025-04-20 05:09:10', '2025-04-20 05:09:10');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `campaigns`
--
ALTER TABLE `campaigns`
  ADD PRIMARY KEY (`campaign_id`),
  ADD KEY `group_id` (`group_id`);

--
-- Indices de la tabla `campaign_sends`
--
ALTER TABLE `campaign_sends`
  ADD PRIMARY KEY (`send_id`),
  ADD KEY `campaign_id` (`campaign_id`),
  ADD KEY `contact_id` (`contact_id`),
  ADD KEY `channel_id` (`channel_id`);

--
-- Indices de la tabla `channels`
--
ALTER TABLE `channels`
  ADD PRIMARY KEY (`channel_id`),
  ADD KEY `idx_session_name` (`session_name`),
  ADD KEY `idx_phone_number` (`phone_number`);

--
-- Indices de la tabla `channel_logs`
--
ALTER TABLE `channel_logs`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `idx_channel_logs_channel_id` (`channel_id`);

--
-- Indices de la tabla `contacts`
--
ALTER TABLE `contacts`
  ADD PRIMARY KEY (`contact_id`),
  ADD UNIQUE KEY `idx_contacts_phone` (`phone_number`);

--
-- Indices de la tabla `groups`
--
ALTER TABLE `groups`
  ADD PRIMARY KEY (`group_id`);

--
-- Indices de la tabla `group_contacts`
--
ALTER TABLE `group_contacts`
  ADD PRIMARY KEY (`gc_id`),
  ADD KEY `group_id` (`group_id`),
  ADD KEY `contact_id` (`contact_id`);

--
-- Indices de la tabla `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `idx_channel_id` (`channel_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `campaigns`
--
ALTER TABLE `campaigns`
  MODIFY `campaign_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `campaign_sends`
--
ALTER TABLE `campaign_sends`
  MODIFY `send_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `channels`
--
ALTER TABLE `channels`
  MODIFY `channel_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT de la tabla `channel_logs`
--
ALTER TABLE `channel_logs`
  MODIFY `log_id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `contacts`
--
ALTER TABLE `contacts`
  MODIFY `contact_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `groups`
--
ALTER TABLE `groups`
  MODIFY `group_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `group_contacts`
--
ALTER TABLE `group_contacts`
  MODIFY `gc_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `messages`
--
ALTER TABLE `messages`
  MODIFY `message_id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=514;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `campaigns`
--
ALTER TABLE `campaigns`
  ADD CONSTRAINT `campaigns_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `groups` (`group_id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `campaign_sends`
--
ALTER TABLE `campaign_sends`
  ADD CONSTRAINT `campaign_sends_ibfk_1` FOREIGN KEY (`campaign_id`) REFERENCES `campaigns` (`campaign_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `campaign_sends_ibfk_2` FOREIGN KEY (`contact_id`) REFERENCES `contacts` (`contact_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `campaign_sends_ibfk_3` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`channel_id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `channel_logs`
--
ALTER TABLE `channel_logs`
  ADD CONSTRAINT `channel_logs_ibfk_1` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`channel_id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `group_contacts`
--
ALTER TABLE `group_contacts`
  ADD CONSTRAINT `group_contacts_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `groups` (`group_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `group_contacts_ibfk_2` FOREIGN KEY (`contact_id`) REFERENCES `contacts` (`contact_id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`channel_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

