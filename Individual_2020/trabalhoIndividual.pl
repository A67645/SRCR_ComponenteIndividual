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

:- include('baseConhecimento.pl').

:- include('funcoesAuxiliares.pl').


%                       RESOLUÇÃO ALÍNEAS

% a) Calcular um trajeto possível entre duas cidades;


%--------------- Pesquisa Depth First - Pesquisa em Profundidade
%Expandir sempre um dos nós mais profundos da árvore

depthFirst(Origem, Destino, Caminho):-
    depthFirst(Origem, Destino, [Origem], Caminho).

depthFirst(Destino, Destino, _ , []).
depthFirst(Origem, Destino, Visitados,
           [(Origem, ProxNodo, Distancia)|Caminho]) :-
    proximoNodo(Origem, ProxNodo, Distancia, Visitados),
    depthFirst(ProxNodo, Destino, [ProxNodo|Visitados], Caminho).



%--Pesquisa em Profundidade limitada a 5 cidades

pesquisaEmProfundidade(Origem, Destino, Caminho):-
    pesquisaEmProfundidade2( Origem, Destino, [Origem], Caminho).

pesquisaEmProfundidade2(Destino, Destino, _, []).
pesquisaEmProfundidade2(Origem, Destino, Visitados, [(Origem, ProxNodo, Distancia)|Caminho]) :-
    tamanhoLista(Visitados, Tamanho),
        Tamanho < 5,
    proximoNodo(Origem, ProxNodo, Distancia, Visitados),
    pesquisaEmProfundidade2(ProxNodo, Destino, [ProxNodo|Visitados], Caminho),
        tamanhoLista(Caminho, Total),
        Total < 5.



%---- Pesquisa Breadth First - Pesquisa em Largura

% Todos os nós de menor profundidade são expandidos primeiro
%ficha11.pl


breadthFirst(Origem, Destino, Caminho):-
    breadthFirst([(Origem, [])|Xs]-Xs, [], Destino, Caminho).

breadthFirst([(Estado, Vs)|_]-_, _, Destino, Rs):-
    Estado == Destino,!, inverso(Vs, Rs).

breadthFirst([(Estado, _)|Xs]-Ys, Historico, Destino, Caminho):-
    membro(Estado, Historico),!,
    breadthFirst(Xs-Ys, Historico, Destino, Caminho).

breadthFirst([(Estado, Vs)|Xs]-Ys, Historico, Destino, Caminho):-
    setof(((Estado, ProxNodo, Distancia), ProxNodo), adjacencia(Estado, ProxNodo, Distancia), Ls),
    atualizar(Ls, Vs, [Estado|Historico], Ys-Zs),
    breadthFirst(Xs-Zs, [Estado|Historico], Destino, Caminho).


%--Pesquisa A*

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

%--Pesquisa Gulosa

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



%--------------------------------------------------------
% b) Selecionar apenas cidades, com uma determinada caraterística, para um determinado trajeto;

% b.1) Apenas cidades com Castelos

%--Pesquisa em Profundidade Limitada


apenasCidadesComCastelo(Origem, Destino, Caminho):-
    cidadeComCastelo(Origem),
    apenasCidadesComCastelo( Origem, Destino, [Origem], Caminho).

apenasCidadesComCastelo(Destino, Destino, _, []).

apenasCidadesComCastelo(Origem, Destino, Visitados, [(Origem, ProxNodo, Distancia)|Caminho]) :-
    tamanhoLista(Visitados, Tamanho),
        Tamanho < 115,
    proximoNodo(Origem, ProxNodo, Distancia, Visitados),
    cidadeComCastelo(ProxNodo),
    apenasCidadesComCastelo(ProxNodo, Destino, [ProxNodo|Visitados], Caminho),
        tamanhoLista(Caminho, Total),
        Total < 115.


%--Pesquisa A*

aestrelaSoCastelos(Origem, Destino, Caminho/Custo) :-
    cidadeComCastelo(Origem),
    estima(Origem,Destino,Estima),
    aEstrelaCastelos([[(0,Origem,_)]/0/Estima], Destino,CaminhoInvertido/Custo/_),
    inverso(CaminhoInvertido, Caminho).

aEstrelaCastelos(Caminhos, Destino, Caminho) :-
    obtem_melhor(Caminhos, Caminho),
    Caminho = [(_,Nodo,_)|_]/_/_,Nodo == Destino.

aEstrelaCastelos(Caminhos, Destino, SolucaoCaminho) :-
    obtem_melhor(Caminhos, MelhorCaminho),
    seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
    expande_aestrelaCastelos(MelhorCaminho, Destino, ExpCaminhos),
    append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
        aEstrelaCastelos(NovoCaminhos, Destino, SolucaoCaminho).

