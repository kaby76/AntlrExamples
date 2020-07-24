#
for i in *.g
do
	echo $i
	java -jar ~/Downloads/antlr-3.5.2-complete.jar "$i"
done
