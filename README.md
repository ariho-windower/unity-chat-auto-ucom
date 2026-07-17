# ucom - Unity Chat Auto Join & Optional Greeting
Windower4 Addon / ユニティチャット自動参加＋挨拶アドオン

## Overview / 概要

ucom is a Windower addon that continuously sends Unity Chat join requests.  
Since the method for detecting successful Unity Chat entry differs between worlds,  
the addon uses a simple and stable approach: repeatedly issuing join commands at fixed intervals.  
It can also send an optional greeting message if the user configures one.

ucom は、ユニティチャット参加要求を自動で送信し続ける Windower 用アドオンです。  
ユニティチャット参加成功を検出する方法はワールドごとに異なるため、  
安定性を重視し、参加要求を一定間隔で繰り返す方式を採用しています。  
挨拶はユーザーが設定した場合のみ送信されます。

---

## Features / 機能
- Auto Unity Chat join loop（ユニティチャット自動参加）
- Optional greeting message（挨拶は設定した場合のみ送信）
- Multi-language support（日本語・英語）
- Retail-compatible（通常版FFXIで動作）
- Lightweight single-file addon（軽量・Lua単体）

---

## Installation / インストール
1. Place **ucom.lua** into:  
   `Windower4/addons/ucom/`
2. Enable the addon:  
   `/lua load ucom`

---

## Usage / 使い方
The addon continuously attempts Unity Chat join in the background.  
A greeting message will be sent **only if the user has configured one**.

アドオンはバックグラウンドでユニティチャット参加要求を送り続けます。  
挨拶はユーザーが設定した場合にのみ送信されます。

### Commands / コマンド
- `/ucom on` ? Enable auto join（自動参加オン）
- `/ucom off` ? Disable auto join（自動参加オフ）
- `/ucom greet <text>` ? Set greeting message（挨拶設定）
- `/ucom status` ? Show current status（状態表示）

---

## Notes / 注意点
- No chat log parsing（チャットログ解析なし）
- No packet injection（パケット書き込みなし）
- Uses only standard Windower commands（Windower標準コマンドのみ）
- Designed for stability even when Unity Chat behaves inconsistently  
  （ユニティチャットの挙動が不安定でも安定動作）

---

## Author / 作者
**ARIHO + Copilot**

Special thanks to Copilot for assistance with development, debugging, and documentation.  
開発・解析・ドキュメント作成に協力してくれた Copilot に感謝します。
