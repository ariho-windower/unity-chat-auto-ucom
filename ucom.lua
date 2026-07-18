-- ucom v1.9.3-multilang
-- Author: ARIHO + Copilot
-- Unity Chat Auto Join + Auto Hello + Auto Only + Stop
-- （多言語対応 / 時間ベース判定 / 2回連続成功 / stop完全停止）

_addon.name     = 'ucom'
_addon.author   = 'ARIHO + Copilot'
_addon.version  = '1.9.3-multilang'
_addon.commands = {'ucom'}

local packets = require('packets')

---------------------------------------------------------
-- 多言語メッセージ（日本語は SJIS）
---------------------------------------------------------
local function M(key)
    local lang = (windower.ffxi.get_info().language or 'Japanese')

    local jp = {
        hello = 'こんにちは。ユニティチャットに挨拶しました。',
        start = 'ユニティチャット自動参加ループを開始します（最大20回）。',
        req   = 'ユニティチャット参加要求を送信しました（Chat Status = true）。',
        ok    = 'ユニティチャット参加を確認しました（成功）。',
        ng    = 'ユニティチャット参加を確認できませんでした（失敗）。',
        stop  = 'ユニティチャットから離脱しました（Chat Status = false）。',
        auto  = 'ユニティチャットに自動参加しました（挨拶なし）。',
        full  = 'ユニティチャットは満員のため参加できませんでした（リトライ継続）。',
    }

    local en = {
        hello = 'Hello. Sent greeting to Unity chat.',
        start = 'Starting Unity chat auto-join loop (max 20 attempts).',
        req   = 'Sent Unity chat join request (Chat Status = true).',
        ok    = 'Unity chat join confirmed (success).',
        ng    = 'Unity chat join failed (no confirmation).',
        stop  = 'Left Unity chat (Chat Status = false).',
        auto  = 'Joined Unity chat automatically (no greeting).',
        full  = 'Unity chat is full; retrying.',
    }

    if lang == 'English' then
        return en[key] or key
    else
        return jp[key] or key
    end
end

---------------------------------------------------------
-- 失敗ログ判定（日本語 / 英語）
---------------------------------------------------------
local function is_unity_not_participating(text)
    local lang = (windower.ffxi.get_info().language or 'Japanese')
    if lang == 'English' then
        return text:contains('You are not participating in Unity chat')
    else
        return text:contains('ユニティチャットに参加していません')
    end
end

local function is_unity_full(text)
    local lang = (windower.ffxi.get_info().language or 'Japanese')
    if lang == 'English' then
        return text:contains('Unity chat is full')
    else
        return text:contains('人数制限により入れません')
    end
end

---------------------------------------------------------
-- 状態管理
---------------------------------------------------------
local unity_check_pending = false
local unity_check_failed  = false
local unity_check_success = false
local unity_check_time    = 0

local UNITY_CHECK_TIMEOUT = 10.0   -- ★ 10秒リトライ
local unity_check_pending_do_hello = false
local stop_requested = false

-- ★ 2回連続成功判定用
local consecutive_success_count = 0

---------------------------------------------------------
-- 挨拶（ATコード）
---------------------------------------------------------
local function say_hello()
    local at = string.char(0xFD, 0x02, 0x01, 0x01, 0x0B, 0xFD)
    coroutine.schedule(function()
        windower.send_command('input /unity '..at)
        windower.add_to_chat(207, '[ucom] '..M('hello'))
    end, 0.5)
end

---------------------------------------------------------
-- Unity参加／離脱（0x118 Chat Status）
---------------------------------------------------------
local function unity_join()
    local p = packets.new('outgoing', 0x118, { ['Chat Status'] = true })
    packets.inject(p)
end

local function unity_leave()
    local p = packets.new('outgoing', 0x118, { ['Chat Status'] = false })
    packets.inject(p)
end

---------------------------------------------------------
-- unity_check 開始
---------------------------------------------------------
local function start_unity_check()
    unity_check_pending = true
    unity_check_failed  = false
    unity_check_success = false
    unity_check_time    = os.clock()
end

---------------------------------------------------------
-- 成功 / 失敗
---------------------------------------------------------
local function unity_join_succeeded()
    unity_check_pending = false
    unity_check_success = true
    windower.add_to_chat(207, '[ucom] '..M('ok'))

    if unity_check_pending_do_hello then
        say_hello()
    end
end

