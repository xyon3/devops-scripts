#!/bin/bash

source ../.env

forwarded=(
    "18443:localhost:8443"
    "13000:localhost:3000"
);

ports=""

for i in ${forwarded[@]}; do
     ports="$ports -R $i";
done

ssh -N $ports $HOST_USER@$HOST_LOCAL_IP
