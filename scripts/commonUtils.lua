local utils = {}
local json = require("json")
local url = require("socket.url")
local language = getLanguage()
local msgBox = require("widgets.messageTextOverlayEx")
local msgBoxModal = require("widgets.messageTextOverlayModal")
local iosPushPopup = require("widgets.iosPushPopup")
local storyboard = require( "storyboard" )

function utils.getFileNameFromFullURL(url)
    local result = url:match("([^/]+)$")
    
    return result
end

function utils.fileExist( fname, path )
    local results = false
    
    if fname == nil or fname == "" then
        return results
    end
    
    local filePath = system.pathForFile( fname, path )

    if filePath then
    	filePath = io.open( filePath, "r" )
    end

    if (filePath) then
        filePath:close()
	results = true
    end
    
    return results
end

function utils.deleteFile( fname, path )
    local results, reason = os.remove( system.pathForFile( fname, path  ) )
end

local function searchChar(url, index, char)
    local startOfFilename = string.find( url, char, index)
    if startOfFilename ~= nil then
        return searchChar(url, startOfFilename + 1, char)
    else
        return index
    end
end

function utils.extractFileName( url )
    local startOfFilename = searchChar( url, 1, "/" )
    local returnData
    if startOfFilename == nil then
    	returnData = nil
    else
    	returnData = string.sub(url, startOfFilename )
    end
		
    return returnData
end

function utils.downloadImage(image, dir, callback)
    local params = {}
    params.progress = true
    
    
    local fileName = utils.extractFileName(image)
    
    network.download(
        image,
        "GET",
        callback,
        params,
        fileName,
        dir
    )
end

function utils.downloadImages(imagelist, dir, callback)
    local params = {}
    params.progress = true
    
    for  i = 1, # imagelist do
        local fileName = utils.extractFileName(imagelist[i])
        
        network.download(
            imagelist[i],
            "GET",
            callback,
            params,
            fileName,
            dir
        )
    end
end

function utils.getAppPropertyData()
    local appTable = {}
    local path = system.pathForFile( __APP_PROPERTY_FILE__, system.DocumentsDirectory )
    local file = io.open( path, "r" )
    if file then
        local data = file:read( "*a" )
        appTable = json.decode(data);
        io.close( file )
        file = nil
    end
    return appTable
end

function utils.setAppPropertyData(k, v)
    local appTable = utils.getAppPropertyData()
    appTable[k] = v
    local path = system.pathForFile( __APP_PROPERTY_FILE__, system.DocumentsDirectory )
    local file = io.open( path, "w" )
    if file then
        local contents = json.encode(appTable)
        file:write( contents )
        io.close( file )
        file = nil
        return true
    else
        return false
    end
end

function utils.setAppInitPropertyData(t)
    local path = system.pathForFile( __APP_PROPERTY_FILE__, system.DocumentsDirectory )
    local file = io.open( path, "w" )
    if file then
        local contents = json.encode(t)
        file:write( contents )
        io.close( file )
        file = nil
        return true
    else
        return false
    end
end

function utils.isEmailValidFormat(email)
    if (email:match("[A-Za-z0-9%.%%%+%-%_]+@[A-Za-z0-9%.%%%+%-%_]+%.%w%w%w?%w?")) then
        return true
    else
        return false
    end
end

function utils.rgbToPercentValue(R, G, B)
    local color = {R/255, G/255, B/255}
    return color
end

function utils.escape (s)
    s = string.gsub(s, "([&=+%c\128-\255])", function (c)
        return string.format("%%%02X", string.byte(c))
    end)
    s = string.gsub(s, " ", "+")
    return s
end

function utils.getDayOfWeek(year, month, day)
    local dw = os.date('*t',os.time{year = year, month = month, day = day})['wday']
    return (language["calendar"]["week"])[dw]
end

