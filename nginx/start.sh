#!/bin/bash
envsubst '$FLASK_SERVER_ADDR $AWS_SERVER_IP' < /tmp/default.conf > /etc/nginx/conf.d/default.conf
nginx -g 'daemon off;'
 
