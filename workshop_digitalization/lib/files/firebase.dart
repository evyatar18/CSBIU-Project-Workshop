import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:workshop_digitalization/global/list_modifier.dart';
import 'package:workshop_digitalization/global/smart_doc_accessor.dart';

import 'container.dart';
import 'firebase_utils.dart';
import 'transfer.dart';
import 'file_utils.dart';

// These fields specify the firebase property names of a `FileInfo` instance
final _fnameField = "name";
final _fsizeField = "size";
final _ftypeField = "type";
final _fpathField = "path";

class _FBFileInfo implements FileInfo {
  @override
  final String fileName;

  @override
  final int fileSize;

  @override
  final String fileType;

  @override
  final String path;

  _FBFileInfo(this.fileName, this.fileSize, this.fileType, this.path);

  factory _FBFileInfo.of(Map<String, dynamic> map) => _FBFileInfo(
      map[_fnameField] ?? "no name",
      map[_fsizeField] ?? -1,
      map[_ftypeField] ?? "no type",
      map[_fpathField] ?? "no path");

  Map<String, dynamic> toData() {
    return <String, dynamic>{
      _fnameField: fileName,
      _fsizeField: fileSize,
      _ftypeField: fileType,
      _fpathField: path
    };
  }

  FileRetrievalSnapshot _downloaded;

  @override
  Stream<FileRetrievalSnapshot> getFile() {
    // check if file exists in local cache
    if (_downloaded != null) {
      return Stream.value(_downloaded);
    }

    try {
      // create file
      final file = createFileSync("${Directory.systemTemp.path}/$path");

      // download
      final download = downloadFirebaseFile(
              fileRef: FirebaseStorage.instance.ref().child(path),
              localFile: file,
              fileName: fileName)
          .asBroadcastStream();

      // save file snapshot if it was succcessful (local caching for _FBInfo object lifetime)
      download.listen((snapshot) => _downloaded =
          snapshot.status == FileTransferStatus.SUCCESS ? snapshot : null);

      return download;
    } on FileCreationException catch (e) {
      return Stream.value(FileRetrievalSnapshot.error(e.message));
    }
  }
}

class FBFileContainer implements FileContainer {
  final _docAccessor = SmartDocumentAccessor();

  final _listHolder = ListModifierHandler<_FBFileInfo>();
  final CollectionReference metadataCollection;
  StreamSubscription _metadataSubscription;

  FBFileContainer(this.metadataCollection) {
    // TODO:: maybe take snapshot stream from global static collection
    metadataCollection.snapshots().listen(_onFirebaseUpdate);
  }

  @override
  List<FileInfo> get latestFiles => _listHolder.latestItems;

  @override
  Stream<List<FileInfo>> get files => _listHolder.items;

  bool _loadedOnce = false;

  @override
  bool get isLoaded => _loadedOnce;

  void _onFirebaseUpdate(QuerySnapshot event) {
    _loadedOnce = true;

    final newList = event.documents
        // get only existent documents
        .where((doc) => doc.exists && !_docAccessor.isDeleted(doc.data))

        // create List<FBFileInfo> from those documents
        .map((doc) => doc.data)
        .map((data) => _FBFileInfo.of(data))
        .toList();

    // this makes sure that when one file is updated, we create new _FBFileInfo instances
    // so there shouldn't be issues with the local caching in _FBFileInfo
    _listHolder.setItems(newList);
  }

  @override
  Stream<FileUploadSnapshot> addFile(File f, {String name, String type}) {
    if (name == null) {
      name = getFilenameFromPath(f.path);
    }

    if (type == null) {
      type = getTypeFromPath(f.path);
    }

    var firebasePath = "${metadataCollection.path}/$name";

    var task = FirebaseStorage.instance.ref().child(firebasePath).putFile(f);

    // convert to this project's upload type
    var uploaderStream = convertUploaderStream(name, task.events).asBroadcastStream();

    // add file metadata to firestore when upload successful
    uploaderStream.listen((snapshot) async {
      if (snapshot.status == FileTransferStatus.SUCCESS) {
        await metadataCollection.add(
            _FBFileInfo(name, await f.length(), type, firebasePath).toData());
      }
    });

    return uploaderStream;
  }

  @override
  Future<void> removeFile(FileInfo file) async {
    // if there are no file info instances with matching path, then ignore this call
    if (!_listHolder.latestItems.any((info) => info.path == file.path)) {
      return;
    }

    // delete documents metadata on firestore
    var docs = await metadataCollection
        .where(_fpathField, isEqualTo: file.path)
        .getDocuments();
    for (var doc in docs.documents) {
      try {
        // await doc.reference.delete();
        await _docAccessor.deleteWithReference(doc.reference);
      } catch (e) {
        print("exception while deleting document" +
            "${doc.reference.documentID}: $e");
      }
    }

    // delete document on storage
    // try {
    //   await FirebaseStorage.instance.ref().child(file.path).delete();
    // } catch (e) {
    //   print(e);
    // }
  }

  @override
  Future<void> dispose() async {
    if (_metadataSubscription != null)
      _metadataSubscription.cancel();
  }
}
