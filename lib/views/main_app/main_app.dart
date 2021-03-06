import 'package:angular2/angular2.dart';
import 'package:logging/logging.dart';
import 'package:polymer_elements/iron_flex_layout/classes/iron_flex_layout.dart';
import 'package:polymer_elements/iron_icons.dart';
import 'package:polymer_elements/iron_form.dart';
import 'package:polymer_elements/paper_icon_button.dart';
//import 'package:polymer_elements/paper_menu.dart';
//import 'package:polymer_elements/paper_dropdown_menu.dart';
import 'package:polymer_elements/paper_listbox.dart';
import 'package:polymer_elements/paper_item.dart';
import 'package:polymer_elements/paper_tab.dart';
import 'package:polymer_elements/paper_tabs.dart';
import 'package:polymer_elements/paper_button.dart';
import 'package:polymer_elements/paper_header_panel.dart';
import 'package:polymer_elements/paper_toolbar.dart';
import 'package:polymer_elements/paper_icon_button.dart';
import 'package:polymer_elements/paper_dialog.dart';
import 'package:polymer_elements/paper_input.dart';
import 'package:polymer_elements/paper_checkbox.dart';
import 'package:polymer_elements/paper_dialog_scrollable.dart';
import '../../views/ring_view/ring_view.dart';

import 'dart:html';
import 'dart:convert';
import 'dart:async';

import '../../model/rings.dart';
import '../../model/swatches.dart';
import '../../model/users.dart';
import '../../model/combos.dart';
import '../../model/clients.dart';
import '../../model/orders.dart';

//import 'package:polymer/polymer.dart';
import 'package:intl/intl.dart';

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
  @ViewChild("pininput") var pinInput;
  @ViewChild("thepage") var thePage;
  @ViewChild("listOfOrders") var listOfOrders;
  String get pathToRingsData => "data/rings.json";
  String get pathToRingsDataPhp => "data/tiers.php";
  String get pathToPartnerData => "data/getClient.php";
  String get pathToLoginData => "data/users.json";
  String get pathToPhpAdd => "data/salesadd.php";
  String get pathToLoadOrders => "data/getOrderList.php";
  String get pathToLoadOrder => "data/getOrderIdx.php";
  String get logoPath => "images/lbrook.jpg";
  String get pathToImages => "images/";
  String get pathToThumbnails => "images/";
  String get pathToSignature => "signature/";
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
  bool openChangeView = false;
  String pin = "";

  Ring lastScanned;

  bool hideBarcodeLastScanned = true;


  DateTime now = new DateTime.now();
  String date;
  String lastScannedImage = "";

