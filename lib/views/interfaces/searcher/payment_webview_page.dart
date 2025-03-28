import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'payment_success_page.dart';
import 'payment_error_page.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String paymentUrl;
  final String orderId;

  const PaymentWebViewPage({
    Key? key,
    required this.orderId,
    required this.paymentUrl,
  }) : super(key: key);

  @override
  _PaymentWebViewPageState createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  WebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: SafeArea(
        child: WebViewWidget(
          controller: _webViewController = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadRequest(Uri.parse(widget.paymentUrl))
            ..setBackgroundColor(const Color(0x00000000))
            ..setNavigationDelegate(
              NavigationDelegate(
                onProgress: (int progress) {
                  // Update loading bar.
                },
                onPageStarted: (String url) {},
                onWebResourceError: (WebResourceError error) {},
                onNavigationRequest: (NavigationRequest request) {
                  print("Navigation to ${request.url}");
                  return NavigationDecision.navigate;
                },
                onPageFinished: (String url) async {
                  debugPrint('WebView finished loading URL: $url');
                  // Check if the loaded URL is the Paymee gateway URL
                  if (url.startsWith('https://sandbox.paymee.tn/gateway')) {
                    debugPrint('Detected Paymee gateway URL.');
                    // Attempt to extract JSON from <pre> tag or body if <pre> is not found
                    String? pageSource = await _webViewController
                        ?.runJavaScriptReturningResult('''
                      (function() {
                        var preTags = document.getElementsByTagName('pre');
                        if (preTags.length > 0) {
                          return preTags[0].innerText;
                        } else {
                          return document.body.innerText;
                        }
                      })();
                    ''') as String?;
                    debugPrint('Page source from WebView: $pageSource');

                    // Try to parse the page content as JSON
                    if (pageSource != null && pageSource.trim().isNotEmpty) {
                      try {
                        Map<String, dynamic> responseJson =
                            jsonDecode(pageSource);
                        debugPrint(
                            "Paymee API Response (parsed): $responseJson");

                        // Check the 'status' field in the JSON response
                        if (responseJson['status'] == true) {
                          // If status is true, payment is successful
                          debugPrint(
                              'Payment status from JSON: Success'); // Added debug print

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PaymentSuccessPage()),
                          );
                        } else {
                          // If status is false, payment failed
                          debugPrint(
                              'Payment status from JSON: Failed'); // Added debug print
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PaymentErrorPage()),
                          );
                        }
                      } catch (e) {
                        // JSON parsing failed
                        debugPrint("Error parsing JSON: $e");
                        debugPrint(
                            'Page source that failed to parse: $pageSource');
                      }
                    } else {
                      debugPrint('Page source is null or empty.');
                    }
                  }

                  // Check for specific return URLs for success and failure FIRST
                  if (url.contains('return_url.tn')) {
                    debugPrint(
                        'Payment status from URL: Success (return_url.tn)');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PaymentSuccessPage(
                                orderId: widget.orderId,
                              )),
                    );
                  } else if (url.contains('cancel_url.tn')) {
                    debugPrint(
                        'Payment status from URL: Failed (cancel_url.tn)');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PaymentErrorPage()),
                    );
                  }
                  // Fallback to check for generic success/fail/error keywords in URL
                  // only if specific return/cancel URLs are not found
                  else if (url.contains('success')) {
                    debugPrint(
                        'Payment status from URL: Success (generic keyword)');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PaymentSuccessPage(
                                orderId: widget.orderId,
                              )),
                    );
                  } else if (url.contains('fail') || url.contains('error')) {
                    debugPrint(
                        'Payment status from URL: Failed (generic keyword)');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PaymentErrorPage()),
                    );
                  }
                },
              ),
            ),
        ),
      ),
    );
  }
}
