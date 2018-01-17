local function sleep(t)
	local ntime = sessionInfo().time + t
	repeat until sessionInfo().time >= ntime
end

Profiler():start("t1")
sleep(1)
Profiler():start("t2")
sleep(1)
Profiler():stop("t2")
Profiler():start("t2")
sleep(0.1)
Profiler():stop("t1")
Profiler():stop("t2")
for _ = 1, 10 do
	Profiler():start("tLoop")
	sleep(0.1)
	Profiler():stop("tLoop")
end

Profiler():report()