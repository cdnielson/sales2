// Copyright (c) 2016, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/core.dart';
import 'dart:html';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'model/rings.dart';
//import 'model/swatches.dart';
import 'model/users.dart';
//import 'model/combos.dart';
import 'model/clients.dart';
import 'model/orders.dart';


@Component(selector: 'my-app', templateUrl: 'app_component.html')
class AppComponent {

  //  final Logger log;
  @ViewChild("barcodeinput") var barcodeInput;
  @ViewChild("pininput") var pinInput;
  @ViewChild("thepage") var thePage;
  @ViewChild("listOfOrders") var listOfOrders;
//  String get pathToRingsData => "data/rings.json";
  String get pathToRingsData => "data/tiers.php";
  String get pathToPartnerData => "data/getClient.php";
  String get pathToLoginData => "data/users.json";
  String get pathToPhpAdd => "data/salesadd.php";
  String get pathToLoadOrders => "data/getOrderList.php";
  String get pathToLoadOrder => "data/getOrderIdx.php";
  String get logoPath => "images/lbrook.jpg";
  String get pathToImages => "images/";
  String get pathToThumbnails => "images/";
  String get pathToSignature => "signature/";
  String get search => "images/search.png";
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
  String tier = "0";


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

  String myString = "";

  void myFunction() {
    String myString = "";
    print(myString);
    print(this.myString);
  }

  ngAfterViewInit() {
    // viewChild is set
    // TODO loading order is making something null
  }

  AppComponent() {
//    log.info("$runtimeType()");

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
    lastScanned = tierData.firstWhere((Ring element) => element.id == int.parse(barcodeFieldData), orElse: () => null);
    if (lastScanned != null) {
      lastScannedImage = pathToImages + "rings/thumbnails/" + lastScanned.image;
      hideBarcodeLastScanned = false;
    }
    barcodeFieldData = "";
  }

  void addRing(ring) {
    Ring currentRing = tierData.firstWhere((Ring element) => element.id == ring, orElse: () => null);
    if (currentRing == null) {
      return;
    }
    if (orderList.contains(currentRing)) {
      orderList.remove(currentRing);
      currentRing.added = "none";
    } else {
      orderList.add(currentRing);
      currentRing.added = "1px solid red";
    }
//    log.info(orderList);
    calculateOrderTotal();
    hideBarcodeLastScanned = true;
    hideLoadButton = true;
  }

