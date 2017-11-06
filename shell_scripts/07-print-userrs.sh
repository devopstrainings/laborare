#!/bin/bash

USERS=$(who |wc -l)
echo "Number of Users Logged in = $USERS"