-- ucom v2.0.1-packet
-- Author: ARIHO + Copilot
-- Unity Chat Auto Join + Auto Hello + Auto Only + Stop
-- パケットベース判定 + 自動リトライ（3秒）
-- ログオン/キャラチェンジ/エリアチェンジ時の自動参加（leave送信なし）
-- 設定は <global> のみを使用（全キャラ共通）
-- //ucom 単体で状態表示（オートモード / Unity参加状態）

_addon.name     = 'ucom'
_addon.author   = 'ARIHO + Copilot'
_addon.version  = '2.0.1-packet'
_addon.commands = {'ucom'}

local packets = require('packets')
local config  = require('config')

---------------------------------------------------------
-- 設定読み込み（全キャラ共通）
---------------------------------------------------------
local defaults = {
    auto_mode_on_login = false,
}

local settings = config.load(defaults, 'global')

---------------------------------------------------------
-- メッセージ（多言語 / SJIS）
---------------------------------------------------------
local function M(key)
    local lang = (windower.ffxi.get_info().language or 'Japanese')

    local jp = {
        hello = 'こんにちは。ユニティチャットに挨拶を送信しました。',
        start = 'ユニティチャット自動参加を開始します。',
        req   = 'ユニティチャット参加要求を送信しました。',
        ok    = 'ユニティチャット参加が確認されました（成功）。',
        ng    = 'ユニティチャット参加に失敗しました。',
        stop  = 'ユニティチャットから離脱しました。',
        auto  = 'ユニティチャットに自動参加しました（挨拶なし）。',
        full  = 'ユニティチャットは満員です。',
        retry = '再試行します（3秒後）…',
        mode_on  = 'オートモードを ON にしました（ログオン/エリアチェンジ時に自動参加）。',
        mode_off = 'オートモードを OFF にしました。',
    }

    local en = {
        hello = 'Hello. Sent greeting to Unity chat.',
        start = 'Starting Unity chat auto-join.',
        req   = 'Sent Unity chat join request.',
        ok    = 'Unity chat join confirmed (success).',
        ng    = 'Unity chat join failed.',
        stop  = 'Left Unity chat.',
        auto  = 'Joined Unity chat automatically (no greeting).',
        full  = 'Unity chat is full.',
        retry = 'Retrying in 3 seconds…',
        mode_on  = 'Auto mode ON (stop→auto on login/zone change).',
        mode_off = 'Auto mode OFF.',
    }

    if lang == 'English' then
        return en[key] or key
    else
        return jp[key] or key
    end
end

---------------------------------------------------------
-- 状態管理
---------------------------------------------------------
local unity_active = false

local join_in_progress = false
local leave_in_progress = false

local auto_mode = false
local do_hello = false

local retry_loop_running = false

---------------------------------------------------------
-- 状態初期化（ログイン時・エリアチェンジ時用）
---------------------------------------------------------
local function reset_state()
    join_in_progress = false
    leave_in_progress = false
    retry_loop_running = false
    auto_mode = false
    do_hello = false
end

---------------------------------------------------------
-- stop / join_auto / join_manual
---------------------------------------------------------

local function stop_retry_loop()
    retry_loop_running = false
end

local function unity_join()
    local p = packets.new('outgoing', 0x118, { ['Chat Status'] = true })
    packets.inject(p)
    join_in_progress = true
    leave_in_progress = false

    unity_active = true  -- ★ 2.0.1 修正：参加要求時点で参加中とみなす

    windower.add_to_chat(207, '[ucom] '..M('req'))
end

local function unity_leave()
    local p = packets.new('outgoing', 0x118, { ['Chat Status'] = false })
    packets.inject(p)
    leave_in_progress = true
    join_in_progress = false
    unity_active = false
    windower.add_to_chat(207, '[ucom] '..M('stop'))
end

local function join_manual()
    auto_mode = false
    do_hello = true
    stop_retry_loop()
    unity_join()
end

local function join_auto()
    auto_mode = true
    do_hello = false
    stop_retry_loop()
    unity_join()
end

local function stop_unity()
    auto_mode = false
    do_hello = false
    stop_retry_loop()
    unity_leave()
