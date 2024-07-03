import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
import 'package:liquidapp/Constants/ui.dart';
import 'package:liquidapp/Databases/db_connection.dart';
import 'package:liquidapp/Databases/model.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;




class Dashboard extends StatefulWidget {
  // final Liquidation liquidation;
  // const Dashboard({super.key, required this.liquidation});
  final String event;
  final double fund;
  final int id;
  const Dashboard(
      {super.key, required this.event, required this.fund, required this.id});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final databaseHelper = DatabaseHelper();

  List<TransactionDetails> transactionDetails = [];

  TextEditingController _payeeController = TextEditingController();
  TextEditingController _or_siController = TextEditingController();
  TextEditingController _particularsController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _dateController = TextEditingController();

  
  List<double> balance = [];
  double remainingBalance = 0.0;
  double totalLiquidated = 0.0;
  double liquidatedAmount = 0.0;
  int counter = 0;

  double currentBalance = 0.0;

  File? imageFile;


  String imgPath = '';

  List<int> _readImageData = [];
  static const MethodChannel _channel =
      MethodChannel('cunning_document_scanner');

  List<String> _pictures = [];
  void getPictures() async {
    List<String> pictures;
    try {
      pictures = await CunningDocumentScanner.getPictures() ?? [];
      if (!mounted) return;
      setState(() {
        _pictures = pictures;
      });
    } catch (exception) {
      // Handle exception here
    }
    print(_pictures[0]);
    imgPath = _pictures[0];

    final ByteData data = await rootBundle.load(imgPath);
    _readImageData = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }


 Future<void> loadData() async {
  var transactions = await databaseHelper.getTransactionDetails(widget.id);

  List<double> calculatedBalances = [];
  double previousBalance = widget.fund;

  for (var transaction in transactions) {
    double currentBalance = previousBalance - transaction.amount;
    calculatedBalances.add(currentBalance);
    previousBalance = currentBalance;
  }

  setState(() {
    transactionDetails = transactions;
    balance = calculatedBalances;
    if (calculatedBalances.isNotEmpty) {
      remainingBalance = calculatedBalances.last;
    } else {
      remainingBalance = widget.fund;
    }
    totalLiquidated = (widget.fund - remainingBalance) / widget.fund * 100;
    liquidatedAmount = widget.fund - remainingBalance;
    counter++;
  });
}


  //add data
Future<void> addTransaction() async { 
  final date = _dateController.text;
  final payee = _payeeController.text;
  final or_si = _or_siController.text;
  final particulars = _particularsController.text;
  final amount = double.tryParse(_amountController.text) ?? 0.0;
  final image = imgPath;
  
  int id = 0;
  if(transactionDetails.isEmpty){
    id = 0;
  } else {
    id = transactionDetails.length + 1;
  }
  
  var newTransaction = TransactionDetails(id: id, date: date, payee: payee, or_si: or_si, particulars: particulars, image: image, amount: amount, transactionId: widget.id);
  await databaseHelper.insertTransactionDetails(newTransaction);
  
  if (balance.isNotEmpty) {
    setState(() {
      currentBalance = balance.last;
    });
  } else {
    setState(() {
      currentBalance = widget.fund;
    });
  }
  loadData();
  _payeeController.clear();
  _or_siController.clear();
  _particularsController.clear();
  _amountController.clear();
  _dateController.clear();
}

  Future<void> deleteTransactionDetails(int id) async {
     try {
      await databaseHelper.deleteTransactionDetails(id);
      loadData();
      print("Transaction deleted successfully");
    } catch (e) {
      print("Error deleting transaction: $e");
    }
  }


 

  Future<void> exportDataToExcel() async {

    // const String imgUrl = 'https://fileinfo.com/img/ss/xl/jpg_44-2.jpg';
    // const String directoryPath = '/storage/emulated/0/Download'; 
    // final Dio dio = Dio();


    // String imgPath = '$directoryPath/image.jpg';
    
    // dio.download(imgUrl, imgPath, onReceiveProgress: (dowloadededSize, totalSize) {
      
    // });

    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];
    
