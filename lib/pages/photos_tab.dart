import 'package:flutter/material.dart';
import 'package:map_sample_flutter/models/store_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PhotosTab extends StatelessWidget {
  final StoreDetail storeDetail;

  final String apiKey;

  const PhotosTab({required this.storeDetail, required this.apiKey});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: storeDetail.photoReferences.length - 2,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 3,
        mainAxisSpacing: 5,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  insetPadding: EdgeInsets.all(8),
                  child: InteractiveViewer(
                    child: CachedNetworkImage(
                      imageUrl:
                          'https://maps.googleapis.com/maps/api/place/photo?maxwidth=500&photoreference=${storeDetail.photoReferences[index]}&key=$apiKey',
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            );
          },
          child: Container(
            child: CachedNetworkImage(
              imageUrl:
                  'https://maps.googleapis.com/maps/api/place/photo?maxwidth=500&photoreference=${storeDetail.photoReferences[index]}&key=$apiKey',
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}
