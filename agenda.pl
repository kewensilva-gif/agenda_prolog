% A dynamic é uma diretiva
% ela é usada para informar que um predicado pode ser modificado dinamicamente
:- dynamic compromisso/3.

% Verifica se há um conflito de horário
verificar_conflito(data(Data1, Mes1, Ano1), hora(Hora1, Minuto1), data(Data2, Mes2, Ano2), hora(Hora2, Minuto2)) :-
    Ano1 =:= Ano2,
    Mes1 =:= Mes2,
    Data1 =:= Data2,
    (   Hora1 =:= Hora2,
        Minuto1 =:= Minuto2
    ->  fail
    ;   true
    ).

% Adiciona um compromisso se não houver conflito
adicionar_compromisso(Data, Hora, _) :-
    compromisso(Data, Hora, _),
    !,
    write('Já existe um compromisso no mesmo horário.'), nl, fail.

% Adiciona um compromisso dinamicamente, utilizando a função assertz
% ou seja, com ela é possível adicionar um compromisso durante a execução do programa
adicionar_compromisso(Data, Hora, Descricao) :-
    assertz(compromisso(Data, Hora, Descricao)),
    write('Compromisso adicionado com sucesso.'), nl.

% Remove um compromisso
remover_compromisso(Data, Hora) :-
    retract(compromisso(Data, Hora, _)),
    write('Compromisso removido com sucesso.'), nl.

% Lista compromissos para uma data específica
listar_compromissos(Data) :-
    compromisso(Data, Hora, Descricao),
    format('~w ~w: ~w~n', [Data, Hora, Descricao]),
    fail.
listar_compromissos(_) :- writeln('').

% Lista todos os compromissos
listar_todos_compromissos :-
    compromisso(Data, Hora, Descricao),
    format('~w ~w: ~w~n', [Data, Hora, Descricao]),
    fail.
listar_todos_compromissos :- writeln('').

% Salva os dados em um arquivo com codificação UTF-8
salvar_no_arquivo(Filename) :-
    open(Filename, write, Stream, [encoding(utf8)]),  
    listing(compromisso/3),
    close(Stream).

% Carrega os dados de um arquivo
carregar_do_arquivo(Filename) :-
    open(Filename, read, Stream, [encoding(utf8)]),
    repeat,
    read(Stream, Term),
    (   Term == end_of_file
    ->  !, close(Stream)
    ;   assertz(Term),
        fail
    ).

% Busca um compromisso pela descrição
buscar_compromisso_por_nome(Descricao) :-
    compromisso(Data, Hora, Descricao),
    format('Compromisso encontrado: ~w ~w: ~w~n', [Data, Hora, Descricao]),
    !.
buscar_compromisso_por_nome(_) :-
    writeln('Nenhum compromisso encontrado com essa descricao.').

% Basicamente é um menu em loop 
% O repeat ativa um loop infinito, semelhante a um while(true)
% a condição de parada vai ser quando o usuário digitar '0' que se refere a opção de saída do menu
% e aí ele faz um cut.
menu_loop :-
    repeat,
    exibe_menu,
    read(Escolha),
    op_selecionada(Escolha),
    Escolha = 0, 
    !.

% Menu de opções
exibe_menu :-
    writeln('Menu:'),
    writeln('1. Listar compromissos a partir de uma data'),
    writeln('2. Adicionar compromisso'),
    writeln('3. Remover compromisso'),
    writeln('4. Lista todos os compromissos'),
    writeln('5. Buscar compromisso pelo nome'),
    writeln('0. Sair'),
    write('Escolha uma opcao: ').

% Funciona como um switch, basicamente é o tratamento das opções escolhidas pelo usuário
op_selecionada(1) :-
    writeln('Lista de compromissos:'),
    write('Digite a data [dd,mm,aaaa]: '),
    read([DataDia, DataMes, DataAno]),
    listar_compromissos(data(DataDia, DataMes, DataAno)).

op_selecionada(2) :-
    writeln('Adicionar compromisso:'),
    write('Digite a data [dd,mm,aaaa]: '),
    read([DataDia, DataMes, DataAno]),
    write('Digite a hora [hh,mm]: '),
    read([Hora, Minuto]),
    write('Digite a descricao: '),
    read(Descricao),
    adicionar_compromisso(data(DataDia, DataMes, DataAno), hora(Hora, Minuto), Descricao).

op_selecionada(3) :-
    writeln('Remover compromisso:'),
    write('Digite a data [dd,mm,aaaa]: '),
    read([DataDia, DataMes, DataAno]),
    write('Digite a hora [hh,mm]: '),
    read([Hora, Minuto]),
    remover_compromisso(data(DataDia, DataMes, DataAno), hora(Hora, Minuto)).

op_selecionada(4) :-
    writeln('Lista de todos os compromissos:'),
    listar_todos_compromissos.

op_selecionada(5) :-
    writeln('Buscar compromisso:'),
    write('Digite o nome do compromisso: '),
    read(Descricao),
    buscar_compromisso_por_nome(Descricao).

% Essa opção finaliza o loop
% salva os compromissos que estão em memória no arquivo
% Exibe mensagem de saída
op_selecionada(0) :-
    salvar_no_arquivo('compromissos.pl'),
    writeln('Saindo do menu.').

% Essa função faz com que ao inicializar o arquivo agenda.pl já seja executada a função 'main'
:- initialization(main).

% A função main executa o carregamento dos compromissos e start o menu_loop
main :-
    carregar_do_arquivo('compromissos.pl'),
    menu_loop.