    // Request permission to write to external storage
  // if (!(await Permission.storage.isGranted)) {
  //   await Permission.storage.request();
  //   if (!(await Permission.storage.isGranted)) {
  //     // Handle the case if permission is still not granted
  //     print('Permission denied');
  //     return;
  //   }
  // }


    // Add headers.
      sheet.getRangeByName('A1').setText('ID');
      sheet.getRangeByName('B1').setText('Date');
      sheet.getRangeByName('C1').setText('Payee');
      sheet.getRangeByName('D1').setText('OR/SI');
      sheet.getRangeByName('E1').setText('Particulars');
      sheet.getRangeByName('F1').setText('Amount');
      sheet.getRangeByName('G1').setText('Balance');
      sheet.getRangeByName('H1').setText('Image');
      
      for (int i = 0; i < transactionDetails.length; i++) {
      final transaction = transactionDetails[i];
      sheet.getRangeByName('A${i + 2}').setNumber(transaction.id.toDouble());
      sheet.getRangeByName('B${i + 2}').setText(transaction.date);
      sheet.getRangeByName('C${i + 2}').setText(transaction.payee);
      sheet.getRangeByName('D${i + 2}').setText(transaction.or_si);
      sheet.getRangeByName('E${i + 2}').setText(transaction.particulars);
      sheet.getRangeByName('F${i + 2}').setNumber(transaction.amount);
      sheet.getRangeByName('G${i + 2}').setNumber(balance[i]);
      
      final String img = base64.encode(_readImageData);
      sheet.pictures.addBase64(i + 2, 8, img);
      

      }
    // Save the file to the device.
    // Save the file
    try {
      final List<int> bytes = workbook.saveAsStream();
      final String directory = "/storage/emulated/0/Download";
      final File file = File('${directory}/output.xlsx');
      await file.writeAsBytes(bytes, flush: true);

      // Open the file after saving (optional)
      await Process.run('xdg-open', [file.path], runInShell: true);
      print('File saved successfully');
    } catch (e) {
      print('Error saving or opening file: $e');
    } finally {
      workbook.dispose();
    }

