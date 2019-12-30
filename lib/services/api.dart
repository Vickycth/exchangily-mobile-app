import 'dart:convert';
import '../utils/string_util.dart' as stringUtils;
import 'package:exchangilymobileapp/logger.dart';
import 'package:http/http.dart' as http;
import '../environments/environment.dart';

/// The service responsible for networking requests
class Api {
  final log = getLogger('API');
  final client = new http.Client();

  static const usdCoinPriceUrl =
      'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,fabcoin,tether&vs_currencies=usd';

  static var btcUrl = environment["endpoints"]["btc"];
  static var fabUrl = environment["endpoints"]["fab"];
  static var ethUrl = environment["endpoints"]["eth"];

// Get Coin Usd Price
  Future getCoinsUsdValue() async {
    final res = await http.get(usdCoinPriceUrl);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return log.e('getCoinsUsdValue Failed to load the data from the API');
  }

  // Get FabUtxos
  Future getFabUtxos(String address) async {
    var url = fabUrl + 'getutxos/' + address;
    print(url);
    var json;
    try {
      var response = await client.get(url);
      json = jsonDecode(response.body);
    }
    catch(e) {

    }
    return json;
  }

// Get BtcUtxos
  Future getBtcUtxos(String address) async {
    var url = btcUrl + 'getutxos/' + address;
    print(url);
    var json;
    try {
      var response = await client.get(url);
      json = jsonDecode(response.body);
    } catch(e) {}
    return json;
  }

  // Post Btc Transaction
  Future postBtcTx(String txHex) async {
    var url = btcUrl + 'sendrawtransaction/' + txHex;
    var json;
    try {
      var response = await client.get(url);
      json = jsonDecode(response.body);
    } catch(e) {}
    var txHash = '';
    var errMsg = '';
    print('json=');
    print(json);
    if (json != null) {
      if (json['txid'] != null) {
        txHash = '0x' + json['txid'];
      } else if (json['Error'] != null) {
        errMsg = json['Error'];
      }
    }
    return {'txHash': txHash, 'errMsg': errMsg};
  }

// Get Fab Transaction
  Future getFabTransactionJson(String txid) async {
    txid = stringUtils.trimHexPrefix(txid);
    var url = fabUrl + 'gettransactionjson/' + txid;
    var json;
    try {
      var response = await client.get(url);
      json = jsonDecode(response.body);
    } catch(e) {}
    return json;
  }

  // Eth Post
  Future postEthTx(String txHex) async {
    var url = ethUrl + 'sendsignedtransaction';
    var data = {'signedtx': txHex};
    var errMsg = '';
    var txHash;
    try {
      var response =
      await client.post(url, headers: {"responseType": "text"}, body: data);
      txHash = response.body;

      if (txHash.indexOf('txerError') >= 0) {
        errMsg = txHash;
        txHash = '';
      }
    } catch(e) {
      errMsg = 'connection error';
    }
    return {'txHash': txHash, 'errMsg': errMsg};
  }

  // Fab Post Tx
  Future postFabTx(String txHex) async {
    var url = fabUrl + 'sendrawtransaction/' + txHex;
    var txHash = '';
    var errMsg = '';
    if (txHex != '') {
      try {
        var response = await client.get(url);
        var json = jsonDecode(response.body);
        if (json != null) {
          if ((json['txid'] != null) && (json['txid'] != '')) {
            txHash = json['txid'];
          } else if (json['Error'] != '') {
            errMsg = json['Error'];
          }
        }
      } catch(e) {
        errMsg = 'connection error';
      }
    }

    return {'txHash': txHash, 'errMsg': errMsg};
  }

// Eth Nonce
  Future getEthNonce(String address) async {
    var url = ethUrl + 'getnonce/' + address + '/latest';
    var nonce = 0;
    try {
      var response = await client.get(url);
      nonce = int.parse(response.body);
    } catch(e) {

    }
    return nonce;
  }
}
