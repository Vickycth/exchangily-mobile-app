import 'package:exchangilymobileapp/constants/colors.dart';
import 'package:exchangilymobileapp/localizations.dart';
import 'package:exchangilymobileapp/screen_state/otc_campaign/team_reward_details_screen_state.dart';
import 'package:exchangilymobileapp/screens/base_screen.dart';
import 'package:exchangilymobileapp/shared/ui_helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../shared/globals.dart' as globals;

class CampaignTeamRewardDetailsView extends StatelessWidget {
  final teamRewardDetails;
  const CampaignTeamRewardDetailsView({Key key, this.teamRewardDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(
        'teamRewardDetails $teamRewardDetails== members length ${teamRewardDetails['members'].length}');
    return BaseScreen<TeamRewardDetailsScreenState>(
      onModelReady: (model) async {
        //  model.teamValueAndRewardWithToken = teamRewardDetails;
        // model.initState();
      },
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(AppLocalizations.of(context).teamDetails,
              style: Theme.of(context).textTheme.headline4),
        ),
        body: Container(
            //  margin: EdgeInsets.all(8.0),
            child: Column(
          children: <Widget>[
            Container(
              color: green,
              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Center(
                      child: Text(AppLocalizations.of(context).teamLeader,
                          style: Theme.of(context).textTheme.headline4)),
                  Center(
                      child: Text(teamRewardDetails['name']['email'].toString(),
                          style: Theme.of(context).textTheme.headline4)),
                ],
              ),
            ),
            UIHelper.verticalSpaceMedium,
            // Members List
            Row(
              children: <Widget>[
                Expanded(
                  child: Center(
                      child: Text('#',
                          style: Theme.of(context).textTheme.subtitle2)),
                ),
                Expanded(
                  child: Center(
                      child: Text(AppLocalizations.of(context).members,
                          style: Theme.of(context).textTheme.subtitle2)),
                ),
              ],
            ),

            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: teamRewardDetails['members'].length,
                itemBuilder: (BuildContext context, int index) {
                  int i = index + 1;
                  return Card(
                    elevation: 5,
                    color: globals.walletCardColor,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Center(
                                  child: Text(
                            i.toString(),
                            style: Theme.of(context).textTheme.headline5,
                          ))),
                          Expanded(
                              child: Center(
                                  child: Text(
                                      teamRewardDetails['members'][index]
                                              ['email']
                                          .toString(),
                                      textAlign: TextAlign.start,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5))),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        )),
      ),
    );
  }
}