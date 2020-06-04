import 'package:flutter/material.dart';
import 'package:workshop_digitalization/filter/filterable.dart';
import 'package:workshop_digitalization/filter/ui/filterable_field.dart';
import 'package:workshop_digitalization/table/ui/filterable_table.dart';

import '../project.dart';

final subject = ObjectField<Project, String>(
  name: "subject",
  getter: (obj) => obj.projectSubject,
);

final goal = ObjectField<Project, String>(
  name: "goal",
  getter: (obj) => obj.projectGoal,
);

final mentorName = ObjectField<Project, String>(
  name: "mentorName",
  getter: (obj) {
    final mentor = obj.mentor;
    if (mentor == null) {
      return "No mentor";
    }

    return "${mentor.firstName} ${mentor.lastName}";
  },
);

final endDate = ObjectField<Project, DateTime>(
  name: "endDate",
  getter: (obj) => obj.endDate,
);

final numberOfStudents = ObjectField<Project, int>(
  name: "numberOfStudents",
  getter: (obj) => obj.numberOfStudents,
);

final textFields = [subject, goal, mentorName];

final castedSelections = [
  createCastingFilterableField(createSelectionFilterable(numberOfStudents)),
];

Widget createFilterableProjectsTable(Stream<List<Project>> projects,
    void Function(BuildContext, Project) onClick) {
  return FilterableTable<Project>(
    objects: projects,
    textFields: textFields,
    otherFilterables: castedSelections,
    nonFilterFields: [endDate],
    onClick: (context, dynamic proj) => onClick(context, proj as Project),
  );
}
