# ucom 2.0.1
Unity Chat Auto Join Addon for Windower4  
Author: ARIHO + Copilot

============================================================
English Section
============================================================

## Overview
ucom is a Windower4 addon that automates joining the Unity Chat in Final Fantasy XI.
It supports auto‑join on login, zone change, and character change, and can optionally send a greeting (AT code).

Version 2.0.1 improves the reliability of Unity Chat participation detection.
Previous versions relied solely on the server’s 0x061 packet to confirm participation.
However, the server may not send this packet in certain situations (e.g., already joined), causing the addon to incorrectly display “Not Joined”.

To resolve this, ucom 2.0.1 now treats the character as “Joined” immediately when sending the join request (outgoing 0x118).
If the server later reports a failure (Message 287), the addon correctly switches back to “Not Joined”.

This ensures that the addon’s status display always matches the actual Unity Chat behavior.

---

## Features
- Auto‑join on login
- Auto‑join on zone change
- Auto‑join on character change
- Join with greeting (/ucom join)
- Join without greeting (/ucom auto)
- Send greeting only (/ucom hello)
- Leave Unity Chat (/ucom stop)
- Status display (/ucom)
  - Auto‑mode ON/OFF
  - Unity Chat participation state

---

## Commands
/ucom join  
/ucom auto  
/ucom hello  
/ucom stop  
/ucom mode on  
/ucom mode off  
/ucom

---

## Behavior Details
Login (load/login):  
- Does not send leave  
- Resets internal state and auto‑joins if auto‑mode is enabled  

Zone change (incoming 0x00A):  
- Does not send leave  
- Resets internal state and auto‑joins if auto‑mode is enabled  

Participation success: incoming 0x061 (_junk2 == 1)  
Participation failure: incoming 0x009 (Message 287), auto‑retry every 3 seconds

---

## State Handling (Improved in 2.0.1)
Participation is assumed immediately when sending join request (outgoing 0x118).  
Participation is cleared only when failure is reported (Message 287).  
This ensures the status display matches actual Unity Chat behavior.

---

## Configuration (Global Only)
Settings are stored in the <global> section (shared across all characters).

Example: addons/ucom/data/settings.xml  
<settings>  
    <global>  
        <auto_mode_on_login>true</auto_mode_on_login>  
    </global>  
</settings>

---

## Notes
- Leave is not sent on login  
- Verified stable on Phoenix environment  
- Lua files: Shift‑JIS  
- README / Release Notes: UTF‑8

---

## Changelog
v2.0.1  
- Improved participation state handling  
- Participation assumed when sending join request  
- Fixed incorrect “Not Joined” state when server does not send 0x061  
- More stable behavior on login and auto‑mode switching  
- Minor stability improvements  

v2.0.0  
- Unified configuration to global section  
- Added /ucom status display  
- Improved internal state reset  
- Removed leave on login  
- Cleaned join/auto/hello/stop behavior  
- Verified stability on Phoenix  

---

## License
MIT License

============================================================
Japanese Section
============================================================

## 概要
ucom は、FFXI のユニティチャットに自動参加するための Windower4 アドオンです。  
ログオン・エリアチェンジ・キャラチェンジ時に自動参加し、必要に応じて挨拶（ATコード）を送信できます。

2.0.1 では、ユニティチャット参加状態の判定がサーバの応答に依存してズレる問題を修正しました。  
従来は参加成功パケット（incoming 0x061）のみを基準としていましたが、  
サーバがこのパケットを返さないケース（既に参加済みなど）が存在し、  
状態表示が「未参加」と誤って表示されることがありました。

2.0.1 では、参加要求（outgoing 0x118）を送信した時点で参加中とみなし、  
失敗（Message 287）が返ってきた場合のみ未参加に戻す方式に変更しています。

これにより、状態表示が実際のチャット状況（黄色ログ）と常に一致します。

---

## 主な機能
- ログオン時の自動参加  
- エリアチェンジ時の自動参加  
- キャラチェンジ時の自動参加  
- 挨拶あり参加（/ucom join）  
- 挨拶なし参加（/ucom auto）  
- 挨拶のみ送信（/ucom hello）  
- 離脱（/ucom stop）  
- 状態表示（/ucom）  
  - オートモード ON/OFF  
  - Unity チャット参加状態

---

## コマンド一覧
/ucom join  
/ucom auto  
/ucom hello  
/ucom stop  
/ucom mode on  
/ucom mode off  
/ucom

---

## 動作仕様
ログオン（load/login）:  
- leave は送信しません  
- 内部状態を初期化し、必要なら自動参加します  

エリアチェンジ（incoming 0x00A）:  
- leave は送信しません  
- 内部状態を初期化し、必要なら自動参加します  

参加成功: incoming 0x061 (_junk2 == 1)  
参加失敗: incoming 0x009 (Message 287)、3 秒間隔で自動リトライ

---

## 状態管理（2.0.1 の改善点）
参加要求送信時点で参加中とみなす（outgoing 0x118）。  
失敗時のみ未参加に戻す（Message 287）。  
これにより、状態表示が実際のチャット状況と一致します。

---

## 設定（全キャラ共通）
設定は <global> セクションに保存されます。

例: addons/ucom/data/settings.xml  
<settings>  
    <global>  
        <auto_mode_on_login>true</auto_mode_on_login>  
    </global>  
</settings>

---

## 注意点
- ログオン時に leave を送信しません  
- Phoenix 環境で安定動作確認済み  
- Lua ファイルは Shift‑JIS  
- README / Release Notes は UTF‑8

---

## 更新履歴
v2.0.1  
- 参加状態判定の改善  
- 参加要求送信時点で参加中とみなす方式に変更  
- サーバが 0x061 を返さないケースで誤表示が出る問題を修正  
- ログオン直後の mode off でも状態がズレないよう改善  
- 軽微な安定性向上  

v2.0.0  
- 設定方式を global に統一  
- /ucom 状態表示を追加  
- 内部状態初期化処理を改善  
- ログオン時の leave 送信を廃止  
- join / auto / hello / stop の動作整理  
- Phoenix での安定性確認済み  

---

## ライセンス
MIT License
