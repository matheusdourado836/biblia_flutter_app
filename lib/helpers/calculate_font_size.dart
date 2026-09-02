double calculateFontSize(int length, double height) {
  double calculatedFontSize = 20;

  if(height <= 800) {
    if(length <= 360) {
      calculatedFontSize = 20;
    }else if(length > 360 && length <= 600) {
      calculatedFontSize = 15;
    }else if(length > 600 && length <= 900) {
      calculatedFontSize = 12;
    }else {
      calculatedFontSize = 10;
    }
  }

  return calculatedFontSize;
}