end

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
-- 自動リトライループ（3秒間隔）
---------------------------------------------------------
local function retry_join_loop()
    if retry_loop_running then return end
    retry_loop_running = true

    coroutine.schedule(function()
        while retry_loop_running do
            coroutine.sleep(3)
            if not retry_loop_running then break end
            windower.add_to_chat(207, '[ucom] '..M('retry'))
            unity_join()
        end
    end, 0)
end

---------------------------------------------------------
-- incoming chunk（0x009 / 0x061 / 0x00A）
---------------------------------------------------------
windower.register_event('incoming chunk', function(id, data)

    -----------------------------------------------------
    -- 参加失敗：incoming 0x009（Message 287）
    -----------------------------------------------------
    if id == 0x009 and join_in_progress then
        local pkt = packets.parse('incoming', data)
        if pkt.ID == 0 and pkt.Index == 0 and pkt.Message == 287 then
            unity_active = false
            join_in_progress = false
            windower.add_to_chat(207, '[ucom] '..M('ng'))
            windower.add_to_chat(207, '[ucom] '..M('full'))
            retry_join_loop()
        end
    end

    -----------------------------------------------------
    -- 成功 / 離脱：incoming 0x061
    -----------------------------------------------------
    if id == 0x061 then
        local pkt = packets.parse('incoming', data)

        if pkt._junk2 == 1 and join_in_progress then
            unity_active = true
            join_in_progress = false
            stop_retry_loop()
            windower.add_to_chat(207, '[ucom] '..M('ok'))
            if do_hello then say_hello() end
            if auto_mode then windower.add_to_chat(207, '[ucom] '..M('auto')) end
        end

        if pkt._junk2 == 0 and leave_in_progress then
            unity_active = false
            leave_in_progress = false
            stop_retry_loop()
            windower.add_to_chat(207, '[ucom] '..M('stop'))
        end
    end

    -----------------------------------------------------
    -- エリアチェンジ：incoming 0x00A
    -----------------------------------------------------
    if id == 0x00A then
        if settings.auto_mode_on_login then
            reset_state()
            join_auto()
        end
    end
end)

---------------------------------------------------------
-- addon load（ゲーム起動時）
---------------------------------------------------------
windower.register_event('load', function()
    if settings.auto_mode_on_login then
        reset_state()
        join_auto()
    end
end)

---------------------------------------------------------
-- login（ログイン完了 / キャラチェンジ）
---------------------------------------------------------
windower.register_event('login', function()
    if settings.auto_mode_on_login then
        reset_state()
        join_auto()
    end
end)

---------------------------------------------------------
-- コマンド登録
---------------------------------------------------------
windower.register_event('addon command', function(...)

    local args = {...}
    local cmd = args[1] and args[1]:lower() or nil

    if cmd == 'join' then
        windower.add_to_chat(207, '[ucom] '..M('start'))
        join_manual()

    elseif cmd == 'auto' then
        windower.add_to_chat(207, '[ucom] '..M('start'))
        join_auto()

    elseif cmd == 'hello' then
        say_hello()

    elseif cmd == 'stop' then
        stop_unity()

    elseif cmd == 'mode' then
        local sw = args[2] and args[2]:lower()
        if sw == 'on' then
            settings.auto_mode_on_login = true
            config.save(settings, 'global')
            windower.add_to_chat(207, '[ucom] '..M('mode_on'))
        elseif sw == 'off' then
            settings.auto_mode_on_login = false
            config.save(settings, 'global')
            windower.add_to_chat(207, '[ucom] '..M('mode_off'))
        else
            windower.add_to_chat(207, '[ucom] mode on/off')
        end

    elseif cmd == nil then
        -------------------------------------------------
        -- //ucom 単体 → 状態表示（簡易版）
        -------------------------------------------------
        local mode = settings.auto_mode_on_login and 'ON' or 'OFF'
        local unity = unity_active and '参加中' or '未参加'

        windower.add_to_chat(207, '[ucom] 現在の状態：')
        windower.add_to_chat(207, '  オートモード：' .. mode)
        windower.add_to_chat(207, '  Unity参加状態：' .. unity)

    else
        windower.add_to_chat(207, '[ucom] コマンド: //ucom join / auto / hello / stop / mode on/off')
    end
end)
