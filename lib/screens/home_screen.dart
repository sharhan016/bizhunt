import 'dart:async';
import 'package:bizhunt/packages/animated_search_field.dart';
import 'package:bizhunt/screens/business_detail_screen.dart';
import 'package:bizhunt/utils/common_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/business_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final businessBloc = BlocProvider.of<BusinessBloc>(context);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (searchController.text.isEmpty &&
            businessBloc.state is BusinessLoaded) {
          final state = businessBloc.state as BusinessLoaded;
          if (!state.hasReachedMax) {
            businessBloc.add(
              LoadMoreBusinessesEvent('NYC', businessBloc.currentPage + 1),
            );
          }
        } else if (searchController.text.isNotEmpty &&
            businessBloc.state is SearchedBusinessesLoaded) {
          final state = businessBloc.state as SearchedBusinessesLoaded;
          print("Search LIST LOAD MORE");
          if (!state.hasReachedMax) {
            businessBloc.add(
              LoadMoreSearchedBusinessEvent(
                'NYC',
                businessBloc.currentSearchPage + 1,
                searchController.text,
              ),
            );
          }
        }
      }
    });
    searchController.addListener(() {
      final text = searchController.text;
      if (text.isEmpty) {
        businessBloc.add(ShowLoadedBusinessesEvent());
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<BusinessBloc>().add(
            text.isEmpty
                ? FetchBusinesses("NYC")
                : FetchBusinessSearchEvent("NYC", text),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: AnimationSearchBar(
              backIconColor: Colors.black,
              isBackButtonVisible: false,
              centerTitle: 'BizHunt',
              focusNode: _searchFocusNode,
              onChanged: (text) {
                context.read<BusinessBloc>().add(text.isEmpty
                    ? FetchBusinesses("NYC")
                    : FetchBusinessSearchEvent("NYC", text));
                print("Search text: $text");
              },
              duration: const Duration(milliseconds: 500),
              searchBarWidth: MediaQuery.of(context).size.width - 30,
              searchTextEditingController: searchController,
              horizontalPadding: 1)),
      body: BlocBuilder<BusinessBloc, BusinessState>(
        builder: (context, state) {
          if (state is BusinessLoading && state is! BusinessLoaded) {
            return loadingIndicator();
          } else if (state is BusinessLoaded && searchController.text.isEmpty) {
            return ListView.builder(
              controller: _scrollController,
              itemCount: state.hasReachedMax
                  ? state.businesses.length
                  : state.businesses.length + 1,
              itemBuilder: (context, index) {
                if (index == state.businesses.length) {
                  return loadingIndicator();
                }

                final business = state.businesses[index];
                return _buildTile(business, context);
              },
            );
          } else if (searchController.text.isNotEmpty &&
              state is SearchedBusinessesLoaded) {
            return ListView.builder(
                controller: _scrollController,
                itemCount: state.hasReachedMax
                    ? state.businesses.length
                    : state.businesses.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.businesses.length) {
                    return loadingIndicator();
                  }
                  final business = state.businesses[index];
                  return _buildTile(business, context);
                });
          } else if (state is BusinessError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildTile(dynamic business, BuildContext context) {
    final imageUrl = business['image_url'].toString().isEmpty
        ? "https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png?20210219185637"
        : business['image_url'];
    return GestureDetector(
      onTap: () {
        _searchFocusNode.unfocus();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => BusinessDetailScreen(business: business)));
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    )
                    /*Image.network(
                    business['image_url'],
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  )*/
                    ),
                if ((business['categories'] as List).isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${business['categories'][0]['title']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      business['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${business['rating'] ?? 0.0} ★',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
