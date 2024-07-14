-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 14 Jul 2024 pada 17.19
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `trovetrips`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `p_CompanyRating` ()   BEGIN
    DECLARE average FLOAT;
    SELECT AVG(rating) INTO average
    FROM ratingcomments;
    CASE
        WHEN average > 4 THEN
            SELECT 'Very Good' AS company_rating;
        WHEN average > 3 THEN
            SELECT 'Good' AS company_rating;
        WHEN average > 2 THEN
            SELECT 'Average' AS company_rating;
        WHEN average > 1 THEN
            SELECT 'Bad' AS company_rating;
        WHEN average >= 0 THEN
            SELECT 'Very Bad' AS company_rating;
        ELSE
            SELECT 'No Rating' AS company_rating;
    END CASE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_SetTripQuality` (IN `p_trip_id` INT, IN `p_region_id` INT)   BEGIN
    DECLARE avg_rating FLOAT;
    DECLARE quality VARCHAR(10);
    DECLARE existing_entry INT;

    SELECT AVG(rating) INTO avg_rating
    FROM ratingcomments
    WHERE trip_id = p_trip_id AND region_id = p_region_id;

    IF avg_rating > 4 THEN
        SET quality = 'Very Good';
    ELSEIF avg_rating > 3 THEN
        SET quality = 'Good';
    ELSEIF avg_rating > 2 THEN
        SET quality = 'Average';
    ELSEIF avg_rating > 1 THEN
        SET quality = 'Bad';
    ELSEIF avg_rating > 0 THEN
        SET quality = 'Very Bad';
    ELSE
        SET quality = 'No rating yet';
    END IF;
    
    SELECT COUNT(*) INTO existing_entry
    FROM tripqualities
    WHERE trip_id = p_trip_id AND region_id = p_region_id;

    IF existing_entry > 0 THEN
        UPDATE tripqualities
        SET quality = quality
        WHERE trip_id = p_trip_id AND region_id = p_region_id;
    ELSE
        INSERT INTO tripqualities (trip_id, region_id, quality)
        VALUES (p_trip_id, p_region_id, quality);
    END IF;
END$$

--
-- Fungsi
--
CREATE DEFINER=`root`@`localhost` FUNCTION `f_TotalConfirmedBookings` () RETURNS INT(11)  BEGIN
DECLARE total_confirmed INT;
SELECT COUNT(booking_id) INTO total_confirmed
FROM bookings
WHERE status = 'Confirmed';
RETURN total_confirmed;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `f_TotalPaymentByStatusAndMethod` (`payment_status` VARCHAR(20), `payment_method_name` VARCHAR(50)) RETURNS INT(11)  BEGIN
    DECLARE total INT;
    SELECT COUNT(p.payment_id) INTO total
    FROM payments p
    JOIN paymentmethods pm ON p.payment_method_id = pm.payment_method_id
    WHERE p.status = payment_status AND pm.payment_method_name = payment_method_name;
    RETURN total;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `activity_log`
--

CREATE TABLE `activity_log` (
  `log_id` int(11) NOT NULL,
  `table_name` varchar(50) NOT NULL,
  `action_type` varchar(20) NOT NULL,
  `record_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `old_value` varchar(255) DEFAULT NULL,
  `new_value` varchar(255) DEFAULT NULL,
  `log_timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `activity_log`
--

INSERT INTO `activity_log` (`log_id`, `table_name`, `action_type`, `record_id`, `user_id`, `description`, `old_value`, `new_value`, `log_timestamp`) VALUES
(1, 'bookings', 'INSERT', 0, 1, 'Booking baru telah di buat untuk trip ID:1', NULL, NULL, '2024-07-14 15:02:10'),
(2, 'payments', 'UPDATE', 1, NULL, 'Payment status berubah', 'Paid', 'Unpaid', '2024-07-14 15:02:20'),
(5, 'users', 'DELETE', 6, NULL, 'User terhapus: Kukuh', NULL, NULL, '2024-07-14 15:07:42'),
(6, 'ratingcomments', 'INSERT', 8, 1, 'Rating baru (5) ditambahkan ke trip ID: 1', NULL, NULL, '2024-07-14 15:08:34'),
(7, 'trips', 'UPDATE', 1, NULL, 'Trip price berubah', '309', '350', '2024-07-14 15:09:11'),
(8, 'bookings', 'DELETE', 12, 1, 'Booking dihapus untuk trip ID: 1', NULL, NULL, '2024-07-14 15:10:12'),
(9, 'bookings', 'INSERT', 0, 1, 'Booking baru telah di buat untuk trip ID:1', NULL, NULL, '2024-07-14 15:17:48');

-- --------------------------------------------------------

--
-- Struktur dari tabel `bookings`
--

CREATE TABLE `bookings` (
  `booking_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `driver_id` int(11) DEFAULT NULL,
  `tour_guide_id` int(11) DEFAULT NULL,
  `car_id` int(11) NOT NULL,
  `trip_id` int(11) DEFAULT NULL,
  `booking_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `status` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `bookings`
--

INSERT INTO `bookings` (`booking_id`, `user_id`, `driver_id`, `tour_guide_id`, `car_id`, `trip_id`, `booking_date`, `status`) VALUES
(1, 1, 1, 2, 5, 1, '2024-07-11 07:52:17', 'Confirmed'),
(2, 2, 3, 1, 1, 2, '2024-07-11 15:55:26', 'Confirmed'),
(3, 3, 4, 4, 2, 3, '2024-07-11 07:52:17', 'Confirmed'),
(4, 1, 5, 5, 7, 4, '2024-07-11 15:55:58', 'Confirmed'),
(5, 4, 2, 2, 6, 5, '2024-07-11 15:55:58', 'Confirmed'),
(6, 5, 4, 3, 3, 4, '2024-07-11 15:55:58', 'Confirmed'),
(7, 2, 1, 1, 4, 3, '2024-07-11 15:55:58', 'Confirmed'),
(8, 1, 2, 3, 4, 3, '2024-07-11 15:57:31', 'Canceled'),
(9, 4, 2, 4, 6, 5, '2024-07-11 15:57:31', 'Pending'),
(10, 1, 1, 3, 4, 5, '2024-07-11 15:57:31', 'Confirmed'),
(11, 4, 5, 5, 8, 1, '2024-07-11 15:57:31', 'Confirmed'),
(13, 1, 1, NULL, 1, 1, '2024-07-14 15:17:48', 'Pending');

--
-- Trigger `bookings`
--
DELIMITER $$
CREATE TRIGGER `after_booking_delete_log` AFTER DELETE ON `bookings` FOR EACH ROW BEGIN
    INSERT INTO activity_log (table_name, action_type, record_id, user_id, description)
    VALUES ('bookings', 'DELETE', OLD.booking_id, OLD.user_id,
            CONCAT('Booking dihapus untuk trip ID: ', OLD.trip_id));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_booking_insert_log` BEFORE INSERT ON `bookings` FOR EACH ROW BEGIN
    INSERT INTO activity_log (table_name, action_type, record_id, user_id, description)
    VALUES ('bookings', 'INSERT', NEW.booking_id, NEW.user_id, 
            CONCAT('Booking baru telah di buat untuk trip ID:', NEW.trip_id));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `cars`
