import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // Name of the generated method
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => getIt.init();