#!/bin/sh

rm -rf obj bin
dotnet build
yes 'aaaa bbbbbb cccc' | head -139999999 > input
time ./bin/Debug/netcoreapp3.1/a.exe input
rm -f input
rm -rf obj bin
