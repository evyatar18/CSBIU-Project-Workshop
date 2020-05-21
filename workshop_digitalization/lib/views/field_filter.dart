// Widget createFieldFilter(String fieldName, List<String> types) {
//   return Column(
//     children: <Widget>[
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           Text(fieldName),
//           Row(
//             children: <Widget>[
//               DropdownButton(
//                 items: types
//                     .map((type) => DropdownMenuItem(
//                           child: Text(type),
//                           value: type,
//                         ))
//                     .toList(),
//                 onChanged: print,
//                 value: types[0],
//               ),
//               IconButton(
//                 icon: Icon(Icons.delete),
//                 onPressed: () => print("deleted of $fieldName"),
//               ),
//             ],
//           )
//         ],
//       ),
//       TextField()
//     ],
//   );
// }

// typedef bool Filter(dynamic filterValue, dynamic element);
// typedef void FilterListener(dynamic value);

// ///
// /// Represents a specific filter. For example a filter of 'startsWith'.
// ///
// abstract class FieldFilterDescription {
//   String get filterName;
//   Filter get filter;

//   dynamic get defaultValue;

//   Widget buildFilterWidget({@required FilterListener onFilter});
// }

// ///
// /// Represents the backend interface with which the FieldFilter communicates when there's a change filtering.
// ///
// ///
// abstract class FilterChangeListener {
//   ///
//   /// Called when this filter is deleted
//   ///
//   void filterDeleted([Key key]);

//   ///
//   /// Called when `filter` was used with the value `value`
//   ///
//   void filter(Filter filter, dynamic value);
// }

// class FieldFilter extends StatefulWidget {
//   final String fieldName;
//   final List<FieldFilterDescription> filterDescriptions;
//   final FilterChangeListener fieldChangeListener;

//   const FieldFilter(
//       {Key key,
//       this.fieldName,
//       this.filterDescriptions,
//       this.fieldChangeListener})
//       : super(key: key);

//   @override
//   _FieldFilterState createState() => _FieldFilterState();
// }

// class _FieldFilterState extends State<FieldFilter> {
//   FieldFilterDescription _currentFilter;
//   dynamic _currentFilterInput;

//   @override
//   void initState() {
//     super.initState();

//     // default value
//     _currentFilter = widget.filterDescriptions[0];
//   }

//   void _onChange(void Function() change) {
//     setState(() {
//       change();
//       widget.fieldChangeListener
//           .filter(_currentFilter.filter, _currentFilterInput);
//     });
//   }

//   void _onFilterInput(dynamic input) {
//     _onChange(() => _currentFilterInput = input);
//   }

//   void _onFilterTypeChanged(FieldFilterDescription desc) {
//     _onChange(() {
//       _currentFilter = desc;
//       _currentFilterInput = desc.defaultValue;
//     });
//   }

//   DropdownMenuItem<FieldFilterDescription> _buildDropdownFilter(
//       FieldFilterDescription description) {
//     return DropdownMenuItem<FieldFilterDescription>(
//       child: Padding(
//         // uses golden ratio (1.6180327868852)
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         child: Text(description.filterName),
//       ),
//       value: description,
//     );
//   }

//   DropdownButton _buildFilterChoiceButton() {
//     return DropdownButton<FieldFilterDescription>(
//       items: widget.filterDescriptions.map(_buildDropdownFilter).toList(),

//       // when filter type changed
//       onChanged: _onFilterTypeChanged,
//       value: _currentFilter,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: <Widget>[
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: <Widget>[
//             Text(widget.fieldName),
//             Row(
//               children: <Widget>[
//                 _buildFilterChoiceButton(),
//                 IconButton(
//                   icon: Icon(Icons.delete),
//                   onPressed: () =>
//                       widget.fieldChangeListener.filterDeleted(widget.key),
//                 ),
//               ],
//             )
//           ],
//         ),
//         _currentFilter.buildFilterWidget(onFilter: _onFilterInput)
//       ],
//     );
//   }
// }