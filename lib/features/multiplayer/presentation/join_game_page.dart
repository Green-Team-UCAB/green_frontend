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

  @override
  void initState() {
    super.initState();
    pinTextController.addListener(() {
      final txt = pinTextController.text;
      if (txt.length > 6) {
        pinTextController.text = txt.substring(0, 6);
        pinTextController.selection = TextSelection.fromPosition(
          const TextPosition(offset: 6),
        );
      }
      setState(() => pin = pinTextController.text);
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    pinTextController.dispose();
    pinFocusNode.dispose();
    super.dispose();
  }

  void onQrScanned(String qrToken) {
    debugPrint('QR escaneado: $qrToken');
    Navigator.of(context).pop(qrToken);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      // Evitamos que el teclado redimensione los widgets bruscamente
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. FONDO DEGRADADO MORADO ACTUALIZADO
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF9D50BB), // Púrpura vibrante
                  Color(0xFF6E48AA), // Púrpura profundo
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // 2. TOP BAR 
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Unirse a un juego',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                // 3. TOGGLE PILLS (Refinado con el nuevo estilo)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildPill('Ingresar PIN', isPinSelected, () {
                            setState(() => isPinSelected = true);
                          }),
                        ),
                        Expanded(
                          child: _buildPill('Escanear QR', !isPinSelected, () {
                            pinFocusNode.unfocus();
                            setState(() => isPinSelected = false);
                          }),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // 4. CONTENIDO CENTRAL (PIN O SCANNER)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset * 0.2 : 0),
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: isPinSelected
                      ? _buildPinInputArea()
                      : _buildQrScannerArea(),
                      ),
                    ),
                  ),
                ),

                // 5. BOTÓN JOIN NOW (Ajustado al nuevo estilo)
                _buildJoinButton(bottomInset),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinInputArea() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => pinFocusNode.requestFocus(),
            child: Text(
              pin.isEmpty ? 'PIN' : _formatPinForDisplay(pin),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: pin.isEmpty ? const Color.fromARGB(137, 232, 229, 229) : Colors.white,
                fontSize: 80,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
          ),
          //const SizedBox(height: 10),
          
          // Hidden TextField
          SizedBox(
            height: 0,
            width: 0,
            child: TextField(
              controller: pinTextController,
              focusNode: pinFocusNode,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrScannerArea() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300, maxHeight: 300),
            child: AspectRatio(
              aspectRatio: 1,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: MobileScanner(
                    controller: cameraController,
                    onDetect: (capture) {
                      final barcode = capture.barcodes.first;
                      if (barcode.rawValue != null) onQrScanned(barcode.rawValue!);
                    },
                  ),
                ),
                // Overlay corners mejorado
                Positioned.fill(
                  child: CustomPaint(painter: _ScannerOverlayPainter()),
                ),
              ],
            ),
            ),
          ),
        ),
        const SizedBox(height: 25),
        const Text(
          "Align the QR code inside the box",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildJoinButton(double bottomInset) {
    bool isEnabled = pin.length >= 4;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(
        bottom: bottomInset > 0 ? bottomInset + 20 : 40,
        left: 30,
        right: 30,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? Colors.white : Colors.white24,
            foregroundColor: const Color(0xFF6E48AA),
            elevation: isEnabled ? 8 : 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: isEnabled ? () => Navigator.of(context).pop(pin) : null,
          child: const Text(
            'INGRESAR',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildPill(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? const Color(0xFF6E48AA) : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatPinForDisplay(String p) {
    if (p.length <= 3) return p;
    return '${p.substring(0, 3)} ${p.substring(3)}';
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(30),
    );
    canvas.drawRRect(rect, paint);

    final cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const l = 30.0; // Largo de las esquinas
    
    // Esquina superior izquierda
    canvas.drawLine(const Offset(0, l), const Offset(0, 0), cornerPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(l, 0), cornerPaint);
    // Esquina superior derecha
    canvas.drawLine(Offset(size.width - l, 0), Offset(size.width, 0), cornerPaint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, l), cornerPaint);
    // Esquina inferior izquierda
    canvas.drawLine(Offset(0, size.height - l), Offset(0, size.height), cornerPaint);
    canvas.drawLine(Offset(0, size.height), Offset(l, size.height), cornerPaint);
    // Esquina inferior derecha
    canvas.drawLine(Offset(size.width - l, size.height), Offset(size.width, size.height), cornerPaint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - l), cornerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}