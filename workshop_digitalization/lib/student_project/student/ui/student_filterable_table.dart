import 'package:flutter/material.dart';
import 'package:workshop_digitalization/filter/filterable.dart';
import 'package:workshop_digitalization/filter/ui/filterable_field.dart';
import 'package:workshop_digitalization/global/strings.dart';
import 'package:workshop_digitalization/table/ui/filterable_table.dart';

import '../student.dart';

final textFields = [
  ObjectField<Student, String>(name: "Id", getter: (obj) => obj.personalID),
  ObjectField<Student, String>(
      name: "firstName", getter: (obj) => obj.firstName),
  ObjectField<Student, String>(name: "lastName", getter: (obj) => obj.lastName),
  ObjectField<Student, String>(name: "phone", getter: (obj) => obj.phoneNumber),
  ObjectField<Student, String>(name: "email", getter: (obj) => obj.email),
];

final year = ObjectField<Student, int>(
  name: "year",
  getter: (obj) => obj.studyYear,
);

final status = ObjectField<Student, StudentStatus>(
    name: "status", getter: (obj) => obj.status, stringer: (stat) => capitalize(studentStatusText(stat)));

final lastUpdate = ObjectField<Student, DateTime>(
  name: "lastUpdate",
  getter: (obj) => obj.lastUpdate,
  stringer: writeDate
);

final loadDate = ObjectField<Student, DateTime>(
  name: "loadDate",
  getter: (obj) => obj.loadDate,
  stringer: writeDate
);

final castedSelections = [
  createCastingFilterableField(createSelectionFilterable(year)),
  createCastingFilterableField(createSelectionFilterable(status)),
];

Widget createFilterableStudentsTable(Stream<List<Student>> students,
    void Function(BuildContext, Student) onClick) {
  return FilterableTable<Student>(
    objects: students,
    textFields: textFields,
    otherFilterables: castedSelections,
    nonFilterFields: [lastUpdate, loadDate],
    shownFields: [castedSelections[0].field.name],
    onClick: (context, dynamic stud) => onClick(context, stud as Student),
  );
}