/*  @reflectable
  bool fireIronResize = false;*/

  List<List<Ring>> paginationList = [[]];
  int currentPage = 0;
  bool hideExistingPartners = true;
  bool hidePartnerSearch = false;
  String partnerSearchData = "";
  List<Client> allPartners = [];
  List<Client> partners = [];

  List<Order> orderNames = [];
  bool hideChooseOrder = true;

  String orderSelected = "";
  bool hideImages = true;
  List<Order> orders = [];

  String customerSearchData = "";

  ngAfterViewInit() {
    // viewChild is set


    // TODO add search icon to search for partners
    // TODO order name not loading with order load
    // TODO change shadow color of added rings to red
  }

  MainApp(Logger this.log) {
    log.info("$runtimeType()");

    HttpRequest.getString(pathToRingsData).then(ringsLoaded);
    HttpRequest.getString(pathToLoginData).then(setLogins);
    HttpRequest.getString(pathToPartnerData).then(setPartners);
    DateFormat dateFormatter = new DateFormat("yyyy-MM-dd");
    date = dateFormatter.format(now);

  }

  void ringsLoaded(data) {
    List<Map> mapList = JSON.decode(data);
    tierData = mapList.map((Map element) => new Ring.fromMap(element)).toList();
    ringsDisplayed = tierData;
    //print(ringsDisplayed);
    setUpPagination();
    pinInput.nativeElement.focus();

    openLoading = false;
  }

  void setUpPagination() {
    currentPage = 0;
    paginationList = [[]];

    int ringListLength = ringsDisplayed.length;
    int numberOfLists = int.parse(((ringListLength / 20) - .5).toStringAsFixed(0));
    if (numberOfLists <= 1) {
      paginationList.add(ringsDisplayed);
      paginationList.removeWhere((List element) => element.isEmpty);
      return;
    }
    int start = 0;
    int end = 19;
    int ringsInListMinusRemainder = numberOfLists * 20;
    if (ringListLength - (ringsInListMinusRemainder) > 0) {
      numberOfLists += 1;
    }


    for (int n = 0; n < numberOfLists ; n++) {
      List<Ring> theList = [];
      for (int i = start; i <= end ; i++) {
        theList.add(ringsDisplayed[i]);
      }
      paginationList.add(theList);

      if (end <= ringsInListMinusRemainder - 20) {
        start += 20;
        end += 20;
      } else {
        start = ringsInListMinusRemainder;
        end = ringListLength -1;
      }
    }

    paginationList.removeWhere((List element) => element.isEmpty);

  }

  void setLogins(data) {
    List<Map> mapList = JSON.decode(data);
    loginData = mapList.map((Map element) => new User.fromMap(element)).toList();
  }

  void setPartners(data) {
    List<Map> mapList = JSON.decode(data);
    allPartners = mapList.map((Map element) => new Client.fromMap(element)).toList();
//    print(allPartners);
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

    // TODO if it doesn't find anything don't cause an error
    String upData = data.toUpperCase();
    ringsDisplayed = tierData.where((Ring element) => element.id.toString().toUpperCase().contains(upData) || element.SKU.toUpperCase().contains(upData) || element.finish.toUpperCase().contains(upData)).toList();
    setUpPagination();
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
      price -= int.parse(item["price"]);
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
//    fireIronResize = true;
    // TODO not working. Figure it out.
    barcodeInput.nativeElement.focus();
  }

  handlePin() {
    for (User user in loginData) {
      if(pin == user.pin) {
        currentUser = user;
        login();
      }
    }
    if(pin.length == 4) {
      pin = "";
    }
  }

  handleLoginButton(String data) {
    pin = pin + data;
    handlePin();
  }

  submitOrder() {
    if (orderList.isNotEmpty) {
      hideOrder = true;
      hideReview = false;
      hideSubmitButton = true;
      setUpOrderToSend();
    } else {
      // TODO create a message
    }
  }

  setUpOrderToSend() {

    for (Ring r in orderList) {

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
    String checked;
    if (hidePartnerSearch) {
      checked = "new";
    } else {
      checked = "existing";
    }

    customerInfo = {
      "client_idx" : "none",
      "checked" : checked,
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
      "date" : date,
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
      showSignature = true;
      hideMain = true;
      orderID = JSON.decode(val.responseText).toString();
    }, onError: (e) => print("error"));
  }
  openAddACustomSku() {
    openCustomSku = true;
  }

  handleCustomSkuForm() {

    typedSkus.add({
      "SKU": customSku,
      "finish": customFinish,
      "price": customPrice
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
    openChangeView = true;
  }

  handleChangeView(item) {
    ringsDisplayed = [];
    switch(item) {
      case "all": ringsDisplayed = tierData; break;
      case "tier1": ringsDisplayed = tierData.where((Ring element) => element.tier == 1).toList(); break;
      case "tier2": ringsDisplayed = tierData.where((Ring element) => element.tier == 1 || element.tier == 2).toList(); break;
      case "tier3": ringsDisplayed = tierData.where((Ring element) => element.tier == 1 || element.tier == 2 || element.tier == 3).toList(); break;
      case "tier4": ringsDisplayed = tierData.where((Ring element) => element.tier == 1 || element.tier == 2 || element.tier == 3 || element.tier == 4).toList(); break;
      /*case "other": ringsDisplayed = tierData.where((Ring element) =>
        element.category[0] == "Fable" ||
        element.category[0] == "Ceramic" ||
        element.category[0] == "Stainless Steel" ||
        element.category[0] == "MossyOak" ||
        element.category[0] == "Fable Camo" ||
        element.category[0] == "Goodyear" ||
        element.category[0] == "King's Camo"
      ); break;*/
      default: ringsDisplayed.addAll(addRingToDisplay(item));
    }

    setUpPagination();
    openChangeView = false;
  }

  List addRingToDisplay(categoryToAdd) {
    List<Ring> toAdd = [];
    for (Ring ring in tierData) {
      for (String category in ring.category) {
        if (category == categoryToAdd) {
          toAdd.add(ring);
        }
      }
    }

    return toAdd;
  }

  changePage(direction) {
    if (direction == "prev") {
      if (currentPage > 0) {
        currentPage -= 1;
      }
    }
    if  (direction == "next") {
      if (currentPage < paginationList.length - 1) {
        currentPage += 1;
      }
    }
    thePage.nativeElement.selected = currentPage;
  }

  goToPage(page) {
    currentPage = page;
  }

  findPartners() {
    partners = allPartners.where((Client element) => element.store_name.contains(partnerSearchData)).toList();
    hideExistingPartners = false;
  }

  showHideExistingPartner() {
    hidePartnerSearch = !hidePartnerSearch;
  }

  partnerSelected(idx) {
    hideExistingPartners = false;
    Client currentPartner = allPartners.where((Client element) => element.client_idx == idx).first;
    store_name = currentPartner.store_name;
    last_name = currentPartner.last_name;
    first_name = currentPartner.first_name;
    address = currentPartner.address;
    city = currentPartner.city;
    state = currentPartner.state;
    zip = currentPartner.zip;
    phone = currentPartner.phone;
    email = currentPartner.email;
  }

  loadFromPHP() {
    HttpRequest.getString(pathToLoadOrders).then(orderLoaded);
  }

  orderLoaded(data) {

    List<Map> mapList = JSON.decode(data);
    orderNames = mapList.map((Map element) => new Order.fromMap(element)).toList();
    print(orderNames);
    // TODO can probably simplify this
//    orderNames.sort((Order a, Order b) => a.id.compareTo(b.id));
    orderNames.sort((Order a, Order b) {
      if (int.parse(a.id) < int.parse(b.id)) {
        return 1;
      }
      else if (int.parse(a.id) > int.parse(b.id)) {
        return -1;
      }
      return 0;
    });
    orders = orderNames;
    hideChooseOrder = false;
  }

  chooseOrder(id) {
    orderSelected = id;
  }

  loadOrder() {
    var data = JSON.encode(orderSelected);
    HttpRequest.request(pathToLoadOrder, method: 'POST', mimeType: 'application/json', sendData: data).catchError((obj) {
      //print(obj);
    }).then((HttpRequest val) {
      //print('response: ${val.responseText}');
      var order = JSON.decode(val.responseText);
      print(order);
      if (order['customer'].isEmpty && order['master'].isEmpty && order['removed'].isEmpty && order['added'].isEmpty && order['accessories'].isEmpty && order['custom'].isEmpty && order['stockbalances'].isEmpty && order['orderdata'].isEmpty) {
        print("no order");
        return;
      }

      fillTheOrder(order);
      hideLoadButton = true;
      hideChooseOrder = true;
    }, onError: (e) => print("error"));

  }

  fillTheOrder(order) {
//    order_id = order['master'][0]['order_idx'];
//    client_id = order['master'][0]['client_idx'];

    store_name = order['customer'][0]['storeName'];
    last_name = order['customer'][0]['lastName'];
    first_name = order['customer'][0]['firstName'];
    address = order['customer'][0]['address'];
    city = order['customer'][0]['city'];
    state = order['customer'][0]['state'];
    zip = order['customer'][0]['zip'];
    phone = order['customer'][0]['phone'];
    email = order['customer'][0]['email'];
    orderID = order['master'][0]['order_idx'];
    tier = order['master'][0]['tier'];
    for (var ring in order['added']) {
      orderList.add(tierData.where((Ring element) => element.SKU == ring['SKU'] && element.finish == ring['finish']).first);
    }
    for (var ring in order['accessories']) {
      orderList.add(tierData.where((Ring element) => element.SKU == ring['SKU'] && element.finish == ring['finish']).first);
    }
    for (var ring in order['custom']) {
      typedSkus.add({
        "SKU": ring['sku'],
        "finish": ring['finish'],
        "price": ring['price']
      });
    }
    for (var ring in order['stockbalances']) {
      stockBalances.add({
        "id": ring['id'],
        "price": ring['price']
      });
    }
    terms = order['orderdata'][0]['terms'];
    notes = order['orderdata'][0]['notes'];
    calculateOrderTotal();
  }

  cancelLoadOrder() {
    hideChooseOrder = true;
  }

  cancelSubmit() {
    hideSubmitButton = false;
    hideReview = true;
    hideOrder = false;
  }



  filterCustomer() {
    // TODO put order names into class
    orders = orderNames.where((Order element) => element.name.contains(customerSearchData)).toList();
  }
}





