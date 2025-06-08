#!/bin/bash

source ../.env

forwarded=(
    "10022:localhost:22"
    "10080:localhost:80"
);

ports=""

for i in ${forwarded[@]}; do
     ports="$ports -R $i";
done

ssh -N $ports $HOST_USER@$HOST_LOCAL_IP
