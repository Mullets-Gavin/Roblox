-- Instructions:
-- Write a program that prints the numbers from 1 to 100
-- For numbers divisible by 3, print “Fizz”
-- For numbers divisible by 5, print “Buzz”
-- For numbers divisible by both 3 and 5, print “FizzBuzz”

-- Solution:
for index = 1, 15 do
    local str = ''
    
    if index % 3 == 0 then
        str = str..'Fizz'
    end
    
    if index % 5 == 0 then
        str = str..'Buzz'
    end
    
    print(index,str)
end

-- Output:
-- 1 
-- 2 
-- 3 Fizz
-- 4 
-- 5 Buzz
-- 6 Fizz
-- 7 
-- 8 
-- 9 Fizz
-- 10 Buzz
-- 11 
-- 12 Fizz
-- 13 
-- 14 
-- 15 FizzBuzz