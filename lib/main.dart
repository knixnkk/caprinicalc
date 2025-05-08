import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:stylishbutton/stylishbutton.dart';
import 'package:matertino_radio/matertino_radio.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:toggle_switch/toggle_switch.dart';

void main() {
  runApp(CapriniRiskApp());
}

class CapriniRiskApp extends StatelessWidget {
  const CapriniRiskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: "IBM Plex Sans Thai"),
      debugShowCheckedModeBanner: false,
      home: InitPage(),
    );
  }
}

class InitPage extends StatelessWidget {
  const InitPage({super.key});

  Future<Map<String, double>> _getImageDimensions(String assetPath) async {
    final Completer<Map<String, double>> completer = Completer();

    final Image image = Image.asset(assetPath);
    image.image
        .resolve(ImageConfiguration())
        .addListener(
          ImageStreamListener((ImageInfo info, bool _) {
            final double width = info.image.width.toDouble();
            final double height = info.image.height.toDouble();
            completer.complete({'width': width, 'height': height});
          }),
        );

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: FutureBuilder<Map<String, double>>(
                future: _getImageDimensions('assets/introduction.png'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      final dimensions = snapshot.data!;
                      double imgWidth = dimensions['width']!;
                      double imgHeight = dimensions['height']!;

                      double responsiveWidth = screenWidth;
                      double aspectRatio = imgWidth / imgHeight;
                      double responsiveHeight = responsiveWidth / aspectRatio;

                      return SizedBox(
                        width: responsiveWidth,
                        height: responsiveHeight,
                        child: Image.asset(
                          'assets/introduction_with_name.png',
                          fit: BoxFit.contain,
                        ),
                      );
                    } else {
                      return Text('Error loading image dimensions');
                    }
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
          ),
          /*
          SizedBox(height: 10),
          Center(
            child: Text(
              """
พัฒนาโดย นายยงยุทธ คำถาและคณะ
Program of Nursing Specialty in Perioperative Nursing
Ubon Ratchathani University
""",
              textAlign: TextAlign.center, // centers each line
              style: TextStyle(fontSize: 18, color: Color(0xff634FA4)),
            ),
          ),
           */
          SizedBox(height: 20),
          Center(
            child: SquareButton(
              text: "Get Started",
              width: screenWidth,
              height: screenHeight * 0.05,
              shadowColor: Color(0xff634FA4),
              buttonColor: Color(0xff634FA4),
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CapriniRiskCalculator(),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class CapriniRiskCalculator extends StatefulWidget {
  const CapriniRiskCalculator({super.key});

  @override
  _CapriniRiskCalculatorState createState() => _CapriniRiskCalculatorState();
}

class _CapriniRiskCalculatorState extends State<CapriniRiskCalculator> {
  final Map<String, int> recentEvents = {
    "CHF": 1,
    "Sepsis": 1,
    "Pneumonia": 1,
    "Hip, pelvis, or leg fracture": 5,
    "Stroke": 5,
    "Multiple trauma": 5,
    "Acute spinal cord injury causing paralysis": 5,
  };
  final Map<String, int> female = {
    "Pregnancy or postpartum (6 weeks)": 1,
    "History of unexplained stillborn infant, recurrent spontaneous abortion (≥3), premature birth with toxemia or growth-restricted infant":
        1,
    "Oral contraceptive or hormone replacement therapy": 1,
  };
  final Map<String, int> diseaseHistory = {
    "Varicose veins": 1,
    "Current swollen legs": 1,
    "Current central venous access": 2,
    "History of DVT/PE": 3,
    "Family history of thrombosis": 3,
    "Positive Factor V Leiden": 3,
    "Positive prothrombin 20210A": 3,
    "Elevated serum homocysteine": 3,
    "Positive lupus anticoagulant": 3,
    "Elevated anticardiolipin antibody": 3,
    "Heparin-induced thrombocytopenia": 3,
    "Other congenital or acquired thrombophilia": 3,
  };
  final Map<String, int> diseaseHistoryOptions = {
    "Mobilizing leg": 0,
    "Immobilizing leg cast or brace": 1,
  };
  final Map<String, int> presentandpastHistory = {
    "History of inflammatory bowel disease": 1,
    "History of prior major surgery": 1,
    "Acute MI": 1,
    "COPD": 1,
    "Present or previous malignancy": 2,
    "Other risk factors": 1,
  };
  final Map<String, int> ageOptions = {
    "< 41 years": 0,
    "41-60 years": 1,
    "61-74 years": 2,
    "≥ 75 years": 3,
  };
  final Map<String, int> surgeryOptions = {
    "None surgery": 0,
    "Minor surgery planned": 1,
    "Minor surgery (>60 min)": 2,
    "Arthroscopic surgery (>60 min)": 2,
    "Laparoscopic surgery (>60 min)": 2,
    "Major surgery lasting 2–3 hrs": 3,
    "Major surgery lasting over 3 hrs": 5,
    "Elective major lower-extremity arthroplasty": 5,
  };

  Map<String, bool> selectedFactors = {};
  Map<String, bool> selectedFemale = {};
  Map<String, bool> selectedDiseaseHistory = {};
  Map<String, bool> selectedPresentAndPastHistory = {};

  List<Map<String, dynamic>> lists = [
    {"title": "Male", "iconData": Icons.male_rounded},
    {"title": "Female", "iconData": Icons.female_rounded},
  ];

  double weight = 0;
  double height = 0;
  double bmi = 0;

  int surgeryScore = 0;
  int mobilityScore = 0;
  int totalScore = 0;
  int ageScore = 0;
  int diseaseHistoryScore = 0;
  int presentAndPastHistoryScore = 0;
  int femaleScore = 0;

  String selectedAge = "Select Age";
  String selectedSurgery = "Select Surgery";
  String selectedMobility = "Select Mobility";
  String gender = "Male";

  String? selectedGender;

  TextEditingController? weightController;
  TextEditingController? heightController;

  Widget buildToggle({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required int score,
  }) {
    return SizedBox(
      width: 150,
      height: 40,
      child: ToggleSwitch(
        initialLabelIndex: value ? 1 : 0,
        totalSwitches: 2,
        labels: ['No  0', 'Yes +$score'],
        activeBgColor: [Color(0xff634FA4)],
        activeFgColor: Colors.white,
        inactiveBgColor: Colors.white,
        inactiveFgColor: Colors.grey[900],
        onToggle: (index) {
          onChanged(index == 1);
        },
      ),
    );
  }

  List<Widget> buildToggleList(
    Map<String, bool> selectedFactors,
    Map<String, int> factors,
  ) {
    return factors.keys.map((factor) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(factor, style: TextStyle(fontSize: 18))),
                buildToggle(
                  value: selectedFactors[factor] ?? false,
                  onChanged: (value) {
                    setState(() {
                      selectedFactors[factor] = value ?? false;
                    });
                    calculateRiskScore();
                  },
                  score: factors[factor] ?? 0,
                ),
              ],
            ),
            Divider(),
          ],
        ),
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    selectedFactors = {for (var key in recentEvents.keys) key: false};
    selectedDiseaseHistory = {for (var key in diseaseHistory.keys) key: false};
    selectedPresentAndPastHistory = {
      for (var key in presentandpastHistory.keys) key: false,
    };
    weightController = TextEditingController();
    heightController = TextEditingController();
  }

