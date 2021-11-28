# Template generated code from trgen 0.10.0
JAR=C:/Users/Kenne/Downloads/antlr-4.9.2-complete.jar
CLASSPATH=$JAR\;.
err=0
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for g in `find ../examples -type f | grep -v '.errors$' | grep -v '.tree$'`
do
  file="$g"
  x1="${g##*.}"
  if [ "$x1" != "errors" ]
  then
    echo "$file"
    trwdog java -classpath $CLASSPATH Program -file "$file"
    status="$?"
    if [ -f "$file".errors ]
    then
      if [ "$stat" = "0" ]
      then
        echo Expected parse fail.
        err=1
        break
      else
        echo Expected.
      fi
    else
      if [ "$status" != "0" ]
      then
        err=1
        break
      fi
    fi
  fi
done
exit $err
