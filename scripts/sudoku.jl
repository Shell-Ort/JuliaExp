# Ejercicio de resuloción de sudoku con bolsa de tareas, en la practica de PPD era en C pero lo paso a Julia.
using Base.Threads

THREADS = 4
N = 9

const Tablero = Matrix{Int}

struct Tarea
    s::Tablero
    fila::Int
    colo::Int
end

function buscaCeldaVacia(s::Tablero, x::Ref{Int}, y::Ref{Int})::Bool
    while x[] <= N
        while y[] <= N
            if s[x[], y[]] == 0
                return true
            end
            y[] += 1
        end
        y[] = 1
        x[] += 1
    end
    return false
end

@inline function iniciar(q::Vector{Tarea})::Nothing
    sudoku = [
        6 0 1 0 0 4 0 8 0
        0 4 9 7 3 0 0 0 0
        8 2 3 0 0 0 0 4 0
        0 0 4 0 0 0 0 0 6
        0 0 7 0 0 0 2 0 0
        9 8 0 0 0 0 3 0 0
        4 1 0 0 0 0 0 6 5
        0 0 0 0 4 1 8 3 0
        0 5 0 2 0 0 4 0 7
    ]
    push!(q, Tarea(sudoku, 1, 1))
    return
end

function escribirtarea(tareaAct::Tarea)::Nothing
    for i in 1:N
        for j in 1:N
            print("$(tareaAct.s[i,j]) ")
        end
        println()
    end
    println()
end

@inline vacia(q::Vector{Tarea})::Bool = isempty(q)
@inline extraer(q::Vector{Tarea})::Tarea = pop!(q)
@inline insertar(q::Vector{Tarea}, nuevaTar::Tarea)::Nothing = (push!(q, nuevaTar); nothing)

function valido(tareaAct::Tarea, nro::Int)::Bool
    s = tareaAct.s
    f, c = tareaAct.fila, tareaAct.colo
    bf = f - (f-1)%3
    bc = c - (c-1)%3
    @inbounds if nro in view(s, f, :) || nro in view(s, :, c)
        return false
    end
    @inbounds if nro in view(s, bf:(bf+2), bc:(bc+2))
        return false
    end
    return true
end

function ponerNumero(t::Tarea, nro::Int)::Tarea
    s = copy(t.s)
    s[t.fila, t.colo] = nro
    if t.colo < N
        return Tarea(s, t.fila, t.colo + 1)
    elseif t.fila < N
        return Tarea(s, t.fila + 1, 1)
    else
        return Tarea(s, N, N)
    end
end

function resulverSudoku()::Nothing
    bolsa = Tarea[]
    iniciar(bolsa)
    critical = ReentrantLock()

    tareas = 1
    acabados = THREADS
    @sync for _ in 1:THREADS
        @spawn begin
            fin = false
            while !fin
                tomada = false
                tareaAct = nothing
                @lock critical begin
                    if tareas == 0 && acabados == THREADS
                        fin = true
                    elseif tareas != 0
                        acabados -= 1
                        tareas -= 1
                        tomada = true
                        tareaAct = extraer(bolsa)
                    end
                end
                if tomada
                    rf = Ref(tareaAct.fila)
                    rc = Ref(tareaAct.colo)
                    if !buscaCeldaVacia(tareaAct.s, rf, rc)
                        @lock critical escribirtarea(tareaAct)
                    else
                        t = Tarea(tareaAct.s, rf[], rc[])
                        for i in 1:N
                            if valido(t, i)
                                nueva = ponerNumero(t, i)
                                @lock critical begin
                                    tareas += 1
                                    insertar(bolsa, nueva)
                                end
                            end
                        end
                    end
                    @lock critical acabados += 1
                else
                    yield()
                end
            end
        end
    end
end

resulverSudoku()
println("FIN")