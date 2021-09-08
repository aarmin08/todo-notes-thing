class Greetings {
  static String showGreetings() {
    String greeting() {
      var timeNow = DateTime.now().hour;
      if (timeNow <= 12) {
        return 'Good Morning, Enjoy your day!';
      } else if ((timeNow > 12) && (timeNow <= 16)) {
        return 'Good Afternoon, Hope everything is good';
      } else if ((timeNow > 16) && (timeNow <= 20)) {
        return 'Good Evening, The day\'s almost over!';
      } else {
        return 'Good Night, Sleep tight!';
      }
    }

    return greeting();
  }
}
