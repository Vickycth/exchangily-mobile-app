/*
* Copyright (c) 2020 Exchangily LLC
*
* Licensed under Apache License v2.0
* You may obtain a copy of the License at
*
*      https://www.apache.org/licenses/LICENSE-2.0
*
*----------------------------------------------------------------------
* Author: barry-ruprai@exchangily.com
*----------------------------------------------------------------------
*/

import 'package:exchangilymobileapp/screen_state/market/MarketPairsTabViewState.dart';
import 'package:exchangilymobileapp/screen_state/nav/MainNavState.dart';
import 'package:exchangilymobileapp/screen_state/otc/otc_screen_state.dart';
import 'package:exchangilymobileapp/screen_state/otc_campaign/campaign_dashboard_screen_state.dart';
import 'package:exchangilymobileapp/screen_state/otc_campaign/campaign_single_state.dart';
import 'package:exchangilymobileapp/screen_state/otc_campaign/instructions_screen_state.dart';
import 'package:exchangilymobileapp/screen_state/otc_campaign/payment_screen_state.dart';
import 'package:exchangilymobileapp/screen_state/otc_campaign/login_screen_state.dart';
import 'package:exchangilymobileapp/screen_state/otc_campaign/register_account_screen_state.dart';
import 'package:exchangilymobileapp/screen_state/settings/language_screen_state.dart';
import 'package:exchangilymobileapp/screen_state/wallet/wallet_features/move_to_wallet_screen_state.dart';
import 'package:exchangilymobileapp/screen_state/wallet/wallet_features/transaction_history_screen_state.dart';
import 'package:exchangilymobileapp/screen_state/wallet/wallet_setup/choose_wallet_language_screen_state.dart';
import 'package:exchangilymobileapp/screen_state/wallet/wallet_setup/confirm_mnemonic_screen_state.dart';
import 'package:exchangilymobileapp/screen_state/settings/settings_screen_state.dart';
import 'package:exchangilymobileapp/screen_state/wallet/wallet_features/wallet_features_screen_state.dart';
import 'package:exchangilymobileapp/screen_state/wallet/wallet_setup/wallet_setup_screen_state.dart';
import 'package:exchangilymobileapp/screens/exchange/markets/markets_viewmodel.dart';
import 'package:exchangilymobileapp/screens/exchange/trade/trade_viewmodel.dart';
import 'package:exchangilymobileapp/screens/trade/place_order/buy_sell_screen_state.dart';
import 'package:exchangilymobileapp/screens/trade/place_order/order_list_screen_state.dart';
import 'package:exchangilymobileapp/services/api_service.dart';
import 'package:exchangilymobileapp/services/db/campaign_user_database_service.dart';
import 'package:exchangilymobileapp/services/db/transaction_history_database_service.dart';
import 'package:exchangilymobileapp/services/db/wallet_database_service.dart';
import 'package:exchangilymobileapp/services/dialog_service.dart';
import 'package:exchangilymobileapp/services/navigation_service.dart';
import 'package:exchangilymobileapp/services/pdf_viewer_service.dart';
import 'package:exchangilymobileapp/services/shared_service.dart';
import 'package:exchangilymobileapp/services/trade_service.dart';
import 'package:exchangilymobileapp/services/vault_service.dart';
import 'package:exchangilymobileapp/services/wallet_service.dart';
import 'package:exchangilymobileapp/services/campaign_service.dart';
import 'package:exchangilymobileapp/screen_state/wallet/wallet_setup/create_password_screen_state.dart';
import 'package:exchangilymobileapp/screen_state/wallet/wallet_features/send_screen_state.dart';
import 'package:exchangilymobileapp/screen_state/wallet/wallet_features/move_to_exchange_screen_state.dart';
import 'package:exchangilymobileapp/screen_state/wallet/wallet_dashboard_screen_state.dart';
import 'package:get_it/get_it.dart';
import 'package:exchangilymobileapp/screen_state/otc/otc_details_screen_state.dart';
import 'package:exchangilymobileapp/services/local_storage_service.dart';
import 'package:exchangilymobileapp/screen_state/otc_campaign/team_reward_details_screen_state.dart';

GetIt locator = GetIt();

Future serviceLocator() async {
  // singleton returns the old instance
  locator.registerLazySingleton(() => WalletService());
  locator.registerLazySingleton(() => VaultService());
  locator.registerLazySingleton(() => ApiService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => WalletDataBaseService());
  locator.registerLazySingleton(() => SharedService());
  locator.registerLazySingleton(() => TradeService());
  locator.registerLazySingleton(() => TransactionHistoryDatabaseService());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => CampaignService());
  locator.registerLazySingleton(() => CampaignUserDatabaseService());
  locator.registerLazySingleton(() => PdfViewerService());

  // Singelton
  var instance = await LocalStorageService.getInstance();
  locator.registerSingleton<LocalStorageService>(instance);

  // factory returns the new instance
  locator.registerFactory(() => ConfirmMnemonicScreenState());
  locator.registerFactory(() => CreatePasswordScreenState());
  locator.registerFactory(() => WalletDashboardScreenState());
  locator.registerFactory(() => WalletFeaturesScreenState());
  locator.registerFactory(() => SendScreenState());
  locator.registerFactory(() => SettingsScreenState());
  locator.registerFactory(() => LanguageScreenState());
  locator.registerFactory(() => WalletSetupScreenState());
  locator.registerFactory(() => ChooseWalletLanguageScreenState());
  locator.registerFactory(() => BuySellScreenState());
  locator.registerFactory(() => TransactionHistoryScreenState());
  locator.registerFactory(() => OtcScreenState());
  locator.registerFactory(() => OtcDetailsScreenState());
  locator.registerFactory(() => OrderListScreenState());
  locator.registerFactory(() => MoveToExchangeScreenState());
  locator.registerFactory(() => MoveToWalletScreenState());
  locator.registerFactory(() => CampaignInstructionsScreenState());
  locator.registerFactory(() => CampaignPaymentScreenState());
  locator.registerFactory(() => CampaignDashboardScreenState());
  locator.registerFactory(() => CampaignLoginScreenState());
  locator.registerFactory(() => CampaignRegisterAccountScreenState());
  locator.registerFactory(() => TeamRewardDetailsScreenState());
  locator.registerFactory(() => MarketsViewModel());
  locator.registerFactory(() => TradeViewModel());
  locator.registerFactory(() => MainNavState());
  locator.registerFactory(() => MarketPairsTabViewState());
  locator.registerFactory(() => CampaignSingleScreenState());
}