--

CREATE TABLE `cars` (
  `car_id` int(11) NOT NULL,
  `car_name` varchar(40) NOT NULL,
  `car_type_id` int(11) NOT NULL,
  `car_color` varchar(20) NOT NULL,
  `license_plate` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `cars`
--

INSERT INTO `cars` (`car_id`, `car_name`, `car_type_id`, `car_color`, `license_plate`) VALUES
(1, 'Toyota Avanza Veloz', 3, 'Black', 'AB 3343 AB'),
(2, 'Daihatsu Xenia', 3, 'Grey', 'AB 1234 AA'),
(3, 'Toyota Innova Reborn', 4, 'Black', 'AB 7654 BB'),
(4, 'Honda HR-V', 1, 'Dark Blue', 'AB 4387 CC'),
(5, 'Mitsubishi Pajero Sport', 2, 'Silver', 'AB 8536 DD'),
(6, 'Toyota Vios', 5, 'Black', 'AB 8865 EE'),
(7, 'Toyota Fortuner', 2, 'White', 'AB 5846 FF'),
(8, 'Toyota Rush', 1, 'Black', 'AB 7722 GG'),
(9, 'Toyota Avanza', 3, 'Grey', 'AB 7856 VV');

-- --------------------------------------------------------

--
-- Struktur dari tabel `cartypes`
--

CREATE TABLE `cartypes` (
  `car_type_id` int(11) NOT NULL,
  `type_code` varchar(15) NOT NULL,
  `type_name` varchar(50) NOT NULL,
  `charge` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `cartypes`
--

INSERT INTO `cartypes` (`car_type_id`, `type_code`, `type_name`, `charge`) VALUES
(1, 'SUV', 'Sport Utility Vehicle', 0),
(2, 'SUV-VIP', 'Sport Utility Vehicle-VIP', 50),
(3, 'MVP', 'Multi Purpose Vehicle', 5),
(4, 'MVP-VIP', 'Multi Purpose Vehicle-VIP', 30),
(5, 'SEDAN', 'Sedan', 50);

-- --------------------------------------------------------

--
-- Struktur dari tabel `drivers`
--

CREATE TABLE `drivers` (
  `driver_id` int(11) NOT NULL,
  `driver_name` varchar(50) NOT NULL,
  `driver_address` varchar(200) NOT NULL,
  `driver_no_telp` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `drivers`
--

INSERT INTO `drivers` (`driver_id`, `driver_name`, `driver_address`, `driver_no_telp`) VALUES
(1, 'Bambang', 'Jl. Magelang, D.I.Yogyakarta', '081234564865'),
(2, 'Samuel', 'Condongcatur, D.I.Yogyakarta', '098767656456'),
(3, 'Isam', 'Sleman, D.I.Yogyakarta', '089775665687'),
(4, 'mamang', 'Magelang, Jawa Tengah', '089765544556'),
(5, 'Udin', 'Bantul, D.I.Yogyakarta', '087689877659');

-- --------------------------------------------------------

--
-- Struktur dari tabel `message`
--

CREATE TABLE `message` (
  `message_id` int(11) NOT NULL,
  `first_name` varchar(20) NOT NULL,
  `last_name` varchar(20) DEFAULT NULL,
  `message` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `message`
--

INSERT INTO `message` (`message_id`, `first_name`, `last_name`, `message`) VALUES
(1, 'Fisan', 'Syafa', 'Why i can\'t login?'),
(2, 'Ahmad', 'Haitsam', 'How can i use this trips?'),
(3, 'Fauzan', 'Yahya', 'Please help me, i forgot the password'),
(4, 'Nizar', 'Mohammad', 'Can i bring my car and you just use your driver?'),
(5, 'Jenderal', 'Nicolas', 'Please help me, i can\'t login to my account');

-- --------------------------------------------------------

--
-- Struktur dari tabel `paymentmethods`
--

CREATE TABLE `paymentmethods` (
  `payment_method_id` int(11) NOT NULL,
  `payment_method_name` varchar(50) DEFAULT NULL,
  `payment_method_code` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `paymentmethods`
--

INSERT INTO `paymentmethods` (`payment_method_id`, `payment_method_name`, `payment_method_code`) VALUES
(1, 'BRI', '345353442'),
(2, 'PayPal', 'trovetrips@gmail.com'),
(3, 'BCA', '865435'),
(4, 'Dana', '081245675435'),
(5, 'BNI', '5778854');

-- --------------------------------------------------------

--
-- Struktur dari tabel `payments`
--

CREATE TABLE `payments` (
  `payment_id` int(11) NOT NULL,
  `booking_id` int(11) DEFAULT NULL,
  `payment_method_id` int(11) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `payment_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `status` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `payments`
--

INSERT INTO `payments` (`payment_id`, `booking_id`, `payment_method_id`, `amount`, `payment_date`, `status`) VALUES
(1, 1, 1, 309, '2024-07-14 15:02:20', 'Unpaid'),
(2, 2, 2, 87, '2024-07-01 17:00:00', 'Unpaid'),
(3, 3, 3, 378, '2024-08-01 17:00:00', 'Paid'),
(4, 4, 3, 335, '2024-09-01 17:00:00', 'Unpaid'),
(5, 5, 1, 310, '2024-10-01 17:00:00', 'Unpaid'),
(6, 6, 4, 335, '2024-10-01 17:00:00', 'Paid'),
(7, 7, 5, 378, '2024-10-01 17:00:00', 'Unpaid'),
(8, 10, 1, 310, '2024-07-11 16:00:09', 'Paid'),
(9, 11, 1, 309, '2024-07-11 16:00:09', 'Paid');

--
-- Trigger `payments`
--
DELIMITER $$
CREATE TRIGGER `before_payment_update_log` BEFORE UPDATE ON `payments` FOR EACH ROW BEGIN
    IF NEW.status != OLD.status THEN
        INSERT INTO activity_log (table_name, action_type, record_id, description, old_value, new_value)
        VALUES ('payments', 'UPDATE', NEW.payment_id, 'Payment status berubah', 
                OLD.status, NEW.status);
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `ratingcomments`
--

CREATE TABLE `ratingcomments` (
  `rating_comment_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `trip_id` int(11) DEFAULT NULL,
  `region_id` int(11) DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `rating` int(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `ratingcomments`
--

INSERT INTO `ratingcomments` (`rating_comment_id`, `user_id`, `trip_id`, `region_id`, `comment`, `rating`) VALUES
(1, 1, 1, 2, 'Amazing trip in Borobudur temple with trovetrips', 5),
(2, 2, 2, 1, 'Very enjoy trip in Prambanan temple', 4),
(3, 3, 3, 1, 'Bromo, great mount!!', 4),
(4, 1, 4, 2, 'Beautiful view in ijen crater', 5),
(5, 4, 5, 5, 'very happy trip in dieng platue', 5),
(6, 5, 4, 3, 'Not bad, cool trip', 3),
(7, 2, 3, 1, 'best trip i ever try! btw Bromo Mount is amazing', 5),
(8, 1, 1, 1, 'Mantapppppp jiwaaa!', 5);

--
-- Trigger `ratingcomments`
--
DELIMITER $$
CREATE TRIGGER `after_rating_insert_log` AFTER INSERT ON `ratingcomments` FOR EACH ROW BEGIN
    INSERT INTO activity_log (table_name, action_type, record_id, user_id, description)
    VALUES ('ratingcomments', 'INSERT', NEW.rating_comment_id, NEW.user_id,
            CONCAT('Rating baru (', NEW.rating, ') ditambahkan ke trip ID: ', NEW.trip_id));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `regions`
--

CREATE TABLE `regions` (
  `region_id` int(11) NOT NULL,
  `region_name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `regions`
--

INSERT INTO `regions` (`region_id`, `region_name`) VALUES
(1, 'Indonesia'),
(2, 'Malaysia'),
(3, 'Thailand'),
(4, 'Vietnam'),
(5, 'Singapore'),
(6, 'United State'),
(7, 'Filipina');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tourguides`
--

CREATE TABLE `tourguides` (
  `tour_guide_id` int(11) NOT NULL,
  `tour_guide_name` varchar(30) NOT NULL,
  `tour_guide_address` text NOT NULL,
  `tour_guide_no_telp` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tourguides`
--

INSERT INTO `tourguides` (`tour_guide_id`, `tour_guide_name`, `tour_guide_address`, `tour_guide_no_telp`) VALUES
(1, 'Ahmad Hasyim', 'Jl. Kaliurang, D.I.Yogyakarta', '088875565987'),
(2, 'Budi Budidi', 'Seturan, D.I. Yogyakarta', '087576543454'),
(3, 'Samsudin Sudin', 'Purwokerto', '08764786446'),
(4, 'Heru Maheru', 'Magelang, Jawa Tengah', '086655467784'),
(5, 'Adi Paradi', 'Bantul, D.I.Yogyakarta', '089876453689');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tripqualities`
--

CREATE TABLE `tripqualities` (
  `trip_quality_id` int(11) NOT NULL,
  `trip_id` int(11) DEFAULT NULL,
  `region_id` int(11) DEFAULT NULL,
  `quality` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tripqualities`
--

INSERT INTO `tripqualities` (`trip_quality_id`, `trip_id`, `region_id`, `quality`) VALUES
(1, 3, 1, 'Very Good'),
(2, 1, 1, 'No rating '),
(3, 2, 1, 'Good'),
(4, 4, 1, 'No rating '),
(5, 1, 2, 'Very Good'),
(6, 4, 2, 'Very Good'),
(7, 4, 5, NULL),
(8, 5, 1, NULL),
(9, 5, 4, NULL);

-- --------------------------------------------------------

--
-- Struktur dari tabel `trips`
--

CREATE TABLE `trips` (
  `trip_id` int(11) NOT NULL,
  `trip_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `price` int(5) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `trips`
--

INSERT INTO `trips` (`trip_id`, `trip_name`, `description`, `price`, `start_date`, `end_date`) VALUES
(1, 'Borobudur Temple', 'The huge temple in Magelang, Central Java', 350, '2024-07-01', '2024-07-07'),
(2, 'Prambanan Temple', 'The iconic temple in Yogyakarta', 87, '2024-08-01', '2024-08-10'),
(3, 'Bromo Mount', 'The Beautiful mount in East Java', 378, '2024-09-01', '2024-09-05'),
(4, 'Ijen Cater', 'The amazing cater near Bromo Mount', 335, '2024-10-01', '2024-10-10'),
(5, 'Dieng Plateu', 'The beautiful village and mountains', 310, '2024-11-01', '2024-11-07');

--
-- Trigger `trips`
--
DELIMITER $$
CREATE TRIGGER `after_trip_update_log` AFTER UPDATE ON `trips` FOR EACH ROW BEGIN
    IF NEW.price != OLD.price THEN
        INSERT INTO activity_log (table_name, action_type, record_id, description, old_value, new_value)
        VALUES ('trips', 'UPDATE', NEW.trip_id, 'Trip price berubah', 
                OLD.price, NEW.price);
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(50) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`user_id`, `username`, `password`, `email`, `phone_number`) VALUES
(1, 'Fisan', 'db11fcba527f9ec9350a21713c060db3', 'fisan@gmail.com', '081223455678'),
(2, 'Haitsam', '57f14b1b87522cd36aafc4f4db9481e5', 'haitsam@gmail.com', '0812345653578'),
(3, 'Nizar', '0b552ef8b10dc2ff5db2f296e24996eb', 'nizar@gmail.com', '081264579875'),
(4, 'Fauzan', 'bac55c49e078b34c165bd50a50a8349c', 'fauzan@gmail.com', '089754465453'),
(5, 'Jenderal', '5e30839f26eee42de14405f3511e8539', 'jenderal@gmail.com', '088765676475');

--
-- Trigger `users`
--
DELIMITER $$
CREATE TRIGGER `before_user_delete_log` BEFORE DELETE ON `users` FOR EACH ROW BEGIN
    INSERT INTO activity_log (table_name, action_type, record_id, description)
    VALUES ('users', 'DELETE', OLD.user_id, 
            CONCAT('User terhapus: ', OLD.username));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `v_horizontal_tripqualities`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `v_horizontal_tripqualities` (
`trip_quality_id` int(11)
,`trip_id` int(11)
,`region_id` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `v_inside_tripqualities`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `v_inside_tripqualities` (
`trip_quality_id` int(11)
,`trip_id` int(11)
,`region_id` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `v_vertical_cars`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `v_vertical_cars` (
`car_id` int(11)
,`car_name` varchar(40)
,`car_type_id` int(11)
,`car_color` varchar(20)
,`license_plate` varchar(15)
);

-- --------------------------------------------------------

--
-- Struktur untuk view `v_horizontal_tripqualities`
--
DROP TABLE IF EXISTS `v_horizontal_tripqualities`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_horizontal_tripqualities`  AS SELECT `tripqualities`.`trip_quality_id` AS `trip_quality_id`, `tripqualities`.`trip_id` AS `trip_id`, `tripqualities`.`region_id` AS `region_id` FROM `tripqualities` ;

-- --------------------------------------------------------

--
-- Struktur untuk view `v_inside_tripqualities`
--
DROP TABLE IF EXISTS `v_inside_tripqualities`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_inside_tripqualities`  AS SELECT `v_horizontal_tripqualities`.`trip_quality_id` AS `trip_quality_id`, `v_horizontal_tripqualities`.`trip_id` AS `trip_id`, `v_horizontal_tripqualities`.`region_id` AS `region_id` FROM `v_horizontal_tripqualities` WHERE `v_horizontal_tripqualities`.`trip_id` = 5WITH CASCADEDCHECK OPTION  ;

-- --------------------------------------------------------

--
-- Struktur untuk view `v_vertical_cars`
--
DROP TABLE IF EXISTS `v_vertical_cars`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_vertical_cars`  AS SELECT `cars`.`car_id` AS `car_id`, `cars`.`car_name` AS `car_name`, `cars`.`car_type_id` AS `car_type_id`, `cars`.`car_color` AS `car_color`, `cars`.`license_plate` AS `license_plate` FROM `cars` WHERE `cars`.`car_type_id` = 3 ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `activity_log`
--
ALTER TABLE `activity_log`
  ADD PRIMARY KEY (`log_id`);

--
-- Indeks untuk tabel `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`booking_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `trip_id` (`trip_id`),
  ADD KEY `driver_id` (`driver_id`),
  ADD KEY `tour_guide_id` (`tour_guide_id`),
  ADD KEY `car_id` (`car_id`);

--
-- Indeks untuk tabel `cars`
--
ALTER TABLE `cars`
  ADD PRIMARY KEY (`car_id`),
  ADD KEY `car_type_id` (`car_type_id`);

--
-- Indeks untuk tabel `cartypes`
--
ALTER TABLE `cartypes`
  ADD PRIMARY KEY (`car_type_id`);

--
-- Indeks untuk tabel `drivers`
--
ALTER TABLE `drivers`
  ADD PRIMARY KEY (`driver_id`);

--
-- Indeks untuk tabel `message`
--
ALTER TABLE `message`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `idx_FirstLastName` (`first_name`,`last_name`);

--
-- Indeks untuk tabel `paymentmethods`
--
ALTER TABLE `paymentmethods`
  ADD PRIMARY KEY (`payment_method_id`);

--
-- Indeks untuk tabel `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`payment_id`),
  ADD KEY `booking_id` (`booking_id`),
  ADD KEY `payment_method_id` (`payment_method_id`);

--
-- Indeks untuk tabel `ratingcomments`
--
ALTER TABLE `ratingcomments`
  ADD PRIMARY KEY (`rating_comment_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `trip_id` (`trip_id`),
  ADD KEY `idx_rating_By_RegionId_TripId` (`region_id`,`trip_id`);

--
-- Indeks untuk tabel `regions`
--
ALTER TABLE `regions`
  ADD PRIMARY KEY (`region_id`);

--
-- Indeks untuk tabel `tourguides`
--
ALTER TABLE `tourguides`
  ADD PRIMARY KEY (`tour_guide_id`);

--
-- Indeks untuk tabel `tripqualities`
--
ALTER TABLE `tripqualities`
  ADD PRIMARY KEY (`trip_quality_id`),
  ADD KEY `region_id` (`region_id`),
  ADD KEY `idx_Quality_By_TripId_RegionId` (`trip_id`,`region_id`);

--
-- Indeks untuk tabel `trips`
--
ALTER TABLE `trips`
  ADD PRIMARY KEY (`trip_id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `activity_log`
--
ALTER TABLE `activity_log`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT untuk tabel `bookings`
--
ALTER TABLE `bookings`
  MODIFY `booking_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT untuk tabel `cars`
--
ALTER TABLE `cars`
  MODIFY `car_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT untuk tabel `cartypes`
--
ALTER TABLE `cartypes`
  MODIFY `car_type_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `drivers`
--
ALTER TABLE `drivers`
  MODIFY `driver_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `message`
--
ALTER TABLE `message`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `paymentmethods`
--
ALTER TABLE `paymentmethods`
  MODIFY `payment_method_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `payments`
--
ALTER TABLE `payments`
  MODIFY `payment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT untuk tabel `ratingcomments`
--
ALTER TABLE `ratingcomments`
  MODIFY `rating_comment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT untuk tabel `regions`
--
ALTER TABLE `regions`
  MODIFY `region_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT untuk tabel `tourguides`
--
ALTER TABLE `tourguides`
  MODIFY `tour_guide_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `tripqualities`
--
ALTER TABLE `tripqualities`
  MODIFY `trip_quality_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT untuk tabel `trips`
--
ALTER TABLE `trips`
  MODIFY `trip_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`trip_id`) REFERENCES `trips` (`trip_id`),
  ADD CONSTRAINT `bookings_ibfk_3` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`driver_id`),
  ADD CONSTRAINT `bookings_ibfk_4` FOREIGN KEY (`tour_guide_id`) REFERENCES `tourguides` (`tour_guide_id`),
  ADD CONSTRAINT `bookings_ibfk_5` FOREIGN KEY (`car_id`) REFERENCES `cars` (`car_id`);

--
-- Ketidakleluasaan untuk tabel `cars`
--
ALTER TABLE `cars`
  ADD CONSTRAINT `cars_ibfk_1` FOREIGN KEY (`car_type_id`) REFERENCES `cartypes` (`car_type_id`);

--
-- Ketidakleluasaan untuk tabel `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`),
  ADD CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`payment_method_id`) REFERENCES `paymentmethods` (`payment_method_id`);

--
-- Ketidakleluasaan untuk tabel `ratingcomments`
--
ALTER TABLE `ratingcomments`
  ADD CONSTRAINT `ratingcomments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `ratingcomments_ibfk_2` FOREIGN KEY (`trip_id`) REFERENCES `trips` (`trip_id`),
  ADD CONSTRAINT `ratingcomments_ibfk_3` FOREIGN KEY (`region_id`) REFERENCES `regions` (`region_id`);

--
-- Ketidakleluasaan untuk tabel `tripqualities`
--
ALTER TABLE `tripqualities`
  ADD CONSTRAINT `tripqualities_ibfk_1` FOREIGN KEY (`trip_id`) REFERENCES `trips` (`trip_id`),
  ADD CONSTRAINT `tripqualities_ibfk_2` FOREIGN KEY (`region_id`) REFERENCES `regions` (`region_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
