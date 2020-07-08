#

for i in `ls examples/*.pli PLI-examples/*.PLI`
do
	echo $i
	./bin/Debug/netcoreapp3.1/pl1.exe $i
done
