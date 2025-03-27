import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class UploadGraph extends StatefulWidget {
  const UploadGraph({super.key});

  @override
  UploadGraphState createState() => UploadGraphState();
}

class UploadGraphState extends State<UploadGraph> {
  List<int> products = List.filled(7, 0); // Counts for the last 7 days
  List<DateTime> last7Days = []; // Store the last 7 days
  bool isLoading = true;

  // Colors for the bars
  final List<Color> barColors = [
    Colors.pink,
    Colors.orange,
    Colors.greenAccent,
    Colors.lightBlue,
    Colors.purpleAccent,
    Colors.yellowAccent,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _fetchProductData();
  }

  Future<void> _fetchProductData() async {
    // Generate the last 7 days, resetting time to midnight
    last7Days = List.generate(7, (index) {
      DateTime date = DateTime.now().subtract(Duration(days: index));
      return DateTime(date.year, date.month, date.day);
    }).reversed.toList(); // Reverse to get today first

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<int> tempProducts = List.filled(7, 0);

    DateTime earliestDate = last7Days.first;
    Timestamp earliestTimestamp = Timestamp.fromDate(earliestDate);

    try {
      // Fetch only products from the last 7 days
      QuerySnapshot snapshot = await firestore
          .collection('products')
          .where('createdAt', isGreaterThanOrEqualTo: earliestTimestamp)
          .get();

      // Loop through the documents and count products per day
      for (var doc in snapshot.docs) {
        final data =
            doc.data() as Map<String, dynamic>?; // Cast to Map<String, dynamic>
        if (data != null && data.containsKey('createdAt')) {
          Timestamp createdAt = data['createdAt'];
          DateTime productDate = createdAt.toDate();
          productDate =
              DateTime(productDate.year, productDate.month, productDate.day);

          // Find index in last7Days
          int index = last7Days.indexOf(productDate);
          if (index != -1) {
            tempProducts[index]++;
          }
        }
      }

      // Update the state with the new data
      setState(() {
        products = tempProducts;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching product data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine maxY for the chart
    double maxY = products.reduce((a, b) => a > b ? a : b).toDouble();
    maxY = (maxY == 0) ? 10 : maxY + 1; // Add padding if necessary

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      padding: const EdgeInsets.all(16.0),
      height: 300.0,
      decoration: BoxDecoration(
        color: Colors.tealAccent[100],
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (products.every((value) => value == 0)
              ? const Center(
                  child: Text(
                    'No product uploads in the last 7 days',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Products Uploaded (Last 7 Days)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16.0),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxY,
                          barGroups: _generateBarData(),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  int index = value.toInt();
                                  if (index < 0 || index >= last7Days.length) {
                                    return const Text('');
                                  }
                                  String formattedDate = DateFormat('MM/dd')
                                      .format(last7Days[index]);
                                  return Text(
                                    formattedDate,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(color: Colors.black),
                                  );
                                },
                              ),
                            ),
                          ),
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                                getTooltipItem:
                                    (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${products[groupIndex]} products',
                                const TextStyle(color: Colors.white),
                              );
                            }, getTooltipColor: (group) {
                              return Colors.black54; // Tooltip background color
                            }),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
    );
  }

  List<BarChartGroupData> _generateBarData() {
    return List.generate(products.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: products[index].toDouble(),
            color: barColors[index % barColors.length],
            width: 20.0,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
        ],
      );
    });
  }
}
