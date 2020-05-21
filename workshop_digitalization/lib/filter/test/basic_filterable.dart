import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:workshop_digitalization/filter/filterable.dart';
import 'package:workshop_digitalization/filter/ui/filterable_field.dart';
import 'package:workshop_digitalization/filter/ui/filters.dart';
import 'package:workshop_digitalization/global/strings.dart';
import 'package:workshop_digitalization/table/basic_table_data_controller.dart';
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

Widget createFilterableTableScaffold() {
  final controller = createController();
  final filtersKey = UniqueKey();
  final scaffold = FiltersScaffold(
    key: filtersKey,
    filterable: controller,
    fields: [
      createCastingFilterableField(createTextFilterable(objectTitleField)),
      createCastingFilterableField(createSelectionFilterable(objectYearField))
    ],
  );

  return Builder(builder: (context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => scaffold),
              );
            },
          )
        ],
      ),
      body: UpdatingTable(controller: controller),
    );
  });
}
