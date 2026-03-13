import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:crispychikisdriver/provider/provider.dart';
import 'package:crispychikisdriver/theme/color/colors.dart';
import 'package:crispychikisdriver/components/appbar.dart';
import 'package:crispychikisdriver/components/button.dart';

class navigationView extends StatelessWidget {
  final MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          bg_color: colorsPalete['dark blue']!,
          shape_color: colorsPalete['orange']!,
        ),
      ),
      body: Consumer<crispyDriverProvider>(
        builder: (context, provider, child) {
          LatLng? destinationPos;
          if (provider.destinationPos != null) {
            print(provider.destinationPos);
            destinationPos = LatLng(
              provider.destinationPos!['latitud_destino'],
              provider.destinationPos!['longitud_destino'],
            );
          }

          final driverPos = provider.lastPosition;
          if (driverPos == null || destinationPos == null) {
            return Stack(
              children: [
                Container(
                  color: colorsPalete['orange'],
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
                Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    color: colorsPalete['dark blue'],
                  ),
                ),
              ],
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mapController.camera.center != driverPos) {
              mapController.move(driverPos, 19.6);
            }
          });

          return FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: driverPos,
              initialZoom: 19.6,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              mapLayer,
              if (provider.routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: provider.routePoints,
                      strokeWidth: 5,
                      color: Colors.blue,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: destinationPos,
                    height: 70,
                    width: 160,
                    rotate: true,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorsPalete['dark blue']!,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Destino',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.location_pin,
                          color: colorsPalete['orange']!,
                          size: 40,
                        ),
                      ],
                    ),
                  ),
                  Marker(
                    width: 60,
                    height: 60,
                    point: driverPos,
                    child: Transform.rotate(
                      angle: (provider.heading * (3.1446 / 180)),
                      child: Icon(
                        Icons.navigation_rounded,
                        color: colorsPalete['orange'],
                        size: 50,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SizedBox(
        height: 90,
        child: Container(
          color: colorsPalete['orange'],
          child: Padding(
            padding: EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 7),
            child: CustomButton(
              text: 'VOLVER',
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ),
    );
  }

  TileLayer get mapLayer => TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'com.dnv.dev.crispychikis',
  );
}
