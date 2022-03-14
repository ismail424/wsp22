CREATE TABLE `Users`(
    `id` integer primary key autoincrement,
    `profile_pic` TEXT NOT NULL,
    `username` TEXT NOT NULL UNIQUE,
    `password_hash` BINARY(16) NOT NULL,
    `email` TEXT NOT NULL UNIQUE,
    `admin` TINYINT(1) NOT NULL
    
);

CREATE TABLE `Comments`(
    `id` integer primary key autoincrement,
    `titel` TEXT NOT NULL,
    `body` TEXT NOT NULL,
    `user_id` INT NOT NULL,
    `game_id` INT NOT NULL,
    FOREIGN KEY (`user_id`) REFERENCES `Users`(`id`),
    FOREIGN KEY (`game_id`) REFERENCES `VideoGames`(`id`)
);

CREATE TABLE `Rating`(
    `id` integer primary key autoincrement ,
    `rating` INT NOT NULL,
    `user_id` INT NOT NULL,
    `game_id` INT NOT NULL,
    FOREIGN KEY (`user_id`) REFERENCES `Users`(`id`) ,
    FOREIGN KEY (`game_id`) REFERENCES `VideoGames`(`id`) 

);


CREATE TABLE `Streamers`(
    `id` integer primary key autoincrement,
    `img_src` TEXT NOT NULL,
    `streamer_name` TEXT NOT NULL,
    `full_name` TEXT NULL,
    `age` INT NULL,
    `height` INT NULL,
    `description` TEXT NOT NULL,
    `platform` TEXT NOT NULL,
    `favorite_game` TEXT NOT NULL
    );

CREATE TABLE `VideoGames`(
    `id` integer primary key autoincrement,
    `name` TEXT NOT NULL,
    `price` DOUBLE(8, 2) NOT NULL,
    `description` TEXT NOT NULL,
    `realse_date` DATE NULL
);

CREATE TABLE `Genres`(
    `id` integer primary key autoincrement,
    `name` TEXT NOT NULL
);

CREATE TABLE `Platforms`(
    `id` integer primary key autoincrement,
    `name` TEXT NOT NULL
);

CREATE TABLE `Images`(
    `id` integer primary key autoincrement,
    `src` TEXT NOT NULL,
    `game_id` INT NOT NULL,
    FOREIGN KEY (`game_id`) REFERENCES `VideoGames`(`id`)
);

CREATE TABLE `GenreToGame`(
    `genre_id` INT NOT NULL,
    `game_id` INT NOT NULL,
    FOREIGN KEY(`game_id`) REFERENCES `VideoGames`(`id`),
    FOREIGN KEY(`genre_id`) REFERENCES `Genres`(`id`)
);

CREATE TABLE `PlatformToGame`(
    `platform_id` INT NOT NULL,
    `game_id` INT NOT NULL,
    FOREIGN KEY(`game_id`) REFERENCES `VideoGames`(`id`),
    FOREIGN KEY(`platform_id`) REFERENCES `Platforms`(`id`)
);


