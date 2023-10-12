#!/bin/bash

# This script is to get weather data from openweathermap.com in the form of a json file
# so that conky will still display the weather when offline even though it doesn't up to date

# you can use this or replace with yours
# b59117c083dfa1d4e6cc3186a568fd26
api_key=a1e881edef7ca02ae33608f2ad95330b
# get your city id at https://openweathermap.org/find and replace
city_id=3204854

url="api.openweathermap.org/data/2.5/weather?id=${city_id}&appid=${api_key}&cnt=5&units=metric&lang=en"
curl ${url} -s -o ~/.cache/weather.json
