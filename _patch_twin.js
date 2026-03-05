const fs = require('fs');
const f = 'c:/Users/ADMIN/Downloads/medailockr--simple-secure-smarter-healthcare-version-5.00/flutter_mediqly/lib/screens/health_twin/health_twin_screen.dart';
let c = fs.readFileSync(f, 'utf8');

// ── 1. Replace _logWater + _logFood with full implementations ──────────────
const START_MARKER = '  void _logWater()';
const END_MARKER   = '  @override\n  Widget build(BuildContext context)';

const newMethods = `  void _logWater([int ml = 250]) {
    _twin.logWater();
    setState(() => _waterFlash = true);
    _toast('\${ml}ml water logged', type: 'success');
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _waterFlash = false);
    });
  }

  Future<void> _pickWaterAmount() async {
    const picks = [150, 250, 350, 500, 750, 1000];
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _slate900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.local_drink_outlined, color: _blue500, size: 18),
              const SizedBox(width: 8),
              const Text('Log Water Intake',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.close, color: _slate400, size: 18),
              ),
            ]),
            const SizedBox(height: 4),
            const Text('Select cup size', style: TextStyle(color: _slate400, fontSize: 12)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: picks.map((ml) => GestureDetector(
                onTap: () { Navigator.pop(ctx); _logWater(ml); },
                child: Container(
                  width: 90,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _slate800,
                    border: Border.all(color: _blue500.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.water_drop_outlined, color: _blue500, size: 22),
                    const SizedBox(height: 6),
                    Text('\${ml}ml', style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  ]),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMeal() async {
    final ctrl = TextEditingController();
    final meal = await showDialog<String>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setSt) => AlertDialog(
          backgroundColor: _slate900,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [
            Icon(Icons.restaurant_outlined, color: _amber500, size: 20),
            SizedBox(width: 8),
            Text('Log Meal',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('What did you eat?', style: TextStyle(color: _slate400, fontSize: 13)),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g. Chicken salad, brown rice...',
                  hintStyle: const TextStyle(color: _slate600),
                  filled: true,
                  fillColor: _slate800,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _slate700),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _slate700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _amber500),
                  ),
                ),
                onSubmitted: (v) => Navigator.pop(ctx2, v.trim()),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Smoothie', 'Coffee']
                    .map((s) => GestureDetector(
                          onTap: () => setSt(() => ctrl.text = s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _slate800,
                              border: Border.all(color: _amber500.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(s,
                                style: const TextStyle(color: _slate300, fontSize: 11)),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx2),
              child: const Text('Cancel', style: TextStyle(color: _slate400)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx2, ctrl.text.trim()),
              child: const Text('Log',
                  style: TextStyle(color: _amber500, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
    if (meal != null && meal.isNotEmpty) {
      _twin.logMeal(meal);
      setState(() => _foodFlash = true);
      _toast('Meal logged: \$meal', type: 'success');
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _foodFlash = false);
      });
    }
  }

  Future<void> _openVoiceAssistant() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _slate900,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _VoiceAssistantSheet(
        vitalsContext:
            'HR: \${_twin.vitals.heartRate.toStringAsFixed(0)} bpm, '
            'BP: \${_twin.vitals.systolicBP.toStringAsFixed(0)}/\${_twin.vitals.diastolicBP.toStringAsFixed(0)}, '
            'SpO2: \${_twin.vitals.oxygenSat.toStringAsFixed(0)}%, '
            'Temp: \${_twin.vitals.temperature.toStringAsFixed(1)}C, '
            'Resp: \${_twin.vitals.respRate.toStringAsFixed(0)}/min',
      ),
    );
  }

`;

const startIdx = c.indexOf(START_MARKER);
const endIdx   = c.indexOf(END_MARKER);
if (startIdx === -1) { console.error('START_MARKER not found'); process.exit(1); }
if (endIdx   === -1) { console.error('END_MARKER not found');   process.exit(1); }

c = c.slice(0, startIdx) + newMethods + c.slice(endIdx);
console.log('Methods replaced. New size:', c.length);

// ── 2. Fix onBt toast + wire all buttons ───────────────────────────────────
const OLD_BT = `                    onBt: () {
                      twin.toggleBluetooth();
                      _toast(twin.bluetoothConnected ? 'Device disconnected.' : 'Connected: Polar H10', type: twin.bluetoothConnected ? 'info' : 'success');
                    },
                    onVoice: () {},
                    onWater: _logWater,
                    onFood: _logFood,
                    onSound: () {
                      setState(() => _soundEnabled = !_soundEnabled);
                      _toast(_soundEnabled ? 'Ambient sound on' : 'Ambient sound off');
                    },`;
const NEW_BT = `                    onBt: () {
                      final wasConnected = twin.bluetoothConnected;
                      twin.toggleBluetooth();
                      _toast(wasConnected ? 'Polar H10 disconnected.' : 'Connected: Polar H10',
                          type: wasConnected ? 'info' : 'success');
                    },
                    onVoice: _openVoiceAssistant,
                    onWater: _pickWaterAmount,
                    onFood: _pickMeal,
                    onSound: () {
                      final willEnable = !_soundEnabled;
                      setState(() => _soundEnabled = willEnable);
                      _toast(willEnable ? 'Ambient sound on' : 'Ambient sound off');
                    },`;

if (!c.includes(OLD_BT)) { console.error('OLD_BT block not found'); process.exit(1); }
c = c.replace(OLD_BT, NEW_BT);
console.log('Button handlers fixed.');

fs.writeFileSync(f, c, 'utf8');
console.log('File written. Final size:', c.length);
