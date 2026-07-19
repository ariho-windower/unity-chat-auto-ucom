# ucom 2.0.1 – Release Notes
Unity Chat Auto Join Addon for Windower4  
Author: ARIHO + Copilot

============================================================
English Section
============================================================

## Overview
ucom 2.0.1 is the first public release after a series of internal development builds (v1.9.x and v2.0.0).  
This version focuses on improving the reliability of Unity Chat participation detection.

In earlier internal builds, the addon relied solely on the server’s incoming 0x061 packet to confirm successful participation.  
However, depending on server behavior or timing (e.g., already joined), this packet may not be sent.  
As a result, the addon could incorrectly display “Not Joined” even though Unity Chat messages were visible.

Version 2.0.1 resolves this issue by treating the character as “Joined” immediately when sending the join request (outgoing 0x118).  
If the server later reports a failure (Message 287), the addon correctly switches back to “Not Joined”.

This ensures that the addon’s status display always matches the actual Unity Chat behavior.

---

## Changes in 2.0.1
### ✔ Improved Unity Chat participation state handling
- `unity_active = true` is now set at the moment the join request is sent.
- Prevents false “Not Joined” states when the server does not send 0x061.
- If incoming 0x009 (Message 287) is received, the addon sets `unity_active = false`.

### ✔ More stable status display
- `/ucom` reliably shows the correct participation state.
- Eliminates mismatches such as:
  - Status: “Not Joined”
  - Actual: Unity Chat messages visible

### ✔ More robust behavior on login and mode switching
- Turning auto‑mode OFF immediately after login no longer causes desynchronization.
- Stable even in environments with packet timing variations (e.g., Phoenix).

### ✔ Internal stability improvements
- Minor adjustments to ensure consistent behavior across zone changes and character changes.

---

## Internal / Unreleased Versions
### v2.0.0 (Internal / Unreleased)
- Unified configuration to global section  
- Added `/ucom` status display  
- Improved internal state reset  
- Removed leave on login  
- Cleaned join/auto/hello/stop behavior  
- Verified stability on Phoenix  

### v1.9.x Series (Internal / Development Builds)
- Experimental auto‑join logic  
- Early packet‑handling improvements  
- Initial testing of Unity Chat state tracking  
- Not intended for public release  

---

## Known Issues
None at this time.

---

## Compatibility
- Windower4  
- Verified on Phoenix environment  
- Lua files: Shift‑JIS  
- README / Release Notes: UTF‑8  

---

## License
MIT License

============================================================
Japanese Section（日本語）
============================================================

## 概要
ucom 2.0.1 は、内部開発版（v1.9.x および v2.0.0）を経て公開される最初の正式版です。  
本バージョンでは、ユニティチャット参加状態の判定をより安定させることに重点を置いています。

内部版では、参加成功を確認するために incoming 0x061 パケットのみを使用していました。  
しかし、サーバの挙動やタイミング（例：すでに参加済み）によっては、このパケットが送られない場合があり、  
黄色チャットが流れているにもかかわらず「未参加」と誤表示される問題がありました。

2.0.1 では、参加要求（outgoing 0x118）を送信した時点で参加中とみなし、  
その後サーバから失敗（Message 287）が返ってきた場合のみ未参加に戻す方式に変更しました。

これにより、状態表示が実際のチャット状況と常に一致するようになります。

---

## 2.0.1 の変更点
### ✔ Unity チャット参加状態の判定を改善
- 参加要求送信時点で `unity_active = true` を設定するように変更。
- サーバが 0x061 を返さないケースでも誤表示が発生しない。
- incoming 0x009（Message 287）を受信した場合のみ `unity_active = false` に戻す。

### ✔ 状態表示の安定化
- `/ucom` の表示が常に実際の参加状態と一致。
- 以下のようなズレを完全に解消：
  - 状態：未参加  
  - 実際：黄色チャットが流れている

### ✔ ログオン直後や mode 切り替え時の安定性向上
- ログオン直後に `/ucom mode off` を実行しても状態がズレない。
- Phoenix のようなパケットタイミングが特殊な環境でも安定。

### ✔ 内部安定性の向上
- エリアチェンジやキャラチェンジ時の動作をより安定化。

---

## 内部版（未公開）
### v2.0.0（内部版 / 未公開）
- 設定方式を global に統一  
- /ucom 状態表示を追加  
- 内部状態初期化処理を改善  
- ログオン時の leave 送信を廃止  
- join / auto / hello / stop の動作整理  
- Phoenix での安定性確認済み  

### v1.9.x 系列（内部開発版）
- 自動参加ロジックの試験実装  
- パケット処理の初期改善  
- Unity チャット状態追跡の初期テスト  
- 公開を前提としない内部ビルド  

---

## 既知の問題
現時点ではありません。

---

## 互換性
- Windower4  
- Phoenix 環境で動作確認済み  
- Lua ファイル：Shift‑JIS  
- README / Release Notes：UTF‑8  

---

## ライセンス
MIT License
