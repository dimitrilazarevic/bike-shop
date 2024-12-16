#!/bin/bash
PSQL='psql --username=freecodecamp --dbname=salon --tuples-only -c'


MAIN_MENU(){

  SERVICES=$($PSQL "SELECT service_id,name FROM services")

  echo "$SERVICES" | while IFS=" |" read SERVICE_ID NAME

  do
    echo -e "$SERVICE_ID) $NAME"
  done

  if [[ ! $1 ]]
  then
    CHOOSE_SERVICE "Please choose a service"
  else
    CHOOSE_SERVICE "$1"
  fi


}

CHOOSE_SERVICE(){

  if [[ $1 ]]
    then
    echo -e "\n$1"
  fi

  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED =~ [0-9]+ ]]

    then
    SELECTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    if [[ ! $SELECTED_SERVICE ]]
      then
      MAIN_MENU "Service not found. Try again..."

      else
      echo -e "\nYou have chosen the service : $SELECTED_SERVICE.\nPlease enter a phone number."

      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      if [[ $CUSTOMER_NAME ]]
        then
        echo -e "\nWelcome back $CUSTOMER_NAME !"

        else
        echo -e "\It seems like it's the first time you come here ! Please enter your name"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
        echo $INSERT_CUSTOMER_RESULT

        if [[ $INSERT_CUSTOMER_RESULT == "INSERT 0 1" ]]
          then
          echo -e "\nYou have been succesfully registered."

          else
          echo -e "\nThere has been an error..."
          MAIN_MENU
          
          fi

      fi

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      echo -e "\nPlease enter a date :"
      read SERVICE_TIME 

      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

      if [[ $INSERT_APPOINTMENT_RESULT = 'INSERT 0 1' ]]
        then

        echo -e "\nI have put you down for a $SELECTED_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."

        else

        echo -e "There's been a mistake"
        MAIN_MENU

      fi

    fi

    else
    MAIN_MENU "Please enter a valid number"

  fi

}

MAIN_MENU
