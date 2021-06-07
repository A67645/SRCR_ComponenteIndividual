%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SIST. REPR. CONHECIMENTO E RACIOCINIO - MiEI/3

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Programacao em logica
% Projecto de Componente Individual

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SICStus PROLOG: Declaracoes iniciais

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- set_prolog_flag( unknown,fail ).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SICStus PROLOG: Includes

:- include('base_conhecimento.pl').

:- include('funcoes_auxiliares.pl').

% Procura em profundidade (breath first) -------------------------------

depthFirst(Origem, Destino, Caminho):-
    depthFirst(Origem, Destino, [Origem], Caminho).

depthFirst(Destino, Destino, _ , []).
depthFirst(Origem, Destino, Visitados,
           [(Origem, ProxNodo, Distancia)|Caminho]) :-
    proximoNodo(Origem, ProxNodo, Distancia, Visitados),
    depthFirst(ProxNodo, Destino, [ProxNodo|Visitados], Caminho).

% Procura em largura (depth first) -------------------------------

breadthFirst(Origem, Destino, Caminho):-
    breadthFirst([(Origem, [])|Xs]-Xs, [], Destino, Caminho).

breadthFirst([(Estado, Vs)|_]-_, _, Destino, Rs):-
    Estado == Destino,!, inverso(Vs, Rs).

breadthFirst([(Estado, _)|Xs]-Ys, Historico, Destino, Caminho):-
    membro(Estado, Historico),!,
    breadthFirst(Xs-Ys, Historico, Destino, Caminho).

breadthFirst([(Estado, Vs)|Xs]-Ys, Historico, Destino, Caminho):-
    setof(((Estado, ProxNodo, Distancia), ProxNodo), aresta(Estado, ProxNodo, Distancia), Ls),
    atualizar(Ls, Vs, [Estado|Historico], Ys-Zs),
    breadthFirst(Xs-Zs, [Estado|Historico], Destino, Caminho).

% Procura em profundidade limitada a N níveis -------------------------------

pesquisaEmProfundidade(Origem, Destino, N, Caminho):-
    pesquisaEmProfundidade2( Origem, Destino, N, [Origem], Caminho).

pesquisaEmProfundidade2(Destino, Destino, N, _, []).
pesquisaEmProfundidade2(Origem, Destino, N, Visitados, [(Origem, ProxNodo, Distancia)|Caminho]) :-
    tamanhoLista(Visitados, Tamanho),
        Tamanho < N,
    proximoNodo(Origem, ProxNodo, Distancia, Visitados),
    pesquisaEmProfundidade2(ProxNodo, Destino, N, [ProxNodo|Visitados], Caminho),
        tamanhoLista(Caminho, Total),
        Total < N.

% Procura em A*  -------------------------------

pesquisaAestrela(Origem, Destino, Caminho/Custo) :-
    estima(Origem,Destino,Estima),
aestrela([[(0,Origem,_)]/0/Estima], Destino, CaminhoInvertido/Custo/_),
    inverso(CaminhoInvertido, Caminho).

%condicao de paragem - destino na cabeça da lista do caminho
aestrela(Caminhos, Destino, Caminho) :-
    obtem_melhor(Caminhos, Caminho),
    Caminho = [(_,Nodo,_)|_]/_/_,Nodo == Destino.

aestrela(Caminhos, Destino, SolucaoCaminho) :-
    obtem_melhor(Caminhos, MelhorCaminho),
    seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
    expande_aestrela(MelhorCaminho, Destino, ExpCaminhos),
    append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
        aestrela(NovoCaminhos, Destino, SolucaoCaminho).


% Procura gulosa -------------------------------

pesquisaGulosa(Origem, Destino, Caminho/Custo) :-
    estima(Origem,Destino,Estima),
gulosa([[(0,Origem,_)]/0/Estima], Destino, CaminhoInvertido/Custo/_),
    inverso(CaminhoInvertido, Caminho).

gulosa(Caminhos, Destino, Caminho) :-
obtem_melhor_gulosa(Caminhos, Caminho),
    Caminho = [(_,Nodo,_)|_]/_/_,Nodo == Destino.

gulosa(Caminhos, Destino, SolucaoCaminho) :-
    obtem_melhor_gulosa(Caminhos, MelhorCaminho),
    seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
    expande_aestrela(MelhorCaminho, Destino, ExpCaminhos),
    append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
        gulosa(NovoCaminhos, Destino, SolucaoCaminho).

% Procura de um precurso considerando a saída da garagem e o despejo no reservatorio

percursoDF(Origem, Destino, N, PontosIntermedios, Caminho):-
solucoes(Percurso, pesquisaEmProfundidade(Origem,Destino, N, Percurso), L),
pontosIntermedios(L, PontosIntermedios, Caminho).


percursoBF(Origem, Destino, PontosIntermedios, Caminho):-
solucoes(Percurso, breadthFirst(Origem,Destino,Percurso), L),
pontosIntermedios(L, PontosIntermedios, Caminho).

percursoAestrela(Origem, Destino, PontosIntermedios, Caminho/Custo) :-
solucoes(Percurso, pesquisaAestrela(Origem, Destino, Caminho/Custo), L),
pontosIntermedios(L, PontosIntermedios, Caminho).

percursoGulosa(Origem, Destino, PontosIntermedios, Caminho/Custo) :-
solucoes(Percurso, pesquisaGulosa(Origem, Destino, Caminho/Custo), L),
pontosIntermedios(L, PontosIntermedios, Caminho).

pontosIntermedios([Ponto|CaudaPontosIntermedios], PontosIntermedios, Caminho):-
    auxiliar(Ponto, PontosIntermedios, Caminho);
    pontosIntermedios(CaudaPontosIntermedios, PontosIntermedios, Caminho).

auxiliar(Caminho, [], Caminho).
auxiliar(Caminho, [Ponto|CaudaPontosIntermedios], Solucao):-
    (membro((Ponto, _, _), Caminho); membro((_, Ponto, _), Caminho)),
    auxiliar(Caminho, CaudaPontosIntermedios, Solucao).
