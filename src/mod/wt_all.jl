# ========== Transforms On A Group Of Signals ==========
# ----- Discrete Wavelet Transform on a set of signals -----
"""
    dwtall(x, wt[, L])

Computes the discrete wavelet transform (DWT) on each slice of signal. Signals are sliced on
the ``n``-th dimension for an ``n``-dimensional input `x`.

*Note:* `dwt` is currently available for 1-D, 2-D, and 3-D signals only. 

# Arguments
- `x::AbstractArray{T} where T<:Number`: Input signals, where each slice corresponds to
  one signal. For a set of input signals `x` of dimension ``n``, signals are sliced on the
  ``n``-th dimension.
- `wt::OrthoFilter`: Wavelet used.
- `L::Integer`: (Default: `Wavelets.maxtransformlevels(xᵢ)`) Number of levels of wavelet
  transforms. 

# Returns
`::Array{T}`: Slices of transformed signals. Signals are sliced the same way as the input
signal `x`.

# Examples
```
using Wavelets, WaveletsExt

# Generate random signals
x = randn(32, 5)
# Create wavelet
wt = wavelet(WT.db4)

# DWT on all signals in x
xw = dwtall(x, wt)
```
"""
function dwtall(x::AbstractArray{T}, args...) where T<:Number
    # Sanity check
    @assert ndims(x) > 1

    # Allocate space for transforms
    y = similar(x)
    # Dimension to slice
    dim = ndims(y)
    # Compute transforms
    @inbounds begin
        @views for (yᵢ, xᵢ) in zip(eachslice(y, dims=dim), eachslice(x, dims=dim))
            dwt!(yᵢ, xᵢ, args...)
        end
    end
    return y
end

# ----- Wavelet Packet Transforms on a set of signals -----
"""
    wptall(x, wt[, L])

    wptall(x, wt, tree)

    wptall(x, wt[, L; standard])

    wptall(x, wt, tree[; standard])

Computes the wavelet packet transform (WPT) on each slice of signal. Signals are sliced on
the ``n``-th dimension for an ``n``-dimensional input `x`.

*Note:* `wpt` is currently available for 1-D signals only.
    
# Arguments
- `x::AbstractArray{T} where T<:Number`: Input signals, where each slice corresponds to
  one signal. For a set of input signals `x` of dimension ``n``, signals are sliced on the
  ``n``-th dimension.
- `wt::OrthoFilter`: Wavelet used.
- `L::Integer`: (Default: `Wavelets.maxtransformlevels(xᵢ)`) Number of levels of wavelet
  decomposition. 
- `tree::BitVector`: (Default: `Wavelets.maketree(xᵢ, :full)`) Tree to follow for wavelet
  decomposition. Default value is only applicable for 1D signals.
- `standard::Bool`: (Default: `true`) Whether to compute the standard or non-standard
  wavelet transform. Only applicable for 2D signals.
# Returns
`::Array{T}`: Slices of transformed signals. Signals are sliced the same way as the input
signal `x`.

# Examples
```
using Wavelets, WaveletsExt

# Generate random signals
x = randn(32, 5)
# Create wavelet
wt = wavelet(WT.db4)

# WPT on all signals in x
xw = wptall(x, wt)
```
"""
function wptall(x::AbstractArray{T}, args..., kwargs...) where T<:Number
    # Sanity check
    @assert ndims(x) > 1
    
    # Allocate space for transform
    y = similar(x)
    # Dimension to slice
    dim = ndims(x)
    # Compute transforms
    @inbounds begin
        @views for (yᵢ, xᵢ) in zip(eachslice(y, dims=dim), eachslice(x, dims=dim))
            wpt!(yᵢ, Array(xᵢ), args..., kwargs...)
        end
    end
    return y
end

# ----- Wavelet Packet Decomposition on a set of signals -----
"""
    wpdall(x, wt[, L])

    wpdall(x, wt[, L; standard])

Computes the wavelet packet decomposition (WPD) on each slice of signal. Signals are sliced
on the ``n``-th dimension for an ``n``-dimensional input `x`.

*Note:* `wpd` is currently available for 1-D signals only.

# Arguments
- `x::AbstractArray{T} where T<:Number`: Input signals, where each slice corresponds to
  one signal. For a set of input signals `x` of dimension ``n``, signals are sliced on the
  ``n``-th dimension.
- `wt::OrthoFilter`: Wavelet used.
- `L::Integer`: (Default: `Wavelets.maxtransformlevels(xᵢ)`) Number of levels of wavelet
  decomposition. 
- `standard::Bool`: (Default: `true`) Whether to compute the standard or non-standard
  wavelet transform. Only applicable for 2D signals.

# Returns
`::Array{T}`: Array of decomposed signals. Signals are sliced by the final dimension.

# Examples
```
using Wavelets, WaveletsExt

# Generate random signals
x = randn(32, 5)
# Create wavelet
wt = wavelet(WT.db4)

# WPT on all signals in x
xw = wpdall(x, wt)
"""
function wpdall(x::AbstractArray{T}, 
                wt::OrthoFilter, 
                L::Integer=maxtransformlevels(x,1);
                kwargs...) where T<:Number
    # Sanity check
    @assert ndims(x) > 1
    @assert 0 ≤ L ≤ maxtransformlevels(x,1)
       
    # Allocate space for transform
    sz = size(x)[begin:end-1]  # Signal size
    N = size(x)[end]           # Number of signals
    y = Array{T}(undef, (sz...,L+1,N))
    # Dimension to slice
    dim_y = ndims(y)
    dim_x = ndims(x)
    # Compute transforms
    @inbounds begin
        @views for (yᵢ, xᵢ) in zip(eachslice(y, dims=dim_y), eachslice(x, dims=dim_x))
            wpd!(yᵢ, Array(xᵢ), wt, L, kwargs...)
        end
    end
    return y
end
