import 'package:equatable/equatable.dart';

/// A stored image returned by the backend. The backend persists only the R2
/// [key] (domain/bucket agnostic) and builds a fully-qualified [url] on the fly
/// when an image is read. Rule of thumb: display [url], send [key] back to the
/// key-based endpoints — never reconstruct a key from a url.
class ImageRef extends Equatable {
  final String key;
  final String url;

  const ImageRef({required this.key, required this.url});

  @override
  List<Object?> get props => [key, url];
}