-- ucom v2.2.1 (完全修復版)
-- 2.0.7 の正常なコマンド説明 / say_hello を復元
-- 2.1.1 の retry_loop / 状態管理を維持
-- 2.2.1 のキャラチェンジ二重送信対策を統合

_addon.name     = 'ucom'
_addon.author   = 'ARIHO + Copilot'
_addon.version  = '2.2.1'
_addon.commands = {'ucom'}

local packets = require('packets')
local config  = require('config')

---------------------------------------------------------
-- 設定
---------------------------------------------------------
local defaults = { auto_mode_on_login = false }
local settings = config.load(defaults, 'global')

---------------------------------------------------------
-- メッセージ（2.0.7 正常版）
---------------------------------------------------------
local function M(key)
    local jp = {
        hello='こんにちは。ユニティチャットに挨拶を送信しました。',
        start='ユニティチャット自動参加を開始します。',
        req='ユニティチャット参加要求を送信しました。',
        ok='ユニティチャット参加が確認されました（成功）。',
        ng='ユニティチャット参加に失敗しました。',
        stop='ユニティチャットを退出しました。',
        auto='ユニティチャットに自動参加しました（挨拶なし）。',
        full='ユニティチャットは満員です。',
        retry='再試行します（10秒後）…',
        mode_on='オートモードが ON になりました。',
        mode_off='オートモードが OFF になりました。',
    }
    return jp[key] or key
end

---------------------------------------------------------
-- 状態
---------------------------------------------------------
local unity_active = false
local join_in_progress = false
local leave_in_progress = false
local retry_loop_running = false
local do_hello = false
local auto_mode = false

local last_fail_full = false
local last_join_request_time = 0
local login_time = 0
local first_join_after_login = false

-- キャラチェンジ時の二重送信抑制
local suppress_zone = false

---------------------------------------------------------
-- 初期化
---------------------------------------------------------
local function reset_state()
    join_in_progress = false
    leave_in_progress = false
    retry_loop_running = false
    last_fail_full = false
    first_join_after_login = true
    suppress_zone = false
end

---------------------------------------------------------
-- retry loop（多重起動防止強化）
---------------------------------------------------------
local function retry_join_loop()
    if retry_loop_running then return end
    retry_loop_running = true

    coroutine.schedule(function()
        while retry_loop_running do
            coroutine.sleep(10)
            if not retry_loop_running then break end
            windower.add_to_chat(207,'[ucom] '..M('retry'))
            packets.inject(packets.new('outgoing', 0x118, { ['Chat Status']=true }))
            join_in_progress = true
            last_join_request_time = os.time()
        end
    end,0)
end

---------------------------------------------------------
-- join / leave
---------------------------------------------------------
local function unity_join()
    packets.inject(packets.new('outgoing', 0x118, { ['Chat Status']=true }))
    join_in_progress = true
    leave_in_progress = false
    last_join_request_time = os.time()
    windower.add_to_chat(207,'[ucom] '..M('req'))
end

local function join_auto()
    auto_mode = true
    do_hello = false

    suppress_zone = true
    coroutine.schedule(function()
        suppress_zone = false
    end, 3)

    unity_join()
end

local function join_manual()
    auto_mode = false
    do_hello = true
    unity_join()
end

local function unity_leave()
    packets.inject(packets.new('outgoing', 0x118, { ['Chat Status']=false }))
    leave_in_progress = true
    join_in_progress = false
    unity_active = false
    -- ★stop の二重表示防止：ここだけ出す
    windower.add_to_chat(207,'[ucom] '..M('stop'))
end

---------------------------------------------------------
-- 挨拶（2.0.7 正常版を復元）
---------------------------------------------------------
local function say_hello()
    local at = string.char(0xFD, 0x02, 0x01, 0x01, 0x0B, 0xFD)
    coroutine.schedule(function()
        windower.send_command('input /unity '..at)
        windower.add_to_chat(207,'[ucom] '..M('hello'))
    end,0.5)
end

---------------------------------------------------------
-- incoming
---------------------------------------------------------
windower.register_event('incoming chunk',function(id,data)

    -- 満員
    if id==0x009 and join_in_progress then
        local p=packets.parse('incoming',data)
        if p.ID==0 and p.Index==0 and p.Message==287 then
            unity_active=false
            join_in_progress=false
            last_fail_full=true
            first_join_after_login=false
            windower.add_to_chat(207,'[ucom] '..M('ng'))
            windower.add_to_chat(207,'[ucom] '..M('full'))
            retry_join_loop()
        end
    end

    -- 成功 / 退出
    if id==0x061 then
        local p=packets.parse('incoming',data)

        if p._junk2==1 and join_in_progress then
            unity_active=true
            join_in_progress=false
            retry_loop_running=false
            last_fail_full=false
            first_join_after_login=false
            windower.add_to_chat(207,'[ucom] '..M('ok'))
            if do_hello then say_hello() end
            if auto_mode then windower.add_to_chat(207,'[ucom] '..M('auto')) end
        end

        if p._junk2==0 and leave_in_progress then
            unity_active=false
            leave_in_progress=false
            retry_loop_running=false
            -- ★ここでは stop を出さない（手動出力と二重になるため）
        end
    end

    -- 通常エリアチェンジ（0x00A）
    if id==0x00A then

        -- login直後は suppress_zone により無視
        if suppress_zone then
            return
        end

        reset_state()

        if settings.auto_mode_on_login then
            join_auto()
        end
    end
end)

---------------------------------------------------------
-- load / login
---------------------------------------------------------
windower.register_event('load',function()
    login_time=os.time()
    reset_state()
end)

windower.register_event('login',function()
    login_time=os.time()
    reset_state()
    if settings.auto_mode_on_login then
        join_auto()
    end
end)

---------------------------------------------------------
-- コマンド（2.0.7 の正常版を復元）
---------------------------------------------------------
windower.register_event('addon command',function(...)
    local args={...}
    local cmd=args[1] and args[1]:lower() or nil

    if cmd=='join' then
        windower.add_to_chat(207,'[ucom] '..M('start'))
        join_manual()

    elseif cmd=='auto' then
        windower.add_to_chat(207,'[ucom] '..M('start'))
        join_auto()

    elseif cmd=='hello' then
        say_hello()

    elseif cmd=='stop' then
        unity_leave()

    elseif cmd=='mode' then
        local sw=args[2] and args[2]:lower()
        if sw=='on' then
            settings.auto_mode_on_login=true
            config.save(settings,'global')
            windower.add_to_chat(207,'[ucom] '..M('mode_on'))
        elseif sw=='off' then
            settings.auto_mode_on_login=false
            config.save(settings,'global')
            windower.add_to_chat(207,'[ucom] '..M('mode_off'))
        else
            windower.add_to_chat(207,'[ucom] mode on/off')
        end

    elseif cmd==nil then
        local mode = settings.auto_mode_on_login and 'ON' or 'OFF'
        local unity = unity_active and '参加中' or '未参加'

        windower.add_to_chat(207,'[ucom] 現在の状態：')
        windower.add_to_chat(207,'  オートモード：'..mode)
        windower.add_to_chat(207,'  Unity参加状態：'..unity)

    else
        windower.add_to_chat(207,'[ucom] コマンド: //ucom join / auto / hello / stop / mode on/off')
    end
end)
