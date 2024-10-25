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
            return Center(child: CircularProgressIndicator());
          } else if (state is BusinessLoaded) {
            return ListView.builder(
              controller: _scrollController,
              itemCount: state.hasReachedMax
                  ? state.businesses.length
                  : state.businesses.length +
                      1,
              itemBuilder: (context, index) {
                if (index == state.businesses.length) {
                  return Center(child: CircularProgressIndicator());
                }

                final business = state.businesses[index];
                return ListTile(
                  leading: business['image_url'] != null
                      ? Image.network(business['image_url'],
                          width: 50, height: 50)
                      : Icon(Icons.store),
                  title: Text(business['name']),
                  subtitle: Text('Rating: ${business['rating']}'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            BusinessDetailScreen(business: business)));
                  },
                );
              },
            );
          } else if (state is BusinessError) {
            return Center(child: Text(state.message));
          }
          return Center(child: Text('No data available'));
        },
      ),
    );
  }
}
