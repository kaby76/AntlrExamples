
# javafixed/bin/Debug/netcoreapp3.1/java.exe c:/Users/kenne/Documents/grammars-v4/java/java9/examples/module-info.java
# javafixed/bin/Debug/netcoreapp3.1/java.exe c:/Users/kenne/Documents/grammars-v4/java/java9/examples/IdentifierTest.java

cd javafixed; rm -rf obj bin; dotnet build; cd ..
cd javaparr; rm -rf obj bin; dotnet build; cd ..
cd java; rm -rf obj bin; dotnet build; cd ..

javafixed/bin/Debug/netcoreapp3.1/java.exe c:/users/kenne/documents/java-parser-test/android-sdk-sources-for-api-level-5/android/accounts/AccountManager.java > out1
javaparr/bin/Debug/netcoreapp3.1/javaparr.exe c:/users/kenne/documents/java-parser-test/android-sdk-sources-for-api-level-5/android/accounts/AccountManager.java > out2
java/bin/Debug/netcoreapp3.1/java.exe c:/users/kenne/documents/java-parser-test/android-sdk-sources-for-api-level-5/android/accounts/AccountManager.java > out3
javafixed/bin/Debug/netcoreapp3.1/java.exe -notree c:/users/kenne/documents/java-parser-test/android-sdk-sources-for-api-level-5/android/accounts/AccountManager.java > out1b
javaparr/bin/Debug/netcoreapp3.1/javaparr.exe -notree c:/users/kenne/documents/java-parser-test/android-sdk-sources-for-api-level-5/android/accounts/AccountManager.java > out2b
java/bin/Debug/netcoreapp3.1/java.exe -notree c:/users/kenne/documents/java-parser-test/android-sdk-sources-for-api-level-5/android/accounts/AccountManager.java > out3b
cat out1 | grep '^[ ]*[(]' | sed 's/^[ ]*[(][ ]\([^ ]*\).*/\1/' | sort | uniq -c | sort -k 1n > out1.count
cat out2 | grep '^[ ]*[(]' | sed 's/^[ ]*[(][ ]\([^ ]*\).*/\1/' | sort | uniq -c | sort -k 1n > out2.count
cat out3 | grep '^[ ]*[(]' | sed 's/^[ ]*[(][ ]\([^ ]*\).*/\1/' | sort | uniq -c | sort -k 1n > out3.count

