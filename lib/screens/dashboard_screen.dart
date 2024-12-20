import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/carbon_intensity_api.dart'; // Adjust the path to match your project structure

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<double> intensityValues = [250, 260, 240, 245, 255, 250, 270];
  late Future<int> currentIntensity;

  @override
  void initState() {
    super.initState();
    currentIntensity = CarbonIntensityApi.fetchCurrentIntensity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Carbon Buddy 🌎'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reload the data:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      currentIntensity = CarbonIntensityApi.fetchCurrentIntensity();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            FutureBuilder<int>(
              future: currentIntensity,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.blueAccent),
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    'Error fetching data: ${snapshot.error}',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  );
                } else if (snapshot.hasData) {
                  final int fetchedIntensity = snapshot.data!;
                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade900,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueAccent, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'National Carbon Intensity',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$fetchedIntensity gCO₂/kWh',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                fetchedIntensity > 200
                                    ? 'Carbon intensity is high! Maybe take a break and read a book instead 📖.'
                                    : 'Carbon intensity is low! Good time to use electricity 🌟.',
                                style: TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: fetchedIntensity > 200 ? Colors.red : Colors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                fetchedIntensity > 200 ? 'HIGH' : 'LOW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
            const SizedBox(height: 20),
            Text(
              'National half-hourly carbon intensity for the current day:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            'H${value.toInt()}',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.lightBlueAccent],
                      ),
                      spots: intensityValues
                          .asMap()
                          .entries
                          .map((entry) =>
                          FlSpot(entry.key.toDouble(), entry.value))
                          .toList(),
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withOpacity(0.3),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: 300,
                  minX: 0,
                  maxX: (intensityValues.length - 1).toDouble(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}