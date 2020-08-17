import 'package:flutter/material.dart';
import 'package:workshop_digitalization/filter/filterable.dart';
import 'package:workshop_digitalization/filter/ui/filterable_field.dart';
import 'package:workshop_digitalization/person/person.dart';
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

final status = ObjectField<Project, String>(
  name: "status",
  getter: (obj) => obj.projectStatus,
);

final textFields = [subject, goal, mentorName, status];

final castedSelections = [
  createCastingFilterableField(createSelectionFilterable(numberOfStudents)),
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

List<ObjectField<Project, String>> _personFields(
    String name, Person Function(Project) personGetter) {
  final personName = ObjectField<Project, String>(
    name: "$name-name",
    getter: (proj) {
      final person = personGetter(proj);
      if (person == null) {
        return null;
      }

      return "${person.firstName} ${person.lastName}";
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

final _projectPersonFields = [
  ..._personFields("mentor", (proj) => proj.mentor),
  ..._personFields("contact", (proj) => proj.contact),
  ..._personFields("initiator", (proj) => proj.initiator),
];

Widget createFilterableProjectsTable(Stream<List<Project>> projects,
    void Function(BuildContext, Project) onClick, String title) {
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
