import 'package:flutter/material.dart';
import 'package:workshop_digitalization/filter/filterable.dart';
import 'package:workshop_digitalization/filter/ui/filterable_field.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';

import 'filterable_table.dart';

final textFields = [
  ObjectField<Student, String>(
      name: "ID", getter: (obj) => obj.personalID, stringer: (s) => s),
  ObjectField<Student, String>(
      name: "firstName", getter: (obj) => obj.firstName, stringer: (s) => s),
  ObjectField<Student, String>(
      name: "lastName", getter: (obj) => obj.lastName, stringer: (s) => s),
  ObjectField<Student, String>(
      name: "phone", getter: (obj) => obj.phoneNumber, stringer: (s) => s),
  ObjectField<Student, String>(
      name: "email", getter: (obj) => obj.email, stringer: (s) => s),
];

final year = ObjectField<Student, int>(
    name: "year",
    getter: (obj) => obj.studyYear,
    stringer: (s) => s.toString());

final status = ObjectField<Student, StudentStatus>(
    name: "status", getter: (obj) => obj.status, stringer: (s) => s.toString());

final castedSelections = [
  createCastingFilterableField(createSelectionFilterable(year)),
  createCastingFilterableField(createSelectionFilterable(status)),
];

final otherFields = [
  ObjectField<Student, int>(
      name: "year",
      getter: (obj) => obj.studyYear,
      stringer: (s) => s.toString()),
  ObjectField<Student, StudentStatus>(
      name: "status",
      getter: (obj) => obj.status,
      stringer: (s) => s.toString()),
  // ObjectField<Student, DateTime>(
  //     name: "lastUpdate",
  //     getter: (obj) => obj.lastUpdate,
  //     stringer: (s) => s.toString()),
  // ObjectField<Student, DateTime>(
  //     name: "loadDate",
  //     getter: (obj) => obj.loadDate,
  //     stringer: (s) => s.toString()),
];

Map<String, dynamic> Function(T) makeJsoner<T>(List<ObjectField> fields) {
  return (obj) {
    final entries =
        fields.map((field) => MapEntry(field.name, field.asString(obj)));
    return Map.fromEntries(entries);
  };
}

Widget createFilterableTableScaffold3(Stream<List<Student>> students) {
  return FilterableTable(
    objects: students,
    textFields: textFields,
    otherFilterables: castedSelections,
    shownFields: [
      castedSelections[0].field.name
    ] //..addAll(otherFields.map((field) => field.name)),
    ,
    onClick: null,
  );
}
