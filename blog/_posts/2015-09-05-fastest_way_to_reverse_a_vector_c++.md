---
layout: post
html_title: Fastest way to reverse a C++ vector
title: '"Reversing" a vector in O(1)'
---

In C++, the most trivial way to return a reversed vector/container is to use the `rbegin()`/`rend()` iterators. e.g.

{% highlight c++ %}
std::vector<int> reverse{myVec.rbegin(), myVec.rend()};
{% endhighlight %}

which is fine for most cases. However, this constructs a new vector of length `myVec.size()` and copies the content of the old, which can be quite expensive for large `sizeof(T)` and/or large `myVec.size()`. Note we can do it with `std::reverse` in-place but this modifies the contents of the vector and is still an O(n) operation.

In most cases, we don't really want to return a reversed vector, but rather index from the reverse, which is quite simple to do with the reverse iterators it provides or if you want to use a for range loop in C++11 by swapping the iterators begin with rbegin and end with rend, e.g. with [`boost::reversed`](boost_reversed).

However, if we actually do want to return a new vector that is reversed, then we cannot use `boost::reversed`, but there is a some-what smarter way to reverse a vector than to construct a new one. In C++ specifically, this has some flaws, which I will discuss further down. The idea is quite simple: instead of copying the elements from `rbegin()` to `rend()` to a new vector, we would simply leave the contents of the vector and switch around it's iterators. This can essentially be achieved
with a new type, for example, `reversed_vec<T>` which would essentially switch the iterators, change the implementation of operator[] and .at(), and contain the unchanged data; alternatively you could just return the vector and only access data via reverse iterators or by vec[vec.size() - 1 - i], which is possible, but annoying.

As I mentioned, creating a new type has some flaws, which I will explain later on. If you don't quite understand what I am describing, here is a (somewhat) practical example of what I mean:

Say I ask you to make a function that takes an integer and returns all the Fibonacci numbers up to and including the Nth sequence, __but__ reversed. The typical/trivial way to implement this, is:

{% highlight c++ linenos %}
std::vector<int> reverse_fib(int N)
{
    std::vector<int> result;
    result.reverse(N + 1);
    for(int i = 0; i < 2 && i < N; ++i)
    {
        result.emplace_back(i);
    }

    for(int i = 2; i <= N; ++i)
    {
        result.emplace_back(result[i - 1] + result[i - 2]);
    }

    return std::vector<int>{result.rbegin(), result.rend()};
}
{% endhighlight %}

Notice the last line and how it is an O(N) operation. Now of course you could DP this problem recursively and add it to a vector in reverse, however, I think a much more straight forward solution to this would be to do the following:

{% highlight c++ linenos %}
reversed_vec<int> reverse_fib(int N)
{
    std::vector<int> result;
    result.reverse(N + 1);
    for(int i = 0; i < 2 && i < N; ++i)
    {
        result.emplace_back(i);
    }

    for(int i = 2; i <= N; ++i)
    {
        result.emplace_back(result[i - 1] + result[i - 2]);     
    }

    return reversed_vec{std::move(result)};
}
{% endhighlight %}

Now notice in the last line how instead of constructing a new vector we are moving our vector into a type called `reversed_vec`. The type `reverse_vec` is essentially a wrapper over `std::vector<T>` which can be implemented via composition or inheritance (the advantage of composition is no implicit conversion, but requires more boiler code). `reverse_vec` just contains the same data as the `vector` but switches around the begin, end iterators with rbegin and rend respectively. It should be noted
that this type is only useful if we are moving a `std::vector<T>`, if we're copying then it's going to be the same as constructing a vector via `vector<T>{myVec.rbegin(), myVec.rend()}`.

An obvious pitfall is for functions explicitly taking a `std::vector<int>`, requiring `std::vector<int>` as a result or callers expecting a `std::vector<int>`. This is due to reversed_vec not actually reversing the vector, but just holding the same data and swapping the implementation of it's iterator getters.

The advantage to using this type over something like [`boost::reversed`](boost_reversed) is the fact that you can return the reversed vector (in my example if you just returned the `rbegin()` iterator, it would be invalidated once you left the function).

Functions taking a `std::vector<int>` wouldn't work with `reversed_vec`, even if it was explicitly or implicitly convertible to `vector<int>`. This is because `reverse_vec` contains the same content as the vector had and would essentially mean that we've converted it to and from a type without changing anything. Instead, when we convert to `std::vector<T>` we could construct a copy of the vector and reverse the internals, but that is what we want to avoid (but this is OK if we actually *do* want to make a copy). Here is code example of what I mean:

{% highlight c++ linenos %}

// here it make sense to copy, since that is what the code is trying to say
reversed_vec rev_vec = make_rev({1, 2, 3, 4});
std::vector<int> vec = rev_vec; // (*)


void foo(const std::vector<int>& vec);

reversed_vec rev_vec = make_rev({1, 2, 3, 4});
foo(rev_vec); // (**)

{% endhighlight %}


\* Notice that if `reversed_vec` inherits from `std::vector<T>` it would be implicitly converted and vec which would just contain `{1, 2, 3, 4}` (since `reverse_vec` doesn't modify the data); a solution to this would be if `begin()`/`end()`/`rbegin()`/`rend()` was declared as virtual, but they're not and I don't think they should be, and even if they were object slicing could still occur (in this example object slicing would occur). Since it makes more sense to copy, but because they are
different types we should just make it a requirement to copy explicitly and not allow implicit conversions (`std::vector<int> vec{rev_vec.begin(), rev_vec.end()};`). 

\** Because of what I mentioned above, this code should cause a compilation error since it cannot/shouldn't be implicitly converted to `std::vector<T>`.

Another pitfall is the following, again due to not actually reversing the contents:

{% highlight c++ linenos %}
reversed_vec<int> v = make_rev({1, 2, 3, 4});
int* start = &v[0]; // this is actually &v[v.size() - 1]
start[2] = 3; // oops, out of bounds! Equivalent to v[v.size() + 1] = 3;
{% endhighlight %}

This only occurs if you are using raw pointers to the underlying data, which can be avoided in some but not all situations, e.g. by using `std::copy` instead of `memcpy`.

In general though, it would be better (try) to avoid having a vector as a parameter explicitly into a function and to prefer iterators/ranges instead, but this requires templates and can make you hate yourself.

# Improvements

One thing could be improved and that is reversed_vec working for not only vector but other container types which make sense to be reversed, e.g. `std::deque`, `std::list`, possibly `std::map` (since std::map is sorted) or anything with `begin`/`rbegin` and `end`/`rend`.

# Notes

This was just a random idea I thought of, I probably wouldn't use this type I made up in the real world, since it's typically easier to just access elements with reverse iterators. Also due to the flaws I mentioned above.

[boost_reversed]: http://www.boost.org/doc/libs/1_43_0/libs/range/doc/html/range/reference/adaptors/reference/reversed.html
