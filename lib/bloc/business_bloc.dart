import 'package:bizhunt/services/yelp_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'business_event.dart';
part 'business_state.dart';

class BusinessBloc extends Bloc<BusinessEvent, BusinessState> {
  final YelpService yelpService;
  int currentPage = 1;

  BusinessBloc(this.yelpService) : super(BusinessInitial()) {
    on<FetchBusinesses>(_onFetchBusinesses);
    on<LoadMoreBusinessesEvent>(_onLoadMoreBusinesses);
  }

  Future<void> _onFetchBusinesses(
      FetchBusinesses event, Emitter<BusinessState> emit) async {
    emit(BusinessLoading());
    try {
      currentPage = 1;
      final businesses =
          await yelpService.fetchBusinesses(event.location, page: currentPage);
      emit(BusinessLoaded(businesses, hasReachedMax: businesses.isEmpty));
    } catch (e) {
      emit(BusinessError('Failed to load businesses: $e'));
    }
  }

  Future<void> _onLoadMoreBusinesses(
      LoadMoreBusinessesEvent event, Emitter<BusinessState> emit) async {
    if (state is BusinessLoaded) {
      final currentState = state as BusinessLoaded;
      if (currentState.hasReachedMax) return;

      try {
        final nextPage = currentPage + 1;
        final newBusinesses =
            await yelpService.fetchBusinesses(event.location, page: nextPage);

        emit(newBusinesses.isEmpty
            ? BusinessLoaded(currentState.businesses, hasReachedMax: true)
            : BusinessLoaded(
                currentState.businesses + newBusinesses,
                hasReachedMax: false,
              ));
        currentPage = nextPage;
      } catch (e) {
        emit(BusinessError('Failed to load more businesses: $e'));
      }
    }
  }
}
