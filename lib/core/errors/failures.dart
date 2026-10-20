import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final dynamic error;

  const Failure(this.message, [this.error]);

  @override
  List<Object?> get props => [message, error];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.error]);
}

class AudioFailure extends Failure {
  const AudioFailure(super.message, [super.error]);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.error]);
}

class ChecksumFailure extends Failure {
  const ChecksumFailure(super.message, [super.error]);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.error]);
}
