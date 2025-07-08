import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

// โมเดลสำหรับเก็บข้อมูลการลงทุนแบบ DCA
class DcaItem {
  String id;
  String name; // ชื่อแผนการลงทุน
  num capital; // เงินต้น
  num savings; // เงินออมต่อเดือน
  num returnRate; // อัตราผลตอบแทนรายปี (%)
  num period; // ระยะเวลาลงทุน (ปี)

  DcaItem({
    String? id,
    this.name = 'แผนการลงทุนใหม่',
    required this.capital,
    required this.savings,
    required this.returnRate,
    required this.period,
  }) : id = id ?? const Uuid().v4();

  // สร้าง DcaItem จากข้อมูลที่มีอยู่แล้ว
  DcaItem copyWith({
    String? name,
    num? capital,
    num? savings,
    num? returnRate,
    num? period,
  }) {
    return DcaItem(
      id: this.id,
      name: name ?? this.name,
      capital: capital ?? this.capital,
      savings: savings ?? this.savings,
      returnRate: returnRate ?? this.returnRate,
      period: period ?? this.period,
    );
  }
}

// โมเดลสำหรับเก็บผลลัพธ์การคำนวณ DCA รายปี
class YearlyResult {
  final int year;
  final num totalCapital; // เงินต้นรวม
  final num dividend; // เงินปันผล
  final num totalAmount; // จำนวนเงินรวม (เงินต้น + ปันผล)

  YearlyResult({
    required this.year,
    required this.totalCapital,
    required this.dividend,
    required this.totalAmount,
  });
}

// โมเดลสำหรับเก็บผลลัพธ์การคำนวณ DCA ทั้งหมด
class DcaResult {
  final DcaItem dcaItem;
  final List<YearlyResult> yearlyResults;
  final num finalAmount; // จำนวนเงินรวมสิ้นงวด

  DcaResult({
    required this.dcaItem,
    required this.yearlyResults,
    required this.finalAmount,
  });