function utils.getTimeStamp(dateString)
--    local pattern = "(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)([%+%-])(%d+)%:(%d+)"
    local pattern = "(%d+)%/(%d+)%/(%d+) (%d+):(%d+):(%d+)"
    local xyear, xmonth, xday, xhour, xminute, xseconds
    local nYear, nMonth, nDay, nHour, nMinute, nSeconds
    local strDateTime
    
    xyear, xmonth, xday, xhour, xminute, xseconds = dateString:match(pattern)
    nYear = tonumber(xyear)
    nMonth = tonumber(xmonth) 
    nDay = tonumber(xday) 
    nHour = tonumber(xhour)
    nMinute = tonumber(xminute)
    nSeconds = tonumber(xseconds)
    
    local dtThen = os.time(
        {
            year = xyear, month = xmonth,
            day = xday, hour = xhour, min = xminute, sec = xseconds
        }
    )
--    local dtNow = os.date("*t")
    local diffTime = math.abs(os.difftime(os.time(), dtThen))
    
    strDateTime = dateString
    
    if(xyear == nil) then
--        strDateTime = dateString
    else
        if(diffTime < 3600) then --1 hour check
            if(diffTime < 60) then --60 seconds check
--                strDateTime = diffTime..language["commonUtils"]["now"]
                strDateTime = language["commonUtils"]["now"]
--                strDateTime = diffTime..language["commonUtils"]["seconds_ago"]
            else
                local diffMinute = math.round(diffTime / 60)
                strDateTime = diffMinute..language["commonUtils"]["minutes_ago"]
            end    
        elseif(diffTime < (24 * 3600)) then --24 hours check
            --시 계산
            local diffHour = math.round(diffTime / 3600)
            local diffMinute = math.round((diffTime % 3600) / 60)
            if(diffMinute > 0) then
                strDateTime = diffHour..language["commonUtils"]["hours"].." "..diffMinute..language["commonUtils"]["minutes_ago"]
            else
                strDateTime = diffHour..language["commonUtils"]["hours_ago"]
            end
        elseif(diffTime < (24 * 3600 * 7)) then -- one week check
            local diffDay = math.round(diffTime / (24 * 3600))
            if(diffDay == 1) then -- yesterday
                strDateTime = language["commonUtils"]["yesterday"].." "..xhour..":"..xminute
            elseif(diffDay == 2) then --two days ago 
                strDateTime = language["commonUtils"]["before_yesterday"].." "..xhour..":"..xminute
            else
                strDateTime = diffDay..language["commonUtils"]["days_ago"].." "..xhour..":"..xminute
            end
        end
    end
    
    return strDateTime.." ("..utils.getDayOfWeek(nYear, nMonth, nDay)..")"
end

function utils.pushNotificationSoundPlay(filename)
    local sound = audio.loadSound(filename)
 
    local function disposeSound( event )
        audio.stop( event.channel )
        audio.dispose( event.handle )
        
        audioplay = nil
    end

    local audioplay = audio.play(sound, { onComplete=disposeSound } )
end

function utils.showMessage(message, showTime)
    if message and message ~= "" then
        msgBox.createDialog(message, showTime)
    end
end

function utils.showMessageModal(message)
    if message and message ~= "" then
        msgBoxModal.createDialog(message)
    end
end

function utils.create_iOSPushPopup(message, showTime)
    iosPushPopup.createPopup(message, showTime)
end

function utils.create_iOSPushPopup4Tour(jobType)
    if system.getInfo("platformName") ~= "Android" then
        math.randomseed( os.time() )

        local doit = math.random( 1, 10 )
        if doit == 3 then
    --      메세지 보여주자  
            local msgNum = math.random( 1, 7 )
            if jobType == __PARENT__ then
                utils.create_iOSPushPopup(language["tourScene"]["push_popup_home"][msgNum]) -- 연출을 위한 코드
            elseif jobType == __DIRECTOR__ or jobType == __TEACHER__ then
                utils.create_iOSPushPopup(language["tourScene"]["push_popup_mnghome"][msgNum]) -- 연출을 위한 코드
            end
        end
    end
end

function utils.getRandomValue(_startDigit, _endDigit)
    math.randomseed( os.time() )

    return math.random( _startDigit, _endDigit )
end

function utils.comma_value(n)
    local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function utils.getLifeTimeFromBirthday(year, month, day)
    local now = os.time()
    local birthday = os.time(
        {
            year = year, 
            month = month, 
            day = day
        }
    )

    local lifeTime = (os.difftime(now, birthday) / (60 * 60 * 24)) + 0.5
    lifeTime = math.floor(lifeTime)
    
    return utils.comma_value(lifeTime)
