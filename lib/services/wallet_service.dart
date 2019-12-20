import 'package:exchangilymobileapp/logger.dart';
import 'package:exchangilymobileapp/service_locator.dart';
import 'package:exchangilymobileapp/services/api.dart';
import 'package:exchangilymobileapp/utils/btc_util.dart';
import 'package:exchangilymobileapp/utils/fab_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:bip39/bip39.dart' as bip39;
import '../packages/bip32/bip32_base.dart' as bip32;
import 'package:hex/hex.dart';
import "package:pointycastle/pointycastle.dart";
import 'dart:convert';
import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import '../shared/globals.dart' as globals;
import '../environments/coins.dart' as coinList;
import '../utils/abi_util.dart';
import '../utils/string_util.dart' as stringUtils;
import '../utils/kanban.util.dart';
import '../utils/keypair_util.dart';
import '../utils/eth_util.dart';
import '../utils/fab_util.dart';
import '../utils/coin_util.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/wallet.dart';
import 'dart:io';
import 'dart:convert';
import 'package:bitcoin_flutter/src/models/networks.dart';
import 'package:bitcoin_flutter/src/payments/p2pkh.dart';
import 'package:bitcoin_flutter/src/transaction_builder.dart';
import 'package:bitcoin_flutter/src/transaction.dart' as btcTransaction;
import 'package:bitcoin_flutter/src/ecpair.dart';
import 'package:bitcoin_flutter/src/utils/script.dart' as script;
import '../environments/environment.dart' as environment;
import 'package:bitcoin_flutter/src/bitcoin_flutter_base.dart';
import 'package:web_socket_channel/io.dart';

class WalletService {
  final log = getLogger('Wallet Service');
  Api _api = locator<Api>();

  List<WalletInfo> _walletInfo = [];

  List<double> totalUsdBalance = [];
  String randomMnemonic = '';
  var seed;
  var sum;

  // Get Random Mnemonic
  String getRandomMnemonic() {
    randomMnemonic = bip39.generateMnemonic();
    log.w('get random method - $randomMnemonic');
    return randomMnemonic;
  }

