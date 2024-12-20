#!/bin/bash

DIR="/vault/files"

FILES=$( ls "$DIR" )
FILES=( $FILES )
QTD=$( ls "$DIR" | wc -l )

COUNTER=0


echo "COUNTER: $QTD"


while [ "x${FILES[$COUNTER]}" != x ]
do
        HASH="${FILES[$COUNTER]}"

        A=${HASH:0:1}  # Primeiro caractere
        B=${HASH:1:1}  # Segundo caractere
        C=${HASH:2:1}  # Terceiro caractere
        D=${HASH:3:1}  # Quarto caractere

        mkdir -p "$DIR/$A/$B/$C/$D"
        echo "Refatorando: ${FILES[$COUNTER]} como $DIR/$A/$B/$C/$D/$HASH"

        mv "$DIR/$HASH" "$DIR/$A/$B/$C/$D/$HASH"

        COUNTER=$(($COUNTER+1))

done
