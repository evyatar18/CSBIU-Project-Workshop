void israeliIDChecker(String candidate) {
  if (candidate.length != 9) {
    throw "Israeli ID length must be 9.";
  }

  int sum = 0;
  int multiplier = 1;

  /* Israeli ID Validation Formula
   * Iterate over 9 digits
   */
  for (int i = 0; i < 9; ++i) {
    int digit = int.parse(candidate[i]);

    int result = digit * multiplier;

    if (result >= 10) {
      // summing two digits of result
      result = (result ~/ 10) + (result % 10);
    }

    sum += result;

    // the multiplier flips between 1 and 2
    multiplier = 3 - multiplier;
  }

  if (sum % 10 != 0) {
    throw "Invalid Israeli ID number";
  }
}