  // Save Encrypted Data to Storage
  saveEncryptedData(String data) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/my_file.byte');
      final text = data;
      await file.writeAsString(text);
      log.w('Encrypted data saved in storage');
    } catch (e) {
      log.e("Couldn't write encrypted datra to file!! $e");
    }
  }

  // Read Encrypted Data from Storage
  readEncryptedData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/my_file.byte');
      String text = await file.readAsString();
      log.i(text);
    } catch (e) {
      log.e("Couldn't read file $e");
    }
  }

  /*--------------------------------------------------
      ||
                      Future GetAllBalances
      ||
      --------------------------------------------------*/

  generateSeedFromUser(String mnemonic) {
    seed = bip39.mnemonicToSeed(mnemonic);
    log.w(seed);
    return seed;
    // getAllBalances();
  }

  Future<List<WalletInfo>> getAllCoins() async {
    log.w('enter in getallbalances');
    log.w('wallet info length ${_walletInfo.length}');
    _walletInfo.clear();
    log.w('Cleared wallet info length ${_walletInfo.length}');
    log.w('Seed in wallet service get all balanced method $seed');
    final root = bip32.BIP32.fromSeed(seed);
    var usdVal = await _api.getCoinsUsdValue();
    try {
      List<String> listOfCoins = ['BTC', 'ETH', 'FAB', 'USDT', 'EXG'];

      for (int i = 0; i < listOfCoins.length; i++) {
        var tickerName = listOfCoins[i];
        if (tickerName == 'BTC') {
          var addr = await getAddressForCoin(root, tickerName);
          var bal = await getBalanceForCoin(root, tickerName);
          double currentUsdValue = usdVal['bitcoin']['usd'];
          log.i(
              'Current btc price in get all balances method $currentUsdValue');
          var calculatedUsdBal =
              calculateUsdBalance(currentUsdValue, bal['balance']);
          log.i(
              'printing calculated bal in get all balances method $calculatedUsdBal');
          _walletInfo.add(WalletInfo(
              tickerName: tickerName,
              address: addr,
              availableBalance: bal['balance'],
              usdValue: calculatedUsdBal,
              name: 'bitcoin',
              logoColor: Color.alphaBlend(Colors.blue, Colors.lightBlue)));
          printValuesAfter(i, tickerName);
        } else if (tickerName == 'FAB') {
          var addr = await getAddressForCoin(root, tickerName);
          var bal = await getBalanceForCoin(root, tickerName);
          _walletInfo.add(WalletInfo(
              tickerName: tickerName,
              address: addr,
              availableBalance: bal['balance'],
              name: 'fast access blockchain',
              logoColor: globals.primaryColor));
          printValuesAfter(i, tickerName);
        } else if (tickerName == 'ETH') {
          var addr = await getAddressForCoin(root, tickerName);
          var bal = await getBalanceForCoin(root, tickerName);
          _walletInfo.add(WalletInfo(
              tickerName: tickerName,
              address: addr,
              availableBalance: bal['balance'],
              name: 'ethereum',
              logoColor: globals.primaryColor));
          printValuesAfter(i, tickerName);
        } else if (tickerName == 'USDT') {
          var addr =
              await getAddressForCoin(root, tickerName, tokenType: 'ETH');
          var bal = await getBalanceForCoin(root, tickerName, tokenType: 'ETH');
          _walletInfo.add(WalletInfo(
              tickerName: tickerName,
              address: addr,
              availableBalance: bal['balance'],
              name: 'usd token',
              logoColor: globals.primaryColor));
          printValuesAfter(i, tickerName);
        } else if (tickerName == 'EXG') {
          var addr =
              await getAddressForCoin(root, tickerName, tokenType: 'FAB');
          var bal = await getBalanceForCoin(root, tickerName, tokenType: 'FAB');
          _walletInfo.add(WalletInfo(
              tickerName: tickerName,
              address: addr,
              availableBalance: bal['balance'],
              usdValue: 0.2,
              name: 'exchangily',
              logoColor: globals.primaryColor));
          printValuesAfter(i, tickerName);
        }
      }
      return _walletInfo;
    } catch (e) {
      log.e(e);
      log.i('Wallet Service Get all balances Failed');
      return null;
    }
  }

  void printValuesAfter(i, name) {
    // log.i('in $name');
    //  log.i(
    //      '${_walletInfo[i].name} address: ${_walletInfo[i].address} -Coin bal is ${_walletInfo[i].availableBalance} and usd Bal is ${_walletInfo[i].usdValue}');
  }

  calculateUsdBalance(double usdValueByApi, double actualWalletBalance) {
    actualWalletBalance = 0.005;
    if (actualWalletBalance != 0) {
      double total = (usdValueByApi * actualWalletBalance);
      totalUsdBalance.clear();
      totalUsdBalance.add(total);
      log.w(
          'calculate usd balance method ${totalUsdBalance.length}, $totalUsdBalance');
      return total;
    } else {
      log.i('Wallet Balance is Zero');
    }
  }

  calculateTotalUsdBalance() {
    sum = 0;
    if (totalUsdBalance.length != 0) {
      log.w('Total usd balance list count ${totalUsdBalance.length}');
      for (var i = 0; i < totalUsdBalance.length; i++) {
        sum = sum + totalUsdBalance[i];
      }
      log.w('Sum $sum');
      return sum;
    }
    log.w('totalUsdBalance List empty');
    return 0.0;
  }

// Add Gas
  Future<int> addGas() async {
    return 0;
  }

// Get Official Address

// Get Coin Type Id By Name

  getCoinTypeIdByName(String coinName) {
    var coins =
        coinList.coin_list.where((coin) => coin['name'] == coinName).toList();
    if (coins != null) {
      return coins[0]['id'];
    }
    return 0;
  }

// Get Original Message

  getOriginalMessage(
      int coinType, String txHash, BigInt amount, String address) {
    var buf = '';
    buf += stringUtils.fixLength(coinType.toString(), 4);
    buf += stringUtils.fixLength(txHash, 64);
    var hexString = amount.toRadixString(16);
    buf += stringUtils.fixLength(hexString, 64);
    buf += stringUtils.fixLength(address, 64);

    return buf;
  }