    workbook.dispose();

    
  }


 Future<bool> requestStoragePermission(Permission permission) async {
    AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;

    if (build.version.sdkInt >= 30) {
      var re = await Permission.manageExternalStorage.request();
      if(re.isGranted){
        // print("Permission granted");
        return true;
      }else{
        // print("Permission denied");
        return false;
      }

    } else {
      if (await permission.isGranted) {
        return true;
      }else{
        var result = await permission.request();
        if(result.isGranted){
          // print("Permission granted");
          return true;
        }else{
          // print("Permission denied");
          return false;
        }
      }
    }
    
  }

 
  @override
  void initState() {
    super.initState();
    remainingBalance = widget.fund;
    currentBalance = widget.fund;
    loadData();
   
    
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(height * 0.06),
          child: AppBar(
            backgroundColor: AppColors.bg,
          )),
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(width * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(width * 0.05),
                width: width * 0.96,
                height: height * 0.2,
                // decoration: BoxDecoration(
                //   color: AppColors.cream,
                //   borderRadius: BorderRadius.circular(10),
                // ),
                child: Row(
                  children: [
                    Container(
                        //  padding: EdgeInsets.all(10),
                        child: CircularPercentIndicator(
                      //circular progress indicator
                      radius: height * 0.075, //radius for circle
                      lineWidth: 15.0, //width of circle line
                      animation:
                          true, //animate when it shows progress indicator first
                      percent:
                          //totalLiquidated == 0.0 ? 0.001/100 : totalLiquidated/100, //vercentage value: 0.6 for 60% (60/100 = 0.6)
                          totalLiquidated == 0.0 
        ? 0.001 / 100 
        : (totalLiquidated / 100 > 1 ? 1 : totalLiquidated / 100),
                      center: Text(
                        "${totalLiquidated.toStringAsFixed(1)}%",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0),
                      ), //center text, you can set Icon as well
                      // footer: Text("Order this Month", style:TextStyle(
                      //   fontWeight: FontWeight.bold, fontSize: 17.0),
                      // ), //footer text
                      backgroundColor:
                          AppColors.cream, //backround of progress bar
                      circularStrokeCap: CircularStrokeCap
                          .round, //corner shape of progress bar at start/end
                      progressColor: AppColors.burnt, //progress bar color
                    )),
                    SizedBox(width: width * 0.05),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: width * 0.03,
                              height: width * 0.03,
                              color: AppColors.burnt,
                            ),
                            SizedBox(width: width * 0.01),
                            Text(
                              "Liquidated",
                              style: TextStyle(
                                fontSize: height * 0.015,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              " ( ${liquidatedAmount.toStringAsFixed(2)} )",
                              style: TextStyle(
                                fontSize: height * 0.015,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.02),
                        Row(
                          children: [
                            Container(
                              width: width * 0.03,
                              height: width * 0.03,
                              color: AppColors.cream,
                            ),
                            SizedBox(width: width * 0.01),
                            Text(
                              "Rem. Balance",
                              style: TextStyle(
                                fontSize: height * 0.015,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              " (${remainingBalance.toStringAsFixed(2)})",
                              style: TextStyle(
                                fontSize: height * 0.015,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: height * 0.05),
              Container(
                height: height * 0.04,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Container(),
                    ElevatedButton(
                      onPressed: () async {
                        // showAlertDialog(height, width);
                        if(await requestStoragePermission(Permission.storage)==true){
                          print("Permission granted");
                        }
                        else{
                          print("Permission denied");
                        }
                        
                      }, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cream,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),

                        )
                        
                      ),
                      child: Text("Give Permission")),
                    ElevatedButton(
                      onPressed: () async {
                        // showAlertDialog(height, width);
                        exportDataToExcel();
                        
                      }, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cream,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),

                        )
                        
                      ),
                      child: Text("Export")),
                  ],
                ),
              ),
              SizedBox(height: height * 0.01),
              Container(
                width: width * 0.96,
                height: height * 0.8,
                color: AppColors.bg,
        
                child: DataTable(

                  dataRowMinHeight: height * 0.03,
                  columns: [
                    // DataColumn(label: Text('ID')),
                    DataColumn(label: SizedBox(
                      width: width * 0.11,
                      child: Text('Payee')),),

                    DataColumn(label: SizedBox(
                      width: width * 0.13,
                      child: Text('Amount')),),

                    DataColumn(label: SizedBox(
                      width: width * 0.11,
                      child: Text('Date')),),

                    DataColumn(label: SizedBox(
                      width: width * 0.12,
                      child: Text('Actions')),),


                    // DataColumn(label: Text('Amount')),
                    // // DataColumn(label: Text('Balance')),
                    // DataColumn(label: Text('Date')),
                    // DataColumn(label: Text('Actions')),
                  ],
                  rows:
                  List<DataRow>.generate( 
                    transactionDetails.length, (index) =>
                    DataRow(
                      cells: [
                      // DataCell(Text('1')),
                      DataCell(SizedBox(
                        width: width * 0.11,
                        child: Text(transactionDetails[index].payee,
                        style: TextStyle(
                          fontSize: height * 0.014,
                        ),),
                      ),),
                      DataCell(SizedBox(
                        width: width * 0.13,
                        child: Text(transactionDetails[index].amount.toString(),
                        style: TextStyle(
                          fontSize: height * 0.014,
                        ),),
                      ),),
                      // DataCell(Text(balance[index].toString(),
                      // style: TextStyle(
                      //   fontSize: height * 0.014,
                      // ),),),
                      DataCell(SizedBox(
                        width: width * 0.11,
                        child: Text(transactionDetails[index].date,
                        style: TextStyle(
                          fontSize: height * 0.014,
                        ),),
                      ),),
                      DataCell(SizedBox(
                        width: width * 0.1,
                        child: PopupMenuButton(
                          color: Colors.white,
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'Edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: 'Update',
                              child: Text('Update'),
                            ),
                            PopupMenuItem(
                              value: 'Delete',
                              child: Text('Delete'),
                              onTap: (){
                                deleteTransactionDetails(transactionDetails[index].id);
                              },
                            ),
                            
                          ],
                        ),
                      ))
        
                      //  DataCell(
                      //     DropdownButton<String>(
                      //       onChanged: (String? value) {
                      //         if (value == 'Edit') {
                      //           // _editRow(index);
                      //         } else if (value == 'Delete') {
                      //           // _deleteRow(index);
                      //         } else if (value == 'Update') {
                      //           // _updateRow(index);
                      //         }
                      //       },
                      //       items: [
        
                      //         DropdownMenuItem(
                      //           value: 'Edit',
                      //           child: Text('Edit'),
                      //         ),
                      //         DropdownMenuItem(
                      //           value: 'Delete',
                      //           child: Text('Delete'),
                      //         ),
                      //         DropdownMenuItem(
                      //           value: 'Update',
                      //           child: Text('Update'),
                      //         ),
                      //       ],
                      //       hint: Text('Actions'),
                      //     ),
                      //  )
                    ]),
                )
                ),
                // decoration: BoxDecoration(
              )
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showAlertDialog(height, width);
        },
        tooltip: 'Add Row',
        backgroundColor: AppColors.cream,
        child: Icon(Icons.add, color: AppColors.brown),
      ),
    );
  }

  void showAlertDialog(double height, double width) {
    // _dateController.clear();

    // set up the button
    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: const Text('Add Liquidation'),
          content: SingleChildScrollView(
            child: SizedBox(
              height: height * 0.5,
              width: width * 0.94,
              child: Column(
                children: [
                  TextFormField(
                    // controller: eventController,
                    controller: _payeeController,
                    decoration: const InputDecoration(
                      labelText: 'Payee',
                      
                    ),
                    style: TextStyle(
                      fontSize: height * 0.015,
                    ),
                    
                  ),
                  SizedBox(height: height * 0.02),
                  TextFormField(
                    controller: _or_siController,
                    decoration: const InputDecoration(
                      labelText: 'OR or SI',
                      
                    ),
                    style: TextStyle(
                      fontSize: height * 0.015,
                    ),
                    
                  ),
                  SizedBox(height: height * 0.02),
                  TextFormField(
                    controller: _particularsController,
                    decoration: const InputDecoration(
                      labelText: 'Particulars',
                      
                    ),
                    style: TextStyle(
                      fontSize: height * 0.015,
                    ),
                    
                  ),
                  SizedBox(height: height * 0.02),
                  TextFormField(
                    // controller: eventController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),

                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      
                    ),
                    style: TextStyle(
                      fontSize: height * 0.015,
                    ),
                    
                    
                  ),
                  SizedBox(height: height * 0.02),
                  TextFormField(
                      readOnly: true,
                      controller: _dateController,
                      decoration: InputDecoration(
                        // filled: true,
                        // fillColor: Colors.grey[200],
                        labelText: 'Select Date mm/dd/yyyy',
                        // border: OutlineInputBorder(
                        //   borderRadius: BorderRadius.all(
                        //     Radius.circular(10.0),
                        //   ),
                        // ),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          _dateController.text = DateFormat('MM/dd/yyyy').format(pickedDate);
                        }
                      },
                    ),
                    SizedBox(height: height * 0.02),
                    Row(
                      children: [ 
                        
                        ElevatedButton(
                        onPressed: () async {
                          getPictures();
                        },
                        child: Icon(Icons.document_scanner),
                      ),
                      SizedBox(width: width * 0.02),
                      Text("capture or upload", style: TextStyle(fontSize: height * 0.011),),

                      ]
                    ),
                    
                ],
                
              ),
              
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // if(double.parse(_amountController.text) > currentBalance){
                //   print("Insufficient Balances sdsdsd");
                // }else{
                //                   addTransaction();

                // }
                addTransaction();
                // if(double.parse(_amountController.text) > widget.fund && counter == 0){
                //    print("Insufficient Balances sdsdsd");
                // }
                // else if(double.parse(_amountController.text) > balance.last && counter != 0){
                //   print("Insufficient Balance");
                // }
                // else{

                //     addTransaction();
                // //                           try {
                // // addTransaction(liquidations.length);
                //   print("Added Successfully");
                // // print(liquidations.length);
                // // } catch (e) {
                // //   print("Failed to add transaction: $e");
                // // }
                // }
              
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
