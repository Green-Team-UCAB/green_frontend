import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:green_frontend/features/multiplayer/presentation/bloc/multiplayer_bloc.dart';
import 'package:green_frontend/core/storage/token_storage.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/session_pin.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/client_role.dart';

class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  bool isPinSelected = true;
  bool isEnteringNickname = false;
  String pin = '';
  String nickname = '';

  final MobileScannerController cameraController = MobileScannerController();
  final TextEditingController pinTextController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final FocusNode pinFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    pinTextController.addListener(() {
      final txt = pinTextController.text;
      if (txt.length > 10) {
        pinTextController.text = txt.substring(0, 10);
      }
      pinTextController.selection = TextSelection.fromPosition(
        TextPosition(offset: pinTextController.text.length),
      );
      setState(() => pin = pinTextController.text);
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    pinTextController.dispose();
    nicknameController.dispose();
    pinFocusNode.dispose();
    super.dispose();
  }

  void onQrScanned(String qrToken) {
    debugPrint('QR escaneado: $qrToken');
    setState(() {
      pin = qrToken;
      isEnteringNickname = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<MultiplayerBloc, MultiplayerState>(
      listener: (context, state) {
        if (state.status == MultiplayerStatus.inLobby) {
          Navigator.pushReplacementNamed(context, '/multiplayer_lobby');
        }
        if (state.status == MultiplayerStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure?.message ?? 'Error')),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF9D50BB), Color(0xFF6E48AA)],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
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
                  if (!isEnteringNickname)
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
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.only(bottom: bottomInset > 0 ? 20 : 0),
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: isEnteringNickname
                              ? _buildNicknameInputArea()
                              : (isPinSelected
                                  ? _buildPinInputArea()
                                  : _buildQrScannerArea()),
                        ),
                      ),
                    ),
                  ),
                  _buildJoinButton(bottomInset),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNicknameInputArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "INGRESA TU NICKNAME",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          constraints: const BoxConstraints(maxWidth: 280),
          child: TextField(
            controller: nicknameController,
            maxLength: 20,
            autofocus: true,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.characters,
            onChanged: (val) => setState(() => nickname = val),
            style: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
            decoration: InputDecoration(
              hintText: "NICKNAME",
              hintStyle: TextStyle(color: Colors.black26),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              counterStyle: TextStyle(color: Colors.black54),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            "${nickname.length} / 20 caracteres",
            style: TextStyle(
              color: (nickname.length >= 6 && nickname.length <= 20)
                  ? Colors.black54
                  : Colors.redAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 30),
        TextButton.icon(
          onPressed: () {
            setState(() {
              isEnteringNickname = false;
              nickname = '';
              nicknameController.clear();
            });
          },
          icon: const Icon(Icons.edit, color: Colors.black54, size: 16),
          label: const Text("EDITAR PIN / QR",
              style: TextStyle(color: Colors.black54, fontSize: 12)),
        )
      ],
    );
  }

  Widget _buildPinInputArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => pinFocusNode.requestFocus(),
          child: Text(
            pin.isEmpty ? 'PIN' : _formatPinForDisplay(pin),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: pin.isEmpty ? Colors.white24 : Colors.white,
              fontSize: pin.length > 7 ? 50 : 70,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
        ),
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
    );
  }

  Widget _buildQrScannerArea() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 280, maxHeight: 280),
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
                      if (barcode.rawValue != null) {
                        onQrScanned(barcode.rawValue!);
                      }
                    },
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(painter: _ScannerOverlayPainter()),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),
        const Text("Alinea el código QR en el cuadro",
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }

  Widget _buildJoinButton(double bottomInset) {
    bool isEnabled = isEnteringNickname
        ? (nickname.trim().length >= 6 && nickname.trim().length <= 20)
        : (pin.length >= 6);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottomInset + 20, left: 40, right: 40),
      child: BlocBuilder<MultiplayerBloc, MultiplayerState>(
        builder: (context, state) {
          final bool isLoading = state.status == MultiplayerStatus.connecting;

          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6E48AA),
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              elevation: 5,
            ),
            onPressed: (isEnabled && !isLoading) ? _handleJoinAction : null,
            child: isLoading
                ? CircularProgressIndicator(color: const Color(0xFF6E48AA))
                : Text(
                    isEnteringNickname ? '¡A JUGAR!' : 'SIGUIENTE',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          );
        },
      ),
    );
  }

  void _handleJoinAction() async {
    if (!isEnteringNickname) {
      setState(() => isEnteringNickname = true);
    } else {
      final token = await TokenStorage.getToken();
      if (!mounted) return;

      final bloc = context.read<MultiplayerBloc>();

      if (isPinSelected) {
        bloc.add(OnConnectStarted(
          role: ClientRole.player,
          pin: SessionPin(pin),
          jwt: token ?? '',
          nickname: nickname,
        ));
      } else {
        bloc.add(OnResolvePinStarted(
          qrToken: pin,
          jwt: token ?? '',
          nickname: nickname,
        ));
      }
    }
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

    const l = 30.0;
    canvas.drawLine(const Offset(0, l), const Offset(0, 0), cornerPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(l, 0), cornerPaint);
    canvas.drawLine(
        Offset(size.width - l, 0), Offset(size.width, 0), cornerPaint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, l), cornerPaint);
    canvas.drawLine(
        Offset(0, size.height - l), Offset(0, size.height), cornerPaint);
    canvas.drawLine(
        Offset(0, size.height), Offset(l, size.height), cornerPaint);
    canvas.drawLine(Offset(size.width - l, size.height),
        Offset(size.width, size.height), cornerPaint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - l), cornerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