expande_aestrelaCastelos(Caminho, Destino, ExpCaminhos) :-
    findall(NovoCaminho, adjacenteComCastelo(Caminho,Destino,NovoCaminho), ExpCaminhos).



% b.2) Apenas cidades Património Mundial

%--Pesquisa em Profundidade Limitada

apenasCidadesPatrimonio(Origem, Destino, Caminho):-
    cidadePatrimonioMundial(Origem),
    apenasCidadesPatrimonio( Origem, Destino, [Origem], Caminho).

apenasCidadesPatrimonio(Destino, Destino, _, []).

apenasCidadesPatrimonio(Origem, Destino, Visitados, [(Origem, ProxNodo, Distancia)|Caminho]) :-
    tamanhoLista(Visitados, Tamanho),
        Tamanho < 115,
    proximoNodo(Origem, ProxNodo, Distancia, Visitados),
    cidadePatrimonioMundial(ProxNodo),
    apenasCidadesPatrimonio(ProxNodo, Destino, [ProxNodo|Visitados], Caminho),
        tamanhoLista(Caminho, Total),
        Total < 115.

%--Pesquisa A*

aestrelaPatrimonioMundial(Origem, Destino, Caminho/Custo) :-
    cidadePatrimonioMundial(Origem),
    estima(Origem,Destino,Estima),
    aEstrelaPatrimonio([[(0,Origem,_)]/0/Estima], Destino,CaminhoInvertido/Custo/_),
    inverso(CaminhoInvertido, Caminho).

aEstrelaPatrimonio(Caminhos, Destino, Caminho) :-
    obtem_melhor(Caminhos, Caminho),
    Caminho = [(_,Nodo,_)|_]/_/_,Nodo == Destino.

aEstrelaPatrimonio(Caminhos, Destino, SolucaoCaminho) :-
    obtem_melhor(Caminhos, MelhorCaminho),
    seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
    expande_aestrelaPatrimonio(MelhorCaminho, Destino, ExpCaminhos),
    append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
        aEstrelaPatrimonio(NovoCaminhos, Destino, SolucaoCaminho).

expande_aestrelaPatrimonio(Caminho, Destino, ExpCaminhos) :-
    findall(NovoCaminho, adjacentePatrimonio(Caminho,Destino,NovoCaminho), ExpCaminhos).





% b.3) Apenas cidades com mais de cem mil habitantes

apenasCidadesPopulosas(Origem, Destino, Caminho):-
    cidadePopulosa(Origem),
    apenasCidadesPopulosas( Origem, Destino, [Origem], Caminho).

apenasCidadesPopulosas(Destino, Destino, _, []).

apenasCidadesPopulosas(Origem, Destino, Visitados, [(Origem, ProxNodo, Distancia)|Caminho]) :-
    tamanhoLista(Visitados, Tamanho),
        Tamanho < 115,
    proximoNodo(Origem, ProxNodo, Distancia, Visitados),
    cidadePopulosa(ProxNodo),
    apenasCidadesPopulosas(ProxNodo, Destino, [ProxNodo|Visitados], Caminho),
        tamanhoLista(Caminho, Total),
        Total < 115.



%--Pesquisa A*


aestrelaPopulosa(Origem, Destino, Caminho/Custo) :-
    cidadePopulosa(Origem),
    estima(Origem,Destino,Estima),
    aestrelaPopulosaAux([[(0,Origem,_)]/0/Estima], Destino,CaminhoInvertido/Custo/_),
    inverso(CaminhoInvertido, Caminho).

aestrelaPopulosaAux(Caminhos, Destino, Caminho) :-
    obtem_melhor(Caminhos, Caminho),
    Caminho = [(_,Nodo,_)|_]/_/_,Nodo == Destino.

aestrelaPopulosaAux(Caminhos, Destino, SolucaoCaminho) :-
    obtem_melhor(Caminhos, MelhorCaminho),
    seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
    expande_aestrelaPopulosa(MelhorCaminho, Destino, ExpCaminhos),
    append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
        aestrelaPopulosaAux(NovoCaminhos, Destino, SolucaoCaminho).

expande_aestrelaPopulosa(Caminho, Destino, ExpCaminhos) :-
    findall(NovoCaminho, adjacentePopulosa(Caminho,Destino,NovoCaminho), ExpCaminhos).


%--------------------------------------------------------
% c) Excluir uma ou mais caracteristicas de cidades para um percurso;

%--------------- Pesquisa em Profundidade
%cidades que não são património Mundial

caminhoSemPatrimonioMundial(Origem, Destino, Caminho):-
    semPatrimonio(Origem),
    caminhoSemPatrimonioMundial( Origem, Destino, [Origem], Caminho).

caminhoSemPatrimonioMundial(Destino, Destino, _, []).

