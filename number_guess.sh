#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -tc"

DELETE_SUCCESS=$PSQL "delete from users;"

echo "Enter your username:"
read USER_NAME

SECRET_NUMBER=$(($RANDOM % 1000 + 1))

# get user name
USER_RECORD=$($PSQL "select * from users where username='$USER_NAME';")

# if user name recognized, print phrase
if [[ -z $USER_RECORD ]]
then
  # if user name not recognized, give welcome message and store user into table
  echo "Welcome, $USER_NAME! It looks like this is your first time here."
  NEW_USER=$($PSQL "insert into users (username, games_played) values ('$USER_NAME',1);")
else
  IFS="|" read -r -a USER_RECORD_SPLIT <<< "$USER_RECORD"
  username=$(echo ${USER_RECORD_SPLIT[1]} | sed -e 's/[[:space:]]/''/g')
  games_played=$(echo ${USER_RECORD_SPLIT[2]} | sed -e 's/[[:space:]]/''/g')
  best_game=$(echo ${USER_RECORD_SPLIT[3]} | sed -e 's/[[:space:]]/''/g')
  echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."

  # increase number of games played by 1
  UPDATE_GAMES_PLAYED=$($PSQL "update users set games_played=games_played+1 where username='$USER_NAME';")
fi

echo "Guess the secret number between 1 and 1000:"

read USERGUESS

i=1
while [ $USERGUESS != $SECRET_NUMBER ]
do
  if ! [[ $USERGUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read USERGUESS
  elif [ $USERGUESS -lt $SECRET_NUMBER ]
  then
    echo "It's higher than that, guess again:"
    ((i+=1))
    read USERGUESS
  else
    echo "It's lower than that, guess again:"
    ((i+=1))
    read USERGUESS
  fi
done

echo "You guessed it in $i tries. The secret number was $SECRET_NUMBER. Nice job!"

# if this is best game, write it to database
# get user name
USER_RECORD=$($PSQL "select * from users where username='$USER_NAME';")
IFS="|" read -r -a USER_RECORD_SPLIT <<< "$USER_RECORD"
best_game=$(echo ${USER_RECORD_SPLIT[3]} | sed -e 's/[[:space:]]/''/g')

if [ -z $best_game ]
then
  UPDATE_BEST=$($PSQL "update users set best_game=$i where username='$USER_NAME';")
elif [ $i -lt $best_game ]
then
  UPDATE_BEST=$($PSQL "update users set best_game=$i where username='$USER_NAME';")
fi
