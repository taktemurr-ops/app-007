import 'package:flutter_test/flutter_test.dart';
import 'package:uyg_tarif_kutusu/uyg_tarif_kutusu.dart';

void main() {
  test('33 dilde ad ve açıklama, doğru kimlik', () {
    expect(tarifKutusuTool.id, tarifKutusuId);
    expect(tarifKutusuTool.title.length, 33);
    expect(tarifKutusuTool.tagline.length, 33);
  });
}
