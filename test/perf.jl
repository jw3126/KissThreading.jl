module Perf
using KissThreading
if isdefined(KissThreading, :tname)
    using KissThreading: tname
else
    tname(s::Symbol) = Symbol(:t, s)

end
using BenchmarkTools

macro race(f, args...; kw...)
    @show kw
    tf = tname(f)
    tt_call   = :(($tf)($(args...)))
    base_call = :((Base.$f)($(args...)))
    call_str = string(:($f($(args...))))
    quote
        println("Benchmark: ", $call_str)
        print("Base: ")
        @btime $(base_call) evals=10 samples=10
        print("Kiss: ")
        @btime $(tt_call) evals=10 samples=10
        println("#"^80)
    end |> esc
end

if !isdefined(KissThreading, :tsum)
    tsum(f, data) = tmapreduce(f, +, data, init=zero(eltype(data)))
end

if !isdefined(KissThreading, :tprod)
    tprod(f, data) = tmapreduce(f, +, data, init=one(eltype(data)))
end

if !isdefined(KissThreading, :tminimum)
    tminimum(f, data) = tmapreduce(f, min, data, init=typemax(eltype(data)))
end

if !isdefined(KissThreading, :tmaximum)
    tmaximum(f, data) = tmapreduce(f, max, data, init=typemin(eltype(data)))
end

if !isdefined(KissThreading, :treduce)
    treduce(op, data) = tmapreduce(identity, op, data, init=zero(eltype(data)))
end

@info "Running benchmarks on $(Threads.nthreads()) threads."
data = randn(10^5)
@race(sum,     sin, data)
@race(prod,    sin, data)
@race(minimum, sin, data)
@race(maximum, sin, data)
@race(reduce, atan, data)
@race(mapreduce, sin, +, data)
@race(map, sin, data)
dst = similar(data)
@race(map!, sin, dst, data)

end#module
