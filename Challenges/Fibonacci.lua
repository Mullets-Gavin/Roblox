-- Instructions:
-- 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, ...
-- The 2 is found by adding the two numbers before it (1+1),
-- The 3 is found by adding the two numbers before it (1+2),
-- The 5 is (2+3),
-- And so on!

-- Solution:
function fibonacciSequence(number)
    if number <= 2 then
        return 1
    end

    return fibonacciSequence(number - 1) + fibonacciSequence(number - 2)
end

for index = 1, 30 do
    print(fibonacciSequence(index))
end

-- Output:
-- 1
-- 1
-- 2
-- 3
-- 5
-- 8
-- 13
-- 21
-- 34
-- 55
-- 89
-- 144
-- 233
-- 377
-- 610
-- 987
-- 1597
-- 2584
-- 4181
-- 6765
-- 10946
-- 17711
-- 28657
-- 46368
-- 75025
-- 121393
-- 196418
-- 317811
-- 514229
-- 832040