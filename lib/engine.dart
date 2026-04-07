// import 'package:silvanus/src/rust/api/api.dart';

// class Engine {
//   static final Engine engine = Engine._internal();
  
//   Future<Api> apiFuture = Api.getApi();
//   late final Api api;
//   bool _initialized = false;

//   factory Engine() {
//     return engine;
//   }
  
//   Engine._internal();
  
//   Future<void> begin() async {
//     if (_initialized == false) {
//       _initialized = true;
//       api = await apiFuture;
//     }
//   }
// }