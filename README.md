# ucom – Unity Chat Auto Join & Optional Greeting
Windower4 Addon

## Overview

ucom is a Windower addon that repeatedly sends Unity Chat join packets using Windower’s packet library.  
Unity Chat success detection is based on incoming packets, but in some environments a clear success indicator may not be available,  
so ucom uses repeated join attempts as a fallback.  
If the user configures a greeting message, ucom can send it after joining.

ucom は、Windower の packet ライブラリを使用してユニティチャット参加要求の
アウトゴーイングパケットを繰り返し送信するアドオンです。  
ユニティチャット参加成功の検出はインカミングパケットに基づきますが、
環境によって明確な成功通知が得られない場合があるため、
フォールバックとして参加要求を繰り返す方式を採用しています。  
挨拶はユーザーが設定した場合のみ送信されます。

---

## Features

- Unity Chat auto join loop  
- Optional greeting message (user-configurable)  
- Simple behavior focused on Unity Chat only  
- Lightweight single-file addon (Lua)

機能概要：

- ユニティチャット自動参加ループ  
- 任意設定の挨拶メッセージ送信  
- ユニティチャット専用のシンプルな挙動  
- Lua 単体の軽量アドオン

---

## Installation

1. Place `ucom.lua` into:

   `Windower4/addons/ucom/`

2. Load the addon:

   `/lua load ucom`

インストール手順：

1. `ucom.lua` を次のフォルダに配置します：

   `Windower4/addons/ucom/`

2. アドオンをロードします：

   `/lua load ucom`

---

## Usage

ucom periodically sends Unity Chat join packets in the background.  
If a greeting message is configured, it will be sent after joining (subject to detection logic and environment).

使い方：

ucom はバックグラウンドで一定間隔ごとにユニティチャット参加要求を送信します。  
挨拶メッセージを設定している場合、参加後に挨拶を送信します（検出ロジックや環境に依存します）。

### Commands

- `/ucom on` – Enable auto join  
- `/ucom off` – Disable auto join  
- `/ucom greet <text>` – Set greeting message  
- `/ucom status` – Show current status

コマンド：

- `/ucom on` – 自動参加を有効化  
- `/ucom off` – 自動参加を無効化  
- `/ucom greet <text>` – 挨拶メッセージを設定  
- `/ucom status` – 現在の状態を表示

---

## Notes

- Uses Windower’s packet library to construct and send outgoing Unity Chat packets  
- Does not attempt to modify or filter incoming packets  
- Behavior may vary depending on how the client and server expose Unity Chat status  
- Future updates may add more safety checks (zoning, events, cutscenes) and stop conditions

注意事項：

- Windower の packet ライブラリを使用してユニティチャット参加用のアウトゴーイングパケットを送信します  
- インカミングパケットの改変やフィルタリングは行いません  
- クライアントやサーバー側のユニティチャット状態の扱いにより、挙動が環境依存となる場合があります  
- 今後の更新で、ゾーン中・イベント中・カットシーン中などの安全チェックや停止条件を追加する可能性があります

---

## Author

**ARIHO**

Special thanks to community feedback on packet handling and Unity Chat behavior.

作者：

**ARIHO**

パケット処理やユニティチャット挙動に関するフィードバックをくれたコミュニティに感謝します。
