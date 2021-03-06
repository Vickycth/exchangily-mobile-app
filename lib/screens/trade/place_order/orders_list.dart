/*
* Copyright (c) 2020 Exchangily LLC
*
* Licensed under Apache License v2.0
* You may obtain a copy of the License at
*
*      https://www.apache.org/licenses/LICENSE-2.0
*
*----------------------------------------------------------------------
* Author: ken.qiu@exchangily.com, barry-ruprai@exchangily.com
*----------------------------------------------------------------------
*/

import 'package:exchangilymobileapp/screens/base_screen.dart';
import 'package:exchangilymobileapp/shared/ui_helpers.dart';
import 'package:exchangilymobileapp/utils/string_util.dart';
import "package:flutter/material.dart";
import 'package:exchangilymobileapp/localizations.dart';
import 'package:exchangilymobileapp/shared/globals.dart' as globals;

import 'order_list_screen_state.dart';

class OrdersList extends StatelessWidget {
  final List<Map<String, dynamic>> orderArray;
  final String type;
  final String exgAddress;

  OrdersList(this.orderArray, this.type, this.exgAddress);

  @override
  Widget build(BuildContext context) {
    return BaseScreen<OrderListScreenState>(
        onModelReady: (model) {
          model.orderArray = orderArray;
          model.type = type;
          model.exgAddress = exgAddress;
          print(model.orderArray.length);
        },
        builder: (context, model, child) => Column(children: <Widget>[
              Row(children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Text(AppLocalizations.of(context).type,
                      style: Theme.of(context).textTheme.subtitle2),
                ),
                Expanded(
                    flex: 2,
                    child: Text(AppLocalizations.of(context).pair,
                        style: Theme.of(context).textTheme.subtitle2)),
                Expanded(
                    flex: 1,
                    child: Text(AppLocalizations.of(context).price,
                        style: Theme.of(context).textTheme.subtitle2)),
                Expanded(
                    flex: 3,
                    child: Center(
                      child: Text(AppLocalizations.of(context).filledAmount,
                          style: Theme.of(context).textTheme.subtitle2),
                    )),
                Expanded(
                  flex: 1,
                  child: Text(AppLocalizations.of(context).cancel,
                      style: Theme.of(context).textTheme.subtitle2),
                ),
                if (type == 'open') Text('')
              ]),
              UIHelper.horizontalSpaceSmall,
              // Order Array Values
              for (var item in orderArray)
                Row(children: <Widget>[
                  Expanded(
                      flex: 1,
                      child: Text(item["type"],
                          style: TextStyle(
                              color: Color((item["type"] == 'Buy')
                                  ? 0xFF0da88b
                                  : 0xFFe2103c),
                              fontSize: 16.0))),
                  Expanded(
                      flex: 2,
                      child: Text(item["pair"],
                          style: Theme.of(context).textTheme.headline5)),
                  Expanded(
                      flex: 1,
                      child: Text(item["price"].toString(),
                          style: Theme.of(context).textTheme.headline5)),
                  Expanded(
                      flex: 3,
                      child: Center(
                        child: Text(
                            doubleAdd(item["amount"], item["filledAmount"])
                                    .toString() +
                                "(" +
                                (item["filledAmount"] *
                                        100 /
                                        doubleAdd(item["filledAmount"],
                                            item["amount"]))
                                    .toStringAsFixed(2) +
                                "%)",
                            style: Theme.of(context).textTheme.headline5),
                      )),
                  if (type == 'open')
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        child: Icon(
                          Icons.clear,
                          color: Colors.white70,
                          size: 20.0,
                          semanticLabel: 'Cancel order',
                        ),
                        onTap: () {
                          model.checkPass(context, item["orderHash"]);
                        },
                      ),
                    )
                ]),
            ]));
  }
}
