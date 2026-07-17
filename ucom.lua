_addon.name     = 'ucom'
_addon.author   = 'ARIHO + Copilot'
_addon.version  = '1.0'
_addon.commands = {'ucom'}

local packets = require('packets')

local info = windower.ffxi.get_info()
local lang = string.lower(info.language)  -- japanese / english / french / german

---------------------------------------------------------
-- フラグ
---------------------------------------------------------
local join_loop = false

---------------------------------------------------------
-- メッセージ
---------------------------------------------------------
local msg = {
    japanese = {
        start = 'ユニティ参加ループ開始（2秒ごとに無制限）',
        stop  = 'ユニティ参加ループ停止',
        hello = '「こんにちは。」を送信しました',
        send  = 'ユニティ参加要求を送信しました',
        usage = '使い方: //ucom join | stop | hello',
    },
    english = {
        start = 'Unity join loop started (every 2 seconds, unlimited)',
        stop  = 'Unity join loop stopped',
        hello = 'Sent “Hello.” to Unity chat',
        send  = 'Sent Unity join request',
        usage = 'Usage: //ucom join | stop | hello',
    },
    french = {
        start = 'Boucle de participation Unity d?marr?e (toutes les 2 secondes, illimit?e)',
        stop  = 'Boucle de participation Unity arr?t?e',
        hello = '? Bonjour. ? envoy? au chat Unity',
        send  = 'Demande de participation Unity envoy?e',
        usage = 'Utilisation : //ucom join | stop | hello',
    },
    german = {
        start = 'Unity-Beitrittsschleife gestartet (alle 2 Sekunden, unbegrenzt)',
        stop  = 'Unity-Beitrittsschleife gestoppt',
        hello = '?Hallo.“ an den Unity-Chat gesendet',
        send  = 'Unity-Beitrittsanforderung gesendet',
        usage = 'Verwendung: //ucom join | stop | hello',
    },
}

---------------------------------------------------------
-- メッセージ取得関数
---------------------------------------------------------
local function M(key)
    return msg[lang][key] or msg['english'][key]
end

---------------------------------------------------------
-- ユニティ参加要求（0x118）
---------------------------------------------------------
local function send_unity_status(enable)
    local p = packets.new('outgoing', 0x118)
    p['Chat Status'] = enable and true or false
    p['_unknown2'] = 1
    packets.inject(p)
end

---------------------------------------------------------
-- 「こんにちは。」（定型文）
---------------------------------------------------------
local function say_hello()
    local at_start = 0xFD
    local at_type = 0x02
    local at_lang = 0x01
    local at_id_upper = 0x01
    local at_id_lower = 0x0B
    local at_end = 0xFD
    local at_string = string.char(at_start, at_type, at_lang, at_id_upper, at_id_lower, at_end)

    windower.send_command('input /unity '..at_string)
end

---------------------------------------------------------
-- joinループ（2秒ごとに無制限）
---------------------------------------------------------
local function join_loop_task()
    if not join_loop then
        return
    end

    send_unity_status(true)
    windower.add_to_chat(207, '[ucom] '..M('send'))

    coroutine.schedule(join_loop_task, 2)
end

---------------------------------------------------------
-- コマンド処理
---------------------------------------------------------
windower.register_event('addon command', function(cmd)
    cmd = cmd and cmd:lower() or ''

    if cmd == 'join' then
        join_loop = true
        windower.add_to_chat(207, '[ucom] '..M('start'))
        join_loop_task()

    elseif cmd == 'stop' then
        join_loop = false
        windower.add_to_chat(207, '[ucom] '..M('stop'))

    elseif cmd == 'hello' then
        say_hello()
        windower.add_to_chat(207, '[ucom] '..M('send'))

    else
        windower.add_to_chat(207, '[ucom] '..M('usage'))
    end
end)
