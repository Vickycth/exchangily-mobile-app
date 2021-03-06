import 'package:exchangilymobileapp/models/campaign/my_referrals.dart';

class CampaignReward {
  int _level;
  List<String> _users;
  double _totalValue; // my investment value
  double _totalQuantities; // my total tokens bought
  double _totalRewardQuantities;
  int _totalAccounts; // number of childrens
  double
      _totalRewardNextQuantities; // suggest user to buy more token to get more rewards

  CampaignReward(
      {int level,
      List<String> users,
      double totalValue,
      double totalQuantities,
      double totalRewardQuantities,
      int totalAccounts,
      double totalRewardNextQuantities}) {
    this._level = level ?? 0;
    this._totalValue = totalValue ?? 0.0;
    this._totalQuantities = totalQuantities ?? 0.0;
    this._totalRewardQuantities = totalRewardQuantities ?? 0.0;
    this._totalAccounts = totalAccounts ?? 0;
    this._totalRewardNextQuantities = totalRewardNextQuantities ?? 0.0;
    this._users = users;
  }

  factory CampaignReward.fromJson(Map<String, dynamic> json) {
    List usersFromJson = json["users"] as List;
    MyReferralsList myReferralsList = MyReferralsList.fromJson(usersFromJson);

    return CampaignReward(
        level: json["level"] as int,

        /// Currently i need email for referrals but i can return whole user object as
        /// i mapped it as in MyRefferal model
        users: myReferralsList.myReferralsList.map((e) => e.email).toList(),
        totalValue: json["totalValue"].toDouble(),
        totalQuantities: json["totalQuantities"].toDouble(),
        totalRewardQuantities: json["totalRewardQuantities"].toDouble(),
        totalAccounts: json["totalAccounts"] as int,
        totalRewardNextQuantities:
            json["totalRewardNextQuantities"].toDouble());
  }

  Map<String, dynamic> toJson() => {
        "level": this._level,
        'users': this._users,
        "totalValue": this._totalValue,
        "totalQuantities": this._totalQuantities,
        "totalRewardQuantities": this._totalRewardQuantities,
        "totalAccounts": this._totalAccounts,
        "totalRewardNextQuantities": this._totalRewardNextQuantities,
      };

  double get totalValue => _totalValue;
  set totalValue(double totalValue) {
    this._totalValue = totalValue;
  }

  List<String> get users => _users;
  set users(List<String> users) {
    this._users = users;
  }

  double get totalQuantities => _totalQuantities;
  set totalQuantities(double totalQuantities) {
    this._totalQuantities = totalQuantities;
  }

  double get totalRewardQuantities => _totalRewardQuantities;
  set totalRewardQuantities(double totalRewardQuantities) {
    this._totalRewardQuantities = totalRewardQuantities;
  }

  double get totalRewardNextQuantities => _totalRewardNextQuantities;
  set totalRewardNextQuantities(double totalRewardNextQuantities) {
    this._totalRewardNextQuantities = totalRewardNextQuantities;
  }

  int get level => _level;
  set level(int level) {
    this._level = level;
  }

  int get totalAccounts => _totalAccounts;
  set totalAccounts(int totalAccounts) {
    this._totalAccounts = totalAccounts;
  }
}

class CampaignRewardList {
  final List<CampaignReward> rewards;
  CampaignRewardList({this.rewards});

  factory CampaignRewardList.fromJson(List<dynamic> parsedJson) {
    List<CampaignReward> rewards = new List<CampaignReward>();
    rewards = parsedJson.map((i) => CampaignReward.fromJson(i)).toList();
    return new CampaignRewardList(rewards: rewards);
  }
}
