import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hashguru/theme/colors.dart';
import 'package:hashguru/widgets/ambient_background.dart';
import 'package:hashguru/widgets/glass_card.dart';
import 'package:hashguru/widgets/hg_button.dart';
import 'package:hashguru/widgets/hg_input.dart';
import 'package:hashguru/widgets/particle_wave.dart';

void main() {
  group('HushGuru design system', () {
    test('exports brand palette and Jost text styles', () {
      expect(HgColors.navy, const Color(0xFF203C6B));
      expect(HgColors.coral, const Color(0xFFD8685B));
      expect(HgColors.blush, const Color(0xFFF7E1DE));
      expect(HgColors.sunriseGradient.colors, hasLength(4));

      final textStylesSource = File(
        'lib/theme/text_styles.dart',
      ).readAsStringSync();
      expect(textStylesSource, contains('abstract final class HgText'));
      expect(textStylesSource, contains('GoogleFonts.jost'));
      expect(textStylesSource, contains('static TextStyle h1'));
      expect(textStylesSource, contains('static TextStyle button'));
    });

    testWidgets('renders primary, outline, and white button variants', (
      tester,
    ) async {
      var taps = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                HgButton(label: 'Primary', onTap: () => taps++),
                HgButton(
                  label: 'Outline',
                  variant: HgButtonVariant.outline,
                  onTap: () => taps++,
                ),
                HgButton(
                  label: 'White',
                  variant: HgButtonVariant.white,
                  onTap: () => taps++,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Outline'), findsOneWidget);
      expect(find.text('White'), findsOneWidget);

      await tester.tap(find.text('Primary'));
      await tester.tap(find.text('Outline'));
      await tester.tap(find.text('White'));
      expect(taps, 3);
    });

    testWidgets('renders frosted glass card and coral-focused input', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(child: HgInput(label: 'Email address')),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.byType(HgInput), findsOneWidget);

      await tester.tap(find.byType(TextField));
      await tester.pump();

      final focusedInput = tester.widget<TextField>(find.byType(TextField));
      final focusedBorder = focusedInput.decoration?.focusedBorder;
      expect(focusedBorder, isA<OutlineInputBorder>());
      expect(
        (focusedBorder! as OutlineInputBorder).borderSide.color,
        HgColors.coral,
      );
    });

    testWidgets('animates star and wave particle modes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ParticleWave(mode: ParticleMode.stars)),
      );
      expect(find.byType(CustomPaint), findsWidgets);

      await tester.pump(const Duration(milliseconds: 16));
      expect(find.byType(CustomPaint), findsWidgets);

      await tester.pumpWidget(
        const MaterialApp(home: ParticleWave(mode: ParticleMode.wave)),
      );
      expect(find.byType(CustomPaint), findsWidgets);

      await tester.pump(const Duration(milliseconds: 16));
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('stacks gradient, blur orbs, particles, and content', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AmbientBackground(
            mode: ParticleMode.wave,
            child: Center(child: Text('Practice')),
          ),
        ),
      );

      expect(find.byType(DecoratedBox), findsWidgets);
      expect(find.byType(ImageFiltered), findsNWidgets(3));
      expect(find.byType(ParticleWave), findsOneWidget);
      expect(find.text('Practice'), findsOneWidget);
    });
  });
}
