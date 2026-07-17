# ucom – Unity Chat Auto Join & Greeting Addon for Windower

ucom is a lightweight Windower addon that automatically sends Unity Chat participation requests and provides a simple auto-greeting command.  
It is designed to work on all retail worlds, regardless of server-specific behavior.

## Features

- Automatically sends Unity Chat participation requests  
  - Repeated every 2 seconds  
  - Unlimited attempts until stopped  
- Sends an Auto-Translate “Hello.” message to Unity Chat  
- Fully multi-language (Japanese / English / French / German)  
  - Language is detected from the FFXI client  
- Safe: does not modify memory or use unsupported packet injection  
- Simple command structure

## Commands

### `//ucom join`
Start sending Unity Chat participation requests every 2 seconds.  
This continues until `//ucom stop` is executed.

### `//ucom stop`
Stop the join loop.

### `//ucom hello`
Send an Auto-Translate “Hello.” message to Unity Chat.

## Requirements

- Windower 4  
- packets library (included with Windower)

## Installation

Place `ucom.lua` into:

## 日本語

ucom は、ユニティチャット参加要求を自動で送信し続ける Windower 用アドオンです。  
ユニティチャット参加成功を検出する方法はワールドごとに異なるため、  
参加要求を繰り返す方式を採用しています。

コマンドは `//ucom join`, `//ucom stop`, `//ucom hello` の3つだけで、  
シンプルかつ安全に動作します。