end

function utils.convert2LocaleDateString(year, month, day)
--    local lang = system.getPreference("ui", "language")
    local returnStr = ""
        
--    if (lang == "ja" or lang == "ko" or lang == "日本語" or lang == "한국어") then --Japan   
    returnStr = year..language["calendar"]["year"].." "..language["calendar"]["month"][tonumber(month)].." "..day..language["calendar"]["date"]
--    else
--        returnStr = language["calendar"]["month"][tonumber(month)]..", "..day..language["calendar"]["date"]..", "..year..language["calendar"]["year"]
--    end
    
    return returnStr
end

function utils.convert2LocaleDateStringFromYYYYMMDD(yyyymmdd)
    local year = string.sub(yyyymmdd, 1, 4)
    local month = string.sub(yyyymmdd, 5, 6)
    local day = string.sub(yyyymmdd, 7, 8)
    
    return utils.convert2LocaleDateString(year, month, day)
end

function utils.convert2LocaleDateStringYYYYMM(year, month)
--    local lang = system.getPreference("ui", "language")
    local returnStr = ""
        
--    if (lang == "ja" or lang == "ko" or lang == "日本語" or lang == "한국어") then --Japan   
    returnStr = year..language["calendar"]["year"].." "..language["calendar"]["month"][tonumber(month)]
--    else
--        returnStr = language["calendar"]["month"][tonumber(month)]..", "..year..language["calendar"]["year"]
--    end
    
    return returnStr
end

function utils.trim(s)
    return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end

function utils.getTodayYYYYMMDD()
    local date = os.date( "*t" );
    local strYear = string.format("%04d",date.year)
    local strMonth = string.format("%02d",date.month)
    local strDay = string.format("%02d",date.day)
    
    return strYear..strMonth..strDay
end

function utils.generateInviteCode()
    math.randomseed( os.time() )
    math.random()
    
    local function num2bs(num)
	local _mod = math.fmod or math.mod
	local _floor = math.floor
	local result = ""
	if(num == 0) then return "0" end
	while(num  > 0) do
            result = _mod(num,2) .. result
            num = _floor(num*0.5)
	end              
        
        return result
    end

    local function bs2num(num)
	local _sub = string.sub
	local index, result = 0, 0
	if(num == "0") then return 0; end
	for p=#num,1,-1 do
            local this_val = _sub( num, p,p )
            if this_val == "1" then
                result = result + ( 2^index )
            end
            index=index+1
	end
	return result
    end

    local function padbits(num,bits)
	if #num == bits then return num end
	if #num > bits then print("too many bits") end
	local pad = bits - #num
	for i=1,pad do
            num = "0" .. num
	end
	return num
    end
    
    local _rnd = math.random
    local _fmt = string.format
    
    _rnd()
    
    local time_low_a = _rnd(0, 65535)
    local time_low_b = _rnd(0, 65535)
    
    local clock_seq_hi_res = _rnd(0,63)
    clock_seq_hi_res = padbits( num2bs(clock_seq_hi_res), 6 )
    clock_seq_hi_res = "10" .. clock_seq_hi_res 
    
    local clock_seq_low = _rnd(0,255)
    clock_seq_low = padbits( num2bs(clock_seq_low), 8 )
    
    local clock_seq = bs2num(clock_seq_hi_res .. clock_seq_low)
    
    local guid = ""
    guid = guid .. padbits(_fmt("%X",time_low_a), 4)
    guid = guid .. padbits(_fmt("%X",time_low_b), 4)
--    guid = guid .. padbits(_fmt("%X",clock_seq), 4) 
    
    return guid
end

function utils.inviteByLineMessenger(message, invite_code)
    local function urlencode(str)
        if (str) then
            str = string.gsub (str, "\n", "\r\n")
            str = string.gsub (str, "([^%w ])",
            function (c) return string.format ("%%%02X", string.byte(c)) end)
            str = string.gsub (str, " ", "+")
        end
        return str
    end
 
    local encodeString = "http://line.me/R/msg/text/?"
        ..url.escape("日本語、한국어 , English test! http://www.kidsup.net")