caminhoSemPatrimonioMundial(Origem, Destino, Visitados, [(Origem, ProxNodo, Distancia)|Caminho]) :-
    tamanhoLista(Visitados, Tamanho),
        Tamanho < 115,
    proximoNodo(Origem, ProxNodo, Distancia, Visitados),
    semPatrimonio(ProxNodo),
    caminhoSemPatrimonioMundial(ProxNodo, Destino, [ProxNodo|Visitados], Caminho),
        tamanhoLista(Caminho, Total),
        Total < 115.


%--Pesquisa A*


aestrelaSemPatrimonioMundial(Origem, Destino, Caminho/Custo) :-
    semPatrimonio(Origem),
    estima(Origem,Destino,Estima),
    aestrelaSemPatrimonio([[(0,Origem,_)]/0/Estima], Destino,CaminhoInvertido/Custo/_),
    inverso(CaminhoInvertido, Caminho).

aestrelaSemPatrimonio(Caminhos, Destino, Caminho) :-
    obtem_melhor(Caminhos, Caminho),
    Caminho = [(_,Nodo,_)|_]/_/_,Nodo == Destino.

aestrelaSemPatrimonio(Caminhos, Destino, SolucaoCaminho) :-
    obtem_melhor(Caminhos, MelhorCaminho),
    seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
    expande_aestrelaSemPatrimonio(MelhorCaminho, Destino, ExpCaminhos),
    append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
        aestrelaSemPatrimonio(NovoCaminhos, Destino, SolucaoCaminho).

expande_aestrelaSemPatrimonio(Caminho, Destino, ExpCaminhos) :-
    findall(NovoCaminho, adjacenteSemPatrimonio(Caminho,Destino,NovoCaminho), ExpCaminhos).


%--Pesquisa Gulosa

pesquisaGulosaSemPatrimonio(Origem, Destino, Caminho/Custo) :-
    semPatrimonio(Origem),
    estima(Origem,Destino,Estima),
    gulosa([[(0,Origem,_)]/0/Estima], Destino, CaminhoInvertido/Custo/_),
    inverso(CaminhoInvertido, Caminho).

gulosa(Caminhos, Destino, Caminho) :-
obtem_melhor_gulosa(Caminhos, Caminho),
    Caminho = [(_,Nodo,_)|_]/_/_,Nodo == Destino.

gulosa(Caminhos, Destino, SolucaoCaminho) :-
    obtem_melhor_gulosa(Caminhos, MelhorCaminho),
    seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
    expande_aestrelaSemPatrimonio(MelhorCaminho, Destino, ExpCaminhos),
    append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
        gulosa(NovoCaminhos, Destino, SolucaoCaminho).


%--------------------------------------------------------
% d) Identificar num determinado percurso qual a cidade com o maior número de ligações;


%--Pesquisa em Profundidade - Devolve nome da cidade com mais ligações

maisLigacoesDF(Origem, Destino, Maior) :-
    pesquisaEmProfundidade(Origem, Destino, Caminho),
    listIDTamFinal(Caminho, MaiorLista), maximo(MaiorLista, (Id, Tam)), cidadeNome(Id, Maior).


maisLigacoesBF(Origem, Destino, Maior) :-
breadthFirst(Origem, Destino, Caminho),
listIDTamFinal(Caminho, MaiorLista), maximo(MaiorLista, (Id, Tam)), cidadeNome(Id, Maior).



%--------------------------------------------------------
% e) Escolher o menor percurso (usando o critério do menor número de cidades percorridas);


%--Pesquisa em Profundidade Limitada

menorPercursoCidadesDF(Origem, Destino, Caminho):-
    findall(Caminho, pesquisaEmProfundidade(Origem, Destino, Caminho), Lista),
    menorLista(Lista, Caminho).


%--Pesquisa em Largura

menorPercursoCidadesBF(Origem, Destino, Caminho):-
findall(Caminho, breadthFirst(Origem, Destino, Caminho), Lista),
menorLista(Lista, Caminho).


%--------------------------------------------------------
% f) Escolher o percurso mais rápido (usando o critério da distância);

%Não funciona com a BC grande

%----Pesquisa em Profundidade Limitada


maisRapido(Origem, Destino, Caminho, Distancia):- findall((Trajecto, DistanciaTotal),
    pesquisaProfundidadeComDistancia(Origem, Destino, Trajecto, DistanciaTotal),
L),
minimo(L, (Caminho,Distancia)).


pesquisaProfundidadeComDistancia(Origem, Destino, Caminho, Custo):-
    pesquisaProfundidadeComDistancia( Origem, Destino, [Origem], Caminho, Custo).

