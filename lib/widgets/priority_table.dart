import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color unitedBlue = Color(0xFF005DAA);

class PriorityTable extends StatelessWidget {
  final Map<String, Map<String, String>> priorityDetails;
  final Map<String, List<dynamic>> standbyPassengers;
  final String currentEmployeeId;
  final void Function(String priority) showPriorityInfo;

  const PriorityTable({
    super.key,
    required this.priorityDetails,
    required this.standbyPassengers,
    required this.currentEmployeeId,
    required this.showPriorityInfo,
  });
  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    bool softWrap = false,
    Color? textColor,
    Widget? leading,
    VoidCallback? onTap,
  }) {
    final style = GoogleFonts.inter(
      fontSize: isHeader ? 12 : 14,
      fontWeight: isBold || isHeader ? FontWeight.bold : FontWeight.normal,
      color: textColor ?? Colors.black,
    );
    Widget content = leading != null
        ? Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              leading,
              const SizedBox(width: 4),
              Text(
                text,
                style: style,
                softWrap: softWrap,
                maxLines: softWrap ? null : 1,
                overflow: softWrap ? TextOverflow.clip : TextOverflow.ellipsis,
              ),
            ],
          )
        : Text(
            text,
            style: style,
            softWrap: softWrap,
            maxLines: softWrap ? null : 1,
            overflow: softWrap ? TextOverflow.clip : TextOverflow.ellipsis,
          );
    if (onTap != null) {
      content = GestureDetector(onTap: onTap, child: content);
    }
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(8),
      child: content,
    );
  }

  TableRow _buildPredictedRow({
    required int position,
    required String label,
    required String priority,
    required String cabin,
    required VoidCallback onTap,
  }) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.blue.shade50),
      children: [
        _buildTableCell('$position', isBold: true, textColor: unitedBlue),
        _buildTableCell(
          label,
          isBold: true,
          softWrap: true,
          leading: const Icon(Icons.star, color: unitedBlue, size: 18),
        ),
        _buildTableCell(
          priority,
          isBold: true,
          softWrap: true,
          onTap: onTap,
        ),
        _buildTableCell(cabin, isBold: true, softWrap: true),
        _buildTableCell('1', isBold: true),
      ],
    );
  }

  List<TableRow> _buildRows() {
    final List<TableRow> rows = [];
    // Add header row.
    rows.add(
      TableRow(
        decoration: BoxDecoration(color: unitedBlue.withOpacity(0.1)),
        children: [
          'Position',
          'Name',
          'Priority',
          'Cabin',
          'Seats',
        ]
            .map((text) =>
                _buildTableCell(text, isHeader: true, softWrap: false))
            .toList(),
      ),
    );
    // Loop through standbyPassengers and add rows.
    standbyPassengers.forEach((cabin, passengers) {
      for (int i = 0; i < passengers.length; i++) {
        final passenger = passengers[i];
        rows.add(
          TableRow(
            decoration: BoxDecoration(
              color: i.isEven ? Colors.grey[50] : Colors.transparent,
            ),
            children: [
              _buildTableCell('${i + 1}'),
              _buildTableCell(passenger.name, softWrap: true),
              _buildTableCell(
                passenger.priority,
                softWrap: true,
                onTap: () => showPriorityInfo(passenger.priority),
              ),
              _buildTableCell(cabin, softWrap: true),
              _buildTableCell('1'),
            ],
          ),
        );
      }
      rows.add(
        _buildPredictedRow(
          position: passengers.length + 1,
          label: 'Vacation e‑Pass',
          priority: 'PS0E',
          cabin: cabin,
          onTap: () => showPriorityInfo('PS0E'),
        ),
      );
      rows.add(
        _buildPredictedRow(
          position: passengers.length + 2,
          label: 'Personal e‑Pass',
          priority: 'SA1P',
          cabin: cabin,
          onTap: () => showPriorityInfo('SA1P'),
        ),
      );
    });
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.8,
      margin: EdgeInsets.zero,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: SingleChildScrollView(
          child: Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(2.5),
              1: FlexColumnWidth(3),
              2: FlexColumnWidth(2.5),
              3: FlexColumnWidth(3),
              4: FlexColumnWidth(2),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: _buildRows(),
          ),
        ),
      ),
    );
  }
}
