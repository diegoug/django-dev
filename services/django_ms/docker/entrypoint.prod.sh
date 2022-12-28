#!/bin/sh

echo "Waiting for Main Postgres..."

while ! nc -z "$POSTGRES_HOST" 5432; do
  sleep 2
done

echo "Waiting for Users Postgres..."

# Run the app
cd /home/app/web/ && uwsgi --wsgi-file=django_ms/wsgi.py --processes=7 --threads=8 --enable-threads --http-socket=:80 --strict --master --vacuum --max-requests="$MAX_REQUESTS"  --http-timeout="$TIMEOUT" --socket-timeout="$TIMEOUT" --harakiri="$TIMEOUT" --disable-logging --log-4xx --log-5xx