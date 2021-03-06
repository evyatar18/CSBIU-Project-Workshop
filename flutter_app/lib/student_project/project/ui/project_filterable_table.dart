import 'package:flutter/material.dart';
import 'package:workshop_digitalization/filter/filterable.dart';
import 'package:workshop_digitalization/filter/ui/filterable_field.dart';
import 'package:workshop_digitalization/person/person.dart';
import 'package:workshop_digitalization/table/ui/filterable_table.dart';

import '../project.dart';

List<ObjectField<Project, String>> _personFields(
    String name, Person Function(Project) personGetter) {
  final personName = ObjectField<Project, String>(
    name: "$name-name",
    getter: (proj) {
      final person = personGetter(proj);
      if (person == null) {
        return null;
      }

      return "${person.firstName ?? ""} ${person.lastName ?? ""}";
    },
  );

  final personEmail = ObjectField<Project, String>(
    name: "$name-email",
    getter: (proj) => personGetter(proj)?.email,
  );

  final personPhone = ObjectField<Project, String>(
    name: "$name-phone",
    getter: (proj) => personGetter(proj)?.phoneNumber,
  );

  return [personName, personEmail, personPhone];
}

final subject = ObjectField<Project, String>(
  name: "subject",
  getter: (obj) => obj.projectSubject,
);

final goal = ObjectField<Project, String>(
  name: "goal",
  getter: (obj) => obj.projectGoal,
);

final endDate = ObjectField<Project, DateTime>(
  name: "endDate",
  getter: (obj) => obj.endDate,
);

final numberOfStudents = ObjectField<Project, int>(
  name: "numberOfStudents",
  getter: (obj) => obj.numberOfStudents,
);

final status = ObjectField<Project, String>(
  name: "status",
  getter: (obj) => obj.projectStatus,
);

final textFields = [
  subject, goal,
  // allow searching only for mentor
  ..._personFields("mentor", (proj) => proj.mentor),
];

final castedSelections = [
  createCastingFilterableField(createSelectionFilterable(numberOfStudents)),
  createCastingFilterableField(createSelectionFilterable(status)),
];

final domain = ObjectField<Project, String>(
  name: "domain",
  getter: (obj) => obj.projectDomain,
);

final challenges = ObjectField<Project, String>(
  name: "challenges",
  getter: (obj) => obj.projectChallenges?.join("; "),
);

final mentorTechAbility = ObjectField<Project, String>(
  name: "mentorTechAbility",
  getter: (obj) => obj.mentorTechAbility,
);

final _projectPersonFields = [
  ..._personFields("contact", (proj) => proj.contact),
  ..._personFields("initiator", (proj) => proj.initiator),
];

Widget createFilterableProjectsTable(Stream<List<Project>> projects,
    void Function(BuildContext, Project) onClick, String title) {
  // create filterable table with all the fields of projects that can be filterd
  return FilterableTable<Project>(
    title: title,
    objects: projects,
    textFields: textFields,
    otherFilterables: castedSelections,
    nonFilterFields: [
      endDate,
      domain,
      challenges,
      mentorTechAbility,
      ..._projectPersonFields
    ],
    onClick: (context, dynamic proj) => onClick(context, proj as Project),
  );
}
