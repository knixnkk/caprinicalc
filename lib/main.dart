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
            // Expands to take available space
            child: Center(
              // Centers the image both horizontally and vertically
              child: FutureBuilder<Map<String, double>>(
                future: _getImageDimensions('assets/introduction.png'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      final dimensions = snapshot.data!;
                      double imgWidth = dimensions['width']!;
                      double imgHeight = dimensions['height']!;

                      // Responsive size (scale to screen width)
                      double responsiveWidth =
                          screenWidth; // 80% of screen width
                      double aspectRatio = imgWidth / imgHeight;
                      double responsiveHeight = responsiveWidth / aspectRatio;

                      return SizedBox(
                        width: responsiveWidth,
                        height: responsiveHeight,
                        child: Image.asset(
                          'assets/introduction.png',
                          fit: BoxFit.contain, // Ensure the image fits properly
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

          // Centered button horizontally
          SizedBox(height: 20), // Adjust top spacing
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

          SizedBox(height: 20), // Adjust bottom spacing
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
    "Immobilizing plaster cast": 2,
    "Hip, pelvis, or leg fracture": 5,
    "Stroke": 5,
    "Multiple trauma": 5,
    "Acute spinal cord injury causing paralysis": 5,
  };
  final Map<String, int> female = {
    "Pregnancy or postpartum (6 weeks)": 1,
    "History of unexplained or recurrent spontaneous abortions": 1,
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
    "Normal, out of bed": 0,
    "Medical patient currently on bed rest": 1,
    "Patient confined to bed > 72 hours": 2,
  };
  final Map<String, int> presentandpastHistory = {
    "History of inflammatory bowel disease": 1,
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
    "Minor surgery (< 45 mins)": 1,
    "Major surgery (> 45 mins)": 2,
    "Laparoscopic surgery (> 45 mins)": 2,
    "Arthroscopic surgery (> 45 mins)": 2,
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
    required int score, // Add score parameter
  }) {
    return SizedBox(
      width: 150,
      height: 40,
      child: ToggleSwitch(
        initialLabelIndex: value ? 1 : 0,
        totalSwitches: 2,
        labels: ['No  0', 'Yes +$score'], // Dynamically show the score
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
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
        ), // Add space between each toggle list
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(factor, style: TextStyle(fontSize: 16))),
                buildToggle(
                  value: selectedFactors[factor] ?? false,
                  onChanged: (value) {
                    setState(() {
                      selectedFactors[factor] =
                          value ?? false; // handle null value
                    });
                    calculateRiskScore();
                  },
                  score: factors[factor] ?? 0, // Pass the factor's score
                ),
              ],
            ),
            Divider(), // Add a line between each factor
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
        bmi = weight / (height * height);
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

      if (bmi >= 30) {
        factorsScore += 1; // BMI score
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
            // Risk Factors Checkboxes
            Expanded(
              child: ListView(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Color(0xff634FA4), // Set background color to white
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
                  // Age Dropdown
                  Row(
                    children: [
                      SizedBox(
                        width:
                            screenWidth * 0.3, // 30% of screen width for text
                        child: Text("Age:", style: TextStyle(fontSize: 18)),
                      ),
                      SizedBox(
                        width:
                            screenWidth *
                            0.6, // 60% of screen width for dropdown
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
                            child: Text(selectedAge),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Gender Selection
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
                  // Weight and Height Inputs
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
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              weight = double.tryParse(value) ?? 0;
                            });
                            calculateBMI();
                          },
                          decoration: InputDecoration(
                            hintText: "Enter Weight (kg)",
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ), // Change the color when focused
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.green,
                              ), // Change the color when not focused
                            ),
                            suffixIcon: Icon(
                              Icons
                                  .scale_rounded, // Icon placed at the top right
                              size: 20, // Adjust icon size as needed
                              color: Colors.blue, // Change icon color if needed
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
                          "Height (m):",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.6,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              height = double.tryParse(value) ?? 0;
                            });
                            calculateBMI();
                          },
                          decoration: InputDecoration(
                            hintText: "Enter Height (m)",
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ), // Change the color when focused
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color.fromARGB(255, 212, 159, 255),
                              ), // Change the color when not focused
                            ),
                            suffixIcon: Icon(
                              Icons.straighten, // Icon placed at the top right
                              size: 20, // Adjust icon size as needed
                              color: Colors.blue, // Change icon color if needed
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // for Surgery
                  Row(
                    children: [
                      SizedBox(
                        width:
                            screenWidth * 0.3, // 30% of screen width for text
                        child: Text(
                          "Surgery type:",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        width:
                            screenWidth *
                            0.6, // 60% of screen width for dropdown
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
                            child: Text(selectedSurgery),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Female-specific options
                  Visibility(
                    visible: gender == "Female",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        ...buildToggleList(selectedFemale, female),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    color: const Color.fromARGB(255, 216, 216, 216),
                    child: Text(
                      "Recent (< 1 month) events",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),

                  // Risk factors checkboxes
                  ...buildToggleList(selectedFactors, recentEvents),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    color: const Color.fromARGB(255, 216, 216, 216),
                    child: Text(
                      "Venous disease or clotting disorder",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  ...buildToggleList(selectedDiseaseHistory, diseaseHistory),

                  // for Mobility
                  Row(
                    children: [
                      SizedBox(
                        width:
                            screenWidth * 0.3, // 30% of screen width for text
                        child: Text(
                          "Mobility:",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        width:
                            screenWidth *
                            0.6, // 60% of screen width for dropdown
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
                            child: Text(selectedMobility),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    color: const Color.fromARGB(255, 216, 216, 216),
                    child: Text(
                      "Present and Past History",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),

                  ...buildToggleList(
                    selectedPresentAndPastHistory,
                    presentandpastHistory,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center, // Center the buttons horizontally
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
                      SizedBox(width: 5), // Space between buttons
                      /*
                      SquareButton(
                        height: 45,
                        width: screenWidth * 0.25,
                        buttonColor: Colors.redAccent,
                        onPressed: () {
                          setState(() {
                            selectedFactors.updateAll((key, value) => false);
                            selectedFemale.updateAll((key, value) => false);
                            selectedDiseaseHistory.updateAll((key, value) => false);
                            selectedPresentAndPastHistory.updateAll((key, value) => false);
                            weight = 0;
                            height = 0;
                            bmi = 0;
                            surgeryScore = 0;
                            mobilityScore = 0;
                            totalScore = 0;
                            ageScore = 0;
                            diseaseHistoryScore = 0;
                            presentAndPastHistoryScore = 0;
                            femaleScore = 0;
                            selectedAge = "Select Age";
                            selectedSurgery = "Select Surgery";
                            selectedMobility = "Select Mobility";
                            gender = "Male";
                            selectedGender = null;
                            weightController?.clear();
                            heightController?.clear();
                          });
                        },
                        text: ("Reset"),
                      ),
                  SizedBox(height: 5),
                  */
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
                      SizedBox(width: 10), // Space between buttons
                    ],
                  ),
                  SizedBox(height: 20),

                  /*
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
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              weight = double.tryParse(value) ?? 0;
                            });
                            calculateBMI();
                          },
                          decoration: InputDecoration(
                            hintText: "Enter Weight (kg)",
                          ),
                        ),
                      ),
                    ],
                  ),
                   */
                  /*
                  TextFieldWithLabel(
                    controller: weightController,
                    labelText: "",
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        weight = double.tryParse(value) ?? 0;
                      });
                      calculateBMI();
                    },
                  ),
                  */
                ],
              ),
            ),
            // Display Results
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color(0xff634FA4), // Set background color to white
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
                        color:
                            getRiskCategory() == "Very High Risk"
                                ? Colors.red
                                : getRiskCategory() == "High Risk"
                                ? Colors.orange
                                : getRiskCategory() == "Moderate Risk"
                                ? const Color.fromARGB(255, 229, 255, 0)
                                : getRiskCategory() == "Low Risk"
                                ? Color.fromARGB(255, 255, 201, 131)
                                : Color(0xffffffff),
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
                  height: 500,
                  fit: BoxFit.contain,
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
                    color: Color(0xff634FA4),
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
                                      color: Theme.of(context).dividerColor,
                                    ),
                                  ),
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
                buttonColor: const Color(0xff634FA4),
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