pesquisaProfundidadeComDistancia(Destino, Destino, _, [],0).
pesquisaProfundidadeComDistancia(Origem, Destino, Visitados, [(Origem, ProxNodo, Distancia)|Caminho], Custo) :-
    tamanhoLista(Visitados, TotalV),
        TotalV < 200,
    proximoNodo(Origem, ProxNodo, Distancia, Visitados),
    pesquisaProfundidadeComDistancia(ProxNodo, Destino, [ProxNodo|Visitados], Caminho, CustoVisitados),
        tamanhoLista(Caminho, Total),
        Total < 200,
        Custo is Distancia + CustoVisitados.


%--Pesquisa A*

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

%--Pesquisa Gulosa

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


%--------------------------------------------------------
% g) Escolher um percurso que passe apenas por cidades “minor”;


%--------------- Pesquisa em Profundidade Limitada

apenasCidadesMinor(Origem, Destino, Caminho):-
    cidadeMinor(Origem),
    apenasCidadesMinor( Origem, Destino, [Origem], Caminho).

apenasCidadesMinor(Destino, Destino, _, []).

apenasCidadesMinor(Origem, Destino, Visitados, [(Origem, ProxNodo, Distancia)|Caminho]) :-
    tamanhoLista(Visitados, Tamanho),
        Tamanho < 115,
    proximoNodo(Origem, ProxNodo, Distancia, Visitados),
    cidadeMinor(ProxNodo),
    apenasCidadesMinor(ProxNodo, Destino, [ProxNodo|Visitados], Caminho),
        tamanhoLista(Caminho, Total),
        Total < 115.


%--Pesquisa A*

aestrelaCidadesMinor(Origem, Destino, Caminho/Custo) :-
    cidadeMinor(Origem),
    estima(Origem,Destino,Estima),
    aEstrelaMinor([[(0,Origem,_)]/0/Estima], Destino,CaminhoInvertido/Custo/_),
    inverso(CaminhoInvertido, Caminho).

aEstrelaMinor(Caminhos, Destino, Caminho) :-
    obtem_melhor(Caminhos, Caminho),
    Caminho = [(_,Nodo,_)|_]/_/_,Nodo == Destino.

aEstrelaMinor(Caminhos, Destino, SolucaoCaminho) :-
    obtem_melhor(Caminhos, MelhorCaminho),
    seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
    expande_aestrelaMinor(MelhorCaminho, Destino, ExpCaminhos),
    append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
        aEstrelaMinor(NovoCaminhos, Destino, SolucaoCaminho).

expande_aestrelaMinor(Caminho, Destino, ExpCaminhos) :-
    findall(NovoCaminho, adjacenteMinor(Caminho,Destino,NovoCaminho), ExpCaminhos).


%--Pesquisa Gulosa

gulosaCidadesMinor(Origem, Destino, Caminho/Custo) :-
    cidadeMinor(Origem),
    estima(Origem,Destino,Estima),
    gulosa([[(0,Origem,_)]/0/Estima], Destino,CaminhoInvertido/Custo/_),
    inverso(CaminhoInvertido, Caminho).

gulosa(Caminhos, Destino, Caminho) :-
    obtem_melhor_gulosa(Caminhos, Caminho),
    Caminho = [(_,Nodo,_)|_]/_/_,Nodo == Destino.

gulosa(Caminhos, Destino, SolucaoCaminho) :-
    obtem_melhor_gulosa(Caminhos, MelhorCaminho),
    seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
    expande_aestrelaMinor(MelhorCaminho, Destino, ExpCaminhos),
    append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
        aEstrelaMinor(NovoCaminhos, Destino, SolucaoCaminho).

expande_aestrelaMinor(Caminho, Destino, ExpCaminhos) :-
    findall(NovoCaminho, adjacenteMinor(Caminho,Destino,NovoCaminho), ExpCaminhos).




%--------------------------------------------------------
% h) Escolher uma ou mais cidades intermédias por onde o percurso deverá obrigatoriamente passar.
 

%--------------- Pesquisa em Profundidade


percursoDF(Origem, Destino, CidadesIntermedias, Caminho):-
findall(Percurso, pesquisaEmProfundidade(Origem,Destino,Percurso), L),
cidadesIntermedias(L, CidadesIntermedias, Caminho).


percursoBF(Origem, Destino, CidadesIntermedias, Caminho):-
findall(Percurso, breadthFirst(Origem,Destino,Percurso), L),
cidadesIntermedias(L, CidadesIntermedias, Caminho).



cidadesIntermedias([Cidade|CaudaCidadesIntermedias], CidadesIntermedias, Caminho):-
    auxiliar(Cidade, CidadesIntermedias, Caminho);
    cidadesIntermedias(CaudaCidadesIntermedias, CidadesIntermedias, Caminho).

auxiliar(Caminho, [], Caminho).
auxiliar(Caminho, [Cidade|CaudaCidadesIntermedias], Solucao):-
    (membro((Cidade, _, _), Caminho); membro((_, Cidade, _), Caminho)),
    auxiliar(Caminho, CaudaCidadesIntermedias, Solucao).


