#!/bin/bash

REPOSITORY=/home/ec2-user/app/step1
PROJECT_NAME=sijangtong-server
PROJECT_NAME2=sijangtong-client

sudo cp $REPOSITORY/zip/*.jar $REPOSITORY/

echo "> check Server Application pid $PROJECT_NAME"
CURRENT_PID=$(pgrep -fl $PROJECT_NAME | grep jar)

echo "> Server Application Pid: $CURRENT_PID"
if [ -z "$CURRENT_PID" ]; then
  echo "> there is no running Application"
else
  echo "> kill -15 $CURRENT_PID (safe kill)"
  kill -15 $CURRENT_PID
  sleep 5

  CURRENT_PID_AFTER_KILL=$(pgrep -f ${PROJECT_NAME})
  if [ -z $CURRENT_PID_AFTER_KILL ]; then
    echo "> Application kill well"
  else
    echo "> Kill Application Forced"
    kill -9 $CURRENT_PID_AFTER_KILL
    sleep 5
  fi
fi

echo "> deploy new Application"

JAR_NAME=$(ls -tr $REPOSITORY/*.jar | tail -n 1)
chmod +x $JAR_NAME

echo "> JAR Name: $JAR_NAME"
sudo nohup java -jar \
    -Dspring.config.location=classpath:/application.
properties \ 
    -Dspring.profiles.active=real \
    $JAR_NAME > $REPOSITORY/nohup.out 2>&1 &
# ,classpath:/application-real.properties,/home/ec2-user/app/application-oauth.properties,/home/ec2-user/app/application-real-db.properties \

echo "> run client project"
cd /$REPOSITORY/$PROJECT_NAME2

echo "> pm2 kill"
pm2 kill

echo "> git pull"
git pull

echo "> npm build"
# npm install
# npm run build
sudo yarn build

echo "> pm2 build"
pm2 serve build/ 3000 --spa
