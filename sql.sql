CREATE TABLE `ollinox_freecar` (
  `id` int(11) NOT NULL,
  `identifier` varchar(255) NOT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;