import 'package:flutter/foundation.dart' show kIsWeb;

/// 是否在瀏覽器（web 預覽）執行 —— 用來決定是否回退到範例資料。
///
/// 為何不直接用 `kIsWeb`：在本專案的 dart2js release 建置中，`kIsWeb` 會被
/// 誤判為 false（dev / DDC server 正常），導致 web 預覽的範例資料 fallback
/// 完全不觸發、畫面改去打真實 API 而卡住。因此額外加上「執行期網址 scheme」
/// 判斷（http / https 代表在瀏覽器）；此判斷取自 `Uri.base`，是執行期值，
/// 不會被最佳化器常數摺疊，因此在 release 也可靠。
final bool isWebPreview = kIsWeb ||
    Uri.base.scheme == 'http' ||
    Uri.base.scheme == 'https';
