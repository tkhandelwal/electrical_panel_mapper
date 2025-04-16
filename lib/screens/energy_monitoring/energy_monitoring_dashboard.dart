// screens/energy_monitoring/energy_monitoring_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../../models/circuit.dart';
import '../../services/panel_service.dart';

class EnergyMonitoringDashboard extends StatefulWidget {
  const EnergyMonitoringDashboard({super.key});
  
  @override
  EnergyMonitoringDashboardState createState() => EnergyMonitoringDashboardState();
}

class EnergyMonitoringDashboardState extends State<EnergyMonitoringDashboard> {
  DateTimeRange? _selectedDateRange;
  Circuit? _selectedCircuit;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Energy Monitoring'),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: _selectDateRange,
            tooltip: 'Select Date Range',
          ),
        ],
      ),
      body: Column(
        children: [
          // Circuit Selector
          _buildCircuitSelector(),
          
          // Energy Usage Overview
          Expanded(
            child: _buildEnergyUsageCharts(),
          ),
          
          // Summary Cards
          _buildEnergySummarySections(),
        ],
      ),
    );
  }
  
  Widget _buildCircuitSelector() {
    return Consumer<PanelService>(
      builder: (context, panelService, child) {
        // Collect all circuits from all panels
        final allCircuits = panelService.panels
            .expand((panel) => panelService.getCircuitsForPanel(panel.id!))
            .toList();
        
        return Padding(
          padding: EdgeInsets.all(16),
          child: DropdownButtonFormField<Circuit>(
            decoration: InputDecoration(
              labelText: 'Select Circuit',
              border: OutlineInputBorder(),
            ),
            value: _selectedCircuit,
            items: allCircuits.map((circuit) {
              return DropdownMenuItem(
                value: circuit,
                child: Text('${circuit.label} (${circuit.amperage}A)'),
              );
            }).toList(),
            onChanged: (circuit) {
              setState(() {
                _selectedCircuit = circuit;
              });
            },
          ),
        );
      },
    );
  }
  
  Widget _buildEnergyUsageCharts() {
    if (_selectedCircuit == null) {
      return Center(
        child: Text(
          'Select a circuit to view energy monitoring',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }
    
    // Placeholder for energy usage data
    final energyData = _generateMockEnergyData();
    
    return Padding(
      padding: EdgeInsets.all(16),
      child: charts.TimeSeriesChart(
        energyData,
        animate: true,
        primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec: charts.BasicNumericTickProviderSpec(
            desiredTickCount: 5,
          ),
          renderSpec: charts.GridlineRendererSpec(
            labelStyle: charts.TextStyleSpec(
              fontSize: 12,
              color: charts.MaterialPalette.gray.shade600,
            ),
          ),
        ),
        dateTimeFactory: const charts.LocalDateTimeFactory(),
      ),
    );
  }
  
  List<charts.Series<TimeSeriesLoad, DateTime>> _generateMockEnergyData() {
    final data = [
      TimeSeriesLoad(DateTime(2024, 1, 1), 5.2),
      TimeSeriesLoad(DateTime(2024, 1, 2), 6.1),
      TimeSeriesLoad(DateTime(2024, 1, 3), 4.9),
      TimeSeriesLoad(DateTime(2024, 1, 4), 7.3),
      TimeSeriesLoad(DateTime(2024, 1, 5), 6.5),
    ];
    
    return [
      charts.Series<TimeSeriesLoad, DateTime>(
        id: 'Load',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesLoad load, _) => load.time,
        measureFn: (TimeSeriesLoad load, _) => load.load,
        data: data,
      )
    ];
  }
  
  Widget _buildEnergySummarySections() {
    return Container(
      color: Colors.grey.shade100,
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSummaryCard(
            icon: Icons.power,
            label: 'Total Usage',
            value: '245 kWh',
          ),
          _buildSummaryCard(
            icon: Icons.attach_money,
            label: 'Estimated Cost',
            value: '\$36.75',
          ),
          _buildSummaryCard(
            icon: Icons.trending_up,
            label: 'Peak Load',
            value: '7.5 kW',
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 36,
          color: Theme.of(context).primaryColor,
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
  
  void _selectDateRange() async {
    final pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    
    if (pickedDateRange != null) {
      setState(() {
        _selectedDateRange = pickedDateRange;
      });
    }
  }
}

// Simple data model for time series load
class TimeSeriesLoad {
  final DateTime time;
  final double load;
  
  TimeSeriesLoad(this.time, this.load);
}