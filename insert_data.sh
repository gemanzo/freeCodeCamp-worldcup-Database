#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#svuota le tabelle
echo $($PSQL "TRUNCATE teams, games")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Salta l'intestazione del file CSV
  if [[ $YEAR != "year" ]]
  then
    # Controlla l'esistenza del team vincente
    WINNER_EXISTS=$($PSQL "SELECT count(*) FROM teams WHERE name='$WINNER'")
    if [[ $WINNER_EXISTS -eq 0 ]]
    then
      # Inserisce il team vincente se non esiste
      INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      echo "Inserted winner: $WINNER"
    fi

    # Controlla l'esistenza del team avversario
    OPPONENT_EXISTS=$($PSQL "SELECT count(*) FROM teams WHERE name='$OPPONENT'")
    if [[ $OPPONENT_EXISTS -eq 0 ]]
    then
      # Inserisce il team avversario se non esiste
      INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      echo "Inserted opponent: $OPPONENT"
    fi
    #prendo gli id dei teams
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    #inserisco il record nella tabella games
    INSERT_GAME=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) values($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS)")
    echo "Inserted game: $YEAR $ROUND"
  fi
done
