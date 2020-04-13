import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workshop_digitalization/utils/utils.dart';
import 'package:workshop_digitalization/view/table.dart';
import 'package:workshop_digitalization/utils/extensions.dart';

import 'bloc.dart';

class FirebaseTableBloc implements Bloc {
  final _controller = StreamController<BasicDataTableData>();

  Stream<BasicDataTableData> get dataStream => _controller.stream;

  // void listen(CollectionReference ref, FirebaseSchema schema) {

  //   var subscription = ref
  //       .orderBy(schema.paths[0], descending: false)
  //       .snapshots().listen()

  //       subscription.listen(onData)
  //       .forEach((snapshot) async {
  //         // signal that there is data being parsed right now
  //         _controller.sink.add(null);

  //         final tableData = List<Map<String, dynamic>>();

  //         for (var doc in snapshot.documents) {
  //           if (doc.data == null) {
  //             continue;
  //           }

  //           tableData.add(flattenMap(doc.data).map((path, value) => MapEntry(schema.getName(path), value)));
  //         }

  //         _controller.sink.add(BasicDataTableData(schema.names, schema.getName(schema.paths[0]), true, tableData));
  //       })  ;
  // }

  Future<void> issueRequest(
      CollectionReference ref, TableDataRequest requestData) async {

    // get ordered collection
    final result = await ref
        .orderBy(requestData.orderColumn, descending: requestData.descending)
        .getDocuments();

    // we choose to filter in client since there is no native search option inside firebase
    // also using startsWith on multiple fields is impossible without generating an appropriate index
    bool _documentFilter(Map<String, dynamic> documentData) =>
        requestData.filters.entries
            .every((filter) => filter.value(documentData[filter.key]));

    final data = result.documents
        // first flatten the fields map (all sub-maps are converted to a field with '.')
        .map((ds) => flattenMap(ds.data))
        // filter documents
        .where(_documentFilter)
        // put display names
        .map(requestData.requestSchema.fromPathToDisplayName)
        // finally convert into list
        .toList(growable: false);

    _controller.add(BasicDataTableData(
      requestData.requestSchema.names,
      requestData.requestSchema.getName(requestData.orderColumn),
      requestData.ascending,
      data,
    ));
  }

  @override
  void dispose() {
    _controller.close();
  }
}

class FirebaseSchema {
  final Map<String, String> _pathToName;
  Map<String, String> _nameToPath;

  List<String> _paths;
  List<String> _names;

  FirebaseSchema(this._pathToName) {
    _nameToPath = _pathToName.inverse();

    _paths = List.from(_pathToName.keys);
    _names = List.from(_pathToName.values);
  }

  List<String> get paths => _paths;
  List<String> get names => _names;

  String getName(path) => _pathToName[path];

  String getPath(name) => _nameToPath[name];

  ///
  /// Converts a map which uses paths as keys to a map which uses
  /// the chosen names as keys
  ///
  Map<String, dynamic> fromPathToDisplayName(Map<String, dynamic> pathedMap) =>
      _pathToName
          .map((path, displayName) => MapEntry(displayName, pathedMap[path]));

}

typedef bool DocumentFilter(dynamic value);

class TableDataRequest {
  final FirebaseSchema requestSchema;
  final String orderColumn;
  final bool descending;
  final Map<String, DocumentFilter> filters;

  ///
  /// requestSchema includes the fields which are to be displayed, and what their display names should be.
  /// orderColumn is a column in the requestSchema which the returned results will be ordered by.
  /// filters are a mapping between a document field path (for example the field a.b) to what values the field should have.
  /// descending is whether the sort order is descending.
  ///
  TableDataRequest(this.requestSchema, this.orderColumn, this.filters,
      {this.descending = false});

  bool get ascending => !descending;
}

class TableDataRequestBuilder {
  FirebaseSchema requestSchema;
  String orderColumn;
  bool descending = false;
  Map<String, DocumentFilter> filters = {};

  TableDataRequest build() =>
      TableDataRequest(requestSchema, orderColumn, filters,
          descending: descending);
}
