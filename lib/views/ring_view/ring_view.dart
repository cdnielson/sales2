@HtmlImport('ring_view.html')
library sales2.views.ring_view;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';
import 'package:polymer_elements/iron_list.dart';
import 'package:polymer_elements/iron_icons.dart';
import 'package:polymer_elements/iron_icon.dart';
import '../../model/rings.dart';

@PolymerRegister('ring-view')
class RingView extends PolymerElement {

//  @property List data;
  @Property(observer: 'dataChanged') List ringData;

  RingView.created() : super.created();

  void ready() {
    print(ringData);
  }

  void dataChanged(List newData, List oldData) {
    print(newData);
  }

  /*@reflectable
  void submit(Event event, var detail) {
    fire("ring-clicked", detail: data);
  }*/
}
