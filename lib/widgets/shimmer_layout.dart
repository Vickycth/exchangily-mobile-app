import 'dart:ui';

import 'package:exchangilymobileapp/constants/colors.dart';
import 'package:exchangilymobileapp/widgets/shimmer_layouts/shimmer_market_pairs_layout.dart';
import 'package:exchangilymobileapp/widgets/shimmer_layouts/shimmer_orderbook_layout.dart';
import 'package:exchangilymobileapp/widgets/shimmer_layouts/shimmer_wallet_dashboard_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

import 'shimmer_layouts/shimmer_market_trades_layouty.dart';

class ShimmerLayout extends StatelessWidget {
  final String layoutType;
  const ShimmerLayout({Key key, this.layoutType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: ListView.builder(
            itemCount: 5,
            itemBuilder: (BuildContext context, int index) {
              Widget layout;

              if (layoutType == 'walletDashboard') {
                layout = Shimmer.fromColors(
                    child: ShimmerWalletDashboardLayout(),
                    baseColor: Colors.grey,
                    highlightColor: Colors.white);
              } else if (layoutType == 'marketPairs') {
                layout = Shimmer.fromColors(
                    child: ShimmerMarketPairsLayout(),
                    baseColor: Colors.grey,
                    highlightColor: Colors.white);
              } else if (layoutType == 'orderbook') {
                layout = Shimmer.fromColors(
                    child: ShimmerOrderbookLayout(),
                    baseColor: primaryColor.withAlpha(155),
                    highlightColor: Colors.white);
              } else if (layoutType == 'marketTrades') {
                layout = Shimmer.fromColors(
                    child: ShimmerMarketTradesLayout(),
                    baseColor: Colors.grey,
                    highlightColor: Colors.white);
              }
              return layout;
            }));
  }
}
