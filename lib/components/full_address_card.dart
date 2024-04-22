import 'package:flutter/material.dart';

class FullAddressCard extends StatefulWidget {
  FullAddressCard({
    super.key,
    required this.address
  });

  String address;

  @override
  State<StatefulWidget> createState() => _FullAddressCard();
}

class _FullAddressCard extends State<FullAddressCard> {
  @override
  void initState() {
    super.initState();
  }

  TextStyle style = const TextStyle( fontSize: 16 );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: MediaQuery.sizeOf(context).height * 0.1,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric( horizontal: 18, vertical: 14 ),
          child: Row(
            children: [
              const Icon(Icons.location_city_rounded, size: 30),
              const SizedBox( width: 12 ),
              Expanded(
                child: Text(widget.address)
              )
            ],
          ),
        ),
      ),
    );
  }
}
