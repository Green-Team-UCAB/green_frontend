import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';

class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  bool isPinSelected = true;
  String pin = '';
  final MobileScannerController cameraController = MobileScannerController();
  final TextEditingController pinTextController = TextEditingController();
  final FocusNode pinFocusNode = FocusNode();

  void onQrScanned(String qrToken) {
    // Aquí puedes resolver el PIN desde el token escaneado
    debugPrint('QR escaneado: $qrToken');
    // Ejemplo: cerrar la pantalla y devolver el token
    Navigator.of(context).pop(qrToken);
  }

  void appendDigit(String d) {
    if (pin.length >= 6) return;
    setState(() => pin += d);
  }

  void backspace() {
    if (pin.isEmpty) return;
    setState(() => pin = pin.substring(0, pin.length - 1));
  }

  @override
  void dispose() {
    cameraController.dispose();
    pinTextController.dispose();
    pinFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    pinTextController.addListener(() {
      final txt = pinTextController.text;
      if (txt.length > 6) {
        pinTextController.text = txt.substring(0, 6);
        pinTextController.selection = TextSelection.fromPosition(
          TextPosition(offset: 6),
        );
      }
      setState(() => pin = pinTextController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado púrpura
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7B4DFF), Color(0xFF6C3CFF)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top bar (moved down a bit)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Join Game',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 28),
                    ],
                  ),
                ),

                // Toggle pills
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPill('Enter PIN', isPinSelected, () {
                        setState(() => isPinSelected = true);
                      }),
                      const SizedBox(width: 12),
                      _buildPill('Scan QR Code', !isPinSelected, () {
                        setState(() {
                          isPinSelected = false;
                        });
                        pinFocusNode.unfocus();
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Center content
                Expanded(
                  child: isPinSelected
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  pinFocusNode.requestFocus();
                                },
                                child: Text(
                                  pin.isEmpty
                                      ? 'ENTER PIN'
                                      : _formatPinForDisplay(pin),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.95),
                                    fontSize: pin.isEmpty ? 40 : 56,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // QR Scanner area
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: MobileScanner(
                                        controller: cameraController,
                                        onDetect: (capture) {
                                          final barcode = capture.barcodes
                                              .firstWhere(
                                                (b) => b.rawValue != null,
                                                orElse: () =>
                                                    capture.barcodes.first,
                                              );
                                          if (barcode.rawValue != null)
                                            onQrScanned(barcode.rawValue!);
                                        },
                                      ),
                                    ),
                                    // Overlay corners
                                    Positioned.fill(
                                      child: IgnorePointer(
                                        child: CustomPaint(
                                          painter: _ScannerOverlayPainter(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Spacer(),
                          ],
                        ),
                ),

                // Bottom area: native keyboard trigger (hidden TextField) or QR controls
                if (isPinSelected) ...[
                  // Hidden TextField to show native keyboard when user taps center text
                  Opacity(
                    opacity: 0,
                    child: TextField(
                      controller: pinTextController,
                      focusNode: pinFocusNode,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 6,
                      decoration: const InputDecoration(counterText: ''),
                    ),
                  ),
                  const SizedBox(height: 8),
                ] else ...[
                  _buildQrBottomControls(),
                ],
              ],
            ),
          ),

          // Bottom centered JOIN NOW button that moves above keyboard
          AnimatedPadding(
            duration: const Duration(milliseconds: 220),
            padding: EdgeInsets.only(
              bottom: bottomInset + 16,
              left: 24,
              right: 24,
            ),
            curve: Curves.easeOut,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 6,
                    shadowColor: Colors.black26,
                  ),
                  onPressed: isPinSelected
                      ? (pin.length >= 4
                            ? () => Navigator.of(context).pop(pin)
                            : null)
                      : () {},
                  child: Text(
                    'JOIN NOW',
                    style: TextStyle(
                      color: Colors.deepPurple[700],
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? const Color(0xFF6C3CFF) : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildQrBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {},
            icon: const CircleAvatar(
              backgroundColor: Color(0xFF4B2FFF),
              child: Icon(Icons.photo, color: Colors.white),
            ),
          ),
          const SizedBox(width: 24),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B4DFF), Color(0xFF6C3CFF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 24),
          IconButton(
            onPressed: () {},
            icon: const CircleAvatar(
              backgroundColor: Color(0xFF4B2FFF),
              child: Icon(Icons.folder_open, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPinForDisplay(String p) {
    // separa en bloques de 3 como en la referencia: "465 789"
    if (p.length <= 3) return p;
    final first = p.substring(0, p.length <= 3 ? p.length : 3);
    final rest = p.length > 3 ? p.substring(3) : '';
    return rest.isEmpty ? first : '$first $rest';
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = const Color(0xFF7B4DFF);

    final rect = Rect.fromLTWH(
      size.width * 0.05,
      size.height * 0.05,
      size.width * 0.9,
      size.height * 0.9,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(20));
    canvas.drawRRect(rrect, paint);

    // corner decorations
    final cornerPaint = Paint()
      ..color = const Color(0xFF7B4DFF)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 28.0;
    // top-left
    canvas.drawLine(
      Offset(rect.left, rect.top + len),
      Offset(rect.left, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + len, rect.top),
      cornerPaint,
    );
    // top-right
    canvas.drawLine(
      Offset(rect.right - len, rect.top),
      Offset(rect.right, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + len),
      cornerPaint,
    );
    // bottom-left
    canvas.drawLine(
      Offset(rect.left, rect.bottom - len),
      Offset(rect.left, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + len, rect.bottom),
      cornerPaint,
    );
    // bottom-right
    canvas.drawLine(
      Offset(rect.right - len, rect.bottom),
      Offset(rect.right, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom - len),
      Offset(rect.right, rect.bottom),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