  void filterSearchData(data) {

    // TODO if it doesn't find anything don't cause an error
    String upData = data.toUpperCase();
    try {
      ringsDisplayed = tierData.where((Ring element) => element.id.toString().toUpperCase().contains(upData) || element.SKU.toUpperCase().contains(upData) || element.finish.toUpperCase().contains(upData)).toList();
      setUpPagination();
    } catch(exception, stackTrace) {
      print(exception);
      print(stackTrace);
    }
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

  void addTier(String tierSelected) {
    if (tierSelected == 'cancel') {
      addATierOpened = false;
      return;
    }
    orderList.removeWhere((Ring element) => element.tier == 1 || element.tier == 2 || element.tier == 3 || element.tier == 4);
    guaranteed = false;
    tier = tierSelected;

    List<Ring> tierList = getTier(tier);

    for (Ring ring in tierList) {
      orderList.add(ring);
      ring.added = "1px solid red";
      hideLoadButton = true;
    }
    calculateOrderTotal();
    addATierOpened = false;
  }

  List<Ring> getTier(tier) {
    List<Ring> tierList;
    switch (tier) {
      case '0': tierList = [];
      break;
      case '1': tierList = tierData.where((Ring element) => element.tier == 1).toList();
      break;
      case '2': tierList = tierData.where((Ring element) => element.tier == 1 || element.tier == 2).toList();
      break;
      case '3': tierList = tierData.where((Ring element) => element.tier == 1 || element.tier == 2 || element.tier == 3).toList();
      break;
      case '4': tierList = tierData.where((Ring element) => element.tier == 1 || element.tier == 2 || element.tier == 3 || element.tier == 4).toList();
      guaranteed = false;
      break;
      case '5': tierList = tierData.where((Ring element) => element.tier == 1 || element.tier == 2 || element.tier == 3 || element.tier == 4).toList();
      guaranteed = true;
      break;
    }
    return tierList;
  }

  void addCombo(String combo) {
    if(combo == "cancel") {
      addAComboOpened = false;
      return;
    }
    if(combo == "core_collection") {
      orderList.add(tierData.where((Ring element) => element.SKU == "CORE_COLLECTION").first);
    }


    List<Ring> comboList = tierData.where((Ring element) => element.combo == combo).toList();
    List<Ring> comboList2 = tierData.where((Ring element) => element.combo2 == combo).toList();
    List<Ring> comboList3 = tierData.where((Ring element) => element.combo3 == combo).toList();
    List<Ring> comboList4 = tierData.where((Ring element) => element.combo4 == combo).toList();
    List<Ring> comboList5 = tierData.where((Ring element) => element.combo5 == combo).toList();
    List<Ring> comboList6 = tierData.where((Ring element) => element.combo6 == combo).toList();
    for (Ring ring in comboList) {
      orderList.add(ring);
      ring.added = "1px solid red";
      hideLoadButton = true;
    }
    for (Ring ring in comboList2) {
      orderList.add(ring);
      ring.added = "1px solid red";
      hideLoadButton = true;
    }
    for (Ring ring in comboList3) {
      orderList.add(ring);
      ring.added = "1px solid red";
      hideLoadButton = true;
    }
    for (Ring ring in comboList4) {
      orderList.add(ring);
      ring.added = "1px solid red";
      hideLoadButton = true;
    }
    for (Ring ring in comboList5) {
      orderList.add(ring);
      ring.added = "1px solid red";
      hideLoadButton = true;
    }
    for (Ring ring in comboList6) {
      orderList.add(ring);
      ring.added = "1px solid red";
      hideLoadButton = true;
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
    print(data);
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
    print(orderList);

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
    print("tierList $tierList");
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
    print("here!!");

//    log.info("accessories $accessories");
//    log.info("added $added");
//    log.info("removed from tier $removedFromTier");
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

    // TODO input custom displays
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
    }).then((val) {
      print(val.responseText);
      showSignature = true;
      hideMain = true;
      orderID = JSON.decode(val.responseText).toString();
    }, onError: (e) => print("error"));
  }

  openAddACustomSku() {
    openCustomSku = true;
  }

  handleCustomSkuForm(method) {
    if (method == "cancel") {
      openCustomSku = false;
      return;
    }
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
    if (price == "cancel") {
      openStockBalances = false;
      return;
    }
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
      case "accessories": ringsDisplayed = tierData.where((Ring element) => element.tier == 22).toList(); break;
      case "tier1": ringsDisplayed = tierData.where((Ring element) => element.tier == 1).toList(); break;
      case "tier2": ringsDisplayed = tierData.where((Ring element) => element.tier == 1 || element.tier == 2).toList(); break;
      case "tier3": ringsDisplayed = tierData.where((Ring element) => element.tier == 1 || element.tier == 2 || element.tier == 3).toList(); break;
      case "tier4": ringsDisplayed = tierData.where((Ring element) => element.tier == 1 || element.tier == 2 || element.tier == 3 || element.tier == 4).toList(); break;
      case "core": ringsDisplayed = tierData.where((Ring element) => element.SKU == "CORE_COLLECTION" || element.SKU == "core_collection_discount").toList(); break;
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
    for(var p in partners) {
      p.selected = "none";
    }
    currentPartner.selected = "lightblue";
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
    order_name = order['master'][0]['order_name'];
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
    store_name = checkForNull(store_name);
    last_name = checkForNull(last_name);
    first_name = checkForNull(first_name);
    address = checkForNull(address);
    city = checkForNull(city);
    state = checkForNull(state);
    zip = checkForNull(zip);
    phone = checkForNull(phone);
    email = checkForNull(email);
    orderID = checkForNull(orderID);

    order_name = checkForNull(order_name);
    terms = checkForNull(terms);
    notes = checkForNull(notes);
    print(order_name);
    if (tier == null) {
      tier = "0";
    }
  }

  String checkForNull(data) {
    if (data == null) {
      return "";
    } else {
      return data;
    }
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
