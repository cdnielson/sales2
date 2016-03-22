import 'package:angular2/angular2.dart';
import 'package:logging/logging.dart';
import 'package:polymer_elements/iron_flex_layout/classes/iron_flex_layout.dart';
import 'package:polymer_elements/iron_icons.dart';
import 'package:polymer_elements/paper_menu.dart';
import 'package:polymer_elements/paper_dropdown_menu.dart';
import 'package:polymer_elements/paper_item.dart';
import 'package:polymer_elements/paper_button.dart';
import 'package:polymer_elements/paper_header_panel.dart';
import 'package:polymer_elements/paper_toolbar.dart';
import 'package:polymer_elements/paper_icon_button.dart';
import 'package:polymer_elements/paper_dialog.dart';
import 'package:polymer_elements/paper_dialog_scrollable.dart';

// TODO remove
//import '../../model/ttt_board.dart';
//import '../board_view/board_view.dart';
//import '../message_bar/message_bar.dart';
// undo remove

import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../../model/rings.dart';
import '../../model/swatches.dart';
import '../../model/users.dart';
import '../../model/combos.dart';
import '../../model/clients.dart';

// TODO not working
/*import 'package:lawndart/lawndart.dart';
import '../../utils/filters.dart' show StringToInt;*/

@Component(selector: 'main-app',
    encapsulation: ViewEncapsulation.Native,
    templateUrl: 'main_app.html'
)
class MainApp {
  final Logger log;
  @ViewChild("barcodeinput") var barcodeInput;
  String get pathToRingsData => "data/rings.json";
  String get pathToRingsDataPhp => "data/tiers.php";
  String get pathToLoginData => "data/users.json";
  String get pathToPhpAdd => "data/salesadd.php";
  String get logoPath => "images/lbrook.jpg";
  String get pathToImages => "images/";
  String get pathToThumbnails => "images/";
  List<Ring> orderList = [];
  List<Ring> tierData = [];
  List<User> loginData = [];
  bool openLoading = true;

  User currentUser;
  bool hideMenus = false;
  String barcodedata = "";
  String barcodeFieldData = "";
  String searchData = "";
  List<Ring> ringsDisplayed = [];
  int subTotal = 0;
  bool addATierOpened = false;
  bool addAComboOpened = false;
  bool guaranteed = false;
  int tier = 0;


  //buttons
  bool hideSubmitButton = false;
  bool hideOtherButtons = true;
  bool hideCloseSignatureButton = true;
  bool hideSaveButton = true;
  bool hideLoadButton = false;
  bool hideButtons = true;

  String order_name = "";
  String store_name = "";
  String last_name = "";
  String first_name = "";
  String address = "";
  String city = "";
  String state = "";
  String zip = "";
  String phone = "";
  String email = "";
  String terms = "";
  String notes = "";

  List removedFromTier = [];
  List added = [];
  List accessories = [];
  List typedSkus = [];
  List stockBalances = [];
  String orderID = "";

  String customSku = "";
  String customFinish = "";
  String customPrice = "";
  String customNote = "";

  bool hideLogIn = false;
  bool hideMain = true;
  bool hideOrder = false;
  bool hideReview = true;
  bool showSignature = false;
  bool openCustomSku = false;
  bool openStockBalances = false;

  Ring lastScanned;

  bool hideBarcodeLastScanned = true;

  DateTime date = new DateTime.now();

  String lastScannedImage = "";

  ngAfterViewInit() {
    // viewChild is set
  }

  overlayOpened() {
    barcodeInput.nativeElement.focus();
  }

  MainApp(Logger this.log) {
    log.info("$runtimeType()");

    HttpRequest.getString(pathToRingsData).then(ringsLoaded);
    HttpRequest.getString(pathToLoginData).then(setLogins);
  }

  void ringsLoaded(data) {
    List<Map> mapList = JSON.decode(data);
    tierData = mapList.map((Map element) => new Ring.fromMap(element)).toList();
    print("here");
    log.info(tierData);
    /*for (var t in tierData) {
      t.cleared = !t.cleared;
      t.added = "Add";
      t.icon = "add";
    }*/
    ringsDisplayed = tierData;
    log.info(ringsDisplayed);
    openLoading = false;
    // TODO figure this out
    // Timer.run(barcodeinput.nativeElement.focus());
  }

