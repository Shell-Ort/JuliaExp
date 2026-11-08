### A Pluto.jl notebook ###
# v1.0.4

using Markdown
using InteractiveUtils

# ╔═╡ 0d1978c0-db7c-11f1-8fae-33a3545b9630
begin 
	using Statistics
	using LinearAlgebra
	using Random
end

# ╔═╡ 4800c9b7-2044-4f3c-b5fa-5000dc88bb1b
begin
    mutable struct Capa
        W :: Matrix{Float64}
        b :: Vector{Float64}
    end
    Capa(n_in, n_out) = Capa(randn(n_out, n_in) * sqrt(2 / n_in), zeros(n_out))
end;

# ╔═╡ d1ea5202-9a4d-4c31-ae88-12e220ed7e4b
begin 
	struct MLP
        capas :: Vector{Capa}
    end
    
    MLP(tamaños :: Vector{Int}) =
        MLP([Capa(i, j) for (i,j) = zip(tamaños,tamaños[2:end])])
end;

# ╔═╡ 0492dfbf-ac2f-4c1d-853b-5547abdd9cf7
md"Función activación y derivada"

# ╔═╡ 635afa75-0565-49c8-86ed-eaee005f7715
begin
	sigmoid(x :: Number)  = 1 / (1 + exp(-x))
	dsigmoid(x :: Number) = x * (1 - x)
end;

# ╔═╡ e25c1890-228d-4ddc-b5bf-acfe7a9a7e8b
md"Función de avance"

# ╔═╡ 7f9c3234-a9ef-4371-92c4-476cc57f17e0
function forward(r :: MLP,x)
	act = [float.(vcat(x))]
	for capa = r.capas
		push!(act,sigmoid.(capa.W * act[end] .+ capa.b))
	end
	return act
end;

# ╔═╡ f5557cae-88f2-4e27-bcdb-1f5c3d2d0be4
md"Función de step y backpropagation"

# ╔═╡ 6b600e0b-600c-442d-9588-b120d257e776
function step!(r :: MLP,x,y,lr)
	a = forward(r,x)
	δ = (a[end] .- y) .* dsigmoid.(a[end])
	for i = length(r.capas):-1:1
		capa = r.capas[i]
		gradW = δ * a[i]'
		gradB = δ
		# Propagación
		i > 1 && (δ = (capa.W' * δ) .* dsigmoid.(a[i]))
		capa.W .-= lr .* gradW
        capa.b .-= lr .* gradB
	end
	return 0.5 * sum((a[end] .- y) .^ 2)
end;

# ╔═╡ c5bc68fb-0d78-4c12-b66a-a8edd13eb546
predict(red::MLP, x) = forward(red, x)[end];

# ╔═╡ f5a02b6c-7f19-40be-b906-84a7c3df8377
let
	Random.seed!(42)
    red = MLP([2, 10, 1])

    X = [0.0 0.0 1.0 1.0
         0.0 1.0 0.0 1.0]
    Y = [0.0 1.0 1.0 0.0]
    
    for epoch = 1:10_000
        lost = mean(step!(red, x, y, 0.5) for (x, y) = zip(eachcol(X), eachcol(Y)))
        epoch % 2000 == 0 && println("Época $epoch, pérdida = $(round(lost, digits=5))")
    end

    for (x, y) = zip(eachcol(X), eachcol(Y))
        println("$x → $(round(predict(red, x)[1], digits=3))  (esperado $(y[1]))")
    end
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.13.3"
manifest_format = "2.1"
project_hash = "f31f60a5a31b6300000a8c5c54aa45214a79e4f3"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.5.5+2"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.13.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.30+0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "1.0.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "e2b53ce13a53367e96601081e33d34746b571bad"
registries = "General"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.5"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[registries.General]
url = "https://github.com/JuliaRegistries/General.git"
uuid = "23338594-aafe-5451-b93e-139f81909106"
"""

# ╔═╡ Cell order:
# ╠═0d1978c0-db7c-11f1-8fae-33a3545b9630
# ╠═4800c9b7-2044-4f3c-b5fa-5000dc88bb1b
# ╠═d1ea5202-9a4d-4c31-ae88-12e220ed7e4b
# ╟─0492dfbf-ac2f-4c1d-853b-5547abdd9cf7
# ╠═635afa75-0565-49c8-86ed-eaee005f7715
# ╟─e25c1890-228d-4ddc-b5bf-acfe7a9a7e8b
# ╠═7f9c3234-a9ef-4371-92c4-476cc57f17e0
# ╟─f5557cae-88f2-4e27-bcdb-1f5c3d2d0be4
# ╠═6b600e0b-600c-442d-9588-b120d257e776
# ╠═c5bc68fb-0d78-4c12-b66a-a8edd13eb546
# ╠═f5a02b6c-7f19-40be-b906-84a7c3df8377
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
