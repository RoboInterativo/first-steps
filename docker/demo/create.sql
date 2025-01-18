CREATE DATABASE [rgr_2]
	CONTAINMENT = NONE
 ON  PRIMARY
( NAME = N'rgr_2', FILENAME = N'7data\rgr_2.mdf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
 LOG ON
( NAME = N'rgr_2_log', FILENAME = N'\\data\\rgr_\\_log.ldf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
 COLLATE Cyrillic_General_CS_AS/data
 GO

 -- use [rgr_1]
 -- go
