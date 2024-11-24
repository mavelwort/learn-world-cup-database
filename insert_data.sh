#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WIN_GOALS OPP_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # insert winner team
    INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER') ON CONFLICT(name) DO NOTHING")
    if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" || $INSERT_WINNER_RESULT == "INSERT 0 0" ]]
    then
      echo "Inserted into teams: $WINNER"
    fi
    
    # insert opponent team
    INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT') ON CONFLICT(name) DO NOTHING")      
    if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" || $INSERT_OPPONENT_RESULT == "INSERT 0 0" ]]
    then
      echo "Inserted into teams: $OPPONENT"
    fi

    # get team_id for winner and opponent
    WIN_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPP_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # insert the game
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
                                 VALUES($YEAR, '$ROUND', $WIN_TEAM_ID, $OPP_TEAM_ID, $WIN_GOALS, $OPP_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted game: $YEAR - $ROUND - $WINNER vs $OPPONENT"
    fi
  fi
done