  // คำนวณผลลัพธ์การลงทุนแบบ DCA จากข้อมูลที่ได้รับ
  static DcaResult calculate(DcaItem item) {
    List<YearlyResult> results = [];
    
    num currentCapital = item.capital;
    num yearlyDeposit = item.savings * 12; // เงินออมทั้งปี
    num returnRateDecimal = item.returnRate / 100; // แปลง % เป็นตัวเลขทศนิยม
    
    for (int year = 1; year <= item.period; year++) {
      // เงินต้นปีนี้ = เงินต้นเดิม + เงินออมทั้งปี
      num totalCapital = currentCapital + yearlyDeposit;
      
      // คำนวณเงินปันผลจากเงินต้นรวม (หลังจากเพิ่มเงินออมแล้ว)
      num dividend = totalCapital * returnRateDecimal;
      
      // จำนวนเงินรวมสิ้นปีนี้ = เงินต้นรวม + เงินปันผล
      num totalAmount = totalCapital + dividend;
      
      // เพิ่มผลลัพธ์ปีนี้เข้าไปในรายการ
      results.add(YearlyResult(
        year: year,
        totalCapital: totalCapital,
        dividend: dividend,
        totalAmount: totalAmount,
      ));
      
      // อัพเดตเงินต้นสำหรับปีถัดไป โดยเอาเงินปันผลมาเพิ่ม (ทบต้น)
      currentCapital = totalAmount;
    }
    
    return DcaResult(
      dcaItem: item,
      yearlyResults: results,
      finalAmount: results.isEmpty ? 0 : results.last.totalAmount,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DCA Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'DCA Calculator'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // รายการแผน DCA ทั้งหมด
  final List<DcaItem> _dcaItems = [];
  // แผน DCA ที่เลือกในปัจจุบัน
  DcaItem? _selectedDcaItem;
  // ผลลัพธ์การคำนวณจากแผนที่เลือก
  DcaResult? _dcaResult;
  // ปีที่เลือกดูรายละเอียด
  int _selectedYear = 1;
  // สถานะการแสดงรายการแผน
  bool _isPlansListExpanded = false;

  // Controllers สำหรับฟอร์มกรอกข้อมูล
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _capitalController = TextEditingController();
  final TextEditingController _savingsController = TextEditingController();
  final TextEditingController _returnRateController = TextEditingController();
  final TextEditingController _periodController = TextEditingController();

  // Formatters สำหรับแสดงผลตัวเลข
  final NumberFormat _currencyFormatter = NumberFormat('#,##0.00', 'th_TH');

  @override
  void initState() {
    super.initState();
    // เพิ่มตัวอย่างข้อมูล
    //_addSampleData();
  }

  // void _addSampleData() {
  //   // เพิ่มตัวอย่างข้อมูล
  //   final sampleItem = DcaItem(
  //     name: 'แผนการลงทุน 1',
  //     capital: 100000,
  //     savings: 5000,
  //     returnRate: 7,
  //     period: 20,
  //   );

  //   setState(() {
  //     _dcaItems.add(sampleItem);
  //     _selectItem(sampleItem);
  //   });
  // }

  void _selectItem(DcaItem item) {
    setState(() {
      _selectedDcaItem = item;
      _selectedYear = 1;
      // คำนวณผลลัพธ์ใหม่
      _dcaResult = DcaResult.calculate(item);
      
      // อัพเดต controllers
      _nameController.text = item.name;
      _capitalController.text = item.capital.toString();
      _savingsController.text = item.savings.toString();
      _returnRateController.text = item.returnRate.toString();
      _periodController.text = item.period.toString();
    });
  }

  void _createNewItem() {
    // สร้างแผนใหม่
    final newItem = DcaItem(
      capital: 0,
      savings: 0,
      returnRate: 0,
      period: 1,
    );
    
    setState(() {
      _dcaItems.add(newItem);
      _selectItem(newItem);
      // เปิดรายการแผนเมื่อสร้างแผนใหม่
      _isPlansListExpanded = true;
    });
  }

  void _deleteSelectedItem() {
    if (_selectedDcaItem == null) return;

    setState(() {
      _dcaItems.removeWhere((item) => item.id == _selectedDcaItem!.id);
      _selectedDcaItem = _dcaItems.isNotEmpty ? _dcaItems.first : null;
      if (_selectedDcaItem != null) {
        _selectItem(_selectedDcaItem!);
      } else {
        _dcaResult = null;
      }
    });
  }

  void _saveChanges() {
    if (_selectedDcaItem == null) return;

    try {
      // รับค่าจาก controllers
      final String name = _nameController.text.isEmpty ? "แผนการลงทุนใหม่" : _nameController.text;
      final num capital = num.tryParse(_capitalController.text) ?? 0;
      final num savings = num.tryParse(_savingsController.text) ?? 0;
      final num returnRate = num.tryParse(_returnRateController.text) ?? 0;
      final num period = num.tryParse(_periodController.text) ?? 1;
      
      // อัพเดตข้อมูล
      final updatedItem = _selectedDcaItem!.copyWith(
        name: name,
        capital: capital,
        savings: savings,
        returnRate: returnRate,
        period: period,
      );
      
      // อัพเดตในรายการ
      setState(() {
        final index = _dcaItems.indexWhere((item) => item.id == _selectedDcaItem!.id);
        if (index != -1) {
          _dcaItems[index] = updatedItem;
          _selectItem(updatedItem);
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อยแล้ว')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  void _togglePlansList() {
    setState(() {
      _isPlansListExpanded = !_isPlansListExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewItem,
            tooltip: 'สร้างแผนใหม่',
          ),
          if (_selectedDcaItem != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedItem,
              tooltip: 'ลบแผนที่เลือก',
            ),
          IconButton(
            icon: Icon(_isPlansListExpanded ? Icons.menu_open : Icons.menu),
            onPressed: _togglePlansList,
            tooltip: 'แสดง/ซ่อนรายการแผน',
          ),
        ],
      ),
      body: _selectedDcaItem == null ? _buildEmptyState() : _buildMainContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'ยังไม่มีแผนการลงทุน',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _createNewItem,
            icon: const Icon(Icons.add),
            label: const Text('สร้างแผนการลงทุน'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // 1. ส่วนแสดงรายการแผน (แสดงเมื่อกด toggle เท่านั้น)
        if (_isPlansListExpanded)
          Container(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _dcaItems.length,
                itemBuilder: (context, index) {
                  final item = _dcaItems[index];
                  final isSelected = _selectedDcaItem?.id == item.id;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(item.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) _selectItem(item);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          
        // 2. ส่วนหลักของหน้าจอ
        Expanded(
          child: _dcaResult == null ? Container() : _buildResultContent(),
        ),
      ],
    );
  }

  Widget _buildResultContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. แสดงชื่อแผนและข้อมูลสรุป
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDcaItem?.name ?? "แผนการลงทุน",
                          style: const TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _showEditDialog,
                        tooltip: 'แก้ไขข้อมูล',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // แสดงข้อมูลสรุปพอสังเขป
                  Text(
                    'เงินต้น: ${_currencyFormatter.format(_selectedDcaItem?.capital)} บาท',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'เงินออม: ${_currencyFormatter.format(_selectedDcaItem?.savings)} บาท/เดือน',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'ผลตอบแทน: ${_selectedDcaItem?.returnRate}% ต่อปี',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'ระยะเวลา: ${_selectedDcaItem?.period} ปี',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 2. แสดงผลลัพธ์สรุป
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ผลลัพธ์การคำนวณ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'เงินต้นทั้งหมด',
                          '${_currencyFormatter.format(_selectedDcaItem!.capital + (_selectedDcaItem!.savings * 12 * _selectedDcaItem!.period))} บาท',
                          Icons.money,
                        ),
                      ),
                      Expanded(
                        child: _buildSummaryCard(
                          'ผลตอบแทนสะสม',
                          '${_currencyFormatter.format(_dcaResult!.finalAmount - (_selectedDcaItem!.capital + (_selectedDcaItem!.savings * 12 * _selectedDcaItem!.period)))} บาท',
                          Icons.trending_up,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryCard(
                    'มูลค่ารวมสิ้นงวด',
                    '${_currencyFormatter.format(_dcaResult!.finalAmount)} บาท',
                    Icons.account_balance_wallet,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 3. แสดงกราฟข้อมูลรายปี
          if (_dcaResult?.yearlyResults != null && _dcaResult!.yearlyResults.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'กราฟแสดงผลการลงทุน',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      height: 250,
                      child: _buildInvestmentChart(),
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // 4. แสดงรายละเอียดรายปี
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'รายละเอียดรายปี',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // สร้าง widget สำหรับเลือกปี
                  if (_dcaResult!.yearlyResults.length > 1) 
                    // กรณีมีหลายปี ใช้ Slider
                    Row(
                      children: [
                        Text('ปีที่ 1'),
                        Expanded(
                          child: Slider(
                            value: _selectedYear.toDouble(),
                            min: 1,
                            max: _dcaResult!.yearlyResults.length.toDouble(),
                            // ให้ divisions มีค่าอย่างน้อย 1 เพื่อหลีกเลี่ยงข้อผิดพลาด
                            divisions: math.max(1, _dcaResult!.yearlyResults.length - 1),
                            label: 'ปีที่ $_selectedYear',
                            onChanged: (value) {
                              setState(() {
                                _selectedYear = value.toInt();
                              });
                            },
                          ),
                        ),
                        Text('ปีที่ ${_dcaResult!.yearlyResults.length}'),
                      ],
                    )
                  else
                    // กรณีมีเพียงปีเดียว แสดงข้อความแทน
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('มีข้อมูลเพียงปีเดียว (ปีที่ 1)', 
                              style: TextStyle(fontStyle: FontStyle.italic)),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // แสดงรายละเอียดของปีที่เลือก
                  if (_selectedYear > 0 && _selectedYear <= _dcaResult!.yearlyResults.length)
                    _buildYearlyDetail(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 5. ตารางแสดงข้อมูลรายปี
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ตารางแสดงผลลัพธ์รายปี',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    height: 300,
                    child: _buildDataTable(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // แสดง Dialog สำหรับแก้ไขข้อมูล
  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('แก้ไขข้อมูลแผนการลงทุน'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อแผนการลงทุน',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _capitalController,
                  decoration: const InputDecoration(
                    labelText: 'เงินต้น (บาท)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _savingsController,
                  decoration: const InputDecoration(
                    labelText: 'เงินออมต่อเดือน (บาท)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _returnRateController,
                  decoration: const InputDecoration(
                    labelText: 'อัตราผลตอบแทนรายปี (%)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _periodController,
                  decoration: const InputDecoration(
                    labelText: 'ระยะเวลา (ปี)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveChanges();
                Navigator.of(context).pop();
              },
              child: const Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInvestmentChart() {
    if (_dcaResult == null || _dcaResult!.yearlyResults.isEmpty) {
      return const Center(child: Text('ไม่มีข้อมูล'));
    }

    // แปลงข้อมูลรายปีเป็นรูปแบบที่ใช้กับ LineChart
    List<FlSpot> capitalSpots = [];
    List<FlSpot> totalSpots = [];
    
    num maxY = 0;
    
    for (int i = 0; i < _dcaResult!.yearlyResults.length; i++) {
      final result = _dcaResult!.yearlyResults[i];
      final year = i + 1;
      
      capitalSpots.add(FlSpot(year.toDouble(), result.totalCapital.toDouble()));
      totalSpots.add(FlSpot(year.toDouble(), result.totalAmount.toDouble()));
      
      if (result.totalAmount > maxY) maxY = result.totalAmount;
    }
    
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % 5 == 0 || value == 1 || value == _dcaResult!.yearlyResults.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('ปีที่ ${value.toInt()}'),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 32,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox();
                
                String valueText = '';
                if (value >= 1000000) {
                  valueText = '${(value / 1000000).toStringAsFixed(0)}M';
                } else if (value >= 1000) {
                  valueText = '${(value / 1000).toStringAsFixed(0)}K';
                } else {
                  valueText = value.toInt().toString();
                }
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(valueText),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        minX: 1,
        maxX: _dcaResult!.yearlyResults.length.toDouble(),
        minY: 0,
        maxY: maxY.toDouble() * 1.1, // เพิ่มพื้นที่ด้านบน 10%
        lineBarsData: [
          // เส้นเงินต้น
          LineChartBarData(
            spots: capitalSpots,
            isCurved: true,
            barWidth: 2,
            color: Colors.blue,
            dotData: const FlDotData(show: false),
          ),
          // เส้นมูลค่ารวม
          LineChartBarData(
            spots: totalSpots,
            isCurved: true,
            barWidth: 3,
            color: Colors.green,
            dotData: const FlDotData(show: false),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.white.withOpacity(0.8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final isCapital = spot.barIndex == 0;
                
                return LineTooltipItem(
                  '${isCapital ? "เงินต้น" : "มูลค่ารวม"}\n${_currencyFormatter.format(spot.y)} บาท',
                  TextStyle(
                    color: isCapital ? Colors.blue : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyDetail() {
    // รับข้อมูลของปีที่เลือก
    final yearData = _dcaResult!.yearlyResults[_selectedYear - 1];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'รายละเอียดปีที่ $_selectedYear',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // แสดงรายละเอียด
        Row(
          children: [
            Expanded(
              child: _buildDetailCard(
                'เงินต้นรวม',
                '${_currencyFormatter.format(yearData.totalCapital)} บาท',
              ),
            ),
            Expanded(
              child: _buildDetailCard(
                'เงินปันผลที่ได้รับ',
                '${_currencyFormatter.format(yearData.dividend)} บาท',
              ),
            ),
            Expanded(
              child: _buildDetailCard(
                'เงินรวมสิ้นปี',
                '${_currencyFormatter.format(yearData.totalAmount)} บาท',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ปีที่')),
            DataColumn(label: Text('เงินต้นรวม')),
            DataColumn(label: Text('เงินปันผล')),
            DataColumn(label: Text('เงินรวมสิ้นปี')),
          ],
          rows: _dcaResult!.yearlyResults.map((yearData) {
            return DataRow(
              selected: yearData.year == _selectedYear,
              onSelectChanged: (selected) {
                if (selected != null && selected) {
                  setState(() {
                    _selectedYear = yearData.year;
                  });
                }
              },
              cells: [
                DataCell(Text('${yearData.year}')),
                DataCell(Text('${_currencyFormatter.format(yearData.totalCapital)} บาท')),
                DataCell(Text('${_currencyFormatter.format(yearData.dividend)} บาท')),
                DataCell(Text('${_currencyFormatter.format(yearData.totalAmount)} บาท')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capitalController.dispose();
    _savingsController.dispose();
    _returnRateController.dispose();
    _periodController.dispose();
    super.dispose();
  }
}
