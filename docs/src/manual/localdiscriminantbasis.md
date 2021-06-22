# [Local Discriminant Basis](@id ldb_manual)

Local Discriminant Basis is a feature extraction technique developed by N. Saito and R. Coifman in 1995. This algorithm follows the following basic steps:

1. Decompose a set of multi-class signals using wavelet packet decomposition. A wavelet packet decomposition decomposes a signal into multiple nodes which resembles a binary tree.
2. Based on the decomposed wavelet coefficients, build an energy map based on time-frequency or probability density.
3. Using the energy map, compute the discriminant measure and select a basis tree that best discriminates the different classes of signals.
4. Based on the selected basis tree, extract the corresponding wavelet coefficients for each signal.
5. Compute the discriminant power of each coefficient index. Select the top k set of coefficients to be used as features to be passed onto a classifier such as Linear Discriminant Analysis (LDA) and Classification and Regression Trees (CART).

A more in-depth tutorial can be found in the Pluto notebook [here](https://github.com/ShozenD/LDBExperiments). For more information on LDB, please refer to the original paper "Local Discriminant Basis and their Applications" by Saito and Coifman [here](https://www.math.ucdavis.edu/~saito/publications/saito_ldb_jmiv.pdf).

## Example
We first generate a multi-class dataset. WaveletsExt.jl has 2 built-in multi-class signals dataset, namely the triangular signals (`:tri`) and the cylinder-bell-funnel signals (`:cbf`).
```@example ldb_tutorial
using Wavelets, WaveletsExt, Plots

# generates 100 signals for each class of cylinder-bell-funnel
X, y = generateclassdata(ClassData(:cbf, 100, 100, 100));

# view sample signals and how each class differs from one another
cylinder = wiggle(X[:,1:5], sc=0.3)
plot!(cylinder, title="Cylinder signals")
bell = wiggle(X[:,101:105], sc=0.3)
plot!(bell, title="Bell signals")
funnel = wiggle(X[:,201:205], sc=0.3)
plot!(funnel, title="Funnel signals")
plot(cylinder, bell, funnel, layout=(3,1))
```

Next, we define the parameters for our Local Discriminant Basis object. Here are a few key parameters to note:
* `wt`: Type of wavelet used. Default is `wavelet(WT.haar)`.
* `max_dec_level`: Maximum decomposition level. Default is to decompose each signal all the way to its maximum possible depth.
* `dm`: Type of discriminant measure. Available choices are:
    - `AsymmetricRelativeEntropy()` (default)
    - `SymmetricRelativeEntropy()`
    - `LpEntropy()`
    - `HellingerDistance()`
* `en`: Type of energy map. Available choices are:
    - `TimeFrequency()` (default)
    - `ProbabilityDensity()`
* `dp`: Type of discriminant power. Available choices are:
    - `BasisDiscriminantMeasure()` (default)
    - `FishersClassSeparability()`
    - `RobustFishersClassSeparability()`
* `top_k`: Max number of coefficients used in each node for the computation of discriminant power. The default setting uses all available coefficients for the computation.
* `n_features`: Number of features to be returned. All features/coefficients will be returned by default.
```@example ldb_tutorial
wt = wavelet(WT.coif4);
ldb = LocalDiscriminantBasis(
    wt=wt, 
    max_dec_level=7,
    dm=SymmetricRelativeEntropy(), 
    en=TimeFrequency(),
    dp=BasisDiscriminantMeasure(),
    top_k=10,
    n_features=10
);

# transform and extract the features using LDB
X̂ = fit_transform(ldb, X, y);
nothing # hide
```

After fitting our data, we will then also be able to conduct our own analysis. We can observe where the best basis is selected from using the `plot_tfbdry` function.
```@example ldb_tutorial
plot_tfbdry(ldb.tree)
```

Another thing we can do is observe the heatmap produced by the discriminant measure (`ldb.DM`).
```@example ldb_tutorial
heatmap(1:ldb.n, 0:ldb.max_dec_level, ldb.DM);
plot!(title="Discriminant Measure Heatmap")
```

To decide how many features we should select, we can use the elbow rule on the discriminant powers (`ldb.DP`). From the plot below, we can see that approximately 6 features should be chosen for the classification step.
```@example ldb_tutorial
plot(ldb.DP[ldb.order], labels="discriminant power");
plot!(title="Plot of LDB Discriminant Power")
```

Knowing the 6 features we want to select, we can go one step further and examine the basis vectors generated by the coefficients of these 6 indices by defining the function below. In the illustration purpose of this tutorial, the basis vectors generated by the coefficients of the top 10 features are plotted below.
```@example ldb_tutorial
function get_basisvectors(n::Integer, wt::DiscreteWavelet, tree::BitVector,
        idx::Vector{<:Integer})

    k = length(idx)
    y = Array{Float64,2}(undef, (n,k))
    for (i,j) in enumerate(idx)
        x = zeros(n)
        x[j] = 1
        y[:,i] = iwpt(x, wt, tree)
    end
    return y
end

bases = get_basisvectors(128, ldb.wt, ldb.tree, ldb.order[1:10]);
wiggle(bases, sc=0.3, ZDir=:reverse);
plot!(title="Top 10 LDB vectors")
```

Since we have decided that 6 features are optimum for classification purposes, we can use the `change_nfeatures` function as below.
```@example ldb_tutorial
X̂ = change_nfeatures(ldb, X̂, 6);
nothing # hide
```

If we are curious, we can use the `inverse_transform` function to observe how the signals look like if they're generated from these 6 features.
```@example ldb_tutorial
X̃  = inverse_transform(ldb, X̂);

# view sample signals and how each class differs from one another
cylinder = wiggle(X̃[:,1:5], sc=0.3)
plot!(cylinder, title="Cylinder signals")
bell = wiggle(X̃[:,101:105], sc=0.3)
plot!(bell, title="Bell signals")
funnel = wiggle(X̃[:,201:205], sc=0.3)
plot!(funnel, title="Funnel signals")
plot(cylinder, bell, funnel, layout=(3,1))
```

With that said, we are essentially done with the LDB step, and we can move on to the model fitting step using packages such as [MLJ.jl](https://alan-turing-institute.github.io/MLJ.jl/stable/) and [MultivariateStats.jl](https://multivariatestatsjl.readthedocs.io/en/latest/).