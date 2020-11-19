bool predicate(String element) {
  return element.length > 5;
}

main() {
  var items = ['Salad', 'Popcorn', 'Toast', 'Lasagne'];

  // You can find with a simple expression:
  var element1 = items.firstWhere((element) => element.length > 5);
  print(element1);

  // Or try using a function block:
  var element2 = items.firstWhere((element) {
    return element.length > 5;
  });
  print(element2);

  // Or even pass in a function reference:
  var element3 = items.firstWhere(predicate);
  print(element3);

  // You can also use an `orElse` function in case no value is found!
  var element4 = items.firstWhere(
    (element) => element.length > 10,
    orElse: () => 'None!',
  );
  print(element4);
}