  void calculateBMI() {
    setState(() {
      if (weight > 0 && height > 0) {
        double heightInMeters = height / 100;
        bmi = weight / (heightInMeters * heightInMeters);
        calculateRiskScore();
      }
    });
  }

  void calculateRiskScore() {
    setState(() {
      int factorsScore = selectedFactors.entries
          .where((entry) => entry.value)
          .map((entry) => recentEvents[entry.key] ?? 0)
          .fold(0, (sum, value) => sum + value);

      int diseaseFactorsScore = selectedDiseaseHistory.entries
          .where((entry) => entry.value)
          .map((entry) => diseaseHistory[entry.key] ?? 0)
          .fold(0, (sum, value) => sum + value);

      int presentAndPastFactorsScore = selectedPresentAndPastHistory.entries
          .where((entry) => entry.value)
          .map((entry) => presentandpastHistory[entry.key] ?? 0)
          .fold(0, (sum, value) => sum + value);

      int femaleScore = selectedFemale.entries
          .where((entry) => entry.value)
          .map((entry) => female[entry.key] ?? 0)
          .fold(0, (sum, value) => sum + value);

      if (bmi >= 30 && bmi < 40) {
        factorsScore += 1;
      } else if (bmi >= 40 && bmi < 50) {
        factorsScore += 2;
      } else if (bmi >= 50) {
        factorsScore += 3;
      }

      totalScore =
          factorsScore +
          diseaseFactorsScore +
          presentAndPastFactorsScore +
          ageScore +
          surgeryScore +
          mobilityScore +
          femaleScore;
    });
  }

