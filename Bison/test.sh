#
dotnet build
rm out
for t in ../../crawl/[0-9]*/*.y
do
	echo $t
	echo $t ============================================= >> out 2>&1
	bin/Debug/netcoreapp3.1/Bison.exe $t >> out 2>&1
done
