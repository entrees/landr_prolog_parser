Code from the book Exploring Layers and Ripples: Studying English with Computer Parsing (978-1-84890-522-1) by Alastair Butler published by College Publications (https://www.collegepublications.co.uk/other/?00044).

For extra support infromation see: https://entrees.github.io/landp.html

To run the program, you need a working XSB Tabling Prolog system (http://xsb.sourceforge.net/).

Example queries
===============

$ xsb

| ?- [main].

| ?- sentence([], [Tree], [w('PRO', '', 'He'), w('VBP', ';_I_', 'smiles'), w('PUNC', '', '.')], []).

| ?- tphrase_set_string([w('NS', '', 'boys')]), parse(noun).

| ?- tphrase_set_string([w('NS', '', 'boys')]), parse(noun_phrase('-SBJ', nt, established)).

| ?- tphrase_set_string([w('D', '', 'the'), w('N', '', 'ascent'), w('P-ROLE', ';_phrase_', 'of'), w('D', '', 'a'), w('ADJ', '', 'human'), w('N', '', 'figure'), w('P-ROLE', ';_phrase_', 'from'), w('D', '', 'the'), w('N', '', 'direction'), w('P-ROLE', ';_phrase_', 'of'), w('D', '', 'the'), w('ADJ', '', 'distant'), w('N', '', 'town')]), parse(noun_phrase('', nt, non_privileged)).

| ?- tphrase_set_string([w('VB', ';_I_', 'look'), w('PUNC', '', '!')]), parse(sentence).

| ?- tphrase_set_string([w('N', '', 'Business'), w('NS', '', 'people'), w('VBP', Y, 'make'), w('PUNC', '', '.')]), parse(sentence).

| ?- L = [w('ADJ', '', _), _, _, _], tphrase_set_string(L), tphrase(adjective_phrase('', nt, store([], []), non_privileged, [], [T0])), reverse_tree(T0, T), say_tree_list([T], 0, 0), fail.

| ?- L = [w('BEP', _, _), _, _, w('PUNC', '', '?')], tphrase_set_string(L), tphrase(sentence([], [T0])), reverse_tree(T0, T), say_tree_list([T], 0, 0), fail.

Licence
=======

All sources (c) 2026 Alastair Butler

This work is licensed under the Creative Commons Attribution 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
