#!/bin/bash

sleep 5

while :
do

# Change the following: CAMERA_IP, RTSP URI, MULTICAST_IP and CAMERA_NAME
cvlc rtsp://CAMERA_IP:554/ch01/0 --play-and-exit --rtsp-tcp --sout '#transcode{acodec=mp4a,ab=32,channels=1,samplerate=8000,scodec=none}:rtp{dst=MULTICAST_IP,port=20000,mux=ts,sap,name=CAMERA_NAME,ttl=10}'

sleep 1
done