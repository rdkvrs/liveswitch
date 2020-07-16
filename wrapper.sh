#!/bin/bash
REDISIP=$(ping -c1 redis | sed -nE 's/^PING[^(]+\(([^)]+)\).*/\1/p')
#Replace default Redis IP address for all configurations.
sed -i "s/127.0.0.1/$REDISIP/" /opt/liveswitch/gateway/FM.LiveSwitch.Gateway.Service.config.json
sed -i "s/127.0.0.1/$REDISIP/" /opt/liveswitch/media-server/FM.LiveSwitch.MediaServer.Service.config.json
sed -i "s/127.0.0.1/$REDISIP/" /opt/liveswitch/sip-connector/FM.LiveSwitch.Connector.Sip.Service.config.json

# Start the gateway
cd /opt/liveswitch/gateway/ 
dotnet ./FM.LiveSwitch.Gateway.Core.dll &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start gateway process: $status"
  exit $status
fi

sleep 10

# Start the media-server 
cd /opt/liveswitch/media-server/
dotnet ./FM.LiveSwitch.MediaServer.Core.dll &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start media-server: $status"
  exit $status
fi

sleep 10

# Start the sip-connector 
cd /opt/liveswitch/sip-connector/
dotnet ./FM.LiveSwitch.SipConnector.Core.dll &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start sip-connector: $status"
  exit $status
fi

while sleep 60; do
  ps aux |grep "dotnet ./FM.LiveSwitch.Gateway.Core.dll" |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux |grep "dotnet ./FM.LiveSwitch.MediaServer.Core.dll" |grep -q -v grep
  PROCESS_2_STATUS=$?
  ps aux |grep "dotnet ./FM.LiveSwitch.SipConnector.Core.dll" |grep -q -v grep
  PROCESS_3_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 -o $PROCESS_3_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  fi
done
