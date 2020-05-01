#

echo yes1
cd yes1; rm -rf bin obj; dotnet build; sed -n '6,8p' Yes1.g4; cd ..
time (yes yes | head -10000000 | ./yes1/bin/Debug/netcoreapp3.1/yes1.exe )

echo yes2
cd yes2; rm -rf bin obj; dotnet build; sed -n '6,8p' Yes2.g4; cd ..
time (yes yes | head -10000000 | ./yes2/bin/Debug/netcoreapp3.1/yes2.exe )

echo yes3
cd yes3; rm -rf bin obj; dotnet build; sed -n '6,8p' Yes3.g4; cd ..
time (yes yes | head -10000000 | ./yes3/bin/Debug/netcoreapp3.1/yes3.exe )
