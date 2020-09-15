local hpa = HPA()

local function bank()
	local pbalance = 0 
	local balance = 0 
	local transactions = {}
	local ntrans = 100

	for i = 1, ntrans do
		table.insert(transactions, math.random(-10, 10))
	end

	function pDepOrDeb(idx)
		hpa:acquire("id")
		pbalance = pbalance + transactions[idx]
		hpa:release("id")
	end

	function DepOrDeb(idx)
		balance = balance + transactions[idx]
	end

	print("start bank test...")
	
	for idx = 1, ntrans do
		hpa:parallel("pDepOrDeb(idx)", idx)
	end
	hpa:joinall()

	for idx = 1, ntrans do
		DepOrDeb(idx)
	end

	if(pbalance == balance)then
		print("Ok")
	else
		print("error: "..pbalance.." ~= "..balance)
	end
	io.flush()
end

local function calcPI()
	local insideCircle = 0
	local pInsideCircle = 0
	local nexecs = 1000000
	local cpus = 2
	local posX = {}
	local posY = {}
	local p1 = 0
	local p2 = 0

	for i = 1, nexecs do
		table.insert(posX, math.random())
		table.insert(posY, math.random())
	end

	function ppi(initial,final)
		for i = initial, final do
			if ((posX[i]*posX[i]) + (posY[i]*posY[i])) <= 1 then
				hpa:acquire(1)
				pInsideCircle = pInsideCircle + 1
				hpa:release(1)
			end
		end
	end

	function pi()
		for ind = 1, nexecs do
			local x = posX[ind]
			local y = posY[ind]
			if ((x*x)+(y*y)) <= 1 then
				insideCircle = insideCircle + 1
			end
		end
	end

	print("start PI calculate...")
	l1 = math.floor(nexecs/2);
	l2 = l1+1
	
	local splitInt = math.floor(nexecs/cpus)
	local start = 1
	local finish = splitInt
	
	while(finish <= nexecs) do
		hpa:parallel("ppi(start,finish)", start, finish)
		start = finish + 1
		finish = finish + splitInt
	end
	hpa:joinall()
	
	pi()

	local presult = 4*(pInsideCircle/nexecs)
	local result = 4*(insideCircle/nexecs)
	
	if presult == result then
		print("Ok")
	else
		print("error")
	end
	
	io.flush()
end

local function stress1()
	local t = 0
	local cpus = 2
	local loops = 100000

	function sum()
		for i = 1, loops do
			hpa:acquire(1)
			t = t + 1
			hpa:release(1)
		end
	end

	print("start sum stress on critical section access...")
	for i = 1, cpus do
		hpa:parallel("sum()")
	end
	hpa:joinall()
	
	if t == loops * cpus then
		print("Ok")
	else
		print("error")
	end
	io.flush()
end

local function stress2()
	local cpus = 2	
	
	function foo()
		local t = 0
		local loops = 100000
		
		for i = 1, loops do
			t = i
			hpa:acquire(t)
			local x = t + i
			hpa:release(t)
		end
	end

	print("start foo stress on critical section access...")
	for i = 1, cpus do
		hpa:parallel("foo()")
	end
	hpa:joinall()
	print("Ok")
	io.flush()
end

local function stress3()
	local verifyVector = {}
	local loops = 100000
	local cpus = 2

	for i = 1, loops do
		table.insert(verifyVector, 0)
	end

	function foo()
		local t = 0
		for j = 1, #verifyVector do
			for i = 1, 1 do
				t = i
				hpa:acquire(j)
				verifyVector[j] = verifyVector[j] + j
				hpa:release(j)
			end
		end
	end

	print("start foo stress on critical section access...")
	for a = 1, cpus do
		hpa:parallel("foo()")
	end
	hpa:joinall()
	
	local verif = false
	for i = 1, loops do
		if(verifyVector[i] ~= (i * cpus)) then
			verif = true
			break
		end
	end
	
	if verif == true then
		print("error")
	else
		print("Ok")
	end
	io.flush()
end

local function parameters()
	local sum = 0
	function par1(p1)
		sum = sum + p1
	end

	function par2(p1, p2)
		sum = sum + p1 + p2
	end

	function par3(p1, p2, p3)
		sum = sum + p1 + p2 + p3
	end

	print("start different number of parameters...")
	hpa:parallel("par1(p1)", 1)
	hpa:parallel("par2(p1, p2)", 1, 2)
	hpa:parallel("par3(p1, p2, p3)", 1, 2, 3)
	hpa:joinall()
	if sum == 10 then
		print("Ok")
		io.flush()
	else
		print("parameters sum error: "..sum)
	end

end

local function workers()
	local loops = 100000
	function foo()
		local temp = 0
		for i = 1, 100 do 
			temp = temp + i/temp+1;
		end
	end
		
	print("start changing number of workers...")
	io.flush()
	
	local np = hpa:np()	
	hpa:np(1)
	for i = 1, loops do
		hpa:parallel("foo()")
	end
	hpa:joinall()
	print("Ok")
	io.flush()

	hpa:np(2)
	for i = 1, loops do
		hpa:parallel("foo()")
	end	
	hpa:joinall()
	print("Ok")
	io.flush()
	hpa:np(np)
end

local function returns()
	function foo3(j,i)
		hpa:acquire(1)
		local aux = {}
		local x, y = foo2()
		hpa:release(1)
		return x
	end
	
	function foo2() 
		return 1, 2
	end
	
	function foo1(j)
		for i = 1, 100 do
			foo3(j, i)
		end
	end
			
	print("start return conditions...")
	for i = 1, 10 do
		hpa:parallel("foo1(i)", i)
	end
	hpa:joinall()
	print("Ok")
	io.flush()
	collectgarbage()
end

local function bankJoin()
	local pbalance = 0 
	local balance = 0 
	local transactions = {}
	local ntrans = 100

	for i = 1, ntrans do
		table.insert(transactions, math.random(-10, 10))
	end

	function pDepOrDeb(idx)
		hpa:acquire("id")
		pbalance = pbalance + transactions[idx]
		hpa:release("id")
	end

	function DepOrDeb(idx)
		balance = balance + transactions[idx]
	end

	print("start bank test with join function...")
	
	for idx = 1, ntrans do
		hpa:parallel("pDepOrDeb(idx)", idx)
	end

	hpa:join("pDepOrDeb")

	-- only for test a funtion that not exists 
	hpa:join("FuncNExist")

	for idx = 1, ntrans do
		DepOrDeb(idx)
	end

	if(pbalance == balance)then
		print("Ok")
	else
		print("error: "..pbalance.." ~= "..balance)
	end
	io.flush()
end	

for n = 1, 10 do
	bank()
	bankJoin()
	calcPI()
	stress1()
	stress2()
	stress3()
	parameters()
	workers()
	returns()
end