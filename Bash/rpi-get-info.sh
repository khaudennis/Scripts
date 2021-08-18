#!/bin/bash

cat /proc/cpuinfo | grep Model

cat /proc/cpuinfo | grep Serial

vcgencmd measure_temp | tr -d temp=