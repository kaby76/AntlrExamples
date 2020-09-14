#!/bin/sh

rm -rf obj bin
dotnet build
yes 'aaaa bbbbbb cccc' | head -139999999 > input
# Note, on my beefy machine, 19m to parse a 2GB+ file.
time ./bin/Debug/netcoreapp3.1/a.exe input
rm -f input
rm -rf obj bin