local function unity_join_failed()
    unity_check_pending = false
    unity_check_failed  = true
    unity_check_success = false
    consecutive_success_count = 0
    windower.add_to_chat(207, '[ucom] '..M('ng'))
end

---------------------------------------------------------
-- /unity . を送信（参加確認用）
---------------------------------------------------------
local function send_unity_check()
    windower.send_command('input /unity .')
    start_unity_check()
end

---------------------------------------------------------
-- incoming text（original のみで判定）
---------------------------------------------------------
windower.register_event('incoming text', function(original)

    if not unity_check_pending then return end
    if not original or original == '' then return end

    -- 失敗ログ
    if is_unity_not_participating(original) then
        unity_join_failed()
        return
    end

    -- 満員ログ
    if is_unity_full(original) then
        unity_check_failed = true
        consecutive_success_count = 0
        windower.add_to_chat(207, '[ucom] '..M('full'))
        return
    end
end)

---------------------------------------------------------
-- incoming chunk（満員ログ）
---------------------------------------------------------
windower.register_event('incoming chunk', function(id, data)

    if id ~= 0x0C8 then return end
    if not unity_check_pending then return end

    local packet = packets.parse('incoming', data)
    if not packet or not packet['Message'] then return end

    local msg = packet['Message']

    if is_unity_full(msg) then
        unity_check_failed = true
        consecutive_success_count = 0
        windower.add_to_chat(207, '[ucom] '..M('full'))
        return
    end
end)

---------------------------------------------------------
-- ★ pending を「時間で」閉じる
---------------------------------------------------------
local function check_pending_timeout()
    if unity_check_pending and (os.clock() - unity_check_time >= UNITY_CHECK_TIMEOUT) then
        unity_check_pending = false
    end
end

---------------------------------------------------------
-- join_loop（挨拶あり）
---------------------------------------------------------
local function join_loop()
    windower.add_to_chat(207, '[ucom] '..M('start'))

    unity_check_pending_do_hello = true
    stop_requested = false
    consecutive_success_count = 0

    for attempt = 1, 20 do
        if stop_requested then break end

        unity_join()
        windower.add_to_chat(207, '[ucom] '..M('req')..' (attempt '..attempt..'/20)')

        coroutine.sleep(1.0)
        send_unity_check()

        -- ★ 10秒待つ間に pending を時間で閉じる
        for _ = 1, 10 do
            coroutine.sleep(1)
            check_pending_timeout()
        end

        if stop_requested then return end

        -- ★ 成功判定：失敗ログなしが2回連続したら成功
        if not unity_check_failed and not unity_check_pending then
            consecutive_success_count = consecutive_success_count + 1

            if consecutive_success_count >= 2 then
                unity_join_succeeded()
                return
            end
        end
    end
end

---------------------------------------------------------
-- auto_loop（挨拶なし）
---------------------------------------------------------
local function auto_loop()
    windower.add_to_chat(207, '[ucom] '..M('start'))

    unity_check_pending_do_hello = false
    stop_requested = false
    consecutive_success_count = 0

    for attempt = 1, 20 do
        if stop_requested then break end

        unity_join()
        windower.add_to_chat(207, '[ucom] '..M('req')..' (auto '..attempt..'/20)')

        coroutine.sleep(1.0)
        send_unity_check()

        for _ = 1, 10 do
            coroutine.sleep(1)
            check_pending_timeout()
        end

        if stop_requested then return end

        if not unity_check_failed and not unity_check_pending then
            consecutive_success_count = consecutive_success_count + 1

            if consecutive_success_count >= 2 then
                unity_join_succeeded()
                windower.add_to_chat(207, '[ucom] '..M('auto'))
                return
            end
        end
    end
end

---------------------------------------------------------
-- stop（ユニティ離脱＋ループ停止）
---------------------------------------------------------
local function stop_unity()
    stop_requested = true
    unity_check_pending = false
    unity_leave()
    windower.add_to_chat(207, '[ucom] '..M('stop'))
end

---------------------------------------------------------
-- コマンド登録
---------------------------------------------------------
windower.register_event('addon command', function(...)

    local args = {...}
    local cmd = args[1] and args[1]:lower() or nil

    if cmd == 'join' then
        join_loop()

    elseif cmd == 'hello' then
        say_hello()

    elseif cmd == 'stop' then
        stop_unity()

    elseif cmd == 'auto' then
        auto_loop()

    else
        windower.add_to_chat(207, '[ucom] コマンド: //ucom join / hello / stop / auto')
    end
end)
