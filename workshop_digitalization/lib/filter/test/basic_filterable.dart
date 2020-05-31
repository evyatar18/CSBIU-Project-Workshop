import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:workshop_digitalization/filter/filterable.dart';
import 'package:workshop_digitalization/filter/ui/filterable_field.dart';
import 'package:workshop_digitalization/filter/ui/filters_scaffold.dart';
import 'package:workshop_digitalization/global/strings.dart';
import 'package:workshop_digitalization/table/basic_table_data_controller.dart';
import 'package:workshop_digitalization/table/ui/filterable_table.dart';
import 'package:workshop_digitalization/table/ui/updating_table.dart';

class MyObject {
  String title;
  int year;
}

final objectTitleField = ObjectField<MyObject, String>(
    name: "title", getter: (obj) => obj.title, stringer: (s) => s);

final objectYearField = ObjectField<MyObject, int>(
    name: "year", getter: (obj) => obj.year, stringer: (i) => i.toString());

final fields = [objectTitleField, objectYearField];

Map<String, dynamic> Function(T) makeJsoner<T>(List<ObjectField> fields) {
  return (obj) {
    final entries =
        fields.map((field) => MapEntry(field.name, field.asString(obj)));
    return Map.fromEntries(entries);
  };
}

Stream<List<MyObject>> myObjectsStream() async* {
  final items = List.generate(100, (index) {
    int year = index ~/ 3;
    String title = randomString(10);

    return MyObject()
      ..title = title
      ..year = year;
  });

  print(items.map((e) => e.year).toList());

  while (true) {
    await Future.delayed(Duration(seconds: 5));

    // print(items.map((e) => "title: ${e.title}, year: ${e.year}").join(", "));

    yield items;
  }
}

BasicTableDataController createController() {
  return BasicTableDataController(
    supplier: ValueConnectableStream(myObjectsStream())..connect(),
    jsoner: makeJsoner(fields),
  );
}

void moveToFilters(BuildContext context, Filterable controller,
    Map<int, FilterWidgetCreator> filterWidgets) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => FiltersScaffold(
        filterable: controller,
        fields: [
          createCastingFilterableField(createTextFilterable(objectTitleField)),
          createCastingFilterableField(
              createSelectionFilterable(objectYearField)),
        ],
        filterWidgets: filterWidgets,
      ),
    ),
  );
}

Widget createFilterableTableScaffold() {
  final controller = createController();
  final filterWidgets = <int, FilterWidgetCreator>{};

  return Builder(builder: (context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => moveToFilters(context, controller, filterWidgets),
          )
        ],
      ),
      body: UpdatingTable(controller: controller),
    );
  });
}

Widget createFilterableTableScaffold2() {
  return FilterableTable(
    objects: myObjectsStream(),
    textFields: [objectTitleField],
    otherFilterables: [
      createCastingFilterableField(createSelectionFilterable(objectYearField))
    ],
    shownFields: [objectYearField.name],
    onClick: (context, obj) => print("${obj.title}, ${obj.year}"),
  );
}
