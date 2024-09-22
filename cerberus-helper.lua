script_name("cerberus-helper")
script_url("https://github.com/Andergr0ynd/luaupdate/")
script_version("22.09.2024.13.55")

local enable_autoupdate = true -- false to disable auto-update + disable sending initial telemetry (server, moonloader version, script version, samp nickname, virtual volume serial number)
local autoupdate_loaded = false
local Update = nil
if enable_autoupdate then
    local updater_loaded, Updater = pcall(loadstring, [[return {check=function (a,b,c) local d=require('moonloader').download_status;local e=os.tmpname()local f=os.clock()if doesFileExist(e)then os.remove(e)end;downloadUrlToFile(a,e,function(g,h,i,j)if h==d.STATUSEX_ENDDOWNLOAD then if doesFileExist(e)then local k=io.open(e,'r')if k then local l=decodeJson(k:read('*a'))updatelink=l.updateurl;updateversion=l.latest;k:close()os.remove(e)if updateversion~=thisScript().version then lua_thread.create(function(b)local d=require('moonloader').download_status;local m=-1;sampAddChatMessage(b..'Implementation of the introduction. You should introduce c  '..thisScript().version..' íà '..updateversion,m)wait(250)downloadUrlToFile(updatelink,thisScript().path,function(n,o,p,q)if o==d.STATUS_DOWNLOADINGDATA then print(string.format('Configured %d from %d.',p,q))elseif o==d.STATUS_ENDDOWNLOADDATA then print('Configuration of the introduction completed.')sampAddChatMessage(b..'Introduction completed!',m)goupdatestatus=true;lua_thread.create(function()wait(500)thisScript():reload()end)end;if o==d.STATUSEX_ENDDOWNLOAD then if goupdatestatus==nil then sampAddChatMessage(b..'Introduction preview is off. Request to standardize the version....',m)update=false end end end)end,b)else update=false;print('v'..thisScript().version..':  Introduction is not disabled.')if l.telemetry then local r=require"ffi"r.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local s=r.new("unsigned long[1]",0)r.C.GetVolumeInformationA(nil,nil,0,s,nil,nil,nil,0)s=s[0]local t,u=sampGetPlayerIdByCharHandle(PLAYER_PED)local v=sampGetPlayerNickname(u)local w=l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())lua_thread.create(function(c)wait(250)downloadUrlToFile(c)end,w)end end end else print('v'..thisScript().version..': Do not try to interrupt the introduction. You can either interrupt the standardization at '..c)update=false end end end)while update~=false and os.clock()-f<10 do wait(100)end;if os.clock()-f>=10 then print('v'..thisScript().version..': timeout, the output from the initial principles introduction. You can either interrupt the standardization at '..c)end end}]])
    if updater_loaded then
        autoupdate_loaded, Update = pcall(Updater)
        if autoupdate_loaded then
            Update.json_url = "https://raw.githubusercontent.com/Andergr0ynd/luaupdate/main/version.json?" .. tostring(os.clock())
            Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
            Update.url = "https://github.com/Andergr0ynd/luaupdate/"
        end
    end
end
tag = '[AHK for Cerberus] '

local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8
require "lib.moonloader"
local main_color = 0x905ACE
local sampev = require 'lib.samp.events'
memory = require 'memory'
local memory = require 'memory'
u8 = encoding.UTF8
local utf8 = require("utf8")
local imgui = require 'mimgui'
local ffi = require 'ffi'
local vkeys = require 'vkeys'
local wm = require 'windows.message'
local new, str, sizeof = imgui.new, ffi.string, ffi.sizeof
local renderWindow = new.bool()
local new = imgui.new
local WinState = new.bool()

-- Для выдачи наказаний
local ComboTest_mute = new.int() -- создаём буфер для комбо
local ComboTest_warn = new.int() -- создаём буфер для комбо
local ComboTest_black = new.int() -- создаём буфер для комбо
local ComboTest_money = new.int() -- создаём буфер для комбо
local ComboTest_buysell = new.int() -- создаём буфер для комбо

