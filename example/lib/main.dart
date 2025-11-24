import 'package:flutter/material.dart';
import 'package:zbd_ramp/zbd_ramp.dart';
import 'dart:convert';

void main() {
  runApp(const ZBDRampExampleApp());
}

class ZBDRampExampleApp extends StatelessWidget {
  const ZBDRampExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZBD Ramp Flutter Example',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const ZBDRampHomePage(),
    );
  }
}

class ZBDRampHomePage extends StatefulWidget {
  const ZBDRampHomePage({super.key});

  @override
  State<ZBDRampHomePage> createState() => _ZBDRampHomePageState();
}

class _ZBDRampHomePageState extends State<ZBDRampHomePage> {
  String sessionToken = '';
  bool showRamp = false;
  bool debugMode = true;
  bool isLoading = false;
  bool useAccessToken = false;
  List<String> logs = [];

  final TextEditingController apiKeyController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController accessTokenController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController webhookUrlController = TextEditingController(
      text: 'https://webhook.site/79f9c0fa-8cfa-4762-9c28-e94290e8c2e1');
  final TextEditingController referenceIdController = TextEditingController();

  void addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    setState(() {
      logs.insert(0, '[$timestamp] $message');
      if (logs.length > 20) {
        logs.removeRange(20, logs.length);
      }
    });
  }

  Future<void> createSessionToken() async {
    // Validate required fields
    if (apiKeyController.text.isEmpty || destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill in API Key and Destination fields')));
      return;
    }

    // Validate authentication method
    if (useAccessToken && accessTokenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter an Access Token')));
      return;
    }

    if (!useAccessToken && emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter an Email address')));
      return;
    }

    setState(() {
      isLoading = true;
    });
    addLog('Creating session token...');

    try {
      final response = await initRampSession(InitRampSessionConfig(
        apikey: apiKeyController.text,
        email: useAccessToken ? null : emailController.text,
        accessToken: useAccessToken ? accessTokenController.text : null,
        destination: destinationController.text,
        quoteCurrency: QuoteCurrency.USD,
        baseCurrency: BaseCurrency.BTC,
        webhookUrl: webhookUrlController.text.isNotEmpty
            ? webhookUrlController.text
            : null,
        referenceId: referenceIdController.text.isNotEmpty
            ? referenceIdController.text
            : null,
        metadata: {
          'created_from': 'ramp-flutter-example',
        },
        environment: Environment.x1,
      ));

      addLog(
          'Session response: ${const JsonEncoder.withIndent('  ').convert(response.toJson())}');

      if (response.success) {
        final token = response.data.sessionToken;
        setState(() {
          sessionToken = token;
          showRamp = true;
        });
        addLog('Session token received: ${token.substring(0, 20)}...');
      } else {
        throw Exception(response.error ?? 'Failed to create session');
      }
    } catch (error) {
      addLog('ERROR: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Session Creation Error: $error')));
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleSuccess(dynamic data) {
    addLog('SUCCESS: ${jsonEncode(data)}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful! 🎉'),
        content: Text(const JsonEncoder.withIndent('  ').convert(data)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void handleError(RampError error) {
    addLog('ERROR: ${error.code} - ${error.message}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Error'),
        content: Text('${error.code}: ${error.message}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void handleStepChange(Map<String, dynamic> payload) {
    final currentStep = payload['currentStep'] ?? 'unknown';
    final previousStep = payload['previousStep'] ?? 'none';
    addLog('STEP: $previousStep → $currentStep');
  }

  void handleLog(RampLog log) {
    if (debugMode) {
      addLog('${log.level.name.toUpperCase()}: ${log.message}');
    }
  }

  void handleReady() {
    addLog('WIDGET: Ready');
  }

  void handleClose() {
    addLog('WIDGET: Closed by user');
    setState(() {
      showRamp = false;
    });
  }

  void startPayment() {
    if (sessionToken.trim().isNotEmpty) {
      addLog('Starting payment with existing session token');
      setState(() {
        showRamp = true;
      });
    } else {
      createSessionToken();
    }
  }

  void closePayment() {
    addLog('Closing payment widget');
    setState(() {
      showRamp = false;
    });
  }

  void clearLogs() {
    setState(() {
      logs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showRamp) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: closePayment,
          ),
          title: const Text('ZBD Ramp'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: ZBDRampWidget(
          config: RampConfig(
            sessionToken: sessionToken,
            environment: Environment.x1,
          ),
          callbacks: RampCallbacks(
            onSuccess: handleSuccess,
            onError: handleError,
            onStepChange: handleStepChange,
            onLog: handleLog,
            onReady: handleReady,
            onClose: handleClose,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ZBD Ramp Flutter Example'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'ZBD Ramp Flutter',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Text(
              'Example Application',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuration',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    const Text('API Key:',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    TextField(
                      controller: apiKeyController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter your ZBD API key...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Authentication Method:',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(
                          value: false,
                          label: Text('Email'),
                        ),
                        ButtonSegment<bool>(
                          value: true,
                          label: Text('Access Token'),
                        ),
                      ],
                      selected: {useAccessToken},
                      onSelectionChanged: (selection) {
                        setState(() {
                          useAccessToken = selection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (!useAccessToken) ...[
                      const Text('Email:',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'user@example.com',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ] else ...[
                      const Text('Access Token:',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      TextField(
                        controller: accessTokenController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Enter your access token...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text('Destination:',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    TextField(
                      controller: destinationController,
                      decoration: const InputDecoration(
                        hintText: 'Lightning address or username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Webhook URL:',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    TextField(
                      controller: webhookUrlController,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        hintText: 'https://your-webhook-url.com',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Reference ID (optional):',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    TextField(
                      controller: referenceIdController,
                      decoration: const InputDecoration(
                        hintText: 'Optional reference ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (sessionToken.isNotEmpty) ...[
                      const Text('Current Session Token:',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${sessionToken.substring(0, 20)}...',
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Debug Logging:',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        Switch(
                          value: debugMode,
                          onChanged: (value) => setState(() {
                            debugMode = value;
                          }),
                          activeThumbColor: Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : startPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                isLoading
                    ? 'Creating Session...'
                    : sessionToken.isNotEmpty
                        ? 'Start Payment'
                        : 'Create Session & Start Payment',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            if (sessionToken.isNotEmpty) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => setState(() {
                  sessionToken = '';
                }),
                child: const Text('Clear Session'),
              ),
            ],
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Debug Logs',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        ElevatedButton(
                          onPressed: clearLogs,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                            minimumSize: const Size(60, 30),
                          ),
                          child: const Text('Clear',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: logs.isEmpty
                          ? const Center(
                              child: Text(
                                'No logs yet...',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic),
                              ),
                            )
                          : ListView.builder(
                              itemCount: logs.length,
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  logs[index],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