  String getRiskCategory() {
    if (totalScore >= 5) return "High Risk";
    if (totalScore >= 3 && totalScore <= 4) return "Moderate Risk";
    if (totalScore >= 1 && totalScore <= 2) return "Low Risk";
    return "Very Low Risk";
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Color(0xff634FA4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Assessment",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.3,
                        child: Text("Age:", style: TextStyle(fontSize: 18)),
                      ),
                      SizedBox(
                        width: screenWidth * 0.6,
                        child: GestureDetector(
                          onTap: () {
                            DropDownState<String>(
                              dropDown: DropDown<String>(
                                data:
                                    ageOptions.keys
                                        .map(
                                          (age) => SelectedListItem<String>(
                                            data: age,
                                          ),
                                        )
                                        .toList(),
                                onSelected: (selectedItems) {
                                  if (selectedItems.isNotEmpty) {
                                    setState(() {
                                      selectedAge = selectedItems.first.data;
                                      ageScore = ageOptions[selectedAge] ?? 0;
                                    });
                                    calculateRiskScore();
                                  }
                                },
                              ),
                            ).showModal(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              selectedAge,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: List.generate(lists.length, (index) {
                      String genderTitle = lists[index]['title'];
                      Color genderColor =
                          genderTitle == "Male" ? Colors.blue : Colors.pink;

                      return Expanded(
                        child: MatertinoRadioListTile(
                          value: genderTitle,
                          groupValue: selectedGender,
                          title: genderTitle,
                          titleStyle: TextStyle(fontSize: 18),
                          selectedRadioIconData: lists[index]['iconData'],
                          unselectedRadioIconData: lists[index]['iconData'],
                          borderColor: genderColor,
                          selectedRadioColor: genderColor,
                          tileColor: Colors.transparent,
                          onChanged: (val) {
                            setState(() {
                              selectedGender = val!;
                              gender = val;
                            });
                            calculateRiskScore();
                          },
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.3,
                        child: Text(
                          "Weight (kg):",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.6,
                        child: TextField(
                          controller: weightController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              weight = double.tryParse(value) ?? 0;
                            });
                            calculateBMI();
                          },
                          decoration: InputDecoration(
                            hintText: "Enter Weight (kg)",
                            hintStyle: TextStyle(fontSize: 18),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                            ),
                            suffixIcon: Icon(
                              Icons.scale_rounded,
                              size: 20,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.3,
                        child: Text(
                          "Height (cm):",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.6,
                        child: TextField(
                          controller: heightController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              height = double.tryParse(value) ?? 0;
                            });
                            calculateBMI();
                          },
                          decoration: InputDecoration(
                            hintText: "Enter Height (cm)",
                            hintStyle: TextStyle(fontSize: 18),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color.fromARGB(255, 212, 159, 255),
                              ),
                            ),
                            suffixIcon: Icon(
                              Icons.straighten,
                              size: 20,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.3,
                        child: Text(
                          "Surgery type:",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.6,
                        child: GestureDetector(
                          onTap: () {
                            DropDownState<String>(
                              dropDown: DropDown<String>(
                                data:
                                    surgeryOptions.keys
                                        .map(
                                          (surgery) => SelectedListItem<String>(
                                            data: surgery,
                                          ),
                                        )
                                        .toList(),
                                onSelected: (selectedItems) {
                                  if (selectedItems.isNotEmpty) {
                                    setState(() {
                                      selectedSurgery =
                                          selectedItems.first.data;
                                      surgeryScore =
                                          surgeryOptions[selectedSurgery] ?? 0;
                                    });
                                    calculateRiskScore();
                                  }
                                },
                              ),
                            ).showModal(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              selectedSurgery,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.3,
                        child: Text(
                          "Mobility:",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.6,
                        child: GestureDetector(
                          onTap: () {
                            DropDownState<String>(
                              dropDown: DropDown<String>(
                                data:
                                    diseaseHistoryOptions.keys
                                        .map(
                                          (mobility) =>
                                              SelectedListItem<String>(
                                                data: mobility,
                                              ),
                                        )
                                        .toList(),
                                onSelected: (selectedItems) {
                                  if (selectedItems.isNotEmpty) {
                                    setState(() {
                                      selectedMobility =
                                          selectedItems.first.data;
                                      mobilityScore =
                                          diseaseHistoryOptions[selectedMobility] ??
                                          0;
                                    });
                                    calculateRiskScore();
                                  }
                                },
                              ),
                            ).showModal(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              selectedMobility,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Visibility(
                    visible: gender == "Female",
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      color: Colors.pink,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "For Women Only",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: gender == "Female",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [...buildToggleList(selectedFemale, female)],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    color: Color(0xff634FA4),
                    child: Text(
                      "Recent (< 1 month) events",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...buildToggleList(selectedFactors, recentEvents),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    color: Color(0xff634FA4),
                    child: Text(
                      "Venous disease or clotting disorder",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...buildToggleList(selectedDiseaseHistory, diseaseHistory),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    color: Color(0xff634FA4),
                    child: Text(
                      "Present and Past History",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  ...buildToggleList(
                    selectedPresentAndPastHistory,
                    presentandpastHistory,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SquareButton(
                        buttonColor: Color.fromARGB(255, 255, 201, 131),
                        height: 45,
                        width: screenWidth * 0.25,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => InitPage()),
                          );
                        },
                        text: ("BACK"),
                      ),
                      SizedBox(width: 5),
                      SquareButton(
                        height: 45,
                        width: screenWidth * 0.25,
                        buttonColor: Color(0xff634FA4),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ResultPage(
                                    totalScore: totalScore,
                                    riskCategory: getRiskCategory(),
                                  ),
                            ),
                          );
                        },
                        text: ("Results"),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            // Display Results
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color:
                    getRiskCategory().toLowerCase() == "very low risk"
                        ? Color(0xff007074)
                        : getRiskCategory().toLowerCase() == "low risk"
                        ? Color(0xff5F99AE)
                        : getRiskCategory().toLowerCase() == "moderate risk"
                        ? Color(0xffFDAB9E)
                        : getRiskCategory().toLowerCase() == "high risk"
                        ? Color(0xffBF3131)
                        : Color(0xff007074), // Set background color to white
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Total Score: $totalScore",
                      style: TextStyle(
                        color: Color(0xffffffff),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Risk Category: ${getRiskCategory()}",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xffffffff),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ResultPage extends StatefulWidget {
  final int totalScore;
  final String riskCategory;

  const ResultPage({
    super.key,
    required this.totalScore,
    required this.riskCategory,
  });

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final Map<String, List<String>> riskGuidelines = {
    "Very Low Risk": [
      "Education",
      "Early ambulation",
      "Foot & ankle exercise (passive & active)",
    ],
    "Low Risk": [
      "Education",
      "Early ambulation",
      "Foot & ankle exercise (passive & active)",
      "Intermittent pneumatic compression",
    ],
    "Moderate Risk": [
      "Education",
      "Early ambulation",
      "Foot & ankle exercise (passive & active)",
      "Intermittent pneumatic compression",
      "ดูแลให้ยา Low-molecular weight heparin",
    ],
    "High Risk": [
      "Education",
      "Early ambulation",
      "Foot & ankle exercise (passive & active)",
      "Intermittent pneumatic compression",
      "ดูแลให้ยา Low-molecular weight heparin",
    ],
    "Very High Risk": [
      "Education",
      "Early ambulation",
      "Foot & ankle exercise (passive & active)",
      "Intermittent pneumatic compression",
      "ดูแลให้ยา Low-molecular weight heparin",
    ],
  };
  // Update your mainDetails map to use a function that returns a widget
  final Map<String, String> mainDetails = {
    "Education": """
	Vein Thromboembolism : VTE คือ ภาวะที่ลิ่มเลือดก่อตัวขึ้นในหลอดเลือดดำ พบมากในเลือดดำส่วนลึกที่ขา (Deep Vein Thrombosis : DVT) ก่อให้เกิดลิ่มเลือดหลุดอุดตันหลอดเลือดดำในปอด (Pulmonary Embolism)
	สาเหตุ
    1.	การหยุดนิ่งของเลือดดำ (Venous stasis)
    2.	ผนังภายในหลอดเลือดดำได้รับอันตราย (Endothelial injury)
    3.	มีการเปลี่ยนแปลงปัจจัยการแข็งตัวของเลือด (Blood coagulation)
    การป้องกัน
    1.	ส่งเสริมให้ผู้ป่วยดื่มน้ำในปริมาณที่เพียงพอ อย่างน้อย 2 ลิตรต่อวัน (หากไม่มีข้อจำกัด) เพื่อลดความหนืดของเลือด (Blood viscosity)
    2.	ดูแลให้ผู้ป่วยยกขาสูงกว่าหัวใจ เพื่อเพิ่มการไหลกลับของเลือดดำ (Venous return)
    3.	สอนการหายใจอย่างมีประสิทธิภาพ (Deep breathing exercise)
    """,
    "Early ambulation":
        "กระตุ้นผู้ป่วยลุกจากเตียงเร็วที่สุด (หากไม่มีข้อจำกัด) เพื่อป้องกันการหยุดนิ่งและการคั่งของเลือดดำที่ขา (venous stasis & pooling)",
    "Foot & ankle exercise (passive & active)":
        "1.   กระดกข้อเท้าขึ้นลงข้างละ 15 ครั้ง/นาที (เช้า กลางวัน เย็น)\n2.   หมุนข้อเท้าเป็นวงกลม 15 ครั้ง/นาที (เช้า กลางวัน เย็น)",
    "Intermittent pneumatic compression":
        """การใช้อุปกรณ์ป้องกัน (Mechanical prophylaxis) 
      หลักการคือ ลด venous stasis กระตุ้นให้เกิด endogenous fibrinolysis 
      1. Passive methods : เช่น graduated compression stocking (GCS) intra-op and post-op 24 hr.
    

      2. Active methods : intermittent pneumatic compression (IPC) ใช้ intra-op post-op and discharge
    """,
  };
  final Map<String, String> lmwhDetails = {
    "Moderate Risk":
        "LMWH ยา Enoxaparin หรือ Low-dose unfractionated heparin ยา heparin (มีสาร glycosaminoglycan ออกฤทธิ์กระตุ้น antithrombin III : AT III ยับยั้ง clotting factor ) ให้ 24 ชม.หลัง admission ถึง 7 วันหลังผ่าตัด ตามแผนการรักษาแพทย์",
    "High Risk":
        "LMWH ยา Enoxaparin หรือ Low-dose unfractionated heparin ยา heparin (มีสาร glycosaminoglycan ออกฤทธิ์กระตุ้น antithrombin III : AT III ยับยั้ง clotting factor ) ให้ 24 ชม.หลัง admission ถึง 30 วันหลังผ่าตัด ตามแผนการรักษาแพทย์",
  };

  @override
  Widget build(BuildContext context) {
    final riskList = riskGuidelines[widget.riskCategory] ?? [];
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double maxExpansionTileWidth =
        screenWidth * 0.85; // Use 85% of screen width
    Map<String, Widget Function(BuildContext)> contentWidgets = {
      "Intermittent pneumatic compression":
          (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("การใช้อุปกรณ์ป้องกัน (Mechanical prophylaxis)"),
              Text(
                "หลักการคือ ลด venous stasis กระตุ้นให้เกิด endogenous fibrinolysis",
              ),
              SizedBox(height: 8),

              Text(
                "1. Passive methods : เช่น graduated compression stocking (GCS) intra-op and post-op 24 hr.",
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Image.asset(
                  'assets/Intermittent_images/gcs_image.jpg',
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: 12),
              Text(
                "2. Active methods : intermittent pneumatic compression (IPC) ใช้ intra-op post-op and discharge",
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Image.asset(
                  'assets/Intermittent_images/ipc_image.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
      "ดูแลให้ยา Low-molecular weight heparin":
          (context) => Column(
            children: [
              Text(
                "การใช้ยาในการป้องกัน (Pharmacologic prophylaxis agent)  ACCP guidelines 2022",
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Image.asset(
                  'assets/lmwh_images/Picture1.jpg',
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.fitWidth,
                ),
              ),
              SizedBox(height: 8),
              Text("""
              1. Unfractionated  heparin : DUH ขนาด 5000 unit 2 hrs. pre-op and 8-12 hr. post-op (SC.) 
              2. Low molecular weight heparin :LMWH เป็นยาต้านการแข็งตัวของเลือดในกลุ่มอนุพันธ์ของ heparin มีน้ำหนักโมเลกุลต่ำ ทำหน้าที่ยับยั้งปัจจัยการแข็งตัวของเลือด factor Xa
                - Enoxaparin 40 mg. (Sc.) OD 
                - Fondaparinux sodium  2.5 mg. (SC.) post-op 6-8 hr.
                - Dalteparin sodium 100 IU/kg. BID or 200 IU/kg. OD
              3. Warfarin 5 mg oral OD.

              """),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Image.asset(
                  'assets/lmwh_images/Picture2.jpg',
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  "Unfractionated heparin  5000 unit",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Image.asset(
                  'assets/lmwh_images/Picture3.jpg',
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  "Enoxaparin 40 mg.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Image.asset(
                  'assets/lmwh_images/Picture4.jpg',
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  "Fondaparinux sodium 2.5 mg.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Image.asset(
                  'assets/lmwh_images/Picture5.jpg',
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  "Dalteparin sodium 5000 IU",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Image.asset(
                  'assets/lmwh_images/Picture6.jpg',
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text("Warfarin 5 mg", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
    };
    String translateRiskCategory(String riskCategory) {
      if (riskCategory.toLowerCase() == "very low risk") {
        return "คุณไม่มีความเสี่ยง (Very Low Risk)";
      } else if (riskCategory.toLowerCase() == "low risk") {
        return "คุณมีความเสี่ยงต่ำ (Low Risk)";
      } else if (riskCategory.toLowerCase() == "moderate risk") {
        return "คุณมีความเสี่ยงปานกลาง (Moderate Risk)";
      } else if (riskCategory.toLowerCase() == "high risk") {
        return "คุณมีความเสี่ยงสูง (High Risk)";
      }
      return riskCategory;
    }

    Color themeColor(String riskCategory) {
      if (riskCategory.toLowerCase() == "very low risk") {
        return Color(0xff007074);
      } else if (riskCategory.toLowerCase() == "low risk") {
        return Color(0xff5F99AE);
      } else if (riskCategory.toLowerCase() == "moderate risk") {
        return Color(0xffFDAB9E);
      } else if (riskCategory.toLowerCase() == "high risk") {
        return Color(0xffBF3131);
      }
      return Color(0xff634FA4);
    }

    return Scaffold(
      body: Stack(
        children: [
          // Main content in a Padding and ListView
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView(
              children: [
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: themeColor(widget.riskCategory),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Nursing Care",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        translateRiskCategory(widget.riskCategory),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Wrap the ExpansionTileGroup in a Container with constraints
                      Container(
                        width: maxExpansionTileWidth,
                        child: ExpansionTileGroup(
                          toggleType: ToggleType.expandOnlyCurrent,
                          spaceBetweenItem: 8.0,
                          children:
                              riskList.map((title) {
                                // Check if we have a special widget for this content
                                Widget? contentWidget;

                                if (contentWidgets.containsKey(title)) {
                                  contentWidget = contentWidgets[title]!(
                                    context,
                                  );
                                } else {
                                  // Use regular text for other items
                                  String description = mainDetails[title] ?? "";

                                  // Special case for LMWH details
                                  if (title ==
                                          "ดูแลให้ยา Low-molecular weight heparin" &&
                                      lmwhDetails.containsKey(
                                        widget.riskCategory,
                                      )) {
                                    description +=
                                        "${lmwhDetails[widget.riskCategory]}";
                                  }

                                  contentWidget = Text(description);
                                }

                                return ExpansionTileItem(
                                  title: Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: themeColor(widget.riskCategory),
                                    ),
                                  ),
                                  textColor: themeColor(widget.riskCategory),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 8.0,
                                      ),
                                      child: contentWidget,
                                    ),
                                  ],
                                );
                              }).toList(),
                        ),
                      ),
                      // Add padding at the bottom to ensure content doesn't get hidden behind the button
                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Button positioned at the center-bottom
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: SquareButton(
                buttonColor: themeColor(widget.riskCategory),
                width: screenWidth * 0.5,
                height: 45,
                onPressed: () {
                  Navigator.pop(context);
                },
                text: "Back to Assessment",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