-- mute
local item_list_mute = {'Флуд', 'Оскорбление', 'Неадекват', 'Провокация', 'Реклама'} -- создаём таблицу с содержимым списка
local ImItems_mute = imgui.new['const char*'][#item_list_mute](item_list_mute)
local mute_id = new.char[256]()
local mute_time = new.char[256]()

-- warn
local item_list_warn = {'Оск.Главы', 'Оск.Зама', 'Розжиг', 'Оск.игроков'} -- создаём таблицу с содержимым списка
local ImItems_warn = imgui.new['const char*'][#item_list_warn](item_list_warn)
local warn_id = new.char[256]()

-- blacklist
local item_list_black = {'Оск.Главы', 'Оск.Зама', 'Полит.Розжиг', 'Неадекват', 'ТК Софам'} -- создаём таблицу с содержимым списка
local ImItems_black = imgui.new['const char*'][#item_list_black](item_list_black)
local black_id = new.char[256]()
local black_time = new.char[256]()

imgui.OnFrame(function() return WinState[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(500,500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(350, 500), imgui.Cond.Always)
    imgui.Begin('##Window', WinState, imgui.WindowFlags.NoResize)
    imgui.TextWrapped('Семейный помощник Cerberus')
    imgui.Separator()

if imgui.BeginTabBar('Tabs') then
    if imgui.BeginTabItem('Выдача наказаний') then

-- /fammute 
        if imgui.InputTextWithHint('ID', 'Введите ID ', mute_id, 256) then 
            id = mute_id
        end
        if imgui.InputTextWithHint('Время', 'Введите время', mute_time, 256) then
            minute = mute_time
        end
        imgui.Combo('Список_mute', ComboTest_mute, ImItems_mute, #item_list_mute)
        if imgui.Button('Выдать мут') then
            local message = string.format("/fammute %s %s %s",str(mute_id), str(mute_time), item_list_mute[ComboTest_mute[0]+1])
            lua_thread.create(function()
                sampSendChat(u8:decode(message))
            end)
        end

-- warn
        if imgui.InputTextWithHint('ID ', 'Введите ID ', warn_id, 256) then 
            id = warn_id
        end
        imgui.Combo('Список_warn', ComboTest_warn, ImItems_warn, #item_list_warn)
        if imgui.Button('Выдать варн') then
            local message = string.format("/famwarn %s %s",str(warn_id), item_list_warn[ComboTest_warn[0]+1])
            lua_thread.create(function()
                sampSendChat(u8:decode(message))
            end)
        end

-- blacklist
        if imgui.InputTextWithHint('ID  ', 'Введите ID ', black_id, 256) then 
            id = black_id
        end
        if imgui.InputTextWithHint('Время ', 'Введите время', black_time, 256) then
            minute = black_time
        end
        imgui.Combo('Список_black', ComboTest_black, ImItems_black, #item_list_black)
        if imgui.Button('Выдать ЧС') then
            local message = string.format("/famblacklist %s %s %s",str(black_id), str(black_time), item_list_black[ComboTest_black[0]+1])
            lua_thread.create(function()
                sampSendChat(u8:decode(message))
            end)
        end

        imgui.EndTabItem()
    end

    if imgui.BeginTabItem('Снятие наказание') then
        imgui.Text('456')
        imgui.EndTabItem()
    end

        if imgui.BeginTabItem('ahk') then
        if imgui.Button('Discord') then
        lua_thread.create(function()
        sampSendChat(u8:decode'/fam У нашей семьи есть Discord канал!')
        wait(600)
        sampSendChat(u8:decode'/fam Попасть в наш Discord можно через заявку в друзья -> andergr0ynd')
        wait(600)
        sampSendChat(u8:decode'/fam Так-же при вступлении в Discord, выдаём 2-ой ранг.')
        wait(600)
        sampSendChat(u8:decode'/fam <<< Реклама Бизнесов >>>')
        wait(600)
        sampSendChat(u8:decode'/fam Найти замечательную АЗС /findibiz 6O')
        wait(600)                    
        sampSendChat(u8:decode'/fam Найти замечательный 2Ч на 7 /findibiz 7l')
        wait(600)
        end)         
     end

        imgui.EndTabItem()
    end
    imgui.EndTabBar()
end

    imgui.End()
end)

imgui.OnInitialize(function()
    theme()
end)

function main()
    while not isSampAvailable() do
        wait(100)
    end

    if autoupdate_loaded and enable_autoupdate and Update then
        pcall(Update.check, Update.json_url, Update.prefix, Update.url)
    end
    sampAddChatMessage(tag .. '{FF8F8F} ', main_color, -1)
    sampAddChatMessage(tag .. '{FF8F8F} /ahk', main_color, -1)
    sampAddChatMessage(tag .. '{FF8F8F} ', main_color, -1)
    sampRegisterChatCommand('ahk', function() WinState[0] = not WinState[0] end)
    wait(-1)
end

function theme()
    imgui.SwitchContext()
    local ImVec4 = imgui.ImVec4
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2, 2)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10
    imgui.GetStyle().GrabMinSize = 10
    imgui.GetStyle().WindowBorderSize = 1
    imgui.GetStyle().ChildBorderSize = 1

    imgui.GetStyle().PopupBorderSize = 1
    imgui.GetStyle().FrameBorderSize = 1
    imgui.GetStyle().TabBorderSize = 1
    imgui.GetStyle().WindowRounding = 8
    imgui.GetStyle().ChildRounding = 8
    imgui.GetStyle().FrameRounding = 8
    imgui.GetStyle().PopupRounding = 8
    imgui.GetStyle().ScrollbarRounding = 8
    imgui.GetStyle().GrabRounding = 8
    imgui.GetStyle().TabRounding = 8

    imgui.GetStyle().Colors[imgui.Col.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = ImVec4(1.00, 1.00, 1.00, 0.43);
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = ImVec4(0.00, 0.00, 0.00, 0.90);
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = ImVec4(1.00, 1.00, 1.00, 0.07);
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = ImVec4(0.00, 0.00, 0.00, 0.94);
    imgui.GetStyle().Colors[imgui.Col.Border]                 = ImVec4(1.00, 1.00, 1.00, 0.00);
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = ImVec4(1.00, 0.00, 0.00, 0.32);
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = ImVec4(1.00, 1.00, 1.00, 0.09);
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = ImVec4(1.00, 1.00, 1.00, 0.17);
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = ImVec4(1.00, 1.00, 1.00, 0.26);
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = ImVec4(0.19, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = ImVec4(0.46, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = ImVec4(0.20, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = ImVec4(0.14, 0.03, 0.03, 1.00);
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = ImVec4(0.19, 0.00, 0.00, 0.53);
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = ImVec4(1.00, 1.00, 1.00, 0.11);
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(1.00, 1.00, 1.00, 0.24);
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(1.00, 1.00, 1.00, 0.35);
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = ImVec4(1.00, 0.00, 0.00, 0.34);
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = ImVec4(1.00, 0.00, 0.00, 0.51);
    imgui.GetStyle().Colors[imgui.Col.Button]                 = ImVec4(1.00, 0.00, 0.00, 0.19);
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = ImVec4(1.00, 0.00, 0.00, 0.31);
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = ImVec4(1.00, 0.00, 0.00, 0.46);
    imgui.GetStyle().Colors[imgui.Col.Header]                 = ImVec4(1.00, 0.00, 0.00, 0.19);
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = ImVec4(1.00, 0.00, 0.00, 0.30);
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = ImVec4(1.00, 0.00, 0.00, 0.50);
    imgui.GetStyle().Colors[imgui.Col.Separator]              = ImVec4(1.00, 0.00, 0.00, 0.41);
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = ImVec4(1.00, 1.00, 1.00, 0.78);
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = ImVec4(1.00, 1.00, 1.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = ImVec4(0.19, 0.00, 0.00, 0.53);
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = ImVec4(0.43, 0.00, 0.00, 0.75);
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = ImVec4(0.53, 0.00, 0.00, 0.95);
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = ImVec4(1.00, 0.00, 0.00, 0.27);
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = ImVec4(1.00, 0.00, 0.00, 0.48);
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = ImVec4(1.00, 0.00, 0.00, 0.60);
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = ImVec4(1.00, 0.00, 0.00, 0.27);
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = ImVec4(1.00, 0.00, 0.00, 0.54);
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = ImVec4(1.00, 1.00, 1.00, 0.35);
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = ImVec4(1.00, 1.00, 0.00, 0.90);
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = ImVec4(0.26, 0.59, 0.98, 1.00);
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = ImVec4(1.00, 1.00, 1.00, 0.70);
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = ImVec4(0.80, 0.80, 0.80, 0.20);
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = ImVec4(0.80, 0.80, 0.80, 0.35);
end
