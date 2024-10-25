part of 'business_bloc.dart';

@immutable
sealed class BusinessEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class FetchBusinesses extends BusinessEvent {
  final String location;
  FetchBusinesses(this.location);

  @override
  List<Object?> get props => [location];
}

final class LoadMoreBusinessesEvent extends BusinessEvent {
  final String location;
  final int page;

  LoadMoreBusinessesEvent(this.location, this.page);

  @override
  List<Object?> get props => [location, page];
}
