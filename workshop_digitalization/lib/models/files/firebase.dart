import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:workshop_digitalization/models/files/transfer.dart';
import 'package:workshop_digitalization/models/files/utils.dart';
import 'package:workshop_digitalization/models/list_modifier.dart';

import 'container.dart';

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

    final download = downloadFirebaseFile(
            fileRef: FirebaseStorage.instance.ref().child(path),
            downloadPath: "${Directory.systemTemp.path}/$path",
            fileName: fileName)
        .asBroadcastStream();

    // save file snapshot if it was succcessful (local caching)
    download.listen((snapshot) => _downloaded =
        snapshot.status == FileTransferStatus.SUCCESS ? snapshot : null);

    return download;
  }
}

class FBFileContainer implements FileContainer {
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

  void _onFirebaseUpdate(QuerySnapshot event) {
    final newList = event.documents
        // get only existent documents
        .where((doc) => doc.exists && doc.data != null)

        // create List<FBFileInfo> from those documents
        .map((doc) => doc.data)
        .map((data) => _FBFileInfo.of(data))
        .toList();

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
    var uploaderStream = convertUploaderStream(task.events).asBroadcastStream();

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
    final fInfo = _listHolder.where((info) => info.path == file.path).first;

    if (fInfo == null) {
      return;
    }

    // delete documents metadata in firestore
    var docs = await metadataCollection
        .where(_fpathField, isEqualTo: file.path)
        .getDocuments();
    for (var doc in docs.documents) {
      try {
        await doc.reference.delete();
      } catch (e) {
        print("exception while deleting document" +
            "${doc.reference.documentID}: $e");
      }
    }

    // delete document on storage
    try {
      await FirebaseStorage.instance.ref().child(fInfo.path).delete();
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> dispose() async {
    _metadataSubscription.cancel();
  }
}
