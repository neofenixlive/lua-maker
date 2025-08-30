message = "message" --define global variables
foo = 3
bar = 5

function print_message() --define global functions
    print(message)
end

function add_values(a, b)
    return a + b
end

foobar = add_values(foo, bar)