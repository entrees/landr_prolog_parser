
/*
 * import grammar
 */

:- ['grammar.pl'].

/*
 * say_tree_list routine
 */

say_tree_list([], _, _).
say_tree_list([node(Tag1, Ext1, nt, [node(Tag2, Ext2, index(Num), [])]) | Tail], Indent, Embedding) :-
  !,
  ( Embedding == 0 -> write(' (') ; nl, tab(Indent), write('(') ),
  write(Tag1), write(Ext1),
  write(' '),
  write(Tag2), write(Ext2), write('-'), write(Num),
  write(')'),
  say_tree_list(Tail, Indent, Embedding).
say_tree_list([node(Tag1, Ext1, _, [node(Tag2, Ext2, _, [])]) | Tail], Indent, Embedding) :-
  !,
  ( Embedding == 0 -> write(' (') ; nl, tab(Indent), write('(') ),
  write(Tag1), write(Ext1),
  write(' '),
  write(Tag2), write(Ext2),
  write(')'),
  say_tree_list(Tail, Indent, Embedding).
say_tree_list([node(Tag, Ext, NodeType, NodeList) | Tail], Indent, _) :-
  say_nonpreterminal_node(Tag, Ext, NodeType, NodeList, Indent),
  ( Indent == 0 -> nl ; true ),
  say_tree_list(Tail, Indent, 1).

say_nonpreterminal_node(Tag, Ext, index(Num), NodeList, Indent) :-
  !,
  nl, tab(Indent),
  write('('),
  write(Tag), write(Ext), write('-'), write(Num),
  NextIndent is Indent+2,
  say_tree_list(NodeList, NextIndent, 0),
  write(')').
say_nonpreterminal_node(Tag, Ext, _, NodeList, Indent) :-
  nl, tab(Indent),
  write('('),
  write(Tag), write(Ext),
  NextIndent is Indent+2,
  say_tree_list(NodeList, NextIndent, 0),
  write(')').

/*
 * main parse routine
 */

:- import append/3 from basics.

parse(Goal0) :-
  Goal0 =.. List0,
  append(List0, [[], [X]], List),
  Goal =.. List,
  setof(X, tphrase(Goal), Results),
  say_parse(Results).
parse(Goal0) :-
  Goal0 =.. List0,
  append(List0, [[], [X, Y | Rest]], List),
  Goal =.. List,
  setof(node('', '', nt, [X, Y | Rest]), tphrase(Goal), Results),
  say_parse(Results).

say_parse(Results0) :-
  reverse_tree_list(Results0, [], Results),
  say_tree_list(Results, 0, 0).

reverse_tree(node(Tag, Ext, NodeType, List), node(Tag, Ext, NodeType, Rev)) :-
  reverse_tree_list(List, [], Rev).

reverse_tree_list([], L, L).
reverse_tree_list([H0 | Tail], SoFar, L) :-
  reverse_tree(H0, H),
  reverse_tree_list(Tail, [H | SoFar], L).

