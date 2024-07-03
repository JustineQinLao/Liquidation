import 'package:flutter/material.dart';
import 'package:liquidapp/Constants/ui.dart';
import 'package:liquidapp/Databases/db_connection.dart';
import 'package:liquidapp/Databases/model.dart';
import 'package:liquidapp/Pages/dashboard.dart';



class Liquid extends StatefulWidget {
  const Liquid({super.key});

  @override
  State<Liquid> createState() => _LiquidState();
}

class _LiquidState extends State<Liquid> {
  
  final databaseHelper = DatabaseHelper();

  final TextEditingController eventController = TextEditingController();
  final TextEditingController fundController = TextEditingController();
  
  List<Liquidation> liquidations = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();

  }

  Future<void> _loadTransactions() async {

    var transactions = await databaseHelper.getDataTransaction();
      setState(() {
      liquidations = transactions;
    });
    
  }

  Future<void> addTransaction(int id) async {
    final event = eventController.text;
    final fund = double.tryParse(fundController.text) ?? 0.0;
    if(liquidations.length == 0){
      id = 0;
    }else{
      // id = liquidations.last.id + 1;
      // id = liquidations.length + 1;
      id = id + 1;
    }

    var newTransaction = Liquidation(id: id, event: event, fund: fund);
    await databaseHelper.insertDataTransaction(newTransaction);

    _loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    // await databaseHelper.deleteTransaction(id);
    // _loadTransactions();
    try {
      await databaseHelper.deleteTransaction(id);
      _loadTransactions();
      print("Transaction deleted successfully");
    } catch (e) {
      print("Error deleting transaction: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(height * 0.06), 
        
        child: AppBar(
          title: const Text('Liquidation'),
          backgroundColor: AppColors.cream,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Add Liquidation'),
                      content: SizedBox(
                        height: height * 0.2,
                        width: width * 0.90,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: eventController,
                              decoration: const InputDecoration(
                                labelText: 'Event',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please input event';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: height * 0.03),
                            TextFormField(
                              controller: fundController,
                              decoration: const InputDecoration(
                                labelText: 'Fund',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please input fund';
                                }
                                if(double.tryParse(value) == null){
                                  return 'Please input a valid number';
                                }
                                return null;
                              },
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
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            
  //                           try {
    addTransaction(liquidations.length);
    print("Added Successfully");
    // print(liquidations.length);
  // } catch (e) {
  //   print("Failed to add transaction: $e");
  // }
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),),
        backgroundColor: AppColors.bg,
        body: Container(
        height: height * 0.88,
        width: width, 
        // color: ,
        // child: Container()
        child: ListView.builder(
          itemCount: liquidations.length,
          itemBuilder: (context, index) {
            final liquid = liquidations[index];
            // return ListTile(
            //   title: Text('${liquid.event} Fund: ${liquid.fund}'),
            //   subtitle: Text('${liquid.id}'),
            // );

            return GestureDetector(
              onTap: () {
                Navigator.push(context, 
                MaterialPageRoute(builder: 
                
                (context) => Dashboard(event: liquid.event, fund: liquid.fund, id: liquid.id, )),
                );
              },
              child: Container(
                height: height * 0.1,
                margin: EdgeInsets.symmetric(horizontal: width * 0.01, vertical: height * 0.002),
                padding: EdgeInsets.all(width * 0.03),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.0),
                  
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.grey.withOpacity(0.5),
                  //     spreadRadius: 1,
                  //     blurRadius: 1,
                  //     offset: Offset(0, 1),
                  //   ),
                  // ],
                ),
                child:  Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            liquid.event,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Fund: ${liquid.fund}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: 
                      // Icon(Icons.more_horiz),
                      PopupMenuButton(
                        color: Colors.white,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            
                            
                            child: Text('Delete'),
                            onTap: () {
                              deleteTransaction(liquid.id);
                              print("Deleted Successfully");
                              // deleteTransaction(liquid.id);
                            },
                          ),
                        ],
                      )
                    ),
                  ],),
                ),
            );
          
          }
          
          
          ),
      ),
      );
    

    
    
  }
}