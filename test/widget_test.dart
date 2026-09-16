import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zereader/main.dart';
import 'package:zereader/providers/language_provider.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LanguageProvider(),
        child: const ZEReader(),
      ),
    );
    expect(find.byType(ZEReader), findsOneWidget);
    await tester.pumpAndSettle();
  });
}
