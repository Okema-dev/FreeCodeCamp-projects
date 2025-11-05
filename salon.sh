#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

echo -e "\nWelcome to My Salon, how can I help you?\n"

DISPLAY_SERVICES () {
  if [[ $1 ]]
    then
      echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT * FROM services")

  echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  
  SELECT_A_SERVICE
}

SELECT_A_SERVICE () {
  # select a service
  read SERVICE_ID_SELECTED

  # check if service is available
  SELECTED_SERVICE=$(echo $($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED") | sed -E 's/^ *| *$//g')
  if [[ -z $SELECTED_SERVICE ]]
    then
      # if not available
      DISPLAY_SERVICES "I could not find that service. What would you like today?\n"
    else
      # get customer phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      # check record for phone number
      CHECK_CUSTOMER_RESULT=$($PSQL "SELECT * FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      if [[ -z $CHECK_CUSTOMER_RESULT ]]
        then
          # if not available
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME

          # add customer to customer table
          ADD_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
      # get customer's desired appointment time
      echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
      read SERVICE_TIME

      # get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME'")
        
      # add customer's appointment to appointments table
      ADD_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      echo -e "\nI have put you down for a $SELECTED_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

DISPLAY_SERVICES



