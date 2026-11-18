/// Paths of the passenger app.
abstract final class Routes {
  static const home = '/home';
  static const history = '/home/history';
  static const _ride = '/home/rides';

  static String rideDetails(String rideId) => '$_ride/$rideId';
  static const rideDetailsPattern = '$_ride/:rideId';
}
