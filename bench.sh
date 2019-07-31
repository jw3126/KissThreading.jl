#!/bin/bash
echo "master"

cp test/perf.jl bench.jl
git checkout master && julia --project=. bench.jl || exit 1

echo "tmap"
git checkout tmap2 && julia --project=. bench.jl || exit 1

rm bench.jl
