import 'dart:io';

import 'package:bizhunt/screens/business_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/business_bloc.dart';

class HomeScreen extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final businessBloc = BlocProvider.of<BusinessBloc>(context);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          context.read<BusinessBloc>().state is BusinessLoaded) {
        final state = context.read<BusinessBloc>().state as BusinessLoaded;
        if (!state.hasReachedMax) {
          businessBloc.add(
              LoadMoreBusinessesEvent('NYC', businessBloc.currentPage + 1));
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Businesses'),
      ),
      body: BlocBuilder<BusinessBloc, BusinessState>(
        builder: (context, state) {
          if (state is BusinessLoading && state is! BusinessLoaded) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BusinessLoaded) {
            return ListView.builder(
              controller: _scrollController,
              itemCount: state.hasReachedMax
                  ? state.businesses.length
                  : state.businesses.length + 1,
              itemBuilder: (context, index) {
                if (index == state.businesses.length) {
                  return Center(child: CircularProgressIndicator());
                }

                final business = state.businesses[index];
                return _buildTile(business, context);
                /*
                return ListTile(
                  leading: business['image_url'] != null
                      ? Image.network(business['image_url'],
                          width: 50, height: 50)
                      : const Icon(Icons.store),
                  title: Text(business['name']),
                  subtitle: Text('Rating: ${business['rating']}'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            BusinessDetailScreen(business: business)));
                  },
                );
                */
              },
            );
          } else if (state is BusinessError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildTile(dynamic business, BuildContext context) {
    return GestureDetector(
      onTap: () {
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
                  child: Image.network(
                    business['image_url'],
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                // Positioned(
                //   bottom: -5,
                //   left: 4,
                //   child: Container(
                //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //     margin: EdgeInsets.only(bottom: 4),
                //     decoration: BoxDecoration(
                //         color: Colors.white,
                //         borderRadius: BorderRadius.only(
                //             topLeft: Radius.circular(0),
                //             topRight: Radius.circular(9))),
                //     child: Text(
                //       business['categories'][0]['title'],
                //       style: TextStyle(
                //         fontSize: 14,
                //         fontWeight: FontWeight.w600,
                //         color: Colors.black87,
                //       ),
                //     ),
                //   ),
                // Row(
                //   children: [
                //     Icon(Icons.access_time, color: Colors.white, size: 16),
                //     SizedBox(width: 4),
                //     Text(
                //       '40 mins • 8.5 km',
                //       style: TextStyle(
                //         color: Colors.white,
                //         fontSize: 14,
                //       ),
                //     ),
                //   ],
                // ),
                // ),
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
