import 'dart:async';

import 'package:flamingo/document.dart';
import 'package:flamingo/flamingo.dart';
import 'package:workshop_digitalization/models/jsonable.dart';
import 'package:workshop_digitalization/models/student.dart';

import 'bloc.dart';

typedef bool DocumentFilter(dynamic value);

class FirebaseTableBloc implements Bloc {
  final _controller = StreamController<List<Jsonable>>();

  Stream<List<Jsonable>> get dataStream => _controller.stream;

  Future<void> issueRequest() async {
    final path = Document.path<FirebaseStudent>();
    final snapshot = await firestoreInstance().collection(path).getDocuments();

    // from snapshot
    var jsonables = snapshot.documents.map((item) => FirebaseStudent(snapshot: item)).toList();

    _controller.sink.add(jsonables);
    
  }

  @override
  void dispose() {
    _controller.close();
  }
}

