# ucom - Unity Chat Auto Join Addon
Windower4 / FFXI  
Version 1.9.3-stable

## Overview

ucom is a Windower4 addon that automatically joins the Unity Chat in Final Fantasy XI.

Unity Chat has several behaviors that make automation difficult:
- No success message is shown when joining
- Failure messages (“You are not participating…”) can be delayed
- “Unity chat is full” messages can also be delayed
- Incoming text/chunk timing is inconsistent
- Chat Status updates may lag behind actual state

ucom solves these issues using a time-based detection method that reliably handles delayed logs and ensures stable auto-joining.

(日本語補足: ユニティチャットは成功時にログが出ず、失敗ログが遅延するため、自動化が非常に難しい仕様です。ucom はログ遅延に完全対応した時間ベース判定方式を採用しています。)

---

## Features

- Auto join Unity Chat (`//ucom join`)
- Auto join without greeting (`//ucom auto`)
- Send Unity greeting (`//ucom hello`)
- Leave Unity Chat (`//ucom stop`)
- Fully handles delayed logs (10-second detection window)
- Success = “no failure logs for 2 consecutive attempts”
- Uses original log text only
- Does not rely on other players’ chat messages
- No false greetings, no false success
- Tested in Phoenix World / Japanese client environment

(日本語補足: Phoenixワールド・日本語環境でのみ実戦テスト済みです。他環境ではログ文言が異なる可能性があります。)

---

## Commands

| Command        | Description |
|----------------|-------------|
| `//ucom join`  | Join Unity Chat (with greeting) |
| `//ucom auto`  | Join Unity Chat (no greeting) |
| `//ucom hello` | Send Unity greeting |
| `//ucom stop`  | Leave Unity Chat |
| `//ucom`       | Show command list |

---

## Detection Logic (How It Works)

### Failure messages
Japanese:
- 「ユニティチャットに参加していません」
- 「人数制限により入れません」

English:
- “You are not participating in Unity chat.”
- “Unity chat is full.”

If any of these appear → failure.

### Success messages
FFXI does not output any success message.  
Success cannot be determined from logs.

### Time-based detection
1. Send `/unity .`
2. Wait 10 seconds
3. If no failure message appears → success candidate
4. If success candidate occurs twice consecutively → success confirmed

### Stop behavior
After `//ucom stop`, success detection is never executed.  
This prevents false greetings or false success.

---

## Tested Environment

This addon has been fully tested only in:
- Phoenix World
- Japanese client
- Japanese log messages
- Windower4 JP environment

(日本語補足: Phoenixワールド・日本語環境でのみ動作確認しています。他ワールド・英語環境ではログ文言が異なる可能性があります。)

---

## Important Notice for English-speaking Users / Other Worlds

Unity Chat messages differ between languages and may vary slightly by world.

If you are using:
- English client
- Another world
- Different log settings

There is a chance that:
- Failure messages may not match
- Detection may behave incorrectly
- Auto-join may not trigger as expected

If you encounter issues, please send feedback:
- Your world name
- Your client language
- Original incoming text lines
- Actual failure messages you see
- Logs around success/failure
- Any incorrect behavior you observed

(日本語補足: 英語環境ではログ文言が異なるため、誤判定が起きる可能性があります。ログの original 行を送っていただければ改善できます。)

---

## Installation

Place the file here:

Windower4/addons/ucom/ucom.lua

To auto-load:

lua load ucom


---

## License

MIT License

