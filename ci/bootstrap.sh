#!/bin/bash
set -e

echo 'travis_fold:start:bootstrap'
echo '# Build & Run Docker Container'
docker build -t faf-league-db-migrations .
docker network create faf
docker run --network="faf" --network-alias="faf-league-db" -p 3307:3306 \
           -e MYSQL_ROOT_PASSWORD=banana \
           -e MYSQL_DATABASE=faf-league \
           -d --name faf-league-db \
           mysql:5.7

echo -n 'Waiting on faf-league-db '
counter=1
# wait 5 minutes on docker container
while [ $counter -le 300 ]
do
    if docker exec -it faf-league-db sh -c "mysqladmin ping -h 127.0.0.1 -uroot -pbanana" &> /dev/null; then
        echo 'travis_fold:end:bootstrap'

        # run flyway migrations
        docker run --network="faf" \
                   -e FLYWAY_URL=jdbc:mysql://faf-league-db/faf-league?useSSL=false \
                   -e FLYWAY_USER=root \
                   -e FLYWAY_PASSWORD=banana \
                   faf-league-db-migrations migrate

        exit 0
    fi
    echo -n "."
    sleep 1
    ((counter++))
done
echo 'Error: faf-league-db is not running after 5 minute timeout'
echo 'travis_fold:end:bootstrap'
exit 1
