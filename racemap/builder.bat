@echo off
start node server.js
sleep 3
start chrome http://localhost:8080
cd racemap
start toaster -wd