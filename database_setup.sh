#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=postgres -tc"

$PSQL "create database number_guess;"


PSQL="psql --username=freecodecamp --dbname=number_guess -tc"
$PSQL "create table if not exists users (
    userid serial primary key,
    username varchar (22) unique not null,
    games_played int default 0,
    best_game int);"


pg_dump -cC --inserts -U freecodecamp number_guess > number_guess.sql