  void setLogins(data) {

    List<Map> mapList = JSON.decode(data);

    loginData = mapList.map((Map element) => new User.fromMap(element)).toList();
    log.info(loginData);

  }

  void searchForBarcode() {
    int ring = int.parse(barcodeFieldData);
    addRing(ring);
    lastScanned = tierData.where((Ring element) => element.id == int.parse(barcodeFieldData)).first;
    lastScannedImage = pathToImages + "rings/thumbnails/" + lastScanned.image;
    hideBarcodeLastScanned = false;
    barcodeFieldData = "";
  }

  void addRing(ring) {
    Ring currentRing = tierData.where((Ring element) => element.id == ring).first;
    if (orderList.contains(currentRing)) {
      orderList.remove(currentRing);
    } else {
      orderList.add(currentRing);
    }
    log.info(orderList);
    calculateOrderTotal();
    hideBarcodeLastScanned = true;
  }

  void filterSearchData(data) {
    String upData = data.toUpperCase();
    ringsDisplayed = tierData.where((Ring element) => element.id.toString().toUpperCase().contains(upData) || element.SKU.toUpperCase().contains(upData) || element.finish.toUpperCase().contains(upData)).toList();
  }

  void calculateOrderTotal() {
    subTotal = 0;
    for(Ring ring in orderList) {
      subTotal += ring.price;
    }
    if(guaranteed) {
      subTotal += 844;
    }

    // add the custom SKUs prices
    int price = 0;
    for (Map item in typedSkus) {
      price += int.parse(item["price"]);
    }
    subTotal += price;

    // add the SB prices
    price = 0;
    for (Map item in stockBalances) {
      price += int.parse(item["price"]);
    }
    subTotal += price;
  }

  void openAddATier() {
    addATierOpened = true;
  }

  void openAddACombo() {
    addAComboOpened = true;
  }

  void addTier(int tierSelected) {
    orderList.removeWhere((Ring element) => element.tier == 1 || element.tier == 2 || element.tier == 3 || element.tier == 4);
    guaranteed = false;
    tier = tierSelected;

    List<Ring> tierList = getTier(tier);

    for (Ring ring in tierList) {
      orderList.add(ring);
    }
    calculateOrderTotal();
    addATierOpened = false;
  }

  List<Ring> getTier(tier) {
    List<Ring> tierList;
    switch (tier) {
      case 0: tierList = [];
      break;
      case 1: tierList = tierData.where((Ring element) => element.tier == 1).toList();
      break;
      case 2: tierList = tierData.where((Ring element) => element.tier == 1 || element.tier == 2).toList();
      break;
      case 3: tierList = tierData.where((Ring element) => element.tier == 1 || element.tier == 2 || element.tier == 3).toList();
      break;
      case 4: tierList = tierData.where((Ring element) => element.tier == 1 || element.tier == 2 || element.tier == 3 || element.tier == 4).toList();
      guaranteed = false;
      break;
      case 5: tierList = tierData.where((Ring element) => element.tier == 1 || element.tier == 2 || element.tier == 3 || element.tier == 4).toList();
      guaranteed = true;
      break;
    }
    return tierList;
  }

  void addCombo(String combo) {

    List<Ring> comboList = tierData.where((Ring element) => element.combo == combo).toList();
    List<Ring> comboList2 = tierData.where((Ring element) => element.combo2 == combo).toList();
    for (Ring ring in comboList) {
      orderList.add(ring);
    }
    for (Ring ring in comboList2) {
      orderList.add(ring);
    }
    calculateOrderTotal();
    addAComboOpened = false;
  }

  login() {
    hideLogIn = true;
    hideMain = false;
  }

  handlePin(pin) {
    for (User user in loginData) {
      if(pin == user.pin) {
        currentUser = user;
        login();
      }
    }
  }

