local ffi = require("ffi")

function on_start(dbc_ptr)

    print('okk')

    local db = sqlite3.open_ptr(dbc_ptr)

    db:exec [[

		create table rpc (
		  id integer primary key autoincrement,
		  ts bigint, 
		  rm_ep text, 
		  lc_ep text, 
		  lc_pid integer, 
          lc_tid integer
		);
 
		create table lpc (
		  id integer primary key autoincrement,
		  ts bigint, 
		  rm_pid integer, 
		  rm_tid integer, 
		  lc_pid integer, 
          lc_tid integer
		); 
		create table info (id integer primary key  autoincrement, content text);

	]]

end

local DbgPrint = print

local dump_memory = function(address, size, per_line)
    local addr = ffi.cast('uint8_t*', address)
    local mem = ''
    for i = 1, size do
        mem = mem .. string.format('%02x,', addr[i - 1])
        if (i % per_line) == 0 then
            DbgPrint(mem)
            mem = ''
        end
    end
    print('---\n')
end

local dump_args = function(func_name, ...)

    local msg = func_name .. '('

    for k, v in pairs {...} do

        local tmp = v
        if type(v) == "table" then

            local tb = "{"

            for _, vv in pairs(v) do

                tb = tb .. tostring(vv) .. ','

            end

            tb = tb .. "}"

            tmp = tb
        end

        msg = msg .. tostring(tmp) .. ','
    end

    msg = msg .. ')'

    print(msg)
    -- DbgPrint(msg)
end

local function STR( ... )
    local msg = ''

    for k, v in pairs {...} do

        local tmp = v
        
        if type(v) == "table" then

            local tb = "{"

            for _, vv in pairs(v) do

                tb = tb .. tostring(vv) .. ','

            end

            tb = tb .. "}"

            tmp = tb
        end

        msg = msg .. tostring(tmp) .. ','
    
    end

    msg = msg .. ')'

    return msg
end

function on_callback(dbc_ptr, val, sz)

    -- print ('数据库' .. tostring(dbc_ptr))

    local db = sqlite3.open_ptr(dbc_ptr)

    --if tonumber(sz) == 90 then
    --   dump_memory(val, tonumber(sz), 16)
    -- end

    local tb = unpack(val)

    -- dump_args('',tb)

    if tb['t'] == 'ALPC' then

        local pid = tb.pid or 0
        local tid = tb.tid or 0
        local dpid = tb.dpid or 0
        local dtid = tb.dtid or 0
        local ts = tb.ts or 0

        local stm_sql = string.format("INSERT INTO  lpc VALUES (NULL, '%d', '%d', '%d', '%d', '%d');", ts, dpid, dtid,
            pid, tid)
        db:exec(stm_sql)

    end

    if tb['t'] == 'DCOM' then

        local pid = tb.pid or 0
        local tid = tb.tid or 0
        local dpid = tb.dpid or 0
        local dtid = tb.dtid or 0
        local ts = tb.ts or 0

        for k, v in pairs(tb['c']) do
           print(k, v)
        end

        local spid = 0

        -- 先查lpc
        for res in db:rows(string.format("SELECT rm_pid FROM lpc where lc_pid=%d and rm_pid!=0", tonumber(pid))) do
            spid = res[1]
            break
        end

        local raddr
        -- 查rpc
        for res in db:rows(string.format("SELECT rm_ep FROM rpc where lc_pid=%d", tonumber(spid))) do
            raddr = res[1]
            break
        end

        dump_args(string.format(
            '\n[无界告警]\n这是来自终端%s通过进程系统PID=%d在Explorer(PID=%d)进程远程调用DCOM接口的攻击行为!\n',
            raddr, spid, pid), '调用参数\n', tb['c'])

    end

    if tb['t'] == 'WMI' then

        --print ('wmi')
        local pid = tb.pid or 0
        local tid = tb.tid or 0
        local dpid = tb.dpid or 0
        local dtid = tb.dtid or 0
        local ts = tb.ts or 0

        for k, v in pairs(tb['c']) do
            print(k, v)
        end

        local spid = 0

        -- 先查lpc
        for res in db:rows(string.format("SELECT rm_pid FROM lpc where lc_pid=%d and rm_pid!=0", tonumber(pid))) do
            spid = res[1]
            break
        end

        local raddr
        -- 查rpc
        for res in db:rows(string.format("SELECT rm_ep FROM rpc where lc_pid=%d order by ts DESC", tonumber(spid))) do
            raddr = res[1]
            break
        end

        dump_args(string.format(
            '\n[无界告警]\n这是来自终端%s通过进程系统PID=%d在WmiPrevSE(PID=%d)进程远程调用WMI接口的攻击行为!\n',
            raddr, spid, pid), '调用参数\n', STR(tb['c'][1]), STR(tb['c'][2]), STR(tb['c'][3]), STR(tb['c'][6]))
    end

    if tb['t'] == 'RPC' then
        -- print('RPC_COMING')

        local pid = tb.pid or 0
        local tid = tb.tid or 0
        local ts = tb.ts or 0

        -- print(ts, tb['raddr'], tb['laddr'], pid, tid)
        local stm_sql = string.format("INSERT INTO  rpc VALUES (NULL, '%d', '%s', '%s', '%d', '%d');", ts, tb['raddr'],
            tb['laddr'], pid, tid)
        db:exec(stm_sql)
    end

    if tb['t'] == 'SRV' then
        dump_args(string.format(
            '\n[无界告警]\n这是来自终端%s远程服务调用%s行为!\n', STR(tb['c'][3]), STR(tb['c'][1])), '调用参数\n',STR(tb['c'][2]))
    end


    -- print (tostring(ffi) , tostring(val) )

    -- local stm_sql = string.format("INSERT INTO info VALUES (NULL, '%s');", tostring(val))

    -- db:exec(stm_sql)

    -- for a in db:nrows('SELECT * FROM lpc') do 
    -- print (a.ts)
    -- end

    -- db:close()

end