--    local encodeString = "http://line.me/R/msg/"
--        ..urlencode(message..invite_code)
    system.openURL(encodeString)
end

function utils.getAppLocalVersion(_devicetype)
    if(_devicetype == "iphone") then
        return __LOCAL_APP_VERSION_IOS__
    elseif(_devicetype == "android") then
        return __LOCAL_APP_VERSION_ANDROID__
    end
end

function utils.getAppServerVersion(_devicetype)
    if(_devicetype == "iphone") then
        return __SERVER_APP_INFO__.ios.version
    elseif(_devicetype == "android") then
        return __SERVER_APP_INFO__.android.version
    end
end

function utils.imageLoadingRect(parent, _x, _y, _width, _height)
    local img = display.newImageRect("images/etc/imageloading.png", 239, 162)
    img.anchorX = 0
    img.anchorY = 0
    img.x = _x + (_width - img.width) * 0.5
    img.y = _y + (_height - img.height) * 0.5
    parent:insert(img)
    
    return img
end

function utils.imageLoadingFailedRect(parent, _x, _y, _width, _height)
    local img = display.newImageRect("images/etc/imagenotloading.png", 239, 162)
    img.anchorX = 0
    img.anchorY = 0
    img.x = _x + (_width - img.width) * 0.5
    img.y = _y + (_height - img.height) * 0.5
    parent:insert(img)
    
    return img
end

