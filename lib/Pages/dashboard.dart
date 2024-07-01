import 'package:flutter/material.dart';
import 'package:liquidapp/Constants/ui.dart';
import 'package:liquidapp/Databases/model.dart';
import 'package:liquidapp/Pages/liquidation.dart';
import 'package:percent_indicator/circular_percent_indicator.dart'; 


class Dashboard extends StatefulWidget {
  final Liquidation liquidation;
  const Dashboard({super.key, required this.liquidation});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(height * 0.06),
        child: AppBar(
          backgroundColor: AppColors.cream,
        )),
      backgroundColor: AppColors.bg,
      body: Container(
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
                     child: CircularPercentIndicator( //circular progress indicator
                      radius: height * 0.075, //radius for circle
                      lineWidth: 15.0, //width of circle line
                      animation: true, //animate when it shows progress indicator first
                      percent: 60/100, //vercentage value: 0.6 for 60% (60/100 = 0.6)
                      center: Text("60.0%",style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20.0),
                      ), //center text, you can set Icon as well
                      // footer: Text("Order this Month", style:TextStyle( 
                      //   fontWeight: FontWeight.bold, fontSize: 17.0),
                      // ), //footer text 
                      backgroundColor: AppColors.cream, //backround of progress bar
                      circularStrokeCap: CircularStrokeCap.round, //corner shape of progress bar at start/end
                      progressColor: AppColors.burnt, //progress bar color
                    )
                  ),
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
                            " ()",
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
                            " ()",
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
              width: width * 0.96,
              height: height * 0.5,
              color: AppColors.cream,

              child: DataTable(
                columns: [
            // DataColumn(label: Text('ID')),
            DataColumn(label: Text('Payee')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Balance')),
            DataColumn(label: Text('Actions')),
          ],
          rows: [
            DataRow(cells: [
              // DataCell(Text('1')),
              DataCell(Text('John')),
              DataCell(Text('25')),
              DataCell(Text('20')),
            DataCell(PopupMenuButton(
              color: Colors.white,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'Edit',
                  child: Text('Edit'),
                ),
                PopupMenuItem(
                  value: 'Delete',
                  child: Text('Delete'),
                ),
                PopupMenuItem(
                  value: 'Update',
                  child: Text('Update'),
                ),
              ],
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
          ],
              ),
              // decoration: BoxDecoration(
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        tooltip: 'Add Row',
        backgroundColor: AppColors.cream,
        child: Icon(Icons.add, color: AppColors.brown),
      ),
    );
  }
}