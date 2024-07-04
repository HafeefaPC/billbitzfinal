import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:url_launcher/url_launcher.dart';

class Scanner extends StatefulWidget {
  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  ScanResult? scanResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _scan,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blue, // Button text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0), // Rectangle shape
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Button padding
                  ),
                  child: Text('Scan QR Code'),
                ),
              ),
              if (scanResult != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () => _openUPIUrl(scanResult!.rawContent),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.blue, // Button text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0), // Rectangle shape
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Button padding
                          ),
                          child: Text('Pay with Google Pay'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _scan() async {
    try {
      final result = await BarcodeScanner.scan();
      setState(() => scanResult = result);
      if (result.rawContent.isNotEmpty) {
        _openUPIUrl(result.rawContent);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No QR code scanned')),
        );
      }
    } on Exception catch (e) {
      setState(() {
        scanResult = ScanResult(
          rawContent: 'Failed to get QR code',
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning QR code: $e')),
      );
    }
  }

  void _openUPIUrl(String url) async {
    if (_isUPIUrl(url)) {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scanned data is not a valid UPI URL')),
      );
    }
  }

  bool _isUPIUrl(String url) {
    // Check if the scanned data matches the UPI URL pattern
    final uri = Uri.tryParse(url);
    return uri != null && uri.scheme == 'upi';
  }
}
