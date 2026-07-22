# ucom – Unity Chat Auto Join Addon for Windower4

Version: v2.2.1  
Author: ARIHO + Copilot  
Platform: Windower4 (FFXI)

ucom is a Windower4 addon that automatically joins Unity Chat, retries when the chat is full, optionally sends greetings, and keeps state synchronized with FFXI packet behavior.  
It is designed for real gameplay environments including character changes, area transitions, Home Point warps, and Unity Chat congestion.

## Features

### Auto Join
Automatically sends the Unity Chat join request when logging in, changing areas, or using the command `//ucom auto`.

### Auto Retry
If Unity Chat is full (incoming packet 0x009 / message 287), ucom retries every 10 seconds until successful.  
Earlier versions retried every 3 seconds, which caused excessive packet traffic.  
Version 2.2.1 changes this to 10 seconds for stability and to avoid server-side throttling.

### Auto Hello
After a successful join, ucom can send a Unity greeting packet.

### State Synchronization
Unity Chat join and leave are synchronized using incoming packet 0x061, incoming packet 0x009, and outgoing packet 0x118.

### Character Change Stability
Character change may trigger both a login event and an incoming 0x00A zone packet.  
This caused double join attempts in older versions.  
Version 2.2.1 ignores zone packets for 3 seconds after login to prevent double join.

### Area Change Stability
Older versions attempted to join Unity Chat on every area change, including Home Point warps.  
This caused repeated retries and unstable behavior.  
Version 2.2.1 adds suppression logic to avoid duplicate retry loops and unnecessary join attempts.

### Home Point Warp Stability
Home Point warps may trigger multiple 0x00A packets.  
ucom prevents duplicate retry loops using strict guards.

## Installation

Place the folder:

Windower4/addons/ucom/

Enable with:

/lua load ucom

## Commands

//ucom  
Show current status.

//ucom join  
Manual join with greeting.

//ucom auto  
Auto join without greeting.

//ucom hello  
Send greeting only.

//ucom stop  
Leave Unity Chat.

//ucom mode on  
Enable auto join on login and zone.

//ucom mode off  
Disable auto join.

//ucom mode  
Show usage (mode on/off).

## Behavior Details

### Auto Join Timing
Login: auto join (zone suppressed for 3 seconds)  
Zone change: auto join (unless suppressed)  
Home Point warp: auto join once (duplicate suppression)

### Retry Loop
Triggered only when Unity Chat is full.  
Runs every 10 seconds.  
Stops automatically on success or leave.

### Greeting
Sent only when manual join or when do_hello is true.  
Auto mode does not send greeting.

## Japanese Supplement

### このアドオンの目的
Unityチャットの参加処理を自動化し、混雑時の満員（287）やキャラチェンジ時の特殊挙動に対応するための Windower4 アドオンです。  
特に、FFXI の Unity チャットは混雑時に満員となり、手動で再試行する必要がありますが、ucom はこれを自動化します。

### キャラチェンジ時の二重送信対策（2.2.1）
キャラチェンジ時は login と 0x00A が同時に発生する場合があり、参加要求が二重送信される問題がありました。  
2.2.1 では login 直後 3秒間は 0x00A を無視することで完全に解決しています。

### エリアチェンジ時の鼓動対策（リトライしっぱなし問題の修正）
旧バージョンでは、エリアチェンジ時に Unity チャットが満員だと、  
リトライが「鼓動のように連続発動」する問題がありました。  
2.2.1 では retry_loop_running のガードを強化し、  
リトライが複数回起動しないように修正しています。

### リトライ間隔の変更（3秒 → 10秒）
旧バージョンでは 3秒間隔でリトライしていましたが、  
サーバー負荷や Windower の処理負荷を考慮し、  
2.2.1 では 10秒間隔に変更しています。

### Home Point ワープ時の安定化
同一エリア内の HP 移動では 0x00A が複数回発生することがあります。  
2.2.1 では retry_loop_running のガード強化により、  
リトライが複数回起動しないようにしています。

### コマンド説明の復元
2.0.7 の正常なコマンド説明を完全復元し、  
2.1.x〜2.2.0 で発生していた説明の欠落・誤表示を修正しています。

### say_hello の復元
2.1.1 以降で欠落していた say_hello 関数を復元し、  
手動 join 時の挨拶機能が正常に動作するようになりました。

## License
MIT License

## Contributions
Pull Requests and Issue Reports are welcome.