// Future Deposit Do

  Future depositDo(String coinName, String tokenType, double amount) async {
    var officalAddress = getOfficalAddress(coinName);
    if (officalAddress == null) {
      return -1;
    }
    var option = {};
    if (coinName == 'USDT') {
      option = {
        'tokenType': tokenType,
        'contractAddress': '0x1c35eCBc06ae6061d925A2fC2920779a1896282c'
      };
    }
    var resST = await sendTransaction(
        coinName, [0], officalAddress, amount, option, false);

    if (resST['errMsg'] != '') {
      print(resST['errMsg']);
      return -2;
    }
    if (resST['txHex'] == '' || resST['txHash'] == '') {
      print(resST['txHex']);
      print(resST['txHash']);
      return -3;
    }

    var txHex = resST['txHex'];
    var txHash = resST['txHash'];
    var amountInLink = BigInt.from(amount * 1e18);

    var coinType = getCoinTypeIdByName(coinName);

    if (coinType == 0) {
      return -4;
    }

    var keyPairKanban = getExgKeyPair(seed);
    var addressInKanban = keyPairKanban["address"];
    var originalMessage = getOriginalMessage(
        coinType,
        stringUtils.trimHexPrefix(txHash),
        amountInLink,
        stringUtils.trimHexPrefix(addressInKanban));

    var signedMess =
        await signedMessage(originalMessage, seed, coinName, tokenType);

    var coinPoolAddress = await getCoinPoolAddress();

    var abiHex = getDepositFuncABI(
        coinType, txHash, amountInLink, addressInKanban, signedMess);
    var nonce = await getNonce(addressInKanban);
    print('nonce=' + nonce.toString());
    print('signedMessage.r=' + signedMess["r"]);
    print('signedMessage.v=' + signedMess["s"]);
    print('signedMessage.s=' + signedMess["v"]);
    print('abiHex=' + abiHex);
    print(coinPoolAddress);
    print('txHash=' + txHash);
    var txKanbanHex = await signAbiHexWithPrivateKey(abiHex,
        HEX.encode(keyPairKanban["privateKey"]), coinPoolAddress, nonce);

    var res = await submitDeposit(txHex, txKanbanHex);
    return res;
  }

