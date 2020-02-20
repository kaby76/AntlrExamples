#
rm out
for t in examples/*.y
do
	echo $t ============================================= >> out 2>&1
	dotnet run $t >> out 2>&1
done
