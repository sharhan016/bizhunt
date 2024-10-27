import 'package:bizhunt/services/yelp_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'business_event.dart';
part 'business_state.dart';

class BusinessBloc extends Bloc<BusinessEvent, BusinessState> {
  final YelpService yelpService;
  int currentPage = 1;
  int currentSearchPage = 1;

  BusinessBloc(this.yelpService) : super(BusinessInitial()) {
    on<FetchBusinesses>(_onFetchBusinesses);
    on<LoadMoreBusinessesEvent>(_onLoadMoreBusinesses);
    on<FetchBusinessSearchEvent>(_onBusinessSearch);
    on<LoadMoreSearchedBusinessEvent>(_onSearchMoreBusinesses);
    on<ShowLoadedBusinessesEvent>(_onShowLoadedBusinessEvent);
  }

  Future _onFetchBusinesses(
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

  Future _onLoadMoreBusinesses(
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

  Future _onBusinessSearch(
      FetchBusinessSearchEvent event, Emitter<BusinessState> emit) async {
    emit(BusinessLoading());
    try {
      currentSearchPage = 1;
      final response = await yelpService.fetchBusinessesBySearch(
          event.location, event.query);
      emit(SearchedBusinessesLoaded(response, response.isEmpty));
    } catch (e) {
      print("Error on business search $e");
    }
  }

  Future _onSearchMoreBusinesses(
      LoadMoreSearchedBusinessEvent event, Emitter<BusinessState> emit) async {
    if (state is SearchedBusinessesLoaded) {
      final currentState = state as SearchedBusinessesLoaded;

      if (currentState.hasReachedMax) return;
      try {
        final nextPage = currentSearchPage + 1;

        final businesses = await yelpService.fetchBusinessesBySearch(
            event.location, event.query,
            page: nextPage);
        print("Businesses length from More search: ${businesses.length}");
        emit(SearchedBusinessesLoaded(
            businesses.isEmpty
                ? currentState.businesses
                : currentState.businesses + businesses,
            businesses.isEmpty));
        currentSearchPage = nextPage;
      } catch (e) {
        emit(BusinessError('Failed to load more businesses: $e'));
      }
    }
  }

  _onShowLoadedBusinessEvent(
      ShowLoadedBusinessesEvent event, Emitter<BusinessState> emit) {
    if (state is BusinessLoaded) {
      emit(state);
    } else {
      add(FetchBusinesses("NYC"));
    }
  }
}