// Future Add Gas Do
  Future AddGasDo(double amount) async {
    var satoshisPerBytes = 14;
    var scarContractAddress = await getScarAddress();
    scarContractAddress = stringUtils.trimHexPrefix(scarContractAddress);
    print('scarContractAddress=');
    print(scarContractAddress);
    var fxnDepositCallHex = '4a58db19';
    var contractInfo =
        await getFabSmartContract(scarContractAddress, fxnDepositCallHex);

    print('contractInfo===');
    print(contractInfo['totalFee']);
    print(contractInfo['contract']);
    print('end of contractInfo');
    var res1 = await getFabTransactionHex(seed, [0], contractInfo['contract'],
        amount, contractInfo['totalFee'], satoshisPerBytes);
    var txHex = res1['txHex'];
    var errMsg = res1['errMsg'];
    var txHash = '';
    if (txHex != null && txHex != '') {
      var res = await _api.postFabTx(txHex);
      txHash = res['txHash'];
      errMsg = res['errMsg'];
    }

    return {'txHex': txHex, 'txHash': txHash, 'errMsg': errMsg};
  }

  convertLiuToFabcoin(amount) {
    return (amount * 1e-8);
  }

  isFabTransactionLocked(String txid, int idx) async {
    if (idx != 0) {
      return false;
    }
    var response = await _api.getFabTransactionJson(txid);

    if ((response['vin'] != null) && (response['vin'].length > 0)) {
      var vin = response['vin'][0];
      if (vin['coinbase'] != null) {
        if (response['onfirmations'] <= 800) {
          return true;
        }
      }
    }
    return false;
  }

  getFabTransactionHex(seed, addressIndexList, toAddress, double amount,
      double extraTransactionFee, int satoshisPerBytes) async {
    final txb = new TransactionBuilder(network: testnet);
    final root = bip32.BIP32.fromSeed(seed);
    var totalInput = 0;
    var changeAddress = '';
    var finished = false;
    var receivePrivateKeyArr = [];

    var totalAmount = amount + extraTransactionFee;
    var amountNum = totalAmount * 1e8;

    var bytesPerInput = 148;
    var feePerInput = bytesPerInput * satoshisPerBytes;

    for (var i = 0; i < addressIndexList.length; i++) {
      var index = addressIndexList[i];
      var fabCoinChild =
          root.derivePath("m/44'/1150'/0'/0/" + index.toString());
      final fromAddress = getBtcAddressForNode(fabCoinChild);
      print('from address=' + fromAddress);
      if (i == 0) {
        changeAddress = fromAddress;
      }
      final privateKey = fabCoinChild.privateKey;
      var utxos = await _api.getFabUtxos(fromAddress);
      if ((utxos != null) && (utxos.length > 0)) {
        for (var j = 0; j < utxos.length; i++) {
          var utxo = utxos[i];
          var idx = utxo['idx'];
          var txid = utxo['txid'];
          var value = utxo['value'];
          var isLocked = await isFabTransactionLocked(txid, idx);
          if (isLocked) {
            continue;
          }
          txb.addInput(txid, idx);
          receivePrivateKeyArr.add(privateKey);
          totalInput += value;

          amountNum -= value;
          amountNum += feePerInput;
          if (amountNum <= 0) {
            finished = true;
            break;
          }
        }
      }

      if (!finished) {
        print('not enough fab coin to make the transaction.');
        return {
          'txHex': '',
          'errMsg': 'not enough fab coin to make the transaction.'
        };
      }

      var transFee = (receivePrivateKeyArr.length) * feePerInput + 2 * 34 + 10;

      var output1 =
          (totalInput - amount * 1e8 - extraTransactionFee * 1e8 - transFee)
              .round();
      var output2 = (amount * 1e8).round();

      if (output1 < 0 || output2 < 0) {
        print('output1 or output2 should be greater than 0.');
        return {
          'txHex': '',
          'errMsg': 'output1 or output2 should be greater than 0.'
        };
      }

      txb.addOutput(changeAddress, output1);
      txb.addOutput(toAddress, output2);

      for (var i = 0; i < receivePrivateKeyArr.length; i++) {
        var privateKey = receivePrivateKeyArr[i];
        print('there we go');
        var alice = ECPair.fromPrivateKey(privateKey,
            compressed: true, network: testnet);
        print('alice.network=');
        print(alice.network);
        txb.sign(i, alice);
      }

      var txHex = txb.build().toHex();
      return {'txHex': txHex, 'errMsg': ''};
    }
  }

  // Send Transaction

  Future sendTransaction(String coin, List addressIndexList, String toAddress,
      double amount, options, bool doSubmit) async {
    final seed = bip39.mnemonicToSeed(bip39.generateMnemonic());
    final root = bip32.BIP32.fromSeed(seed);
    print('coin=' + coin);
    print(addressIndexList);
    print(toAddress);
    print(amount);
    var totalInput = 0;
    var finished = false;
    var gasPrice = 10.2;
    var gasLimit = 21000;
    var satoshisPerBytes = 14;
    var txHex = '';
    var txHash = '';
    var errMsg = '';

    var receivePrivateKeyArr = [];

    var tokenType = options['tokenType'] ?? '';
    var contractAddress = options['contractAddress'] ?? '';
    var changeAddress = '';
    if (coin == 'BTC') {
      var bytesPerInput = 148;
      var amountNum = amount * 1e8;
      amountNum += (2 * 34 + 10);
      final txb = new TransactionBuilder(network: testnet);
      // txb.setVersion(1);

      print('addressIndexList=');
      print(addressIndexList);
      print(addressIndexList.length);
      for (var i = 0; i < addressIndexList.length; i++) {
        var index = addressIndexList[i];
        var bitCoinChild = root.derivePath("m/44'/1'/0'/0/" + index.toString());
        final fromAddress = getBtcAddressForNode(bitCoinChild);
        if (i == 0) {
          changeAddress = fromAddress;
        }
        final privateKey = bitCoinChild.privateKey;
        var utxos = await _api.getBtcUtxos(fromAddress);
        print('utxos=');
        print(utxos);
        if ((utxos == null) || (utxos.length == 0)) {
          continue;
        }
        for (var j = 0; j < utxos.length; j++) {
          var tx = utxos[j];
          if (tx['idx'] < 0) {
            continue;
          }
          txb.addInput(tx['txid'], tx['idx']);
          print('amountNum=' + amountNum.toString());
          amountNum -= tx['value'];
          print('amountNum1=' + amountNum.toString());
          amountNum += bytesPerInput * satoshisPerBytes;
          print('amountNum2=' + amountNum.toString());
          totalInput += tx['value'];
          receivePrivateKeyArr.add(privateKey);
          if (amountNum <= 0) {
            finished = true;
            break;
          }
        }

        fixLength(String str, int length) {
          var retStr = '';
          int len = str.length;
          int len2 = length - len;
          if (len2 > 0) {
            for (int i = 0; i < len2; i++) {
              retStr += '0';
            }
          }
          retStr += str;
          return retStr;
        }

        trimHexPrefix(String str) {
          if (str.startsWith('0x')) {
            str = str.substring(2);
          }
          return str;
        }
      }

      print('finished=' + finished.toString());
      if (!finished) {
        txHex = '';
        txHash = '';
        errMsg = 'not enough fund.';
        return {'txHex': txHex, 'txHash': txHash, 'errMsg': errMsg};
      }

      var transFee =
          (receivePrivateKeyArr.length) * bytesPerInput * satoshisPerBytes +
              2 * 34 +
              10;
      var output1 = (totalInput - amount * 1e8 - transFee).round();
      var output2 = (amount * 1e8).round();
      print('111');
      txb.addOutput(changeAddress, output1);
      print('222');
      txb.addOutput(toAddress, output2);
      print('333');
      for (var i = 0; i < receivePrivateKeyArr.length; i++) {
        var privateKey = receivePrivateKeyArr[i];
        print('there we go');
        var alice = ECPair.fromPrivateKey(privateKey,
            compressed: true, network: testnet);
        print('alice.network=');
        print(alice.network);
        txb.sign(i, alice);
      }

      var tx = txb.build();
      txHex = tx.toHex();
      if (doSubmit) {
        var res = await _api.postBtcTx(txHex);
        txHash = res['txHash'];
        errMsg = res['errMsg'];
        return {'txHash': txHash, 'errMsg': errMsg};
      } else {
        txHash = '0x' + tx.getId();
      }
    }

    // ETH Transaction

    else if (coin == 'ETH') {
      // Credentials fromHex = EthPrivateKey.fromHex("c87509a[...]dc0d3");
      final ropstenChainId = 3;
      final ethCoinChild = root.derivePath("m/44'/60'/0'/0/0");
      final privateKey = HEX.encode(ethCoinChild.privateKey);
      var amountNum = (amount * 1e18).round();
      Credentials credentials = EthPrivateKey.fromHex(privateKey);

      final address = await credentials.extractAddress();
      final addressHex = address.hex;
      final nonce = await _api.getEthNonce(addressHex);

      var apiUrl =
          "https://ropsten.infura.io/v3/6c5bdfe73ef54bbab0accf87a6b4b0ef"; //Replace with your API

      var httpClient = new http.Client();
      var ethClient = new Web3Client(apiUrl, httpClient);

      print('amountNum=');
      print(amountNum);
      final signed = await ethClient.signTransaction(
          credentials,
          Transaction(
            nonce: nonce,
            to: EthereumAddress.fromHex(toAddress),
            gasPrice:
                EtherAmount.fromUnitAndValue(EtherUnit.gwei, gasPrice.round()),
            maxGas: gasLimit,
            value: EtherAmount.fromUnitAndValue(EtherUnit.wei, amountNum),
          ),
          chainId: ropstenChainId,
          fetchChainIdFromNetworkId: false);
      print('signed=');
      print(signed);
      txHex = '0x' + HEX.encode(signed);
      print(txHex);
      if (doSubmit) {
        var res = await _api.postEthTx(txHex);
        txHash = res['txHash'];
        errMsg = res['errMsg'];
      } else {
        txHash = getTransactionHash(signed);
      }
    } else if (coin == 'FAB') {
      var res1 = await getFabTransactionHex(
          seed, addressIndexList, toAddress, amount, 0, satoshisPerBytes);
      txHex = res1['txHex'];
      errMsg = res1['errMsg'];
      if ((errMsg == '') && (txHex != '')) {
        if (doSubmit) {
          var res = await _api.postFabTx(txHex);
          print('res therrrr');
          print(res);
          txHash = res['txHash'];
          errMsg = res['errMsg'];
        } else {
          var tx = btcTransaction.Transaction.fromHex(txHex);
          txHash = '0x' + tx.getId();
        }
      }
    } else if (tokenType == 'FAB') {
      var transferAbi = 'a9059cbb';
      var amountSent = (amount * 1e18).round();
      var fxnCallHex = transferAbi +
          stringUtils.fixLength(stringUtils.trimHexPrefix(toAddress), 64) +
          stringUtils.fixLength(
              stringUtils.trimHexPrefix(amountSent.toRadixString(16)), 64);
      contractAddress = stringUtils.trimHexPrefix(contractAddress);

      var contractInfo = await getFabSmartContract(contractAddress, fxnCallHex);

      var res1 = await getFabTransactionHex(
          seed,
          addressIndexList,
          contractInfo['contract'],
          0,
          contractInfo['totalFee'],
          satoshisPerBytes);
      txHex = res1['txHex'];
      errMsg = res1['errMsg'];
      if (txHex != null && txHex != '') {
        if (doSubmit) {
          var res = await _api.postFabTx(txHex);
          txHash = res['txHash'];
          errMsg = res['errMsg'];
        } else {
          var tx = btcTransaction.Transaction.fromHex(txHex);
          txHash = '0x' + tx.getId();
        }
      }
    } else if (tokenType == 'ETH') {
      final ropstenChainId = 3;
      final ethCoinChild = root.derivePath("m/44'/60'/0'/0/0");
      final privateKey = HEX.encode(ethCoinChild.privateKey);
      Credentials credentials = EthPrivateKey.fromHex(privateKey);

      final address = await credentials.extractAddress();
      final addressHex = address.hex;
      final nonce = await _api.getEthNonce(addressHex);
      gasLimit = 100000;
      var amountSent = (amount * 1e6).round();
      var transferAbi = 'a9059cbb';
      var fxnCallHex = transferAbi +
          stringUtils.fixLength(stringUtils.trimHexPrefix(toAddress), 64) +
          stringUtils.fixLength(
              stringUtils.trimHexPrefix(amountSent.toRadixString(16)), 64);
      var apiUrl =
          "https://ropsten.infura.io/v3/6c5bdfe73ef54bbab0accf87a6b4b0ef"; //Replace with your API

      var httpClient = new http.Client();
      var ethClient = new Web3Client(apiUrl, httpClient);

      final signed = await ethClient.signTransaction(
          credentials,
          Transaction(
              nonce: nonce,
              to: EthereumAddress.fromHex(contractAddress),
              gasPrice: EtherAmount.fromUnitAndValue(
                  EtherUnit.gwei, gasPrice.round()),
              maxGas: gasLimit,
              value: EtherAmount.fromUnitAndValue(EtherUnit.wei, 0),
              data: Uint8List.fromList(stringUtils.hex2Buffer(fxnCallHex))),
          chainId: ropstenChainId,
          fetchChainIdFromNetworkId: false);
      print('signed=');
      txHex = '0x' + HEX.encode(signed);

      if (doSubmit) {
        var res = await _api.postEthTx(txHex);
        txHash = res['txHash'];
        errMsg = res['errMsg'];
      } else {
        txHash = getTransactionHash(signed);
      }
    }

    return {'txHex': txHex, 'txHash': txHash, 'errMsg': errMsg};
  }

  getFabSmartContract(String contractAddress, String fxnCallHex) async {
    var gasLimit = 800000;
    var gasPrice = 40;
    var totalAmount = gasLimit * gasPrice / 1e8;
    // let cFee = 3000 / 1e8 // fee for the transaction

    var totalFee = totalAmount;
    var chunks = new List<dynamic>();
    chunks.add(84);
    chunks.add(Uint8List.fromList(stringUtils.number2Buffer(gasLimit)));
    chunks.add(Uint8List.fromList(stringUtils.number2Buffer(gasPrice)));
    chunks.add(Uint8List.fromList(stringUtils.hex2Buffer(fxnCallHex)));
    chunks.add(Uint8List.fromList(stringUtils.hex2Buffer(contractAddress)));
    chunks.add(194);

    print('chunks=');
    print(chunks);
    var contract = script.compile(chunks);
    print('contract=');
    print(contract);
    var contractSize = contract.toString().length;

    totalFee += convertLiuToFabcoin(contractSize * 10);

    var res = {'contract': contract, 'totalFee': totalFee};
    return res;
  }
}
