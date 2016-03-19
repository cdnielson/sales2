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
  String get pathToLoginData => "data/users.json";
  String get logoPath => "images/lbrook.jpg";
  String get pathToImages => "images/";
  String get pathToThumbnails => "images/";
  List<Ring> orderList = [];
  List<Ring> tierData = [];
  List<User> loginData = [];
  bool openLoading = true;
  bool hideLogIn = false;
  User currentUser;
  bool hideMenus = false;
  String barcodedata = "";
  String barcodeFieldData = "";
  String searchData = "";
  List<Ring> ringsDisplayed;
  int subTotal = 0;
  bool addATierOpened = false;
  bool addAComboOpened = false;
  bool guaranteed = false;


  //buttons
  bool hideSubmitButton = false;
  bool hideOtherButtons = true;
  bool hideCloseSignatureButton = true;
  bool hideSaveButton = true;
  bool hideLoadButton = false;
  bool hideButtons = true;




  ngAfterViewInit() {
    // viewChild is set
  }


  MainApp(Logger this.log) {
    log.info("$runtimeType()");

    HttpRequest.getString(pathToRingsData).then(ringsLoaded);
    HttpRequest.getString(pathToLoginData).then(setLogins);
  }

  void ringsLoaded(data) {
    var mapList = JSON.decode(data);
    tierData = mapList.map((Map element) => new Ring.fromMap(element)).toList();
    for (var t in tierData) {
      t.cleared = !t.cleared;
      t.added = "Add";
      t.icon = "add";
    }
    ringsDisplayed = tierData;
    openLoading = false;
    // TODO figure this out
    // Timer.run(barcodeinput.nativeElement.focus());
  }

  void setLogins(data) {
    print("test");
    var mapList = JSON.decode(data);
    loginData = mapList((Map element) => new User.fromMap(element)).toList();
  }

  void searchForBarcode(String data) {
    print(data);
    barcodedata = data;
    int ring = int.parse(data);
    addRing(ring);
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
  }

  void openAddATier() {
    addATierOpened = true;
  }

  void openAddACombo() {
    addAComboOpened = true;
  }

  void addTier(int tier) {
    orderList.removeWhere((Ring element) => element.tier == 1 || element.tier == 2 || element.tier == 3 || element.tier == 4);
    guaranteed = false;

    List<Ring> tierList;
    switch (tier) {
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

    for (Ring ring in tierList) {
      orderList.add(ring);
    }
    calculateOrderTotal();
    addATierOpened = false;
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
  }

  handlePin(pin) {
    print(pin);
    for (User user in loginData) {
      if(pin == user.pin) {
        currentUser = user;
        login();
      }
    }
  }
}





