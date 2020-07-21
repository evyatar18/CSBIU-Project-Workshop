import 'package:flamingo/document_accessor.dart';
import 'package:flamingo/flamingo.dart';

class SmartDocumentAccessor extends DocumentAccessor {
  final _documentAccessor = DocumentAccessor();

  SmartDocumentAccessor();

  static const DEL_PROP = "deleted";
  static const DEL_TIMESTAMP = "deleted-timestamp";

  bool isDeleted(Map<String, dynamic> docData) => docData[DEL_PROP] == true;

  Future delete(Document document) {
    return deleteWithReference(document.reference);
  }

  Future deleteWithReference(DocumentReference reference) async {
    try {
      final m = <String, dynamic>{}
        ..[DEL_PROP] = true
        ..[DEL_TIMESTAMP] = FieldValue.serverTimestamp();

      _documentAccessor.updateRaw(m, reference);
    } on Exception {
      rethrow;
    }
  }

  @override
  Future update(Document document) {
    try {
      final m = Map.of(document.toData())..[DEL_PROP] = false;
      return _documentAccessor.updateRaw(m, document.reference);
    } on Exception {
      rethrow;
    }
  }
}
