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


%Auxilia no calcula das cidades com mais adjacencias
listIDTamFinal(Caminho, L) :-
    listaIDTam(Caminho, A, L).

listaIDTam([], A, A).
listaIDTam([(Origem, Destino,_)| Cauda], A, L) :-
    cidadeID(Origem, TamOrigem),
    cidadeID(Destino, TamDestino),
    TamOrigem =< TamDestino, !,
    listaIDTam(Cauda, [(Destino, TamDestino) | A], L).
listaIDTam([(Origem, Destino,_)| Cauda], A, L) :-
    cidadeID(Origem, TamOrigem),
    listaIDTam(Cauda, [(Origem, TamOrigem) | A], L).



%Identifica cidade pelo id e devolve tamanho das adjacencias
cidadeID(ID, Tam):- cidade(ID,_,_,_,_,_,Adjacencia,_,_,_),
        length(Adjacencia,Tam).

%Identifica cidade pelo id e devolve nome.
cidadeNome(ID, Nome):- cidade(ID,_,_,Nome,_,_,_,_,_,_).




% Verifica se uma cidade tem poderes administrativos minor
cidadeMinor(IDCidade) :- cidade(IDCidade, _, _, _, _, PoderesAdminist, _, _, _, _), PoderesAdminist == 'minor'.

% Verifica se uma cidade é património mundial
semPatrimonio(IDCidade) :- cidade(IDCidade, _, _, _, _, _, _, 0, _, _).


% Verifica se uma cidade tem castelo
cidadeComCastelo(IDCidade) :- cidade(IDCidade, _, _, _, _, _, _, _, 1, _).

% Verifica se uma cidade é patrimonio mundial
cidadePatrimonioMundial(IDCidade) :- cidade(IDCidade, _, _, _, _, _, _, 1, _, _).

%Verifica se uma cidade tem mais de cem mil habitantes
cidadePopulosa(IDCidade) :- cidade(IDCidade, _, _, _, _, _, _, _, _, 1).


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


% Estima distância entre duas cidades
estima(IDOrigem, IDDestino, Estima) :- cidade(IDOrigem, Lat1,Long1,_,_,_,_,_,_,_), cidade(IDDestino, Lat2, Long2,_,_,_,_,_,_,_),
    Estima is sqrt(((Lat1-Lat2)*(Lat1-Lat2)) + ((Long1 - Long2) * (Long1 - Long2))).


%Encontra as Cidades adjacdentes a uma determinada Cidade
expande_aestrela(Caminho, Destino, ExpCaminhos) :-
    findall(NovoCaminho, adjacente(Caminho,Destino,NovoCaminho), ExpCaminhos).

%Cidades Adjacentes e Seu custo
adjacente([(NodoAnterior,NodoActual,Distancia)
          |Caminho]/Custo/_, Destino, [(NodoActual,ProxNodo, PassoCusto), (NodoAnterior,NodoActual,Distancia)|Caminho]/NovoCusto/Estima) :-
    adjacencia(NodoActual, ProxNodo, PassoCusto),\+ member((NodoActual,ProxNodo), Caminho),
    NovoCusto is Custo + PassoCusto,
    estima(ProxNodo,Destino,Estima).


%Cidades Adjacentes e verifica se tem Castelos
adjacenteComCastelo([(NodoAnterior, NodoActual, Distancia)
    |Caminho]/Custo/_, Destino, [(NodoActual,ProxNodo, PassoCusto), (NodoAnterior,NodoActual, Distancia)|Caminho]/NovoCusto/Estima) :-
    adjacencia(NodoActual, ProxNodo, PassoCusto), cidadeComCastelo(ProxNodo), \+ member((Nodo,ProxNodo), Caminho),
        NovoCusto is Custo + PassoCusto,
        estima(ProxNodo,Destino,Estima).

%Cidades Adjacentes e verifica se é património
adjacentePatrimonio([(NodoAnterior, NodoActual, Distancia)
|Caminho]/Custo/_, Destino, [(NodoActual,ProxNodo, PassoCusto), (NodoAnterior,NodoActual, Distancia)|Caminho]/NovoCusto/Estima) :-
adjacencia(NodoActual, ProxNodo, PassoCusto), cidadePatrimonioMundial(ProxNodo), \+ member((Nodo,ProxNodo), Caminho),
    NovoCusto is Custo + PassoCusto,
    estima(ProxNodo,Destino,Estima).

%Cidades Adjacentes e com mais de cem mil habitantes
adjacentePopulosa([(NodoAnterior, NodoActual, Distancia)
|Caminho]/Custo/_, Destino, [(NodoActual,ProxNodo, PassoCusto), (NodoAnterior,NodoActual, Distancia)|Caminho]/NovoCusto/Estima) :-
adjacencia(NodoActual, ProxNodo, PassoCusto), cidadePopulosa(ProxNodo), \+ member((Nodo,ProxNodo), Caminho),
    NovoCusto is Custo + PassoCusto,
    estima(ProxNodo,Destino,Estima).

%Cidades Adjacentes e minor
adjacenteMinor([(NodoAnterior, NodoActual, Distancia)
|Caminho]/Custo/_, Destino, [(NodoActual,ProxNodo, PassoCusto), (NodoAnterior,NodoActual, Distancia)|Caminho]/NovoCusto/Estima) :-
adjacencia(NodoActual, ProxNodo, PassoCusto), cidadeMinor(ProxNodo), \+ member((Nodo,ProxNodo), Caminho),
    NovoCusto is Custo + PassoCusto,
    estima(ProxNodo,Destino,Estima).



%Cidades Adjacentes e minor
adjacenteSemPatrimonio([(NodoAnterior, NodoActual, Distancia)
|Caminho]/Custo/_, Destino, [(NodoActual,ProxNodo, PassoCusto), (NodoAnterior,NodoActual, Distancia)|Caminho]/NovoCusto/Estima) :-
adjacencia(NodoActual, ProxNodo, PassoCusto), semPatrimonio(ProxNodo), \+ member((Nodo,ProxNodo), Caminho),
    NovoCusto is Custo + PassoCusto,
    estima(ProxNodo,Destino,Estima).







inverso(Xs, Ys):-
    inverso(Xs, [], Ys).

inverso([], Xs, Xs).
inverso([X|Xs],Ys, Zs):-
    inverso(Xs, [X|Ys], Zs).

seleciona(E, [E|Xs], Xs).
seleciona(E, [X|Xs], [X|Ys]) :- seleciona(E, Xs, Ys).
