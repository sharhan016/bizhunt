part of 'business_bloc.dart';

@immutable
sealed class BusinessState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class BusinessInitial extends BusinessState {}

final class BusinessLoading extends BusinessState {}

final class BusinessLoaded extends BusinessState {
  final List<dynamic> businesses;
  final bool hasReachedMax;

BusinessLoaded(this.businesses, {this.hasReachedMax = false});

  @override
  List<Object?> get props => [businesses, hasReachedMax];
}

final class BusinessError extends BusinessState {
  final String message;

  BusinessError(this.message);

  @override
  List<Object?> get props => [message];
}

final class SearchedBusinessesLoaded extends BusinessState {
  final List<dynamic> businesses;
  final bool hasReachedMax;

  SearchedBusinessesLoaded(this.businesses, this.hasReachedMax);

  @override
  List<Object?> get props => [businesses, hasReachedMax];
}
