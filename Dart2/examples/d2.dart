main() {
	List<int> fixedLengthList = new List(5);
	fixedLengthList.length = 0;  // Error
	fixedLengthList.add(499);    // Error
	fixedLengthList[0] = 87;
	List<int> growableList = [1, 2];
	growableList.length = 0;
	growableList.add(499);
	growableList[0] = 87;
}
