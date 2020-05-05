import 'package:flutter/material.dart';
import '../progress.dart';

class LinearProgressBar extends StatelessWidget {
  final ProgressSnapshot snapshot;

  LinearProgressBar({@required this.snapshot});

  /// Builds the task status bar
  Widget _statusBar(TextStyle baseFont, int percents) {
    return Align(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(snapshot.taskName, style: baseFont.apply(fontSizeDelta: 2)),
          Text("$percents%", style: baseFont.apply(fontSizeDelta: 1)),
        ],
      ),
      alignment: Alignment.bottomLeft,
    );
  }

  /// Builds the actual widget (without padding/margin)
  Widget _buildLinearBar() {
    final color = snapshot.failed
        ? Colors.red
        : (snapshot.progress >= 1.0 ? Colors.green : Colors.orange[500]);

    final percents = (snapshot.progress * 100).toInt();

    return Builder(builder: (context) {
      final baseFont = Theme.of(context).textTheme.body1;

      return Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox(
                height: 20,
                child: LinearProgressIndicator(
                  value: snapshot.progress,
                  backgroundColor: Colors.grey[400],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                child: _statusBar(baseFont, percents),
              )
            ],
          ),
          SizedBox(height: 5),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              snapshot.message,
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .apply(fontSizeDelta: 1, fontWeightDelta: 2),
            ),
          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: _buildLinearBar(),
    );
  }
}