function utils.UTF8ToCharArray(str)
    local charArray = {};
    local iStart = 0;
    local strLen = str:len();
    
    local function bit(b)
        return 2 ^ (b - 1);
    end
 
    local function hasbit(w, b)
        return w % (b + b) >= b;
    end
    
    local checkMultiByte = function(i)
        if (iStart ~= 0) then
            charArray[#charArray + 1] = str:sub(iStart, i - 1);
            iStart = 0;
        end        
    end
    
    for i = 1, strLen do
        local b = str:byte(i);
        local multiStart = hasbit(b, bit(7)) and hasbit(b, bit(8));
        local multiTrail = not hasbit(b, bit(7)) and hasbit(b, bit(8));
 
        if (multiStart) then
            checkMultiByte(i);
            iStart = i;
            
        elseif (not multiTrail) then
            checkMultiByte(i);
            charArray[#charArray + 1] = str:sub(i, i);
        end
    end
    
    checkMultiByte(strLen + 1);
 
    return charArray;
end

function utils.UFT8Len(str)
    return select(2, str:gsub('[^\128-\193]', ''))
end

function utils.UTF8Sub(str, _startIndex, _numChars)
    local function chsize(char)
        if not char then
            return 0
        elseif char > 240 then
            return 4
        elseif char > 225 then
            return 3
        elseif char > 192 then
            return 2
        else
            return 1
        end
    end
    
    local startIndex = _startIndex
    local numChars = _numChars
    local currentIndex = startIndex

    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + chsize(char)
        numChars = numChars -1
    end
    
    return str:sub(startIndex, currentIndex - 1)
end

function utils.getLocale()
    local locale = system.getPreference( "locale", "language" ):lower()
    if system.getInfo("platformName") ~= "Android" then
        locale = system.getPreference("ui", "language")
    end
    
    return string.gsub(locale, "-", "_")
end

function utils.getLanguageType4api(_lang)
    local langType = "2" --English(default)
    
--    if _lang == "ja" or _lang == "日本語" then
    langType = "1"
--    elseif _lang == "ko" or _lang == "한국어" then
--        langType = "3"
--    end
    
    return langType
end

function utils.isValidDate(yyyy, mm, dd)
    local y = tonumber(yyyy)
    local m = tonumber(mm)
    local d = tonumber(dd)

    if d <= 0 or d > 31 or m <= 0 or m > 12 or y <= 0 then
        return false
    elseif m == 4 or m == 6 or m == 9 or m == 11 then 
        return d <= 30
    elseif m == 2 then
        -- 2월달
        if y%400 == 0 or (y%100 ~= 0 and y%4 == 0) then
            return d <= 29
        else
            return d <= 28
        end
    else 
        return d <= 31
    end
end

function utils.IS_Demo_mode(storyboard, showMessage)
    if ( storyboard.state.DEMO_MODE and storyboard.state.DEMO_MODE == true ) then
        if (showMessage and showMessage == true) then
            utils.showMessage( language["tourScene"]["warning_message"] )
        end

        return true
    else
        return false
    end
end

function utils.getTourAccount(jobType)
    local email = ""
    local password = ""
    local languageCode = "en" --기본 영어
    local lang = system.getPreference("ui", "language")
    
--    if (lang == "ja" or lang == "日本語") then --Japan   
    languageCode = "ja"
--    elseif (lang == "ko" or lang == "한국어") then --Japan   
--        languageCode = "ko"
--    else
--        languageCode = "en" --기본 영어
--    end
    
    for i = 1, #__TOUR_ACCOUNTS__ do
        local account = __TOUR_ACCOUNTS__[i]
        if account.languageName == languageCode then
            if jobType == __PARENT__ then
                email = __TOUR_ACCOUNTS__[i].parent_account[1]
                password = __TOUR_ACCOUNTS__[i].parent_account[2]
            elseif jobType == __TEACHER__ then
                email = __TOUR_ACCOUNTS__[i].teacher_account[1]
                password = __TOUR_ACCOUNTS__[i].teacher_account[2]
            elseif jobType == __DIRECTOR__ then    
                email = __TOUR_ACCOUNTS__[i].director_account[1]
                password = __TOUR_ACCOUNTS__[i].director_account[2]
            end
        end
    end
    
    return email, password
end

function utils.getURLfromContents( string_with_URLs )
    local urlTable = {}
    
    local function existSameURL(_url)
        for i = 1, #urlTable do
            if urlTable[i] == _url then
                return true
            end
        end
        
        return false
    end
    
    
    local domains = [[.ac.ad.ae.aero.af.ag.ai.al.am.an.ao.aq.ar.arpa.as.asia.at.au
        .aw.ax.az.ba.bb.bd.be.bf.bg.bh.bi.biz.bj.bm.bn.bo.br.bs.bt.bv.bw.by.bz.ca
        .cat.cc.cd.cf.cg.ch.ci.ck.cl.cm.cn.co.com.coop.cr.cs.cu.cv.cx.cy.cz.dd.de
        .dj.dk.dm.do.dz.ec.edu.ee.eg.eh.er.es.et.eu.fi.firm.fj.fk.fm.fo.fr.fx.ga
        .gb.gd.ge.gf.gh.gi.gl.gm.gn.gov.gp.gq.gr.gs.gt.gu.gw.gy.hk.hm.hn.hr.ht.hu
        .id.ie.il.im.in.info.int.io.iq.ir.is.it.je.jm.jo.jobs.jp.ke.kg.kh.ki.km.kn
        .kp.kr.kw.ky.kz.la.lb.lc.li.lk.lr.ls.lt.lu.lv.ly.ma.mc.md.me.mg.mh.mil.mk
        .ml.mm.mn.mo.mobi.mp.mq.mr.ms.mt.mu.museum.mv.mw.mx.my.mz.na.name.nato.nc
        .ne.net.nf.ng.ni.nl.no.nom.np.nr.nt.nu.nz.om.org.pa.pe.pf.pg.ph.pk.pl.pm
        .pn.post.pr.pro.ps.pt.pw.py.qa.re.ro.ru.rw.sa.sb.sc.sd.se.sg.sh.si.sj.sk
        .sl.sm.sn.so.sr.ss.st.store.su.sv.sy.sz.tc.td.tel.tf.tg.th.tj.tk.tl.tm.tn
        .to.tp.tr.travel.tt.tv.tw.tz.ua.ug.uk.um.us.uy.va.vc.ve.vg.vi.vn.vu.web.wf
        .ws.xxx.ye.yt.yu.za.zm.zr.zw]]
    local tlds = {}
    local pos, url, prot, subd, tld, colon, port, slash, path
    for tld in domains:gmatch'%w+' do
        tlds[tld] = true
    end
    
    local protocols = {[''] = 0, ['http://'] = 0, ['https://'] = 0, ['ftp://'] = 0}
    for pos, url, prot, subd, tld, colon, port, slash, path in string_with_URLs:gmatch
        '()(([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w+)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))'
    do
        if protocols[prot:lower()] == (1 - #slash) * #path
            and (colon == '' or port ~= '' and port + 0 < 65536)
            and (tlds[tld:lower()] or tld:find'^%d+$' and subd:find'^%d+%.%d+%.%d+%.$'
            and math.max(tld, subd:match'^(%d+)%.(%d+)%.(%d+)%.$') < 256)
            and not subd:find'%W%W'
        then
--            print(pos, url)
            if string.upper(string.sub(url, 1, 4)) ~= "HTTP" then --만일 http가 없을경우(system.openURL() 에서 오류)
                url = "http://" .. url
            end
            
            if existSameURL(url) == false then
                urlTable[#urlTable + 1] = url
            end
        end
    end
    
    return urlTable
end

function utils.setParagraphContents(row, contents, txt_options, yBeginOffset, xLoc )
    local yOffset = 10 + yBeginOffset--row.txt_createTime.y + row.txt_createTime.height
    local paragraph = ""
    local tmpString = contents
    
    repeat
        local b, e = string.find(tmpString, "\n")  
        if b then
            paragraph = string.sub(tmpString, 1, b - 1)
            tmpString = string.sub(tmpString, e + 1)
        else 
            paragraph = tmpString
            tmpString = ""
        end    

        if paragraph then
            txt_options.text = paragraph
            row.paragraphs[#row.paragraphs + 1] = display.newText( txt_options )
            row.paragraphs[#row.paragraphs].anchorX = 0
            row.paragraphs[#row.paragraphs].anchorY = 0
            row.paragraphs[#row.paragraphs].x = xLoc--row.viewPanel.x + 5
            row.paragraphs[#row.paragraphs].y = yOffset 
            row.paragraphs[#row.paragraphs]:setFillColor( unpack(__Read_NoticeList_FontColor__))
            row:insert( row.paragraphs[#row.paragraphs] )
            yOffset = yOffset + row.paragraphs[#row.paragraphs].height
        end
    until tmpString == nil or string.len( tmpString ) == 0  
    
    return yOffset
end

function utils.getParagraphContentsHeight(contents, txt_options )
    local yOffset = 0
    local paragraph = ""
    local paragraphs = {}
    local tmpString = contents
    local height
    
    local tmpString = contents
    repeat
        local b, e = string.find(tmpString, "\n")  
        if b then
            paragraph = string.sub(tmpString, 1, b-1)
            tmpString = string.sub(tmpString, e+1)
        else 
            paragraph = tmpString
            tmpString = ""
        end    

        if paragraph then
            txt_options.text = paragraph
            paragraphs[#paragraphs + 1] = display.newText( txt_options )
            paragraphs[#paragraphs].anchorX = 0
            paragraphs[#paragraphs].anchorY = 0
            paragraphs[#paragraphs].y = yOffset
            yOffset = yOffset + paragraphs[#paragraphs].height
            height = yOffset

            paragraphs[#paragraphs]:removeSelf()
            paragraphs[#paragraphs] = nil
        end
    until tmpString == nil or string.len( tmpString ) == 0  
    
    local urlTable = utils.getURLfromContents(contents)
    local tmpUrlText
    for i = 1, #urlTable do
        txt_options.text = urlTable[i]
    
        tmpUrlText = display.newText( txt_options )
        height = height + tmpUrlText.height + 5
        
        tmpUrlText:removeSelf()
        tmpUrlText = nil
    end
    if #urlTable > 0 then
        height = height + 10
    end
    
    return height
end

function utils.showWebView(_url, _titleOfLoading)
    local options = {
        effect = "fromBottom",
        time = 300,
        params = {
            title = _titleOfLoading,
            url = _url,
        },
        isModal = true
    }
    storyboard.showOverlay( "scripts.webViewScene" ,options )
end

function utils.getDisplayClassName4Teacher(classTable)
    local str = ""
    
    if #classTable > 1 then
        str = classTable[1].name .." + " .. #classTable - 1
    else
        str = classTable[1].name
    end
    
    return str
end

return utils