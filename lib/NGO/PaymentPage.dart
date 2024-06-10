import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Paymentpage extends StatefulWidget {
  const Paymentpage({Key? key}) : super(key: key);

  @override
  State<Paymentpage> createState() => _PaymentpageState();
}

class _PaymentpageState extends State<Paymentpage> {
  final TextEditingController _amountController =
      TextEditingController(text: '0.00');
  final CollectionReference _transactions =
      FirebaseFirestore.instance.collection('transactions');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Incentives",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Form(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 25),
                Container(
                  height: 40,
                  width: 350,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 2.0),
                    ),
                  ),
                  child: Text(
                    'Enter Recycling Bonus',
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 21.59,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                ),
                SizedBox(height: 60),
                Container(
                  width: 300.39,
                  height: 148.44,
                  decoration: BoxDecoration(
                    color: Color(0xFF002D56),
                    borderRadius: BorderRadius.circular(31.62),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter Credit Amount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21.84,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                            height: 0,
                          ),
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                            height: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  onPressed: () {
                    double amount = double.parse(_amountController.text) * 100;
                    Razorpay razorpay = Razorpay();
                    var options = {
                      'key': 'rzp_test_1DP5mmOlF5G5ag',
                      'amount': amount.toInt(),
                      'name': 'Neeharika S',
                      'description': 'Plastrack: Cultivating Change',
                      'retry': {'enabled': true, 'max_count': 1},
                      'send_sms_hash': true,
                      'prefill': {
                        'contact': '8888888888',
                        'email': 'test@razorpay.com'
                      },
                      'external': {
                        'wallets': ['paytm']
                      }
                    };
                    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
                        handlePaymentErrorResponse);
                    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
                        handlePaymentSuccessResponse);
                    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
                        handleExternalWalletSelected);
                    razorpay.open(options);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'View Payment Options',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    /*
    * PaymentFailureResponse contains three values:
    * 1. Error Code
    * 2. Error Description
    * 3. Metadata
    * */
    showAlertDialog(context, "Payment Failed",
        "Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) async {
    try {
      await _transactions.add({
        'upi_transaction_id': response.paymentId,
        'amount': 25, // Replace with the actual amount
        'time_stamp': FieldValue.serverTimestamp(),
        'to_user': "Ananya Sign",
        'reason': 'Recycling Bonus'
      });

      // Show success dialog
      showAlertDialog(
          context, "Payment Successful", "Payment ID: ${response.paymentId}");
    } catch (e) {
      print('Error adding transaction to Firestore: $e');
      // Show error dialog
      showAlertDialog(
          context, "Error", "Failed to update transaction in database.");
    }
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    showAlertDialog(
        context, "External Wallet Selected", "${response.walletName}");
  }

  void showAlertDialog(BuildContext context, String title, String Message) {
    Widget continueButton = ElevatedButton(
      child: const Text("Continue"),
      onPressed: () {},
    );
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(Message),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }
}
