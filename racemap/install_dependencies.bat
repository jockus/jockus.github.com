@echo off
echo Go To http://nodejs.org and click INSTALL
start iexplore http://nodejs.org
echo Done installing Node.js???
pause
call npm install -g coffee-script
call npm install -g coffee-toaster
call npm install connect

echo Run "builder.bat" to set up a compiler and server!
echo Modify source files in racemap/src
echo Access website via http://localhost:8080