  submitOrder() {
    if (orderList.isNotEmpty) {
      hideOrder = true;
      hideReview = false;
      setUpOrderToSend();
    } else {
      // TODO create a message
    }
  }

  setUpOrderToSend() {

    for (Ring r in orderList) {
      print("Test");
      if (r.tier == 22) {
        accessories.add({
          "SKU" : r.SKU,
          "finish" : r.finish,
          "price" : r.price,
          "notes" : r.notes
        });
      }

      if (r.tier != 22) {
        added.add({
          "SKU" : r.SKU,
          "finish" : r.finish,
          "price" : r.price,
          "notes" : r.notes
        });
      }
    }
    List<Ring> tierList = getTier(tier);
    for (Ring r in tierList) {
      Ring missing = checkIfMissing(r);
      if (missing != null) {
        removedFromTier.add({
          "SKU" : missing.SKU,
          "finish" : missing.finish,
          "price" : missing.price
        });
      }
    }

    log.info("accessories $accessories");
    log.info("added $added");
    log.info("removed from tier $removedFromTier");
  }

  Ring checkIfMissing(ring) {
    for (Ring r in orderList) {
      if (r.SKU == ring.SKU && r.finish == ring.finish) {
        return null;
      }
    }
    return ring;
  }

  void saveOrderToPhp() {
    bool completed = true;
    Map customerInfo;
    Map orderData;
    String dateadd;

    customerInfo = {
      "client_idx" : "none",
      "checked" : "new",
      "storeName" : store_name,
      "lastName" : last_name,
      "firstName" : first_name,
      "address" : address,
      "city" : city,
      "state" : state,
      "zip" : zip,
      "phone" : phone,
      "email" : email
    };
    orderData = {
      "terms" : terms,
      "notes" : notes
    };

    dateadd = date.toString();

    Map customDisplay = {};
    //print("Last Name that will be uploaded is:" + customerInfo["lastName"]);
    /*if (customDisplayAdded == true) {
      customDisplay = {
        "top" : topSwatch,
        "side" : sideSwatch,
        "acrylic" : acrylic
      };
    }*/

    var data =
    {
      "completed" : completed,
      "date" : dateadd,
      "customer_info" : customerInfo,
      "order_data" : orderData,
      "order_name" : order_name,
      "tier" : tier,
      "rings_removed" : removedFromTier,
      "rings_added" : added,
      "accessories" : accessories,
      "customrings" : typedSkus,
      "stockbalances" : stockBalances,
      "rep" : currentUser.username,
      "new" : 1,
      "display" : customDisplay
    };

    var datasend = JSON.encode(data);

    HttpRequest.request(pathToPhpAdd, method: 'POST', mimeType: 'application/json', sendData: datasend).catchError((obj) {
      //print(obj);
    }).then((HttpRequest val) {
      //print('The response that gets the ID is: ${val.responseText}');
      print(val.responseText);
      orderID = JSON.decode(val.responseText);
      showSignature = true;
      hideMain = true;
    }, onError: (e) => print("error"));
  }
  openAddACustomSku() {
    openCustomSku = true;
  }

  handleCustomSkuForm() {
    typedSkus.add({
      "SKU": customSku,
      "finish": customFinish,
      "price": customPrice,
      "notes": customNote
    });

    customSku = "";
    customFinish = "";
    customPrice = "";
    customNote = "";
    openCustomSku = false;
    calculateOrderTotal();
  }

  openAddAStockBalance() {
    openStockBalances = true;
  }

  handleStockBalanceForm(price) {
    int sbId = stockBalances.length + 1;
    stockBalances.add({
      'id' : sbId,
      'price' : price
    });
    openStockBalances = false;
    calculateOrderTotal();
  }

  killSb(id) {
    stockBalances.removeWhere((Map element) => element['id'] == id);
    calculateOrderTotal();
  }

  killCustom(sku, finish) {
    typedSkus.removeWhere((Map element) => element['SKU'] == sku && element['finish'] == finish);
    calculateOrderTotal();
  }

  changeView() {

  }
}





