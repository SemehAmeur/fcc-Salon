#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ WELCOM TO OUR SALON ~~~~\n"

MAIN_MENU() {
  echo -e "\n$1"
  SERVICES_LIST=$($PSQL "SELECT * FROM services;")
  echo "$SERVICES_LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  if [[ -z $SERVICE_ID_SELECTED ]]
  then
    MAIN_MENU "Please select a valid service number"
  else
    echo -e "\nPlease enter your phone number"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nPlease insert your name"
      read CUSTOMER_NAME

      CUSTOMER_QUERY=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
      
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
      
    fi
    echo -e "Please give us an appointment"
    read SERVICE_TIME
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
    APPOINTMENT_ID=$($PSQL "SELECT MAX(appointment_id) FROM appointments;")
    echo "$($PSQL "SELECT services.name, time, customers.name FROM appointments INNER JOIN customers USING(customer_id) INNER JOIN services USING(service_id) WHERE appointment_id=$APPOINTMENT_ID;")" | while read SERVICE BAR TIME BAR NAME
    do
      echo -e "\nI have put you down for a $SERVICE at $TIME, $NAME."
    done
  fi
  
}
MAIN_MENU "Please select the desired service"
