%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Funções Auxiliares

% Calcula o número de elementos de uma lista.
tamanhoLista([], 0).
tamanhoLista([Cabeca|Cauda], TotalElementos) :- tamanhoLista(Cauda, Total), TotalElementos is Total+1.


% Verifica se o nodo Próximo já foi visitado.
proximoNodo(Actual, Proximo, Distancia, Caminho) :-
    adjacencia(Actual, Proximo, Distancia),
    naopertence(Proximo, Caminho).

% Verifica se o nodo Próximo já foi visitado.
proximoNodo(Actual, ProxNodo,Distancia,Caracteristica,Visitados) :-
    adjacencia(Actual, Proximo, Distancia),
    naopertence(Proximo, Caminho).


% Verifica se um elemento não faz parte de uma lista
naopertence(Elem, []) :- !.
naopertence(Elem, [Cabeca|Cauda]) :-
     Elem \= Cabeca,
    naopertence(Elem, Cauda).


%Actualiza o estado de uma lista
atualizar([],_,_,X-X).
atualizar([(_,Estado)|Ls], Vs, Historico, Xs-Ys):-
    membro(Estado, Historico), !,
    atualizar(Ls, Vs, Historico, Xs-Ys).


atualizar([(Move, Estado)|Ls], Vs, Historico, [(Estado, [Move|Vs])|Xs]-Ys) :- atualizar(Ls,Vs, Historico, Xs-Ys).


%verifica se elemento está contido numa lista
membro(X, [X|_]).
membro(X, [_|Xs]) :- membro(X,Xs).

membros([],_).
membros([X|Xs], Members):- membro(X,Members), membro(Xs,Members).

%Inverte uma lista
inverso(Xs, Ys):- inverso(Xs, [], Ys).

inverso([], Xs, Xs).
inverso([X|Xs], Ys, Zs):- inverso(Xs, [X|Ys], Zs).



%Encontra a lista com menor comprimento num conjunto de listas.
menorLista([L], L).
menorLista([ListaX,ListaY|CaudaDeListas], Menor) :-
    length(ListaX, TamX),
    length(ListaY, TamY),
    TamX =< TamY, !, menorLista([ListaX|CaudaDeListas], Menor).

menorLista([ListaX,ListaY|CaudaDeListas], Menor):- menorLista([ListaY|CaudaDeListas], Menor).


% Calcula o minimo de uma lista de pares
minimo([(P,X)], (P,X)).
minimo([(Px,X)|L], (Py, Y)) :- minimo(L, (Py,Y)), X > Y.
minimo([(Px,X)|L], (Px, X)) :- minimo(L, (Py,Y)), X =< Y.

% Calcula o maximo de uma lista de pares
maximo([(P,X)], (P,X)).
maximo([(Px,X)|L], (Py, Y)) :- maximo(L, (Py,Y)), X =< Y.
maximo([(Px,X)|L], (Px, X)) :- maximo(L, (Py,Y)), X > Y.

% Escreve uma lista com \n entre os elementos
escrever([]).
escrever([X|L]):- write(X), nl, escrever(L).

% Obtem melhor para Gulosa
obtem_melhor_gulosa([Caminho],Caminho):- !.

obtem_melhor_gulosa([Caminho1/Custo1/Est1,_/Custo2/Est2|Caminhos], MelhorCaminho):-
    Est1 =< Est2, !,
    obtem_melhor_gulosa([Caminho1/Custo1/Est1|Caminhos],MelhorCaminho).

obtem_melhor_gulosa([_|Caminhos],MelhorCaminho):- obtem_melhor_gulosa(Caminhos,MelhorCaminho).


%melhor caminho para A*
obtem_melhor([Caminho], Caminho) :- !.

obtem_melhor([Caminho1/Custo1/Est1,_/Custo2/Est2|Caminhos], MelhorCaminho) :-
    Custo1 + Est1 =< Custo2 + Est2, !,
    obtem_melhor([Caminho1/Custo1/Est1|Caminhos], MelhorCaminho).

obtem_melhor([_|Caminhos], MelhorCaminho) :-
    obtem_melhor(Caminhos, MelhorCaminho).

%Encontra os pontos de recolha adjacdentes a um determinado ponto de recolha
expande_aestrela(Caminho, Destino, ExpCaminhos) :-
    findall(NovoCaminho, adjacente(Caminho,Destino,NovoCaminho), ExpCaminhos).

inverso(Xs, Ys):-
    inverso(Xs, [], Ys).

inverso([], Xs, Xs).
inverso([X|Xs],Ys, Zs):-
    inverso(Xs, [X|Ys], Zs).

seleciona(E, [E|Xs], Xs).
seleciona(E, [X|Xs], [X|Ys]) :- seleciona(E, Xs, Ys).
