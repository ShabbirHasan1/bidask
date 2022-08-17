module BidAsk

using Statistics

function is_nan_inf(x)
    if isnan(x)
        return true
    elseif isinf(x)
        return true
    else
        return false
    end
end

function nanmean(x::AbstractVector)
    return mean(filter(!is_nan_inf, x))
end

function nanvar(x::AbstractVector)
    return var(filter(!is_nan_inf, x))
end

"""
Efficient Estimation of Bid-Ask Spreads from OHLC Prices

Implements an efficient estimation procedure of the bid-ask spread from Open, High, Low, and Close
prices as proposed in Ardia, Guidotti, Kroencke (2021): https://www.ssrn.com/abstract=3892335

Prices must be sorted in ascending order of the timestamp.

Parameters
----------
- `open`::AbstractVector of open prices
- `high`::AbstractVector of high prices
- `low`::AbstractVector of low prices
- `close`::AbstractVector of close prices

Returns
-------
`Float64` The spread estimate.

"""
function edge(open::AbstractVector, high::AbstractVector, low::AbstractVector, close::AbstractVector)
    
    o = log.(open)
    h = log.(high)
    l = log.(low)
    c = log.(close)
    
    m = (h .+ l) ./ 2.0

    h1 = h[1:end-1]
    l1 = l[1:end-1]
    c1 = c[1:end-1]
    m1 = m[1:end-1]

    o = o[2:end]
    h = h[2:end]
    l = l[2:end]
    c = c[2:end]
    m = m[2:end]

    x1 = (m-o) .* (o-m1) + (m-c1) .* (c1-m1)
    x2 = (m-o) .* (o-c1) + (o-c1) .* (c1-m1)

    e1 = nanmean(x1)
    e2 = nanmean(x2)

    v1 = nanvar(x1)
    v2 = nanvar(x2)

    w1 = v2 ./ (v1 .+ v2)
    w2 = v1 ./ (v1 .+ v2)
    k = 4 .* w1 .* w2

    n1 = nanmean(o .== h)
    n2 = nanmean(o .== l)
    n3 = nanmean(c1 .== h1)
    n4 = nanmean(c1 .== l1)
    n5 = nanmean(h .== l .&& l .== c1)

    s2 = -4 * (w1 * e1 + w2 * e2) / ((1 - k * (n1 + n2) / 2) + (1 - n5) * (1 - k * (n3 + n4) / 2))

    return s2
end

export 
edge

end # module
