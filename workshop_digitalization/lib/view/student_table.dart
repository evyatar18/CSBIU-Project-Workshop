import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:workshop_digitalization/blocs/bloc.dart';
import 'package:workshop_digitalization/blocs/table_bloc.dart';
import 'package:workshop_digitalization/models/data/name.dart';
import 'package:workshop_digitalization/models/data/student.dart';
import 'package:workshop_digitalization/view/forms/types/types.dart';
import 'package:workshop_digitalization/view/data_table.dart';
import 'package:workshop_digitalization/view/student_form.dart';

typedef void SearchListener(BuildContext context, String query);

class StudentTable extends StatelessWidget {
  final _StudentTableBloc _bloc = _StudentTableBloc();
  final FirebaseSchema _schema;

  StudentTable(this._schema);

  Widget _buildTable(BasicDataTableListeners listeners) {
    return StreamBuilder(
      stream: _bloc.dataStream,
      builder: (context, snapshot) {
        final data = snapshot.data;

        if (data == null) {
          return Center(
              child: SpinKitChasingDots(
                  color: Theme.of(context).accentColor, size: 80.0));
        }

        return BasicDataTable(data, listeners);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // initiate request builder with the schema and default order column
    final requestBuilder = TableDataRequestBuilder();
    requestBuilder.requestSchema = _schema;
    requestBuilder.orderColumn = _schema.paths[0];

    // request data
    _bloc.studentRequest(requestBuilder.build());

    return Container(
      margin: EdgeInsets.fromLTRB(15, 20, 10, 5),
      child: BlocProvider(
        bloc: _bloc,
        child: _InheritedTableRequestBuilder(
          requestBuilder,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _SearchBar(_onSearch),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildTable(_StudentTableListeners())),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

///
/// We use this class so that both the search feature and the table can create consistent TableDataRequests
///
class _InheritedTableRequestBuilder extends InheritedWidget {
  final TableDataRequestBuilder requestBuilder;

  _InheritedTableRequestBuilder(this.requestBuilder, {Key key, this.child})
      : super(key: key, child: child);

  final Widget child;

  static TableDataRequestBuilder of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedTableRequestBuilder>()
        .requestBuilder;
  }

  @override
  bool updateShouldNotify(_InheritedTableRequestBuilder oldWidget) {
    return true;
  }
}

class _StudentTableBloc extends FirebaseTableBloc {
  CollectionReference _col;

  _StudentTableBloc() {
    this._col = Firestore.instance.collection("students");
  }

  Future<void> studentRequest(TableDataRequest tdr) =>
      super.issueRequest(_col, tdr);
}

class _StudentTableListeners implements BasicDataTableListeners {
  @override
  List<ColumnClickListener> get columnClick => [_onColumnClick];

  @override
  List<RowClickListener> get rowClick => <RowClickListener>[_onRowClick];
}

class _SearchBar extends StatelessWidget {
  final SearchListener _listener;
  _SearchBar(this._listener);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(7))),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          hintText: 'student name (ex. plony almony)',
        ),
        onChanged:
            _listener == null ? null : (query) => _listener(context, query),
      ),
    );
  }
}

void _onColumnClick(BuildContext context, String column, bool ascending) {
  final bloc = BlocProvider.of<_StudentTableBloc>(context);
  final requestBuilder = _InheritedTableRequestBuilder.of(context);
  final schema = requestBuilder.requestSchema;

  // set parameters
  requestBuilder.descending = !ascending;
  requestBuilder.orderColumn = schema.getPath(column);

  // create and send request
  bloc.studentRequest(requestBuilder.build());
}

void _onSearch(BuildContext context, String query) {
  final requestBuilder = _InheritedTableRequestBuilder.of(context);
  final bloc = BlocProvider.of<_StudentTableBloc>(context);
  final name = valueTransformers.nameFromString(query);

  requestBuilder.filters["name.first"] =
      (field) => (field is String) && (field as String).contains(name.first);
  requestBuilder.filters["name.last"] =
      (field) => (field is String) && (field as String).contains(name.last);

  bloc.studentRequest(requestBuilder.build());
}

void _onRowClick(BuildContext context, Map<String, dynamic> clickedRow) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text("Hello")),
        body: StudentForm(student: _make(clickedRow)),
      ),
    ),
  );
}

class _Stud implements Student {
  @override
  String email;

  @override
  Name fullName;

  @override
  String id;

  @override
  DateTime lastUpdate;

  @override
  DateTime loadDate;

  @override
  String phoneNumber;

  @override
  StudentStatus status;

  @override
  int studyYear;
}

Student _make(Map<String, dynamic> map) {
  var s = _Stud();
  s.email = map["Email"];
  s.id = map["ID"];
  s.lastUpdate = (map["Last Update"] as Timestamp).toDate();
  s.loadDate = (map["Load Date"] as Timestamp).toDate();
  s.fullName = Name(first: map["First Name"], last: map["Last Name"]);
  s.phoneNumber = map["Phone"];
  s.status = StudentStatus.values[map["Status"]];
  s.studyYear = map["Year"];
  return s;
}
