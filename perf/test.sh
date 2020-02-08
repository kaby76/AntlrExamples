#!/bin/bash

echo ====================
echo a1
echo Base.
cd a1; rm -rf bin obj; dotnet run -c Release; cd ..
echo ====================
echo a2
echo Predicate as property lhs.
cd a2; rm -rf bin obj; dotnet run -c Release input_s; cd ..
echo ====================
echo a3
echo Predicate as property rhs.
cd a3; rm -rf bin obj; dotnet run -c Release input_s; cd ..
echo ====================
echo a4
echo Predicate as property lhs, with COMMENT to test effect on inter-dfa recognition.
cd a4; rm -rf bin obj; dotnet run -c Release cinput; cat cinput | wc; grep -v '//' cinput | wc; cd ..
echo ====================
echo a5
echo Predicate as property rhs, with COMMENT to test effect on inter-dfa recognition.
cd a5; rm -rf bin obj; dotnet run -c Release cinput; cat cinput | wc; grep -v '//' cinput | wc; cd ..
echo ====================
echo a6
echo Predicate as field lhs.
cd a6; rm -rf bin obj; dotnet run -c Release input_s; cd ..
echo ====================
echo a7
echo Predicate as field rhs.
cd a7; rm -rf bin obj; dotnet run -c Release input_s; cd ..

rm -rf {a1,a2,a3,a4,a5,a6,a7}/{obj,bin,.vs}
