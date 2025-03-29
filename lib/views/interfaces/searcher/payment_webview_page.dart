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
                  // Check if the loaded URL is the Paymee gateway URL or a URL that might contain the JSON response.
                  if (url.startsWith('https://sandbox.paymee.tn/gateway') ||
                      url.contains('return_url.tn') ||
                      url.contains('cancel_url.tn')) {
                    debugPrint(
                        'Detected Paymee gateway URL or return/cancel URL.');
                    // Attempt to extract JSON from <pre> tag or body if <pre> is not found
                    String? pageSource = await _webViewController
                        ?.runJavaScriptReturningResult('''
                      (function() {
                        try {
                          var preTags = document.getElementsByTagName('pre');
                          if (preTags.length > 0) {
                            return preTags[0].innerText;
                          } else {
                            return document.body.innerText;
                          }
                        } catch (e) {
                          return '{"status": false, "message": "Failed to extract page content", "code": -1}';
                        }
                      })();
                    ''') as String?;
                    debugPrint('Page source from WebView: $pageSource');

                    if (pageSource != null && pageSource.trim().isNotEmpty) {
                      try {
                        Map<String, dynamic> responseJson =
                            jsonDecode(pageSource);
                        debugPrint(
                            "Paymee API Response (parsed): $responseJson");

                        if (responseJson['status'] == true) {
                          debugPrint('Payment status: Success');
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentSuccessPage(
                                orderId: widget.orderId,
                              ),
                            ),
                          );
                        } else {
                          debugPrint('Payment status: Failed');
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentErrorPage(),
                            ),
                          );
                        }
                      } catch (e) {
                        debugPrint("Error parsing JSON: $e");
                        debugPrint(
                            'Page source that failed to parse: $pageSource');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentErrorPage(),
                          ),
                        );
                      }
                    } else {
                      debugPrint(
                          'Page source is null or empty, or not a JSON response.');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentErrorPage(),
                        ),
                      );
                    }
                  } else {
                    debugPrint(
                        'URL is not a Paymee gateway URL, ignoring JSON check.');
                  }
                },
              ),
            ),
        ),
      ),
    );
  }
}
