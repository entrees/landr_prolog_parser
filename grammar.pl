:- import member/2 from basics.
:- import append/3 from basics.

:- auto_table.

main_utterance(Tree) -->
  sentence([], [Tree]).
main_utterance(node('FRAG', '', nt, FL)) -->
  fragment_layer([], FL).
main_utterance(node('utterance', '', nt, UL)) -->
  sentence([], UL1),
  utterance_collect(UL1, UL).
main_utterance(node('utterance', '', nt, UL)) -->
  fragment([], UL1),
  utterance_collect(UL1, UL).

% Sentence

sentence(L, [node('IP-MAT', '', nt, [Punc | IL]) | L]) -->
  clause_top_layer('statement_order', store([], []), [], IL),
  final_punc(Punc).
sentence(L, [node('IP-IMP', '', nt, [Punc | IL]) | L]) -->
  clause_top_layer('imperative_clause', store([], []), [], IL),
  final_punc(Punc).
sentence(L, [node('CP-QUE-MAT', '', nt, [Punc, node('IP-SUB', '', nt, IL)]) | L]) -->
  clause_top_layer('matrix_interrogative', store([], []), [], IL),
  final_question_punc(Punc).
sentence(L, [node('IP-MAT', '', nt, [Punc, node('CP-QUE-TAG', '', nt, [node('IP-SUB', '', nt, TL)]) | IL]) | L]) -->
  clause_top_layer('statement_order', store([], []), [], IL1),
  punc('non_final', IL1, IL),
  clause_top_layer('tag_question', store([], []), [], TL),
  final_question_punc(Punc).
sentence(L, [node('IP-MAT', '', nt, [Punc, node('ILYR', '', nt, [node('CONJP', '', nt, [node('ILYR', '', nt, IL2), CONJ]), node('ILYR', '', nt, IL1)])]) | L]) -->
  clause_top_layer('statement_order', store([], []), [], IL1),
  conj(CONJ),
  [w('ADV', '', 'so')],
  clause_top_layer('tag_question', store([], []), [node('ADVP', '-CLR', nt, [node('ADV', '', pt, [node('so', '', t, [])])])], IL2),
  final_punc(Punc).

sentence(L, [node('IP-MAT', '', nt, [Punc | IL]) | L]) -->
  {
    ( Ich = np(node('*ICH*', '', index(101), []))
    ; Ich = pp(node('*ICH*', '', index(101), []))
    ; Ich = pp_lgs(node('*ICH*', '', index(101), []))
    ; Ich = adjp(node('*ICH*', '', index(101), []))
    ; Ich = cp_that(node('*ICH*', '', index(101), []))
    ; Ich = utterance(node('*ICH*', '', index(101), []))
    )
  },
  clause_top_layer('statement_order', store([], [Ich]), [], IL1),
  punc('non_final', [node('ILYR', '', nt, IL1)], IL2),
  displaced_item('-RNR', index(101), Ich, IL2, IL),
  final_punc(Punc).

displaced_item(Ext, Index, np(node('*ICH*', '', Index, [])), L0, L) -->
  noun_phrase(Ext, Index, 'established', L0, L).
displaced_item(Ext, Index, pp(node('*ICH*', '', Index, [])), L0, L) -->
  preposition_phrase(Ext, Index, 'established', L0, L).
displaced_item(Ext, Index, pp_lgs(node('*ICH*', '', Index, [])), L, [node('PP', Ext, Index, [NP, Role]) | L]) -->
  lgs_role(Role),
  noun_phrase('', nt, 'established', [], [NP]).
displaced_item(Ext, Index, adjp(node('*ICH*', '', Index, [])), L0, L) -->
  adjective_phrase(Ext, Index, store([], []), 'established', L0, L).
displaced_item(Ext, Index, cp_that(node('*ICH*', '', Index, [])), L0, L) -->
  {
    ( Feat = 'with_c' ; Feat = 'without_c' )
  },
  cp_that(Ext, Index, Feat, store([], []), L0, L).
displaced_item(Ext, Index, utterance(node('*ICH*', '', Index, [])), L0, L) -->
  punc('left_quotation_mark', L0, L1),
  utterance(Ext, Index, L1, L2),
  punc('right_quotation_mark', L2, L).

% Fragment

fragment(L, [node('FRAG', '', nt, [Punc | FL]) | L]) -->
  fragment_layer([], FL),
  final_punc(Punc).

fragment_layer(L0, L) -->
  {
    ( Feat = 'non_privileged'
    ; Feat = 'established'
    ; Feat = 'interrogative'
    ; Feat = 'relative'
    )
  },
  noun_phrase('', nt, Feat, L0, L).
fragment_layer(L0, L) -->
  {
    ( Feat = 'established'
    ; Feat = 'interrogative'
    ; Feat = 'relative'
    ; Feat = 'filled_sbj'
    )
  },
  adjective_phrase('', nt, store([], []), Feat, L0, L).
fragment_layer(L0, L) -->
  adverbial(L0, L).
fragment_layer(L0, L) -->
  ip_to_inf('', nt, store([], []), L0, L).
fragment_layer(L, [node('IP-PPL', '3', nt, IL) | L]) -->
  {
    ( Infl = 'hag_participle'
    ; Infl = 'en_participle'
    ; Infl = 'ing_participle'
    ),
    ( SbjFeat = 'filled_sbj' ; SbjFeat = 'unfilled_sbj' )
  },
  ip_ppl_adverbial_layer(SbjFeat, Infl, [], IL).

% utterance

utterance(Ext, Node_type, L, [node('utterance', Ext, Node_type, UL) | L]) -->
  utterance_collect([], UL).

utterance_collect(L0, L) -->
  sentence(L0, L).
utterance_collect(L0, L) -->
  fragment(L0, L).
utterance_collect(L0, L) -->
  sentence(L0, L1),
  utterance_collect(L1, L).
utterance_collect(L0, L) -->
  fragment(L0, L1),
  utterance_collect(L1, L).

% Nouns

noun(L, [node('NS', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('NS', '', Word)].
noun(L, [node('N', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('N', '', Word)].
noun(L, [node('NPRS', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('NPRS', '', Word)].
noun(L, [node('NPR', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('NPR', '', Word)].

noun_head(L, [node('Q', ';_nphd_', pt, [node(Word, '', t, [])]) | L]) -->
  [w('Q', ';_nphd_', Word)].
noun_head(L, [node('D', ';_nphd_', pt, [node(Word, '', t, [])]) | L]) -->
  [w('D', ';_nphd_', Word)].

noun_head_full(Feat, L, [node('PNX', '', pt, [node(Word, '', t, [])]) | L]) -->
  {
    Feat = 'non_privileged'
  },
  [w('PNX', '', Word)].
noun_head_full(Feat, L, [node('PRO', '', pt, [node(Word, '', t, [])]) | L]) -->
  {
    ( Feat = 'non_privileged' ; Feat = 'established' )
  },
  [w('PRO', '', Word)].
noun_head_full(Feat, L, [node('PRO', ';_expletive_', pt, [node(Word, '', t, [])]) | L]) -->
  {
    ( Feat = 'non_privileged' ; Feat = 'established' )
  },
  [w('PRO', ';_expletive_', Word)].
noun_head_full(Feat, L, [node('NP', '-GEN', nt, [node('PRO', ';_ppge_', pt, [node(Word, '', t, [])])]) | L]) -->
  {
    ( Feat = 'non_privileged' ; Feat = 'established' )
  },
  [w('PRO', ';_ppge_', Word)].
noun_head_full(Feat, L, [node('WPRO', '', pt, [node(Word, '', t, [])]) | L]) -->
  {
    ( Feat = 'non_privileged' ; Feat = 'interrogative' )
  },
  [w('WPRO', '', Word)].
noun_head_full(Feat, L, [node('RPRO', '', pt, [node(Word, '', t, [])]) | L]) -->
  {
    Feat = 'relative'
  },
  [w('RPRO', '', Word)].

% Determiners

det(Feat, L, [node('Q', '', pt, [node(Word, '', t, [])]) | L]) -->
  {
    ( Feat = 'non_privileged' ; Feat = 'established' )
  },
  [w('Q', '', Word)].
det(Feat, L, [node('D', '', pt, [node(Word, '', t, [])]) | L]) -->
  {
    ( Feat = 'non_privileged' ; Feat = 'established' )
  },
  [w('D', '', Word)].
det(Feat, L, [node('WD', '', pt, [node(Word, '', t, [])]) | L]) -->
  {
    ( Feat = 'non_privileged' ; Feat = 'interrogative' )
  },
  [w('WD', '', Word)].
det('relative', L, [node('RD', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('RD', '', Word)].

% Genitive words

genm(L, [node('GENM', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('GENM', '', Word)].

pronoun_genm(Feat, L, [node('PRO', ';_genm_', pt, [node(Word, '', t, [])]) | L]) -->
  {
    ( Feat = 'non_privileged' ; Feat = 'established' )
  },
  [w('PRO', ';_genm_', Word)].
pronoun_genm(Feat, L, [node('WPRO', ';_genm_', pt, [node(Word, '', t, [])]) | L]) -->
  {
    ( Feat = 'non_privileged' ; Feat = 'interrogative' )
  },
  [w('WPRO', ';_genm_', Word)].
pronoun_genm('relative', L, [node('RPRO', ';_genm_', pt, [node(Word, '', t, [])]) | L]) -->
  [w('RPRO', ';_genm_', Word)].

% Clause subject

subject('there_sbj', L, [node('EX', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('EX', '', Word)].
subject('provisional_sbj', L, [node('NP', '-SBJ', nt, [node('PRO', ';_provisional_', pt, [node(Word, '', t, [])])]) | L]) -->
  [w('PRO', ';_provisional_', Word)].
subject('filled_sbj', L0, L) -->
  noun_phrase('-SBJ', nt, 'established', L0, L).
subject('filled_sbj', L0, L) -->
  ip_ppl_active('-SBJ', nt, store([], []), 'filled_sbj', 'ing_participle', L0, L).
subject('derived_sbj', L0, L) -->
  noun_phrase('-SBJ', nt, 'established', L0, L).

% Adverbs

adv('established', L, [node('ADV', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('ADV', '', Word)].
adv('established', L, [node('ADVR', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('ADVR', '', Word)].
adv('established', L, [node('ADVS', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('ADVS', '', Word)].
adv('interrogative', L, [node('WADV', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('WADV', '', Word)].
adv('relative', L, [node('RADV', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('RADV', '', Word)].
adv('particle', L, [node('RP', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('RP', '', Word)].

% Adjectives

adj('established', L, [node('ADJ', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('ADJ', '', Word)].
adj('established', L, [node('ADJR', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('ADJR', '', Word)].
adj('established', L, [node('ADJS', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('ADJS', '', Word)].
adj('catenative', L, [node('ADJ', ';_cat_', pt, [node(Word, '', t, [])]) | L]) -->
  [w('ADJ', ';_cat_', Word)].

% Verb word

verb(Infl, Code, L, [node(Tag, Code, pt, [node(Word, '', t, [])]) | L]) -->
  [w(Tag, Code, Word)],
  {
    verb_tag(Infl, TagList),
    member(Tag, TagList),
    sub_atom(Tag, 0, 1, _, Char),
    verb_code(Char, Infl, Code)
  }.

% Verb tags

verb_tag('finite', ['VBP', 'VBD', 'DOP', 'DOD', 'HVP', 'HVD', 'BEP', 'BED']).
verb_tag('imperative', ['VB', 'DO', 'HV', 'BE']).
verb_tag('infinitive', ['VB', 'DO', 'HV', 'BE']).
verb_tag('do_supported_infinitive', ['VB', 'DO', 'HV']).
verb_tag('ing_participle', ['VAG', 'DAG', 'HAG', 'BAG']).
verb_tag('en_participle', ['VVN', 'DON', 'HVN', 'BEN']).

% Verb codes

verb_code('V', _, Code) :-
  member(Code, [
     ';_La_', ';_Ln_',
     ';_I_', ';_Ip_', ';_Ipr_', ';_In/pr_', ';_It_',
     ';_Tn_', ';_Tn.p_', ';_Tn.pr_',
     ';_Tf_', ';_Tw_', ';_Tr_', ';_Tt_', ';_Tnt_',
     ';_Tprt_', ';_Tni_', ';_Tg_', ';_Tng_', ';_Tsg_',
     ';_Dn.n_', ';_Dn.f_', ';_Dn.w_', ';_Dn.r_', ';_Dn.t_',
     ';_Dn.*_', ';_Dn.pr_', ';_Dpr.f_', ';_Dpr.r_',
     ';_Cn.a_', ';_Cn.n_', ';_Cn.n/a_', ';_Cn.pr_',
     ';_Cn.t_', ';_Cn.i_', ';_Cn.g_',
     ';_V_as_though/as_if/like_',
     ';_VP24A_', ';_VP24C_' ]).
verb_code('V', Infl, Code) :-
  member(Infl, ['finite', 'infinitive', 'do_supported_infinitive']),
  member(Code, [
     ';_cat_Vt_', ';_cat_Vi_', ';_cat_Vg_', ';_cat_VgPASS_',
     ';_cat_VePASS_', ';_ex_V_', ';_ex_Vpr_', ';_ex_cat_Vt_' ]).
verb_code('V', Infl, Code) :-
  member(Infl, ['imperative', 'ing_participle', 'en_participle']),
  member(Code, [';_cat_Vt_', ';_cat_Vi_', ';_cat_Vg_', ';_cat_VgPASS_', ';_cat_VePASS_']).
verb_code('D', _, Code) :-
  member(Code, [';_Tn_', ';_Cn.a_']).
verb_code('H', _, Code) :-
  member(Code, [';_Tn_', ';_VP24B_', ';_VP24C_']).
verb_code('H', Infl, Code) :-
  member(Infl, ['finite', 'infinitive']),
  member(Code, [';_cat_Vi_', ';_cat_Vt_', ';_cat_Ve_']).
verb_code('H', Infl, Code) :-
  member(Infl, ['imperative', 'ing_participle', 'en_participle']),
  member(Code, [';_cat_Vi_', ';_cat_Vt_']).
verb_code('B', _, Code) :-
  member(Code, [
     ';_La_', ';_Ln_',
     ';_I_', ';_Ip_', ';_Ipr_',
     ';_cat_Vt_', ';_cat_VtPASS_', ';_cat_VePASS_',
     ';_equ_Vf_', ';_equ_Vw_', ';_equ_Vt_', ';_equ_Vg_' ]).
verb_code('B', Infl, Code) :-
  member(Infl, ['finite', 'infinitive', 'ing_participle', 'en_participle']),
  member(Code, [';_ex_V_', ';_ex_Vp_', ';_ex_Vpr_', ';_ex_La_', ';_ex_Ln_']).
verb_code('B', Infl, Code) :-
  member(Infl, ['finite', 'infinitive', 'en_participle']),
  member(Code, [
     ';_cat_Vg_', ';_ex_cat_Vt_', ';_ex_cat_VtPASS_',
     ';_ex_cat_Vg_', ';_ex_cat_VePASS_', ';_cleft_Vn_' ]).

% Modal verbs

modal(';_cat_Vi_', L, [node('MD', ';_cat_Vi_', pt, [node(Word, '', t, [])]) | L]) -->
  [w('MD', ';_cat_Vi_', Word)].
modal(';_cat_Vt_', L, [node('MD', ';_cat_Vt_', pt, [node(Word, '', t, [])]) | L]) -->
  [w('MD', ';_cat_Vt_', Word)].

% Other clause level words

optional_clitic_negation(L, [node('NEG', ';_clitic_', pt, [node(Word, '', t, [])]) | L]) -->
  [w('NEG', ';_clitic_', Word)].
optional_clitic_negation(L, [node('NEG', ';_clitic_;_high_', pt, [node(Word, '', t, [])]) | L]) -->
  [w('NEG', ';_clitic_;_high_', Word)].
optional_clitic_negation(L, L) -->
  [].

neg(L, [node('NEG', ';_high_', pt, [node(Word, '', t, [])]) | L]) -->
  [w('NEG', ';_high_', Word)].
neg(L, [node('NEG', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('NEG', '', Word)].

to(L, [node('TO', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('TO', '', Word)].

clause_misc_item(L, [node('INTJ', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('INTJ', '', Word)].
clause_misc_item(L, [node('REACT', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('REACT', '', Word)].
clause_misc_item(L, [node('FRM', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('FRM', '', Word)].

initial_adverbial(L, [node('CONJ', ';_cl_', pt, [node(Word, '', t, [])]) | L]) -->
  [w('CONJ', ';_cl_', Word)].
initial_adverbial(L0, L) -->
  clause_misc_item(L0, L).
initial_adverbial(L0, L) -->
  adverb_phrase('-NIM', nt, 'established', L0, L).
initial_adverbial(L0, L) -->
  preposition_phrase('-NIM-TPC', nt, 'established', L0, L).
initial_adverbial(L0, L) -->
  scon_clause(L0, L).

% Connective words

phrase_conj(node('CONJ', ';_phrase_', pt, [node(Word, '', t, [])])) -->
  [w('CONJ', ';_phrase_', Word)].

conj(node('CONJ', '', pt, [node(Word, '', t, [])])) -->
  [w('CONJ', '', Word)].

comp(node('C', '', pt, [node(Word, '', t, [])])) -->
  [w('C', '', Word)].

comp_wq(node('WQ', '', pt, [node(Word, '', t, [])])) -->
  [w('WQ', '', Word)].

conn(node('P-CONN', '', pt, [node(Word, '', t, [])])) -->
  [w('P-CONN', '', Word)].

phrase_role(node('P-ROLE', ';_phrase_', pt, [node(Word, '', t, [])])) -->
  [w('P-ROLE', ';_phrase_', Word)].

lgs_role(node('P-ROLE', ';_lgs_', pt, [node(Word, '', t, [])])) -->
  [w('P-ROLE', ';_lgs_', Word)].

role(node('P-ROLE', '', pt, [node(Word, '', t, [])])) -->
  [w('P-ROLE', '', Word)].

% Punctuation

punc('non_final', L, [node('PUNC', '', pt, [node(',', '', t, [])]) | L]) -->
  [w('PUNC', '', ',')].
punc('non_final', L, [node('PUNC', ';_non_final_', pt, [node(Word, '', t, [])]) | L]) -->
  [w('PUNC', ';_non_final_', Word)].
punc('left_quotation_mark', L, [node('PULQ', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('PULQ', '', Word)].
punc('right_quotation_mark', L, [node('PURQ', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('PURQ', '', Word)].

optional_punc_non_final(L0, L) -->
  punc('non_final', L0, L).
optional_punc_non_final(L, L) -->
  [].

final_punc(node('PUNC', '', pt, [node('.', '', t, [])])) -->
  [w('PUNC', '', '.')].
final_punc(node('PUNC', '', pt, [node('!', '', t, [])])) -->
  [w('PUNC', '', '!')].
final_punc(node('PUNC', ';_final_', pt, [node(Word, '', t, [])])) -->
  [w('PUNC', ';_final_', Word)].

final_question_punc(node('PUNC', '', pt, [node('?', '', t, [])])) -->
  [w('PUNC', '', '?')].
final_question_punc(node('PUNC', ';_final_question_', pt, [node(Word, '', t, [])])) -->
  [w('PUNC', ';_final_question_', Word)].

% Noun phrase

noun_phrase(Ext, Node_type, Feat, L, [node('NP', Ext, Node_type, NL) | L]) -->
  noun_phrase_top(Feat, [], NL).

noun_phrase_top(Feat, L0, L) -->
  noun_head_full(Feat, L0, L).
noun_phrase_top(Feat, L0, L) -->
  noun_phrase_initial_layer(Feat, L0, L).

noun_phrase_initial_layer(Feat, L0, L) -->
  determiner_layer(Feat, L0, L1),
  internal_np_higher_layer(L1, L).
noun_phrase_initial_layer(Feat, L0, L) -->
  {
    ( Feat = 'non_privileged' ; Feat = 'interrogative' )
  },
  adjective_phrase('', nt, store([], []), 'interrogative', L0, L1),
  internal_np_higher_layer(L1, L).
noun_phrase_initial_layer(Feat, L0, L) -->
  {
    ( Feat = 'non_privileged' ; Feat = 'established' )
  },
  noun_head(L0, L).
noun_phrase_initial_layer(Feat, L0, L) -->
  {
    ( Feat = 'non_privileged' ; Feat = 'established' )
  },
  internal_np_higher_layer(L0, L).
noun_phrase_initial_layer(Feat, L, [node('NLYR', '', nt, [node('CONJP', '', nt, [node('NLYR', '', nt, NL2), CONJ2]), node('NLYR', '', nt, NL1), CONJ1]) | L]) -->
  phrase_conj(CONJ1),
  noun_phrase_top(Feat, [], NL1),
  phrase_conj(CONJ2),
  noun_phrase_top(Feat, [], NL2).
noun_phrase_initial_layer(Feat, L, [node('NLYR', '', nt, CL) | L]) -->
  noun_phrase_top(Feat, [], NL),
  noun_phrase_initial_tail(Feat, [node('NLYR', '', nt, NL)], CL).
noun_phrase_initial_layer(Feat, L0, L) -->
  noun_phrase_initial_layer(Feat, L0, L1),
  preposition_phrase('', nt, 'phrase', L1, L).
noun_phrase_initial_layer(Feat, L0, L) -->
  {
    Feat = 'relative'
  },
  noun_phrase_initial_layer('established', L0, L1),
  preposition_phrase('', nt, 'relative', L1, L).
noun_phrase_initial_layer(Feat, L0, L) -->
  noun_phrase_initial_layer(Feat, L0, L1),
  relative_clause(L1, L).

noun_phrase_initial_tail(Feat, L, [node('CONJP', '', nt, [node('NLYR', '', nt, NL), CONJ]) | L]) -->
  phrase_conj(CONJ),
  noun_phrase_top(Feat, [], NL).
noun_phrase_initial_tail(Feat, L0, L) -->
  punc('non_final', L0, L1),
  noun_phrase_top(Feat, [], NL),
  noun_phrase_initial_tail(Feat, [node('CONJP', '', nt, [node('NLYR', '', nt, NL)]) | L1], L).

internal_np_higher_layer(L0, L) -->
  internal_np_lower_layer(L0, L).

internal_np_higher_layer(L0, L) -->
  adjective_phrase('', nt, store([], []), 'established', L0, L1),
  internal_np_higher_layer(L1, L).
internal_np_higher_layer(L0, L) -->
  internal_np_higher_layer(L0, L1),
  preposition_phrase('', nt, 'phrase', L1, L).
internal_np_higher_layer(L0, L) -->
  internal_np_higher_layer(L0, L1),
  relative_clause(L1, L).
internal_np_higher_layer(L, [node('NLYR', '', nt, CL) | L]) -->
  internal_np_higher_layer([], NL),
  internal_np_higher_tail([node('NLYR', '', nt, NL)], CL).

internal_np_higher_tail(L, [node('CONJP', '', nt, [node('NLYR', '', nt, NL), CONJ]) | L]) -->
  phrase_conj(CONJ),
  internal_np_higher_layer([], NL).
internal_np_higher_tail(L0, L) -->
  punc('non_final', L0, L1),
  internal_np_higher_layer([], NL),
  internal_np_higher_tail([node('CONJP', '', nt, [node('NLYR', '', nt, NL)]) | L1], L).

internal_np_lower_layer(L0, L) -->
  noun(L0, L).
internal_np_lower_layer(L0, L) -->
  noun(L0, L1),
  ip_to_inf('', nt, store([], []), L1, L).
internal_np_lower_layer(L0, L) -->
  noun(L0, L1),
  cp_that('', nt, 'with_c', store([], []), L1, L).
internal_np_lower_layer(L0, L) -->
  noun(L0, L1),
  cp_embedded_que('', nt, store([], []), L1, L).

internal_np_lower_layer(L0, L) -->
  noun(L0, L1),
  internal_np_lower_layer(L1, L).
internal_np_lower_layer(L, [node('NLYR', '', nt, CL) | L]) -->
  internal_np_lower_layer([], NL),
  internal_np_lower_tail([node('NLYR', '', nt, NL)], CL).

internal_np_lower_tail(L, [node('CONJP', '', nt, [node('NLYR', '', nt, NL), CONJ]) | L]) -->
  phrase_conj(CONJ),
  internal_np_lower_layer([], NL).
internal_np_lower_tail(L0, L) -->
  punc('non_final', L0, L1),
  internal_np_lower_layer([], NL),
  internal_np_lower_tail([node('CONJP', '', nt, [node('NLYR', '', nt, NL)]) | L1], L).

% Determiner layer

determiner_layer(Feat, L0, L) -->
  det(Feat, L0, L).
determiner_layer(Feat, L, [node('NP', '-GEN', nt, NL) | L]) -->
  noun_phrase_genm_layer(Feat, [], NL).

% Genitive noun phrases

noun_phrase_genm_layer(Feat, L0, L) -->
  pronoun_genm(Feat, L0, L).
noun_phrase_genm_layer(Feat, L0, L) -->
  noun_phrase_initial_layer(Feat, L0, L1),
  genm(L1, L).
noun_phrase_genm_layer(Feat, L, [node('NLYR', '', nt, CL) | L]) -->
  noun_phrase_genm_layer(Feat, [], NL),
  noun_phrase_genm_tail(Feat, [node('NLYR', '', nt, NL)], CL).

noun_phrase_genm_tail(Feat, L, [node('CONJP', '', nt, [node('NLYR', '', nt, NL), CONJ]) | L]) -->
  phrase_conj(CONJ),
  noun_phrase_genm_layer(Feat, [], NL).
noun_phrase_genm_tail(Feat, L0, L) -->
  punc('non_final', L0, L1),
  noun_phrase_genm_layer(Feat, [], NL),
  noun_phrase_genm_tail(Feat, [node('CONJP', '', nt, [node('NLYR', '', nt, NL)]) | L1], L).

% Adverb phrase

adverb_phrase(Ext, Node_type, Feat, L, [node('ADVP', Ext, Node_type, AL) | L]) -->
  {
    ( Feat = 'established'
    ; Feat = 'interrogative'
    ; Feat = 'relative'
    ; Feat = 'particle'
    )
  },
  adverb_phrase_layer(Feat, [], AL).
adverb_phrase(Ext, Node_type, Feat0, L, [node('ADVP', Ext, Node_type, AL) | L]) -->
  {
    Feat0 = 'non_privileged',
    ( Feat = 'established' ; Feat = 'interrogative' )
  },
  adverb_phrase_layer(Feat, [], AL).

adverb_phrase_layer(Feat, L0, L) -->
  adv(Feat, L0, L).
adverb_phrase_layer('established', L0, L) -->
  noun_phrase('', nt, 'established', L0, L1),
  adverb_phrase_layer('established', L1, L).
adverb_phrase_layer('established', L0, L) -->
  neg(L0, L1),
  adverb_phrase_layer('established', L1, L).
adverb_phrase_layer(Feat, L0, L) -->
  adverb_phrase('', nt, Feat, L0, L1),
  adverb_phrase_layer('established', L1, L).
adverb_phrase_layer('established', L0, L) -->
  adverb_phrase_layer('established', L0, L1),
  preposition_phrase('', nt, 'phrase', L1, L).
adverb_phrase_layer(Feat, L, [node('AVLYR', '', nt, CL) | L]) -->
  adverb_phrase_layer(Feat, [], AL),
  adverb_phrase_tail(Feat, [node('AVLYR', '', nt, AL)], CL).

adverb_phrase_tail(Feat, L, [node('CONJP', '', nt, [node('AVLYR', '', nt, AL), CONJ]) | L]) -->
  phrase_conj(CONJ),
  adverb_phrase_layer(Feat, [], AL).
adverb_phrase_tail(Feat, L0, L) -->
  punc('non_final', L0, L1),
  adverb_phrase_layer(Feat, [], AL),
  adverb_phrase_tail(Feat, [node('CONJP', '', nt, [node('AVLYR', '', nt, AL)]) | L1], L).

% Adjective phrase

adjective_phrase(Ext, Node_type, Store, Feat, L, [node('ADJP', Ext, Node_type, AL) | L]) -->
  {
    ( Feat = 'established'
    ; Feat = 'interrogative'
    ; Feat = 'relative'
    ; Feat = 'filled_sbj'
    ; Feat = 'there_sbj'
    ; Feat = 'provisional_sbj'
    ; Feat = 'derived_sbj'
    )
  },
  adjective_phrase_layer(Store, Feat, [], AL).
adjective_phrase(Ext, Node_type, store([], []), Feat0, L, [node('ADJP', Ext, Node_type, AL) | L]) -->
  {
    Feat0 = 'non_privileged',
    ( Feat = 'established' ; Feat = 'interrogative' )
  },
  adjective_phrase_layer(store([], []), Feat, [], AL).

adjective_phrase_layer(store([], []), Feat, L0, L) -->
  {
    ( Feat = 'interrogative' ; Feat = 'relative' )
  },
  adverb_phrase('', nt, Feat, L0, L1),
  adjective_phrase_layer(store([], []), 'established', L1, L).
adjective_phrase_layer(Store, SbjFeat, L0, [node('IP-INF', '', nt, VL) | L]) -->
  adj('catenative', L0, L),
  to_inf_layer(Store, SbjFeat, 'active', [], VL).
adjective_phrase_layer(Store, SbjFeat, L0, [node('PP', '', nt, PL) | L]) -->
  adj('catenative', L0, L),
  phrase_role(Role),
  ip_ppl_active('', nt, Store, SbjFeat, 'ing_participle', [Role], PL).
adjective_phrase_layer(store([], []), 'established', L0, L) -->
  adj('established', L0, L).
adjective_phrase_layer(store([], []), 'established', L0, L) -->
  adj('established', L0, L1),
  cp_that('', nt, 'with_c', store([], []), L1, L).
adjective_phrase_layer(store([], []), 'established', L0, L) -->
  noun_phrase('', nt, 'established', L0, L1),
  adjective_phrase_layer(store([], []), 'established', L1, L).
adjective_phrase_layer(store([], []), 'established', L0, L) -->
  neg(L0, L1),
  adjective_phrase_layer(store([], []), 'established', L1, L).
adjective_phrase_layer(store([], []), 'established', L0, L) -->
  adverb_phrase('', nt, 'established', L0, L1),
  adjective_phrase_layer(store([], []), 'established', L1, L).
adjective_phrase_layer(store([], []), 'established', L0, L) -->
  adjective_phrase_layer(store([], []), 'established', L0, L1),
  preposition_phrase('', nt, 'phrase', L1, L).
adjective_phrase_layer(store([], []), 'established', L0, [node('IP-INF', '', nt, VL) | L]) -->
  adjective_phrase_layer(store([], []), 'established', L0, L),
  {
    ( SbjFeat = 'filled_sbj' ; SbjFeat = 'unfilled_sbj' )
  },
  to_inf_layer(store([], []), SbjFeat, 'active', [], VL).
adjective_phrase_layer(Store, Feat, L, [node('AJLYR', '', nt, CL) | L]) -->
  adjective_phrase_layer(Store, Feat, [], AL),
  adjective_phrase_tail(Store, Feat, [node('AJLYR', '', nt, AL)], CL).

adjective_phrase_tail(Store, Feat, L, [node('CONJP', '', nt, [node('AJLYR', '', nt, AL), CONJ]) | L]) -->
  phrase_conj(CONJ),
  adjective_phrase_layer(Store, Feat, [], AL).
adjective_phrase_tail(Store, Feat, L0, L) -->
  punc('non_final', L0, L1),
  adjective_phrase_layer(Store, Feat, [], AL),
  adjective_phrase_tail(Store, Feat, [node('CONJP', '', nt, [node('AJLYR', '', nt, AL)]) | L1], L).

% Preposition phrases

preposition_phrase(Ext, Node_type, Feat, L, [node('PP', Ext, Node_type, PL) | L]) -->
  preposition_phrase_layer(Feat, [], PL).

preposition_phrase_layer(Feat, L0, L) -->
  {
    Feat = 'phrase'
  },
  phrase_role(Role),
  noun_phrase('', nt, 'established', [Role | L0], L).
preposition_phrase_layer(Feat, L0, L) -->
  {
    Feat = 'relative'
  },
  phrase_role(Role),
  noun_phrase('', nt, Feat, [Role | L0], L).
preposition_phrase_layer(Feat, L0, L) -->
  {
    ( Feat = 'non_privileged'
    ; Feat = 'established'
    ; Feat = 'interrogative'
    ; Feat = 'relative'
    )
  },
  role(Role),
  noun_phrase('', nt, Feat, [Role | L0], L).

preposition_phrase_layer(Feat, L0, L) -->
  {
    Feat = 'phrase'
  },
  phrase_role(Role),
  adverb_phrase('', nt, 'established', [Role | L0], L).
preposition_phrase_layer(Feat, L0, L) -->
  {
    ( Feat = 'non_privileged' ; Feat = 'established' )
  },
  role(Role),
  adverb_phrase('', nt, Feat, [Role | L0], L).

preposition_phrase_layer(Feat, L, [node('IP-PPL', '', nt, IL), Role | L]) -->
  {
    Feat = 'phrase',
    ( SbjFeat = 'filled_sbj' ; SbjFeat = 'unfilled_sbj' )
  },
  phrase_role(Role),
  ip_ppl_adverbial_layer(SbjFeat, 'ing_participle', [], IL).
preposition_phrase_layer(Feat, L, [node('IP-PPL', '', nt, IL), Role | L]) -->
  {
    ( Feat = 'non_privileged' ; Feat = 'established' ),
    ( SbjFeat = 'filled_sbj' ; SbjFeat = 'unfilled_sbj' )
  },
  role(Role),
  ip_ppl_adverbial_layer(SbjFeat, 'ing_participle', [], IL).

preposition_phrase_layer(Feat, L0, L) -->
  {
    Feat = 'phrase'
  },
  phrase_role(Role),
  cp_embedded_que('', nt, store([], []), [Role | L0], L).
preposition_phrase_layer(Feat, L0, L) -->
  {
    ( Feat = 'non_privileged' ; Feat = 'established' )
  },
  role(Role),
  cp_embedded_que('', nt, store([], []), [Role | L0], L).

preposition_phrase_layer(Feat, L, [node('IP-ADV', '', nt, IL), Role | L]) -->
  {
    Feat = 'phrase'
  },
  phrase_role(Role),
  clause_top_layer('statement_order', store([], []), [], IL).
preposition_phrase_layer(Feat, L, [node('IP-ADV', '', nt, IL), Role | L]) -->
  {
    ( Feat = 'non_privileged' ; Feat = 'established' )
  },
  role(Role),
  clause_top_layer('statement_order', store([], []), [], IL).

% Verb complements top layer

verb_complements_top_layer(Code, Store, SbjFeat, Voice, L0, L) -->
  verb_complements_by_code(Code, Store, SbjFeat, Voice, L0, L).
verb_complements_top_layer(Code, Store, SbjFeat0, Voice, L0, L) -->
  {
    SbjFeat0 = 'provisional_sbj',
    ( SbjFeat = 'filled_sbj' ; SbjFeat = 'derived_sbj' )
  },
  verb_complements_top_layer(Code, store([], []), SbjFeat, Voice, L0, L1),
  notional_item('-NSBJ', Store, L1, L).
verb_complements_top_layer(Code, Store, SbjFeat0, Voice, L0, L) -->
  {
    SbjFeat0 = 'provisional_sbj',
    ( SbjFeat = 'filled_sbj' ; SbjFeat = 'derived_sbj' )
  },
  verb_complements_top_layer(Code, Store, SbjFeat, Voice, L0, L1),
  notional_item('-NSBJ', store([], []), L1, L).

verb_complements_top_layer(Code, Store, SbjFeat, Voice, L0, [node('IP-INF', '-NSBJ', nt, VL) | L]) -->
  {
    Code = ';_cat_VePASS_',
    SbjFeat = 'derived_sbj'
  },
  verb_complements_top_layer(Code, store([], []), 'filled_sbj', Voice, L0, L),
  to_inf_layer(Store, 'filled_sbj', 'active', [], VL).

verb_complements_top_layer(Code, Store, SbjFeat0, Voice, L0, [node('IP-INF', '-NSBJ', nt, VL) | L]) -->
  {
    ( Code = ';_La_' ; Code = ';_Tn_' ),
    SbjFeat0 = 'derived_sbj',
    Voice = 'active',
    ( SbjFeat = 'filled_sbj' ; SbjFeat = 'unfilled_sbj' )
  },
  verb_complements_top_layer(Code, store([], []), 'filled_sbj', Voice, L0, L),
  to_inf_layer(Store, SbjFeat, 'passive', [], VL).

verb_complements_top_layer(Code, Store, SbjFeat, Voice, L0, L) -->
  neg(L0, L1),
  verb_complements_top_layer(Code, Store, SbjFeat, Voice, L1, L).
verb_complements_top_layer(Code, Store, SbjFeat, Voice, L0, L) -->
  adverb_phrase('-NIM', nt, 'established', L0, L1),
  verb_complements_top_layer(Code, Store, SbjFeat, Voice, L1, L).
verb_complements_top_layer(Code, Store, SbjFeat, Voice, L0, L) -->
  verb_complements_top_layer(Code, Store, SbjFeat, Voice, L0, L1),
  adverbial(L1, L).

% Adverbials

adverbial(L0, L) -->
  clause_misc_item(L0, L).
adverbial(L0, L) -->
  adverb_phrase('-NIM', nt, 'non_privileged', L0, L).
adverbial(L0, L) -->
  preposition_phrase('-NIM', nt, 'non_privileged', L0, L).
adverbial(L0, L) -->
  scon_clause(L0, L).

% Linking verb complements

verb_complements_by_code(';_La_', store([], []), 'filled_sbj', 'active', L0, L) -->
  adjective_phrase('-PRD', nt, store([], []), 'non_privileged', L0, L).
verb_complements_by_code(';_La_', Store, SbjFeat, 'active', L0, L) -->
  adjective_phrase('-PRD', nt, Store, SbjFeat, L0, L).
verb_complements_by_code(';_La_', store(Left, Right), 'filled_sbj', 'active', L, [node('ADJP', '-PRD', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [adjp(ICH)])
  },
  [].

verb_complements_by_code(';_Ln_', store([], []), 'filled_sbj', 'active', L0, L) -->
  noun_phrase('-PRD', nt, 'non_privileged', L0, L).
verb_complements_by_code(';_Ln_', store(Left, Right), 'filled_sbj', 'active', L, [node('NP', '-PRD', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [np(ICH)])
  },
  [].

% Intransitive verb complements

verb_complements_by_code(';_I_', store([], []), 'filled_sbj', 'active', L, L) -->
  [].

verb_complements_by_code(';_Ip_', store([], []), 'filled_sbj', 'active', L0, L) -->
  adverb_phrase('-CLR', nt, 'particle', L0, L).
verb_complements_by_code(';_Ip_', store([advp(ICH)], []), 'filled_sbj', 'active', L, [node('ADVP', '-CLR', nt, [ICH]) | L]) -->
  [].

verb_complements_by_code(';_Ipr_', store([], []), 'filled_sbj', 'active', L0, L) -->
  preposition_phrase('-CLR', nt, 'non_privileged', L0, L).
verb_complements_by_code(';_Ipr_', store(Left, Right), 'filled_sbj', 'active', L, [node('PP', '-CLR', nt, [node('NP', '', nt, [ICH]), Role]) | L]) -->
  {
    append(Left, Right, [np(ICH)])
  },
  role(Role).
verb_complements_by_code(';_Ipr_', store(Left, Right), 'filled_sbj', 'active', L, [node('PP', '-CLR', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [pp(ICH)])
  },
  [].
verb_complements_by_code(';_Ipr_', store([], []), 'filled_sbj', 'lgs_passive', L, [node('PP', '-CLR', nt, [Role]) | L]) -->
  role(Role).

verb_complements_by_code(';_In/pr_', store([], []), 'filled_sbj', 'active', L0, L) -->
  noun_phrase('-CLR', nt, 'non_privileged', L0, L).
verb_complements_by_code(';_In/pr_', store([], []), 'filled_sbj', 'active', L0, L) -->
  preposition_phrase('-CLR', nt, 'non_privileged', L0, L).

verb_complements_by_code(';_It_', store([], []), 'filled_sbj', 'active', L0, L) -->
  ip_to_inf('-CLR', nt, store([], []), L0, L).

% Mono-transitive verb complements

verb_complements_by_code(';_Tn_', store([], []), 'filled_sbj', 'active', L0, L) -->
  noun_phrase('-OB1', nt, 'non_privileged', L0, L).
verb_complements_by_code(';_Tn_', store(Left, Right), 'filled_sbj', 'active', L, [node('NP', '-OB1', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [np(ICH)])
  },
  [].
verb_complements_by_code(';_Tn_', store([], []), 'filled_sbj', 'lgs_passive', L, L) -->
  [].

verb_complements_by_code(';_Tn.p_', store([], []), 'filled_sbj', 'active', L0, L) -->
  noun_phrase('-OB1', nt, 'non_privileged', L0, L1),
  adverb_phrase('-CLR', nt, 'particle', L1, L).
verb_complements_by_code(';_Tn.p_', store([], []), 'filled_sbj', 'active', L0, L) -->
  adverb_phrase('-CLR', nt, 'particle', L0, L1),
  noun_phrase('-OB1', nt, 'non_privileged', L1, L).
verb_complements_by_code(';_Tn.p_', store(Left, Right), 'filled_sbj', 'active', L0, [node('NP', '-OB1', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [np(ICH)])
  },
  adverb_phrase('-CLR', nt, 'particle', L0, L).
verb_complements_by_code(';_Tn.p_', store(Left, Right), 'filled_sbj', 'active', L0, [node('ADVP', '-CLR', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [advp(ICH)])
  },
  noun_phrase('-OB1', nt, 'non_privileged', L0, L).
verb_complements_by_code(';_Tn.p_', store(Left, Right), 'filled_sbj', 'active', L, [node('NP', '-OB1', nt, [ICH1]), node('ADVP', '-CLR', nt, [ICH2]) | L]) -->
  {
    (
      append(Left, Right, [advp(ICH2), np(ICH1)])
    ;
      append(Left, Right, [np(ICH1), advp(ICH2)])
    )
  },
  [].
verb_complements_by_code(';_Tn.p_', store([], []), 'filled_sbj', 'lgs_passive', L0, L) -->
  adverb_phrase('-CLR', nt, 'particle', L0, L).
verb_complements_by_code(';_Tn.p_', store(Left, Right), 'filled_sbj', 'lgs_passive', L, [node('ADVP', '-CLR', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [advp(ICH)])
  },
  [].

verb_complements_by_code(';_Tn.pr_', store([], []), 'filled_sbj', 'active', L0, L) -->
  noun_phrase('-OB1', nt, 'non_privileged', L0, L1),
  preposition_phrase('-CLR', nt, 'non_privileged', L1, L).
verb_complements_by_code(';_Tn.pr_', store([], []), 'filled_sbj', 'active', L0, L) -->
  preposition_phrase('-CLR', nt, 'non_privileged', L0, L1),
  noun_phrase('-OB1', nt, 'non_privileged', L1, L).
verb_complements_by_code(';_Tn.pr_', Store, 'filled_sbj', 'active', L0, L) -->
  [w('PRO', ';_provisional_', Word)],
  preposition_phrase('-CLR', nt, 'non_privileged', [node('NP', '-OB1', nt, [node('PRO', ';_provisional_', pt, [node(Word, '', t, [])])]) | L0], L1),
  notional_item('-NOB1', Store, L1, L).
verb_complements_by_code(';_Tn.pr_', store(Left, Right), 'filled_sbj', 'active', L0, [node('PP', '-CLR', nt, [node('NP', '', nt, [ICH]), Role]) | L]) -->
  {
    append(Left, Right, [np(ICH)])
  },
  noun_phrase('-OB1', nt, 'non_privileged', L0, L),
  role(Role).
verb_complements_by_code(';_Tn.pr_', store(Left, Right), 'filled_sbj', 'active', L0, [node('PP', '-CLR', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [pp(ICH)])
  },
  noun_phrase('-OB1', nt, 'non_privileged', L0, L).
verb_complements_by_code(';_Tn.pr_', store(Left, Right), 'filled_sbj', 'active', L0, L) -->
  {
    append(Left, Right, [np(ICH)])
  },
  preposition_phrase('-CLR', nt, 'non_privileged', [node('NP', '-OB1', nt, [ICH]) | L0], L).
verb_complements_by_code(';_Tn.pr_', store([], []), 'filled_sbj', 'lgs_passive', L0, L) -->
  preposition_phrase('-CLR', nt, 'non_privileged', L0, L).
verb_complements_by_code(';_Tn.pr_', store(Left, Right), 'filled_sbj', 'lgs_passive', L, [node('PP', '-CLR', nt, [node('NP', '', nt, [ICH]), Role]) | L]) -->
  {
    append(Left, Right, [np(ICH)])
  },
  role(Role).
verb_complements_by_code(';_Tn.pr_', store(Left, Right), 'filled_sbj', 'lgs_passive', L, [node('PP', '-CLR', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [pp(ICH)])
  },
  [].
verb_complements_by_code(';_Tn.pr_', store([], []), 'filled_sbj', 'lgs_passive', L0, [node('PP', '-CLR', nt, [Role]) | L]) -->
  noun_phrase('-OB1', nt, 'non_privileged', L0, L),
  role(Role).
verb_complements_by_code(';_Tn.pr_', store([], []), 'filled_sbj', 'passive', L0, L) -->
  lgs_role(Role),
  noun_phrase('', nt, 'non_privileged', [], [NP]),
  preposition_phrase('-CLR', nt, 'non_privileged', [node('PP', '-LGS', nt, [NP, Role]) | L0], L).

verb_complements_by_code(';_Tf_', Store, 'filled_sbj', 'active', L0, L) -->
  {
    ( Feat = 'with_c' ; Feat = 'without_c' )
  },
  cp_that('-OB1', nt, Feat, Store, L0, L).
verb_complements_by_code(';_Tf_', store(Left, Right), 'filled_sbj', 'active', L, [node('CP-THT', '-OB1', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [cp_that(ICH)])
  },
  [].

verb_complements_by_code(';_Tw_', Store, 'filled_sbj', 'active', L0, L) -->
  cp_embedded_que('-OB1', nt, Store, L0, L).

verb_complements_by_code(';_Tr_', store([], []), 'filled_sbj', 'active', L0, L) -->
  optional_punc_non_final(L0, L1),
  punc('left_quotation_mark', L1, L2),
  utterance('-OB1', nt, L2, L3),
  punc('right_quotation_mark', L3, L).
verb_complements_by_code(';_Tr_', store(Left, Right), 'filled_sbj', 'active', L, [node('utterance', '-OB1', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [utterance(ICH)])
  },
  [].

verb_complements_by_code(';_Tt_', Store, 'filled_sbj', 'active', L0, L) -->
  ip_to_inf('-OB1', nt, Store, L0, L).

verb_complements_by_code(';_Tnt_', Store, 'filled_sbj', 'active', L0, [node('IP-INF', '-OB1', nt, VL) | L]) -->
  noun_phrase('-DOB1', nt, 'non_privileged', L0, L),
  to_inf_layer(Store, 'filled_sbj', 'active', [], VL).
verb_complements_by_code(';_Tnt_', store(Left, Right), 'filled_sbj', 'active', L, [node('IP-INF', '-OB1', nt, VL), node('NP', '-DOB1', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [np(ICH)])
  },
  to_inf_layer(store([], []), 'filled_sbj', 'active', [], VL).
verb_complements_by_code(';_Tnt_', Store, 'filled_sbj', 'lgs_passive', L, [node('IP-INF', '-OB1', nt, VL) | L]) -->
  to_inf_layer(Store, 'filled_sbj', 'active', [], VL).
verb_complements_by_code(';_Tnt_', Store, 'filled_sbj', 'passive', L, [node('IP-INF', '-OB1', nt, VL), node('PP', '-LGS', nt, [NP, Role]) | L]) -->
  lgs_role(Role),
  noun_phrase('', nt, 'non_privileged', [], [NP]),
  to_inf_layer(Store, 'filled_sbj', 'active', [], VL).
verb_complements_by_code(';_Tnt_', Store, 'filled_sbj', 'active', L0, L) -->
  [w('PRO', ';_provisional_', Word)],
  to_inf_layer(store([], []), 'filled_sbj', 'active', [], VL),
  notional_item('-NDOB1', Store, [node('IP-INF', '-OB1', nt, VL), node('NP', '-DOB1', nt, [node('PRO', ';_provisional_', pt, [node(Word, '', t, [])])]) | L0], L).
verb_complements_by_code(';_Tnt_', Store, 'filled_sbj', 'active', L, [node('IP-INF', '-OB1', nt, VL), node('EX', '', pt, [node(Word, '', t, [])]) | L]) -->
  [w('EX', '', Word)],
  to_inf_layer(Store, 'there_sbj', 'active', [], VL).
verb_complements_by_code(';_Tnt_', Store, 'there_sbj', 'lgs_passive', L, [node('IP-INF', '-OB1', nt, VL) | L]) -->
  to_inf_layer(Store, 'there_sbj', 'active', [], VL).
verb_complements_by_code(';_Tnt_', Store, 'there_sbj', 'passive', L, [node('IP-INF', '-OB1', nt, VL), node('PP', '-LGS', nt, [NP, Role]) | L]) -->
  lgs_role(Role),
  noun_phrase('', nt, 'non_privileged', [], [NP]),
  to_inf_layer(Store, 'there_sbj', 'active', [], VL).

verb_complements_by_code(';_Tprt_', Store, 'filled_sbj', 'active', L0, [node('IP-INF', '-OB1', nt, VL) | L]) -->
  preposition_phrase('-DOB1', nt, 'non_privileged', L0, L),
  to_inf_layer(Store, 'filled_sbj', 'active', [], VL).

verb_complements_by_code(';_Tni_', store([], []), 'filled_sbj', 'active', L0, [node('IP-INF', '-OB1', nt, VL) | L]) -->
  noun_phrase('-DOB1', nt, 'non_privileged', L0, L),
  verb_phrase_layer(store([], []), 'filled_sbj', 'infinitive', 'active', [], VL).
verb_complements_by_code(';_Tni_', store(Left, Right), 'filled_sbj', 'active', L, [node('IP-INF', '-OB1', nt, VL), node('NP', '-DOB1', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [np(ICH)])
  },
  verb_phrase_layer(store([], []), 'filled_sbj', 'infinitive', 'active', [], VL).

verb_complements_by_code(';_Tg_', Store, 'filled_sbj', 'active', L0, L) -->
  ip_ppl_active('-OB1', nt, Store, 'filled_sbj', 'ing_participle', L0, L).

verb_complements_by_code(';_Tng_', store([], []), 'filled_sbj', 'active', L0, L) -->
  noun_phrase('-DOB1', nt, 'non_privileged', L0, L1),
  ip_ppl_active('-OB1', nt, store([], []), 'filled_sbj', 'ing_participle', L1, L).
verb_complements_by_code(';_Tng_', store([np(ICH)], []), 'filled_sbj', 'active', L0, L) -->
  ip_ppl_active('-OB1', nt, store([], []), 'filled_sbj', 'ing_participle', [node('NP', '-DOB1', nt, [ICH]) | L0], L).
verb_complements_by_code(';_Tng_', store([], []), 'filled_sbj', 'lgs_passive', L0, L) -->
  ip_ppl_active('-OB1', nt, store([], []), 'filled_sbj', 'ing_participle', L0, L).

verb_complements_by_code(';_Tsg_', store([], []), 'filled_sbj', 'active', L, [node('IP-PPL', '3-OB1', nt, VL) | L]) -->
  noun_phrase_genm_layer('non_privileged', [], NL),
  verb_phrase_layer(store([], []), 'filled_sbj', 'ing_participle', 'active', [node('NP', '-SBJ', nt, NL)], VL).
verb_complements_by_code(';_Tsg_', store([], []), 'filled_sbj', 'active', L, [node('IP-PPL', '3-OB1', nt, VL) | L]) -->
  noun_phrase('-SBJ', nt, 'non_privileged', [], VL1),
  verb_phrase_layer(store([], []), 'filled_sbj', 'ing_participle', 'active', VL1, VL).

% Ditransitive verb complements

verb_complements_by_code(';_Dn.n_', store([], []), 'filled_sbj', 'active', L0, L) -->
  [w('PRO', '', 'it')],
  noun_phrase('-OB2', nt, 'non_privileged', [node('NP', '-OB1', nt, [node('PRO', '', pt, [node('it', '', t, [])])]) | L0], L).
verb_complements_by_code(';_Dn.n_', store([], []), 'filled_sbj', 'active', L0, L) -->
  noun_phrase('-OB2', nt, 'non_privileged', L0, L1),
  noun_phrase('-OB1', nt, 'non_privileged', L1, L).
verb_complements_by_code(';_Dn.n_', store(Left, Right), 'filled_sbj', 'active', L0, [node('NP', '-OB1', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [np(ICH)])
  },
  noun_phrase('-OB2', nt, 'non_privileged', L0, L).
verb_complements_by_code(';_Dn.n_', store([], []), 'filled_sbj', 'lgs_passive', L0, L) -->
  noun_phrase('-OB1', nt, 'non_privileged', L0, L).
verb_complements_by_code(';_Dn.n_', store(Left, Right), 'filled_sbj', 'lgs_passive', L, [node('NP', '-OB1', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [np(ICH)])
  },
  [].

verb_complements_by_code(';_Dn.f_', Store, 'filled_sbj', 'active', L0, L) -->
  noun_phrase('-OB2', nt, 'non_privileged', L0, L1),
  {
    ( Feat = 'with_c' ; Feat = 'without_c' )
  },
  cp_that('-OB1', nt, Feat, Store, L1, L).
verb_complements_by_code(';_Dn.f_', Store, 'filled_sbj', 'lgs_passive', L0, L) -->
  {
    ( Feat = 'with_c' ; Feat = 'without_c' )
  },
  cp_that('-OB1', nt, Feat, Store, L0, L).

verb_complements_by_code(';_Dn.w_', Store, 'filled_sbj', 'active', L0, L) -->
  noun_phrase('-OB2', nt, 'non_privileged', L0, L1),
  cp_embedded_que('-OB1', nt, Store, L1, L).
verb_complements_by_code(';_Dn.w_', Store, 'filled_sbj', 'lgs_passive', L0, L) -->
  cp_embedded_que('-OB1', nt, Store, L0, L).

verb_complements_by_code(';_Dn.r_', store([], []), 'filled_sbj', 'active', L0, L) -->
  noun_phrase('-OB2', nt, 'non_privileged', L0, L1),
  optional_punc_non_final(L1, L2),
  punc('left_quotation_mark', L2, L3),
  utterance('-OB1', nt, L3, L4),
  punc('right_quotation_mark', L4, L).
verb_complements_by_code(';_Dn.r_', store([], []), 'filled_sbj', 'lgs_passive', L0, L) -->
  optional_punc_non_final(L0, L1),
  punc('left_quotation_mark', L1, L2),
  utterance('-OB1', nt, L2, L3),
  punc('right_quotation_mark', L3, L).

verb_complements_by_code(';_Dn.t_', Store, 'filled_sbj', 'active', L0, [node('IP-INF', '-OB1', nt, VL) | L]) -->
  noun_phrase('-OB2', nt, 'non_privileged', L0, L),
  to_inf_layer(Store, 'filled_sbj', 'active', [], VL).
verb_complements_by_code(';_Dn.t_', Store, 'filled_sbj', 'active', L0, [node('IP-INF', '-OB1', nt, VL) | L]) -->
  noun_phrase('-OB2', nt, 'non_privileged', L0, L1),
  adverbial(L1, L),
  to_inf_layer(Store, 'filled_sbj', 'active', [], VL).
verb_complements_by_code(';_Dn.t_', Store, 'filled_sbj', 'lgs_passive', L, [node('IP-INF', '2-OB1', nt, VL) | L]) -->
  to_inf_layer(Store, 'filled_sbj', 'active', [], VL).

verb_complements_by_code(';_Dn.*_', store([], []), 'filled_sbj', 'active', L0, L) -->
  noun_phrase('-OB2', nt, 'non_privileged', L0, L).

verb_complements_by_code(';_Dn.pr_', store([], []), 'filled_sbj', 'active', L0, L) -->
  noun_phrase('-OB1', nt, 'non_privileged', L0, L1),
  preposition_phrase('-OB2', nt, 'non_privileged', L1, L).
verb_complements_by_code(';_Dn.pr_', store([], []), 'filled_sbj', 'active', L0, L) -->
  preposition_phrase('-OB2', nt, 'non_privileged', L0, L1),
  noun_phrase('-OB1', nt, 'non_privileged', L1, L).
verb_complements_by_code(';_Dn.pr_', store(Left, Right), 'filled_sbj', 'active', L0, L) -->
  {
    append(Left, Right, [np(ICH)])
  },
  preposition_phrase('-OB2', nt, 'non_privileged', [node('NP', '-OB1', nt, [ICH]) | L0], L).
verb_complements_by_code(';_Dn.pr_', store(Left, Right), 'filled_sbj', 'active', L0, [node('PP', '-OB2', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [pp(ICH)])
  },
  noun_phrase('-OB1', nt, 'non_privileged', L0, L).
verb_complements_by_code(';_Dn.pr_', store(Left, Right), 'filled_sbj', 'active', L0, [node('PP', '-OB2', nt, [node('NP', '', nt, [ICH]), Role]) | L]) -->
  {
    append(Left, Right, [np(ICH)])
  },
  noun_phrase('-OB1', nt, 'non_privileged', L0, L),
  role(Role).
verb_complements_by_code(';_Dn.pr_', store([], []), 'filled_sbj', 'lgs_passive', L0, L) -->
  preposition_phrase('-OB2', nt, 'non_privileged', L0, L).
verb_complements_by_code(';_Dn.pr_', store(Left, Right), 'filled_sbj', 'lgs_passive', L, [node('PP', '-OB2', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [pp(ICH)])
  },
  [].
verb_complements_by_code(';_Dn.pr_', store(Left, Right), 'filled_sbj', 'lgs_passive', L, [node('PP', '-OB2', nt, [node('NP', '', nt, [ICH]), Role]) | L]) -->
  {
    append(Left, Right, [np(ICH)])
  },
  role(Role).

verb_complements_by_code(';_Dpr.f_', Store, 'filled_sbj', 'active', L0, L) -->
  preposition_phrase('-OB2', nt, 'non_privileged', L0, L1),
  {
    ( Feat = 'with_c' ; Feat = 'without_c' )
  },
  cp_that('-OB1', nt, Feat, Store, L1, L).

verb_complements_by_code(';_Dpr.r_', store([], []), 'filled_sbj', 'active', L0, L) -->
  preposition_phrase('-OB2', nt, 'non_privileged', L0, L1),
  optional_punc_non_final(L1, L2),
  punc('left_quotation_mark', L2, L3),
  utterance('-OB1', nt, L3, L4),
  punc('right_quotation_mark', L4, L).

% Complex-transitive verb complements

verb_complements_by_code(';_Cn.a_', store([], []), 'filled_sbj', 'active', L0, L) -->
  noun_phrase('-OB1', nt, 'non_privileged', L0, L1),
  adjective_phrase('-PRD', nt, store([], []), 'non_privileged', L1, L).
verb_complements_by_code(';_Cn.a_', store([], []), 'filled_sbj', 'active', L0, L) -->
  adjective_phrase('-PRD', nt, store([], []), 'non_privileged', L0, L1),
  noun_phrase('-OB1', nt, 'non_privileged', L1, L).
verb_complements_by_code(';_Cn.a_', store(Left, Right), 'filled_sbj', 'active', L0, [node('NP', '-OB1', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [np(ICH)])
  },
  adjective_phrase('-PRD', nt, store([], []), 'non_privileged', L0, L).
verb_complements_by_code(';_Cn.a_', store([], []), 'filled_sbj', 'active', L0, L) -->
  [w('PRO', ';_provisional_', Word)],
  adjective_phrase('-PRD', nt, store([], []), 'non_privileged', [node('NP', '-OB1', nt, [node('PRO', ';_provisional_', pt, [node(Word, '', t, [])])]) | L0], L1),
  notional_item('3-NOB1', store([], []), L1, L).
verb_complements_by_code(';_Cn.a_', Store, 'filled_sbj', 'active', L0, [node('IP-INF', '-NOB1', nt, VL) | L]) -->
  noun_phrase('-OB1', nt, 'non_privileged', L0, L1),
  adjective_phrase('-PRD', nt, store([], []), 'non_privileged', L1, L),
  to_inf_layer(Store, 'filled_sbj', 'passive', [], VL).
verb_complements_by_code(';_Cn.a_', store(Left, Right), 'filled_sbj', 'active', L0, [node('IP-INF', '-NOB1', nt, VL) | L]) -->
  {
    append(Left, Right, [np(ICH)])
  },
  adjective_phrase('-PRD', nt, store([], []), 'non_privileged', [node('NP', '-OB1', nt, [ICH]) | L0], L),
  to_inf_layer(store([], []), 'filled_sbj', 'passive', [], VL).
verb_complements_by_code(';_Cn.a_', store([], []), 'filled_sbj', 'lgs_passive', L0, L) -->
  adjective_phrase('-PRD', nt, store([], []), 'non_privileged', L0, L).
verb_complements_by_code(';_Cn.a_', store([], []), 'filled_sbj', 'lgs_passive', L0, [node('IP-INF', '-NOB1', nt, VL) | L]) -->
  adjective_phrase('-PRD', nt, store([], []), 'non_privileged', L0, L),
  to_inf_layer(store([], []), 'filled_sbj', 'passive', [], VL).

verb_complements_by_code(';_Cn.n_', store([], []), 'filled_sbj', 'active', L0, L) -->
  noun_phrase('-OB1', nt, 'non_privileged', L0, L1),
  noun_phrase('-PRD', nt, 'non_privileged', L1, L).
verb_complements_by_code(';_Cn.n_', store([], []), 'filled_sbj', 'active', L0, L) -->
  [w('PRO', ';_provisional_', Word)],
  noun_phrase('-PRD', nt, 'non_privileged', [node('NP', '-OB1', nt, [node('PRO', ';_provisional_', pt, [node(Word, '', t, [])])]) | L0], L1),
  notional_item('3-NOB1', store([], []), L1, L).
verb_complements_by_code(';_Cn.n_', store(Left, Right), 'filled_sbj', 'active', L0, [node('NP', '-OB1', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [np(ICH)])
  },
  noun_phrase('-PRD', nt, 'non_privileged', L0, L).
verb_complements_by_code(';_Cn.n_', store([], []), 'filled_sbj', 'lgs_passive', L0, L) -->
  noun_phrase('-PRD', nt, 'non_privileged', L0, L).
verb_complements_by_code(';_Cn.n_', store(Left, Right), 'filled_sbj', 'lgs_passive', L, [node('NP', '-PRD', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [np(ICH)])
  },
  [].

verb_complements_by_code(';_Cn.n/a_', store([], []), 'filled_sbj', 'active', L0, [node('PP', '-PRD', nt, [NP, node('P-ROLE', '', pt, [node('as', '', t, [])])]) | L]) -->
  noun_phrase('-OB1', nt, 'non_privileged', L0, L),
  [w('P-ROLE', '', 'as')],
  noun_phrase('', nt, 'non_privileged', [], [NP]).
verb_complements_by_code(';_Cn.n/a_', store([], []), 'filled_sbj', 'active', L0, [node('PP', '-PRD', nt, [node('NP', '', nt, [ADJP]), node('P-ROLE', '', pt, [node('as', '', t, [])])]) | L]) -->
  noun_phrase('-OB1', nt, 'non_privileged', L0, L),
  [w('P-ROLE', '', 'as')],
  adjective_phrase('', nt, store([], []), 'non_privileged', [], [ADJP]).
verb_complements_by_code(';_Cn.n/a_', store([], []), 'filled_sbj', 'lgs_passive', L, [node('PP', '-PRD', nt, [NP, node('P-ROLE', '', pt, [node('as', '', t, [])])]) | L]) -->
  [w('P-ROLE', '', 'as')],
  noun_phrase('', nt, 'non_privileged', [], [NP]).
verb_complements_by_code(';_Cn.n/a_', store([], []), 'filled_sbj', 'lgs_passive', L, [node('PP', '-PRD', nt, [node('NP', '', nt, [ADJP]), node('P-ROLE', '', pt, [node('as', '', t, [])])]) | L]) -->
  [w('P-ROLE', '', 'as')],
  adjective_phrase('', nt, store([], []), 'non_privileged', [], [ADJP]).
verb_complements_by_code(';_Cn.n/a_', store([], []), 'filled_sbj', 'passive', L, [node('PP', '-PRD', nt, [NP2, node('P-ROLE', '', pt, [node('as', '', t, [])])]), node('PP', '-LGS', nt, [NP1, Role]) | L]) -->
  lgs_role(Role),
  noun_phrase('', nt, 'non_privileged', [], [NP1]),
  [w('P-ROLE', '', 'as')],
  noun_phrase('', nt, 'non_privileged', [], [NP2]).
verb_complements_by_code(';_Cn.n/a_', store([], []), 'filled_sbj', 'passive', L, [node('PP', '-PRD', nt, [node('NP', '', nt, [ADJP]), node('P-ROLE', '', pt, [node('as', '', t, [])])]), node('PP', '-LGS', nt, [NP, Role]) | L]) -->
  lgs_role(Role),
  noun_phrase('', nt, 'non_privileged', [], [NP]),
  [w('P-ROLE', '', 'as')],
  adjective_phrase('', nt, store([], []), 'non_privileged', [], [ADJP]).

verb_complements_by_code(';_Cn.pr_', store([], []), 'filled_sbj', 'active', L0, L) -->
  noun_phrase('-OB1', nt, 'non_privileged', L0, L1),
  preposition_phrase('-PRD', nt, 'non_privileged', L1, L).
verb_complements_by_code(';_Cn.pr_', store([], []), 'filled_sbj', 'lgs_passive', L0, L) -->
  preposition_phrase('-PRD', nt, 'non_privileged', L0, L).

verb_complements_by_code(';_Cn.t_', Store, 'filled_sbj', 'active', L0, [node('IP-INF', '-PRD', nt, VL) | L]) -->
  noun_phrase('-OB1', nt, 'non_privileged', L0, L),
  to_inf_layer(Store, 'filled_sbj', 'active', [], VL).
verb_complements_by_code(';_Cn.t_', store(Left, Right), 'filled_sbj', 'active', L, [node('IP-INF', '-PRD', nt, VL), node('NP', '-OB1', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [np(ICH)])
  },
  to_inf_layer(store([], []), 'filled_sbj', 'active', [], VL).
verb_complements_by_code(';_Cn.t_', Store, 'filled_sbj', 'lgs_passive', L, [node('IP-INF', '-PRD', nt, VL) | L]) -->
  to_inf_layer(Store, 'filled_sbj', 'active', [], VL).

verb_complements_by_code(';_Cn.i_', Store, 'filled_sbj', 'active', L0, [node('IP-INF', '-PRD', nt, VL) | L]) -->
  noun_phrase('-OB1', nt, 'non_privileged', L0, L),
  verb_phrase_layer(Store, 'filled_sbj', 'infinitive', 'active', [], VL).
verb_complements_by_code(';_Cn.i_', Store, 'filled_sbj', 'active', L, [node('EX', '', pt, [node(Word, '', t, [])]), node('IP-INF', '-PRD', nt, VL) | L]) -->
  [w('EX', '', Word)],
  verb_phrase_layer(Store, 'there_sbj', 'infinitive', 'active', [], VL).

verb_complements_by_code(';_Cn.g_', Store, 'filled_sbj', 'active', L0, L) -->
  noun_phrase('-OB1', nt, 'non_privileged', L0, L1),
  ip_ppl_active('-PRD', nt, Store, 'filled_sbj', 'ing_participle', L1, L).
verb_complements_by_code(';_Cn.g_', Store, 'filled_sbj', 'lgs_passive', L0, L) -->
  ip_ppl_active('-PRD', nt, Store, 'filled_sbj', 'ing_participle', L0, L).

% VP24A

verb_complements_by_code(';_VP24A_', Store, 'filled_sbj', 'active', L0, L) -->
  noun_phrase('-OB1', nt, 'non_privileged', L0, L1),
  ip_ppl_passive('IP-PPL', '-PRD', Store, 'filled_sbj', 'en_participle', L1, L).
verb_complements_by_code(';_VP24A_', Store, 'filled_sbj', 'lgs_passive', L0, L) -->
  ip_ppl_passive('IP-PPL', '-PRD', Store, 'filled_sbj', 'en_participle', L0, L).

% VP24B

verb_complements_by_code(';_VP24B_', Store, 'filled_sbj', 'active', L0, L) -->
  noun_phrase('-OB1', nt, 'non_privileged', L0, L1),
  ip_ppl_passive('IP-PPL', '-PRD', Store, 'filled_sbj', 'en_participle', L1, L).

% VP24C

verb_complements_by_code(';_VP24C_', Store, 'filled_sbj', 'active', L0, L) -->
  noun_phrase('-OB1', nt, 'non_privileged', L0, L1),
  ip_ppl_passive('IP-PPL', '-PRD', Store, 'filled_sbj', 'en_participle', L1, L).

% Existential verb complements

verb_complements_by_code(';_ex_V_', store([], []), 'there_sbj', 'active', L0, L) -->
  noun_phrase('-ESBJ', nt, 'established', L0, L).
verb_complements_by_code(';_ex_V_', store(Left, Right), 'there_sbj', 'active', L, [node('NP', '-ESBJ', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [np(ICH)])
  },
  [].

verb_complements_by_code(';_ex_Vp_', store([], []), 'there_sbj', 'active', L0, L) -->
  noun_phrase('-ESBJ', nt, 'established', L0, L1),
  adverb_phrase('-CLR', nt, 'particle', L1, L).
verb_complements_by_code(';_ex_Vp_', store(Left, Right), 'there_sbj', 'active', L0, L) -->
  {
    append(Left, Right, [np(ICH)])
  },
  adverb_phrase('-CLR', nt, 'particle', [node('NP', '-ESBJ', nt, [ICH]) | L0], L).

verb_complements_by_code(';_ex_Vpr_', store([], []), 'there_sbj', 'active', L0, L) -->
  noun_phrase('-ESBJ', nt, 'established', L0, L1),
  preposition_phrase('-CLR', nt, 'non_privileged', L1, L).
verb_complements_by_code(';_ex_Vpr_', store(Left, Right), 'there_sbj', 'active', L0, L) -->
  {
    append(Left, Right, [np(ICH)])
  },
  preposition_phrase('-CLR', nt, 'non_privileged', [node('NP', '-ESBJ', nt, [ICH]) | L0], L).
verb_complements_by_code(';_ex_Vpr_', store(Left, Right), 'there_sbj', 'active', L0, [node('PP', '-CLR', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [pp(ICH)])
  },
  noun_phrase('-ESBJ', nt, 'established', L0, L).

verb_complements_by_code(';_ex_La_', store([], []), 'there_sbj', 'active', L0, L) -->
  noun_phrase('-ESBJ', nt, 'established', L0, L1),
  adjective_phrase('-PRD', nt, store([], []), 'non_privileged', L1, L).
verb_complements_by_code(';_ex_La_', store(Left, Right), 'there_sbj', 'active', L0, L) -->
  {
    append(Left, Right, [np(ICH)])
  },
  adjective_phrase('-PRD', nt, store([], []), 'non_privileged', [node('NP', '-ESBJ', nt, [ICH]) | L0], L).

verb_complements_by_code(';_ex_Ln_', store([], []), 'there_sbj', 'active', L0, L) -->
  noun_phrase('-ESBJ', nt, 'established', L0, L1),
  noun_phrase('-PRD', nt, 'non_privileged', L1, L).
verb_complements_by_code(';_ex_Ln_', store(Left, Right), 'there_sbj', 'active', L0, L) -->
  {
    append(Left, Right, [np(ICH)])
  },
  noun_phrase('-PRD', nt, 'non_privileged', [node('NP', '-ESBJ', nt, [ICH]) | L0], L).

verb_complements_by_code(';_ex_cat_Vt_', Store, 'there_sbj', 'active', L0, [node('IP-INF', '-CAT', nt, VL) | L]) -->
  noun_phrase('-ESBJ', nt, 'established', L0, L),
  to([], VL1),
  verb_phrase_layer(Store, 'filled_sbj', 'infinitive', 'active', VL1, VL).
verb_complements_by_code(';_ex_cat_Vt_', store([np(ICH) | Left], Right), 'there_sbj', 'active', L, [node('IP-INF', '-CAT', nt, VL), node('NP', '-ESBJ', nt, [ICH]) | L]) -->
  to([], VL1),
  verb_phrase_layer(store(Left, Right), 'filled_sbj', 'infinitive', 'active', VL1, VL).

verb_complements_by_code(';_ex_cat_VtPASS_', Store, 'there_sbj', 'active', L0, [node('IP-INF', '-CAT', nt, VL) | L]) -->
  noun_phrase('-ESBJ', nt, 'established', L0, L),
  {
    ( SbjFeat = 'filled_sbj' ; SbjFeat = 'unfilled_sbj' )
  },
  to_inf_layer(Store, SbjFeat, 'passive', [], VL).
verb_complements_by_code(';_ex_cat_VtPASS_', store([np(ICH) | Left], Right), 'there_sbj', 'active', L, [node('IP-INF', '-CAT', nt, VL), node('NP', '-ESBJ', nt, [ICH]) | L]) -->
  {
    ( SbjFeat = 'filled_sbj' ; SbjFeat = 'unfilled_sbj' )
  },
  to_inf_layer(store(Left, Right), SbjFeat, 'passive', [], VL).

verb_complements_by_code(';_ex_cat_Vg_', Store, 'there_sbj', 'active', L0, L) -->
  noun_phrase('-ESBJ', nt, 'established', L0, L1),
  ip_ppl_active('-CAT', nt, Store, 'filled_sbj', 'ing_participle', L1, L).
verb_complements_by_code(';_ex_cat_Vg_', store([np(ICH) | Left], Right), 'there_sbj', 'active', L0, L) -->
  ip_ppl_active('-CAT', nt, store(Left, Right), 'filled_sbj', 'ing_participle', [node('NP', '-ESBJ', nt, [ICH]) | L0], L).

verb_complements_by_code(';_ex_cat_VePASS_', Store, 'there_sbj', 'active', L0, L) -->
  noun_phrase('-ESBJ', nt, 'established', L0, L1),
  ip_ppl_passive('IP-PPL', '-CAT', Store, 'filled_sbj', 'en_participle', L1, L).
verb_complements_by_code(';_ex_cat_VePASS_', store([np(ICH) | Left], Right), 'there_sbj', 'active', L0, L) -->
  ip_ppl_passive('IP-PPL', '-CAT', store(Left, Right), 'filled_sbj', 'en_participle', [node('NP', '-ESBJ', nt, [ICH]) | L0], L).

% Equatives

verb_complements_by_code(';_equ_Vf_', store([], []), 'filled_sbj', 'active', L0, L) -->
  {
    ( Feat = 'with_c' ; Feat = 'without_c' )
  },
  cp_that('-PRD', nt, Feat, store([], []), L0, L).

verb_complements_by_code(';_equ_Vw_', store([], []), 'filled_sbj', 'active', L0, L) -->
  cp_embedded_que('-PRD', nt, store([], []), L0, L).

verb_complements_by_code(';_equ_Vt_', store([], []), 'filled_sbj', 'active', L0, L) -->
  ip_to_inf('-PRD', nt, store([], []), L0, L).

verb_complements_by_code(';_equ_Vg_', store([], []), 'filled_sbj', 'active', L, [node('IP-PPL', '-PRD', nt, IL) | L]) -->
  ip_ppl_adverbial_layer('filled_sbj', 'ing_participle', [], IL).
verb_complements_by_code(';_equ_Vg_', store([], []), 'filled_sbj', 'active', L, [node('IP-PPL', '3-PRD', nt, IL) | L]) -->
  ip_ppl_adverbial_layer('unfilled_sbj', 'ing_participle', [], IL).

% Cleft

verb_complements_by_code(';_cleft_Vn_', store([], []), 'provisional_sbj', 'active', L0, [node('IP-CLF', '', nt, IL) | L]) -->
  noun_phrase('-FOC', nt, 'non_privileged', L0, L),
  relative_clause_finite_top_layer([], IL).
verb_complements_by_code(';_cleft_Vn_', store(Left, Right), 'provisional_sbj', 'active', L, [node('IP-CLF', '', nt, IL), node('NP', '-FOC', nt, [ICH]) | L]) -->
  {
    append(Left, Right, [np(ICH)])
  },
  relative_clause_finite_top_layer([], IL).

% V_as_though/as_if/like

verb_complements_by_code(';_V_as_though/as_if/like_', Store, 'there_sbj', 'active', L, [node('PP', '-CLR', nt, [node('IP-ADV', '', nt, IL), Role]) | L]) -->
  role(Role),
  subject('there_sbj', [], IL1),
  clause_middle_layer(Store, 'there_sbj', IL1, IL).
verb_complements_by_code(';_V_as_though/as_if/like_', Store, 'filled_sbj', 'active', L, [node('PP', '-CLR', nt, [node('IP-ADV', '', nt, IL), Role]) | L]) -->
  role(Role),
  clause_top_layer('statement_order', Store, [], IL).

% Catenative verb complements

verb_complements_by_code(';_cat_Vt_', Store, SbjFeat, 'active', L, [node('IP-INF', '-CAT', nt, VL) | L]) -->
  {
    SbjFeat \= 'provisional_sbj'
  },
  to([], VL1),
  verb_phrase_layer(Store, SbjFeat, 'infinitive', 'active', VL1, VL).

verb_complements_by_code(';_cat_VtPASS_', Store, 'filled_sbj', 'active', L, [node('IP-INF', '-CAT', nt, VL) | L]) -->
  {
    ( SbjFeat = 'filled_sbj' ; SbjFeat = 'unfilled_sbj' )
  },
  to_inf_layer(Store, SbjFeat, 'passive', [], VL).

verb_complements_by_code(';_cat_Vi_', Store, SbjFeat, 'active', L, [node('IP-INF', '-CAT', nt, VL) | L]) -->
  {
    SbjFeat \= 'provisional_sbj'
  },
  verb_phrase_layer(Store, SbjFeat, 'infinitive', 'active', [], VL).

verb_complements_by_code(';_cat_Vg_', Store, SbjFeat, 'active', L0, L) -->
  {
    SbjFeat \= 'provisional_sbj'
  },
  ip_ppl_active('-CAT', nt, Store, SbjFeat, 'ing_participle', L0, L).

verb_complements_by_code(';_cat_VgPASS_', Store, SbjFeat, 'active', L0, L) -->
  {
    SbjFeat \= 'provisional_sbj'
  },
  ip_ppl_passive('IP-PPL', '-CAT', Store, SbjFeat, 'ing_participle', L0, L).

verb_complements_by_code(';_cat_Ve_', Store, SbjFeat, 'active', L0, L) -->
  {
    SbjFeat \= 'provisional_sbj'
  },
  ip_ppl_active('-CAT', nt, Store, SbjFeat, 'en_participle', L0, L).

verb_complements_by_code(';_cat_VePASS_', Store, SbjFeat, 'active', L0, L) -->
  {
    SbjFeat \= 'provisional_sbj'
  },
  ip_ppl_passive('IP-PPL', '-CAT', Store, SbjFeat, 'en_participle', L0, L).

% Clause top layer

clause_top_layer('statement_order', Store, L0, L) -->
  subject(SbjFeat, L0, L1),
  clause_middle_layer(Store, SbjFeat, L1, L).
clause_top_layer('imperative_clause', Store, L0, L) -->
  verb_phrase_layer(Store, 'filled_sbj', 'imperative', 'active', L0, L).
clause_top_layer('tag_question', store([], []), L0, L) -->
  do_operator_layer(L0, L1),
  subject('filled_sbj', L1, L).
clause_top_layer('tag_question', store([], []), L0, L) -->
  have_be_or_md_finite_layer(_, L0, L1),
  subject('filled_sbj', L1, L).
clause_top_layer(Feat, Store, L0, L) -->
  {
    ( Feat = 'matrix_interrogative'
    ; Feat = 'matrix_constituent_interrogative'
    ; Feat = 'inversion_order'
    )
  },
  do_operator_layer(L0, L1),
  subject(SbjFeat, L1, L2),
  verb_phrase_layer(Store, SbjFeat, 'do_supported_infinitive', 'active', L2, L).
clause_top_layer(Feat, Store, L0, L) -->
  {
    ( Feat = 'matrix_interrogative'
    ; Feat = 'matrix_constituent_interrogative'
    ; Feat = 'inversion_order'
    )
  },
  have_be_or_md_finite_layer(Code, L0, L1),
  subject(SbjFeat, L1, L2),
  verb_complements_top_layer(Code, Store, SbjFeat, 'active', L2, L).
clause_top_layer('matrix_constituent_interrogative', store([np(ICH) | Left], Right), L0, L) -->
  {
    ( SbjFeat = 'filled_sbj' ; SbjFeat = 'derived_sbj' )
  },
  clause_middle_layer(store(Left, Right), SbjFeat, [node('NP', '-SBJ', nt, [ICH]) | L0], L).

clause_top_layer(Feat0, Store, L0, L) -->
  {
    ( Feat0 = 'statement_order' ->
      ( Feat = 'statement_order' ; Feat = 'inversion_order' )
    ;
      Feat = Feat0
    )
  },
  initial_adverbial(L0, L1),
  optional_punc_non_final(L1, L2),
  clause_top_layer(Feat, Store, L2, L).
clause_top_layer(Feat, Store, L0, L) -->
  clause_top_layer(Feat, Store, L0, L1),
  optional_punc_non_final(L1, L2),
  adverbial(L2, L).
clause_top_layer('matrix_interrogative', store(Left, Right), L0, L) -->
  {
    ( Ich = np(node('*ICH*', '', index(102), []))
    ; Ich = pp(node('*ICH*', '', index(102), []))
    ; Ich = pp_lgs(node('*ICH*', '', index(102), []))
    ; Ich = adjp(node('*ICH*', '', index(102), []))
    ; Ich = advp(node('*ICH*', '', index(102), []))
    )
  },
  interrogative_displaced_item('', index(102), Ich, L0, L1),
  clause_top_layer('matrix_constituent_interrogative', store([Ich | Left], Right), L1, L).
clause_top_layer('matrix_interrogative', Store, L0, L) -->
  adverb_phrase('-NIM', nt, 'interrogative', L0, L1),
  clause_top_layer('matrix_constituent_interrogative', Store, L1, L).
clause_top_layer('statement_order', store(Left, Right), L0, L) -->
  {
    ( Ich = np(node('*ICH*', '', index(103), []))
    ; Ich = pp(node('*ICH*', '', index(103), []))
    ; Ich = pp_lgs(node('*ICH*', '', index(103), []))
    ; Ich = adjp(node('*ICH*', '', index(103), []))
    ; Ich = cp_that(node('*ICH*', '', index(103), []))
    ; Ich = utterance(node('*ICH*', '', index(103), []))
    )
  },
  displaced_item('-TPC', index(103), Ich, L0, L1),
  optional_punc_non_final(L1, L2),
  clause_top_layer('statement_order', store([Ich | Left], Right), L2, L).
clause_top_layer(Feat, Store, L, [node('ILYR', '', nt, CL) | L]) -->
  clause_top_layer(Feat, Store, [], IL),
  clause_top_tail(Feat, Store, [node('ILYR', '', nt, IL)], CL).

clause_top_tail(Feat, Store, L, [node('CONJP', '', nt, [node('ILYR', '', nt, IL), CONJ]) | L]) -->
  conj(CONJ),
  clause_top_layer(Feat, Store, [], IL).
clause_top_tail(Feat, Store, L0, L) -->
  punc('non_final', L0, L1),
  clause_top_layer(Feat, Store, [], IL),
  clause_top_tail(Feat, Store, [node('CONJP', '', nt, [node('ILYR', '', nt, IL)]) | L1], L).

interrogative_displaced_item(Ext, Index, np(node('*ICH*', '', Index, [])), L0, L) -->
  noun_phrase(Ext, Index, 'interrogative', L0, L).
interrogative_displaced_item(Ext, Index, pp(node('*ICH*', '', Index, [])), L0, L) -->
  preposition_phrase(Ext, Index, 'interrogative', L0, L).
interrogative_displaced_item(Ext, Index, pp_lgs(node('*ICH*', '', Index, [])), L, [node('PP', Ext, Index, [NP, Role]) | L]) -->
  lgs_role(Role),
  noun_phrase('', nt, 'interrogative', [], [NP]).
interrogative_displaced_item(Ext, Index, adjp(node('*ICH*', '', Index, [])), L0, L) -->
  adjective_phrase(Ext, Index, store([], []), 'interrogative', L0, L).
interrogative_displaced_item(Ext, Index, advp(node('*ICH*', '', Index, [])), L0, L) -->
  adverb_phrase(Ext, Index, 'interrogative', L0, L).

% Verb phrase layer

verb_phrase_layer(Store, SbjFeat, Infl, Voice, L0, L) -->
  verb(Infl, Code, L0, L1),
  verb_complements_top_layer(Code, Store, SbjFeat, Voice, L1, L).
verb_phrase_layer(Store, SbjFeat, Infl, Voice, L0, L) -->
  {
    SbjFeat = 'filled_sbj',
    Infl = 'imperative',
    Voice = 'active'
  },
  [w('DO', '', Word)],
  optional_clitic_negation([node('DO', '', pt, [node(Word, '', t, [])]) | L0], L1),
  verb_phrase_layer(Store, SbjFeat, 'infinitive', Voice, L1, L).
verb_phrase_layer(Store, SbjFeat, Infl, Voice, L0, L) -->
  adverb_phrase('-NIM', nt, 'established', L0, L1),
  verb_phrase_layer(Store, SbjFeat, Infl, Voice, L1, L).
verb_phrase_layer(Store, SbjFeat, Infl, Voice, L0, L) -->
  verb_phrase_layer(Store, SbjFeat, Infl, Voice, L0, L1),
  adverbial(L1, L).
verb_phrase_layer(Store, SbjFeat, Infl, Voice, L, [node('ILYR', '', nt, CL) | L]) -->
  verb_phrase_layer(Store, SbjFeat, Infl, Voice, [], IL),
  verb_phrase_tail(Store, SbjFeat, Infl, Voice, [node('ILYR', '', nt, IL)], CL).

verb_phrase_tail(Store, SbjFeat, Infl, Voice, L, [node('CONJP', '', nt, [node('ILYR', '', nt, IL), CONJ]) | L]) -->
  conj(CONJ),
  verb_phrase_layer(Store, SbjFeat, Infl, Voice, [], IL).
verb_phrase_tail(Store, SbjFeat, Infl, Voice, L0, L) -->
  punc('non_final', L0, L1),
  verb_phrase_layer(Store, SbjFeat, Infl, Voice, [], IL),
  verb_phrase_tail(Store, SbjFeat, Infl, Voice, [node('CONJP', '', nt, [node('ILYR', '', nt, IL)]) | L1], L).

% DO operator layer

do_operator_layer(L0, L) -->
  [w(Tag, '', Word)],
  {
    ( Tag = 'DOP' ; Tag = 'DOD' )
  },
  optional_clitic_negation([node(Tag, '', pt, [node(Word, '', t, [])]) | L0], L).

% HAVE, BE or modal verb finite layer

have_be_or_md_finite_layer(Code, L0, L) -->
  [w(Tag, Code, Word)],
  {
    ( Tag = 'HVP' ; Tag = 'HVD' ),
    verb_code('H', 'finite', Code)
  },
  optional_clitic_negation([node(Tag, Code, pt, [node(Word, '', t, [])]) | L0], L).
have_be_or_md_finite_layer(Code, L0, L) -->
  [w(Tag, Code, Word)],
  {
    ( Tag = 'BEP' ; Tag = 'BED' ),
    verb_code('B', 'finite', Code)
  },
  optional_clitic_negation([node(Tag, Code, pt, [node(Word, '', t, [])]) | L0], L).
have_be_or_md_finite_layer(Code, L0, L) -->
  modal(Code, L0, L1),
  optional_clitic_negation(L1, L).

% Verb sequencing

ip_ppl_active(Ext, Node_type, Store, SbjFeat, Infl, L, [node('IP-PPL', Ext, Node_type, VL) | L]) -->
  verb_phrase_layer(Store, SbjFeat, Infl, 'active', [], VL).

% Verb sequencing with passive

ip_ppl_passive(Tag, Ext, Store, SbjFeat, Infl, L, [node(Tag, Ext, nt, VL) | L]) -->
  verb_phrase_layer(Store, SbjFeat, Infl, 'lgs_passive', [node('NP', '-LGS', nt, [node('*', '', filler, [])])], VL).
ip_ppl_passive(Tag, Ext, Store, SbjFeat, Infl, L, [node(Tag, Ext, nt, [node('PP', '-LGS', nt, [NP, Role]) | VL]) | L]) -->
  verb_phrase_layer(Store, SbjFeat, Infl, 'lgs_passive', [], VL),
  lgs_role(Role),
  noun_phrase('', nt, 'non_privileged', [], [NP]).
ip_ppl_passive(Tag, Ext, Store, SbjFeat, Infl, L, [node(Tag, Ext, nt, VL) | L]) -->
  {
    ( Store = store([pp_lgs(ICH) | Left], Right)
    ; Store = store(Left, [pp_lgs(ICH) | Right])
    )
  },
  verb_phrase_layer(store(Left, Right), SbjFeat, Infl, 'lgs_passive', [node('PP', '-LGS', nt, [ICH])], VL).
ip_ppl_passive(Tag, Ext, Store, SbjFeat, Infl, L, [node(Tag, Ext, nt, VL) | L]) -->
  verb_phrase_layer(Store, SbjFeat, Infl, 'passive', [], VL).
ip_ppl_passive(Tag, Ext, Store, SbjFeat, Infl, L, [node(Tag, Ext, nt, [node('ILYR', '', nt, CL)]) | L]) -->
  ip_ppl_passive('ILYR', '', Store, SbjFeat, Infl, [], IL),
  ip_ppl_passive_tail(Store, SbjFeat, Infl, IL, CL).

ip_ppl_passive_tail(Store, SbjFeat, Infl, L, [node('CONJP', '', nt, IL) | L]) -->
  conj(CONJ),
  ip_ppl_passive('ILYR', '', Store, SbjFeat, Infl, [CONJ], IL).
ip_ppl_passive_tail(Store, SbjFeat, Infl, L0, L) -->
  punc('non_final', L0, L1),
  ip_ppl_passive('ILYR', '', Store, SbjFeat, Infl, [], IL),
  ip_ppl_passive_tail(Store, SbjFeat, Infl, [node('CONJP', '', nt, IL) | L1], L).

% Clause middle layer

clause_middle_layer(Store, SbjFeat, L0, L) -->
  verb_phrase_layer(Store, SbjFeat, 'finite', 'active', L0, L).
clause_middle_layer(Store, SbjFeat, L0, L) -->
  do_operator_layer(L0, L1),
  verb_phrase_layer(Store, SbjFeat, 'do_supported_infinitive', 'active', L1, L).
clause_middle_layer(Store, SbjFeat, L0, L) -->
  have_be_or_md_finite_layer(Code, L0, L1),
  verb_complements_top_layer(Code, Store, SbjFeat, 'active', L1, L).
clause_middle_layer(Store, SbjFeat, L0, L) -->
  adverb_phrase('-NIM', nt, 'established', L0, L1),
  clause_middle_layer(Store, SbjFeat, L1, L).
clause_middle_layer(Store, SbjFeat, L, [node('ILYR', '', nt, CL) | L]) -->
  clause_middle_layer(Store, SbjFeat, [], IL),
  clause_middle_tail(Store, SbjFeat, [node('ILYR', '', nt, IL)], CL).

clause_middle_tail(Store, SbjFeat, L, [node('CONJP', '', nt, [node('ILYR', '', nt, IL), CONJ]) | L]) -->
  conj(CONJ),
  clause_middle_layer(Store, SbjFeat, [], IL).
clause_middle_tail(Store, SbjFeat, L0, L) -->
  punc('non_final', L0, L1),
  clause_middle_layer(Store, SbjFeat, [], IL),
  clause_middle_tail(Store, SbjFeat, [node('CONJP', '', nt, [node('ILYR', '', nt, IL)]) | L1], L).

% CP-THT (that-clause)

cp_that(Ext, Node_type, Feat, Store, L, [node('CP-THT', Ext, Node_type, [node('IP-SUB', '', nt, IL)]) | L]) -->
  clause_that_layer(Feat, Store, [], IL).
cp_that(Ext, Node_type, Feat, Store, L, [node('CP-THT', Ext, Node_type, [node('IP-SUB', '', nt, [node('ILYR', '', nt, CL)])]) | L]) -->
  clause_that_layer(Feat, Store, [], IL),
  cp_that_tail(Feat, Store, [node('ILYR', '', nt, IL)], CL).

cp_that_tail(Feat, Store, L, [node('CONJP', '', nt, [node('ILYR', '', nt, IL), CONJ]) | L]) -->
  conj(CONJ),
  clause_that_layer(Feat, Store, [], IL).
cp_that_tail(Feat, Store, L0, L) -->
  punc('non_final', L0, L1),
  clause_that_layer(Feat, Store, [], IL),
  cp_that_tail(Feat, Store, [node('CONJP', '', nt, [node('ILYR', '', nt, IL)]) | L1], L).

clause_that_layer('with_c', Store, L0, L) -->
  comp(C),
  clause_top_layer('statement_order', Store, [C | L0], L).
clause_that_layer('without_c', Store, L0, L) -->
  clause_top_layer('statement_order', Store, L0, L).
clause_that_layer('without_c', store([np(ICH) | Left], Right), L0, L) -->
  {
    ( SbjFeat = 'filled_sbj' ; SbjFeat = 'derived_sbj' )
  },
  clause_middle_layer(store(Left, Right), SbjFeat, [node('NP', '-SBJ', nt, [ICH]) | L0], L).

% TO infinitive layer

to_inf_layer(Store, SbjFeat, Voice, L0, L) -->
  {
    Voice = 'active'
  },
  to(L0, L1),
  verb_phrase_layer(Store, SbjFeat, 'infinitive', Voice, L1, L).
to_inf_layer(Store, SbjFeat, Voice, L0, L) -->
  {
    Voice = 'passive'
  },
  to([node('NP', '-LGS', nt, [node('*', '', filler, [])]) | L0], L1),
  verb_phrase_layer(Store, SbjFeat, 'infinitive', 'lgs_passive', L1, L).
to_inf_layer(Store, SbjFeat, Voice, L0, L) -->
  {
    Voice = 'lgs_passive'
  },
  to(L0, L1),
  verb_phrase_layer(Store, SbjFeat, 'infinitive', Voice, L1, L).
to_inf_layer(Store, SbjFeat0, Voice, L0, L) -->
  {
    SbjFeat0 = 'unfilled_sbj',
    Voice = 'active'
  },
  conn(Conn),
  subject(SbjFeat, [Conn | L0], L1),
  to_inf_layer(Store, SbjFeat, Voice, L1, L).
to_inf_layer(Store, SbjFeat0, Voice, L0, L) -->
  {
    SbjFeat0 = 'unfilled_sbj',
    Voice = 'passive'
  },
  conn(Conn),
  noun_phrase('-LGS', nt, 'non_privileged', [Conn | L0], L1),
  to_inf_layer(Store, 'filled_sbj', 'lgs_passive', L1, L).
to_inf_layer(Store, SbjFeat0, Voice, L0, L) -->
  neg(L0, L1),
  to_inf_layer(Store, SbjFeat0, Voice, L1, L).
to_inf_layer(Store, SbjFeat, Voice, L, [node('ILYR', '', nt, CL) | L]) -->
  to_inf_layer(Store, SbjFeat, Voice, [], IL),
  to_inf_tail(Store, SbjFeat, Voice, [node('ILYR', '', nt, IL)], CL).

to_inf_tail(Store, SbjFeat, Voice, L, [node('CONJP', '', nt, [node('ILYR', '', nt, IL), CONJ]) | L]) -->
  conj(CONJ),
  to_inf_layer(Store, SbjFeat, Voice, [], IL).
to_inf_tail(Store, SbjFeat, Voice, L0, L) -->
  punc('non_final', L0, L1),
  to_inf_layer(Store, SbjFeat, Voice, [], IL),
  to_inf_tail(Store, SbjFeat, Voice, [node('CONJP', '', nt, [node('ILYR', '', nt, IL)]) | L1], L).

% CP-QUE (embedded question clause)

cp_embedded_que(Ext, Node_type, Store, L, [node('CP-QUE', Ext, Node_type, [node('IP-SUB', '', nt, IL)]) | L]) -->
  clause_embedded_que_finite_top_layer(Store, [], IL).
cp_embedded_que(Ext, Node_type, Store, L, [node('CP-QUE', Ext, Node_type, [node('IP-SUB', '', nt, [node('ILYR', '', nt, CL)])]) | L]) -->
  clause_embedded_que_finite_top_layer(Store, [], IL),
  cp_embedded_que_finite_tail(Store, [node('ILYR', '', nt, IL)], CL).

cp_embedded_que(Ext, Node_type, Store, L, [node('CP-QUE', Ext, Node_type, [node('IP-INF', '', nt, IL)]) | L]) -->
  clause_embedded_que_to_inf_top_layer(Store, [], IL).
cp_embedded_que(Ext, Node_type, Store, L, [node('CP-QUE', Ext, Node_type, [node('IP-INF', '', nt, [node('ILYR', '', nt, CL)])]) | L]) -->
  clause_embedded_que_to_inf_top_layer(Store, [], IL),
  cp_embedded_que_to_inf_tail(Store, [node('ILYR', '', nt, IL)], CL).

cp_embedded_que_finite_tail(Store, L, [node('CONJP', '', nt, [node('ILYR', '', nt, IL), CONJ]) | L]) -->
  conj(CONJ),
  clause_embedded_que_finite_top_layer(Store, [], IL).
cp_embedded_que_finite_tail(Store, L0, L) -->
  punc('non_final', L0, L1),
  clause_embedded_que_finite_top_layer(Store, [], IL),
  cp_embedded_que_finite_tail(Store, [node('CONJP', '', nt, [node('ILYR', '', nt, IL)]) | L1], L).

cp_embedded_que_to_inf_tail(Store, L, [node('CONJP', '', nt, [node('ILYR', '', nt, IL), CONJ]) | L]) -->
  conj(CONJ),
  clause_embedded_que_to_inf_top_layer(Store, [], IL).
cp_embedded_que_to_inf_tail(Store, L0, L) -->
  punc('non_final', L0, L1),
  clause_embedded_que_to_inf_top_layer(Store, [], IL),
  cp_embedded_que_to_inf_tail(Store, [node('CONJP', '', nt, [node('ILYR', '', nt, IL)]) | L1], L).

clause_embedded_que_finite_top_layer(Store, L0, L) -->
  comp_wq(C),
  clause_top_layer('statement_order', Store, [C | L0], L).
clause_embedded_que_finite_top_layer(store(Left, Right), L0, L) -->
  noun_phrase('', index(104), 'interrogative', L0, L1),
  clause_embedded_que_finite_lower_layer(store([np(node('*ICH*', '', index(104), [])) | Left], Right), L1, L).
clause_embedded_que_finite_top_layer(store(Left, Right), L0, L) -->
  {
    ( Ich = adjp(node('*ICH*', '', index(105), []))
    ; Ich = advp(node('*ICH*', '', index(105), []))
    )
  },
  interrogative_displaced_item('', index(105), Ich, L0, L1),
  clause_top_layer('statement_order', store([Ich | Left], Right), L1, L).
clause_embedded_que_finite_top_layer(Store, L0, L) -->
  adverb_phrase('-NIM', nt, 'interrogative', L0, L1),
  clause_top_layer('statement_order', Store, L1, L).

clause_embedded_que_finite_lower_layer(store([np(ICH) | Left], Right), L0, L) -->
  {
    ( SbjFeat = 'filled_sbj' ; SbjFeat = 'derived_sbj' )
  },
  clause_middle_layer(store(Left, Right), SbjFeat, [node('NP', '-SBJ', nt, [ICH]) | L0], L).
clause_embedded_que_finite_lower_layer(Store, L0, L) -->
  clause_top_layer('statement_order', Store, L0, L).

clause_embedded_que_to_inf_top_layer(Store, L0, L) -->
  comp_wq(C),
  to_inf_layer(Store, 'filled_sbj', 'active', [C | L0], L).
clause_embedded_que_to_inf_top_layer(store(Left, Right), L0, L) -->
  noun_phrase('', index(106), 'interrogative', L0, L1),
  to_inf_layer(store([np(node('*ICH*', '', index(106), [])) | Left], Right), 'filled_sbj', 'active', L1, L).
clause_embedded_que_to_inf_top_layer(store(Left, Right), L0, L) -->
  adverb_phrase('', index(107), 'interrogative', L0, L1),
  to_inf_layer(store([advp(node('*ICH*', '', index(107), [])) | Left], Right), 'filled_sbj', 'active', L1, L).
clause_embedded_que_to_inf_top_layer(Store, L0, L) -->
  adverb_phrase('-NIM', nt, 'interrogative', L0, L1),
  to_inf_layer(Store, 'filled_sbj', 'active', L1, L).

% notional item

notional_item(Ext, Store, L0, L) -->
  {
    ( Feat = 'with_c' ; Feat = 'without_c' )
  },
  cp_that(Ext, nt, Feat, Store, L0, L).
notional_item(Ext, Store, L0, L) -->
  cp_embedded_que(Ext, nt, Store, L0, L).
notional_item(Ext, Store, L0, L) -->
  ip_to_inf(Ext, nt, Store, L0, L).
notional_item(Ext, Store, L0, L) -->
  ip_ppl_active(Ext, nt, Store, 'filled_sbj', 'ing_participle', L0, L).

ip_to_inf(Ext, Node_type, Store, L, [node('IP-INF', Ext, Node_type, VL) | L]) -->
  to_inf_top_layer(Store, [], VL).

to_inf_top_layer(Store, L0, L) -->
  to_inf_layer(Store, 'unfilled_sbj', 'active', L0, L).
to_inf_top_layer(Store, L0, L) -->
  to_inf_layer(Store, 'filled_sbj', 'active', L0, L).

% subordinate conjunction clause

scon_clause(L, [node('PP-SCON', '', nt, [node('IP-ADV', '', nt, IL), Conn]) | L]) -->
  conn(Conn),
  clause_top_layer('statement_order', store([], []), [], IL).
scon_clause(L, [node('PP-SCON', '', nt, [node('IP-INF', '2', nt, VL), Conn]) | L]) -->
  conn(Conn),
  to_inf_layer(store([], []), 'filled_sbj', 'active', [], VL).
scon_clause(L, [node('PP-SCON', '', nt, [node('IP-INF', '', nt, VL), Conn]) | L]) -->
  conn(Conn),
  {
    ( SbjFeat = 'filled_sbj' ; SbjFeat = 'unfilled_sbj' )
  },
  to_inf_layer(store([], []), SbjFeat, 'passive', [], VL).
scon_clause(L, [node('PP-SCON', '', nt, [node('IP-PPL', '2', nt, IL), Conn]) | L]) -->
  conn(Conn),
  {
    ( Infl = 'hag_participle'
    ; Infl = 'en_participle'
    ; Infl = 'ing_participle'
    )
  },
  ip_ppl_adverbial_layer('filled_sbj', Infl, [], IL).
scon_clause(L, [node('PP-SCON', '', nt, [node('IP-PPL', '3', nt, IL), Conn]) | L]) -->
  conn(Conn),
  {
    ( Infl = 'hag_participle'
    ; Infl = 'en_participle'
    ; Infl = 'ing_participle'
    )
  },
  ip_ppl_adverbial_layer('unfilled_sbj', Infl, [], IL).

ip_ppl_adverbial_layer(SbjFeat0, Infl, L0, L) -->
  {
    SbjFeat0 = 'unfilled_sbj'
  },
  subject(SbjFeat, L0, L1),
  ip_ppl_adverbial_layer(SbjFeat, Infl, L1, L).
ip_ppl_adverbial_layer(SbjFeat, Infl, L0, L) -->
  {
    Infl = 'hag_participle'
  },
  [w('HAG', ';_cat_Ve_', Word)],
  ip_ppl_active('-CAT', nt, store([], []), SbjFeat, 'en_participle', [node('HAG', ';_cat_Ve_', pt, [node(Word, '', t, [])]) | L0], L).
ip_ppl_adverbial_layer(SbjFeat, Infl, L0, L) -->
  {
    Infl = 'ing_participle'
  },
  verb_phrase_layer(store([], []), SbjFeat, Infl, 'active', L0, L).
ip_ppl_adverbial_layer(SbjFeat, Infl, L0, L) -->
  {
    Infl = 'en_participle'
  },
  verb_phrase_layer(store([], []), SbjFeat, Infl, 'active', L0, L).
ip_ppl_adverbial_layer(SbjFeat, Infl, L0, [node('PP', '-LGS', nt, [NP, Role]) | L]) -->
  {
    Infl = 'en_participle'
  },
  verb_phrase_layer(store([], []), SbjFeat, Infl, 'lgs_passive', L0, L),
  lgs_role(Role),
  noun_phrase('', nt, 'non_privileged', [], [NP]).
ip_ppl_adverbial_layer(SbjFeat, Infl, L0, L) -->
  {
    Infl = 'en_participle'
  },
  verb_phrase_layer(store([], []), SbjFeat, Infl, 'lgs_passive', [node('NP', '-LGS', nt, [node('*', '', filler, [])]) | L0], L).
ip_ppl_adverbial_layer(SbjFeat, Infl, L0, L) -->
  {
    Infl = 'en_participle'
  },
  verb_phrase_layer(store([], []), SbjFeat, Infl, 'passive', L0, L).
ip_ppl_adverbial_layer(SbjFeat, Infl, L, [node('ILYR', '', nt, CL) | L]) -->
  ip_ppl_adverbial_layer(SbjFeat, Infl, [], IL),
  ip_ppl_adverbial_tail(SbjFeat, Infl, [node('ILYR', '', nt, IL)], CL).

ip_ppl_adverbial_tail(SbjFeat, Infl, L, [node('CONJP', '', nt, [node('ILYR', '', nt, IL), CONJ]) | L]) -->
  conj(CONJ),
  ip_ppl_adverbial_layer(SbjFeat, Infl, [], IL).
ip_ppl_adverbial_tail(SbjFeat, Infl, L0, L) -->
  punc('non_final', L0, L1),
  ip_ppl_adverbial_layer(SbjFeat, Infl, [], IL),
  ip_ppl_adverbial_tail(SbjFeat, Infl, [node('CONJP', '', nt, [node('ILYR', '', nt, IL)]) | L1], L).

% Relative clauses

relative_clause(L, [node('IP-REL', '', nt, IL) | L]) -->
  relative_clause_finite_top_layer([], IL).
relative_clause(L, [node('IP-INF-REL', '', nt, IL) | L]) -->
  relative_clause_to_inf_top_layer([], IL).
relative_clause(L0, L) -->
  ip_ppl_active('', nt, store([], []), 'filled_sbj', 'ing_participle', L0, L).
relative_clause(L0, L) -->
  ip_ppl_passive('IP-PPL', '', store([], []), 'filled_sbj', 'en_participle', L0, L).

relative_clause_finite_top_layer(L0, L) -->
  comp(C),
  relative_clause_finite_inside(store([np(node('*T*', '', filler, []))], []), [C | L0], L).
relative_clause_finite_top_layer(L0, L) -->
  noun_phrase('', index(108), 'relative', L0, L1),
  relative_clause_finite_inside(store([np(node('*ICH*', '', index(108), []))], []), L1, L).
relative_clause_finite_top_layer(L0, L) -->
  preposition_phrase('', index(109), 'relative', L0, L1),
  clause_top_layer('statement_order', store([pp(node('*ICH*', '', index(109), []))], []), L1, L).
relative_clause_finite_top_layer(L0, L) -->
  lgs_role(Role),
  noun_phrase('', nt, 'relative', [], [NP]),
  clause_top_layer('statement_order', store([pp_lgs(node('*ICH*', '', index(110), []))], []), [node('PP', '', index(110), [NP, Role]) | L0], L).
relative_clause_finite_top_layer(L0, L) -->
  preposition_phrase('-NIM', nt, 'relative', L0, L1),
  clause_top_layer('statement_order', store([], []), L1, L).
relative_clause_finite_top_layer(L0, L) -->
  adverb_phrase('', index(111), 'relative', L0, L1),
  clause_top_layer('statement_order', store([advp(node('*ICH*', '', index(111), []))], []), L1, L).
relative_clause_finite_top_layer(L0, L) -->
  adverb_phrase('-NIM', nt, 'relative', L0, L1),
  clause_top_layer('statement_order', store([], []), L1, L).
relative_clause_finite_top_layer(L0, L) -->
  clause_top_layer('statement_order', store([np(node('*T*', '', filler, []))], []), L0, L).
relative_clause_finite_top_layer(L0, L) -->
  clause_top_layer('statement_order', store([], []), [node('NP', '-NIM', nt, [node('*T*', '', filler, [])]) | L0], L).
relative_clause_finite_top_layer(L, [node('ILYR', '', nt, CL) | L]) -->
  relative_clause_finite_top_layer([], IL),
  relative_clause_finite_top_tail([node('ILYR', '', nt, IL)], CL).

relative_clause_finite_top_tail(L, [node('CONJP', '', nt, [node('ILYR', '', nt, IL), CONJ]) | L]) -->
  conj(CONJ),
  relative_clause_finite_top_layer([], IL).
relative_clause_finite_top_tail(L0, L) -->
  punc('non_final', L0, L1),
  relative_clause_finite_top_layer([], IL),
  relative_clause_finite_top_tail([node('CONJP', '', nt, [node('ILYR', '', nt, IL)]) | L1], L).

relative_clause_finite_inside(store([np(ICH) | Left], Right), L0, L) -->
  {
    ( SbjFeat = 'filled_sbj' ; SbjFeat = 'derived_sbj' )
  },
  clause_middle_layer(store(Left, Right), SbjFeat, [node('NP', '-SBJ', nt, [ICH]) | L0], L).
relative_clause_finite_inside(Store, L0, L) -->
  clause_top_layer('statement_order', Store, L0, L).

relative_clause_to_inf_top_layer(L0, L) -->
  preposition_phrase('', index(112), 'relative', L0, L1),
  to_inf_top_layer(store([pp(node('*ICH*', '', index(112), []))], []), L1, L).
relative_clause_to_inf_top_layer(L0, L) -->
  preposition_phrase('-NIM', nt, 'relative', L0, L1),
  to_inf_top_layer(store([], []), L1, L).
relative_clause_to_inf_top_layer(L0, L) -->
  to_inf_top_layer(store([np(node('*T*', '', filler, []))], []), L0, L).
relative_clause_to_inf_top_layer(L0, L) -->
  to_inf_layer(store([], []), 'filled_sbj', 'active', [node('NP', '-SBJ', nt, [node('*T*', '', filler, [])]) | L0], L).
relative_clause_to_inf_top_layer(L0, L) -->
  to_inf_top_layer(store([], []), [node('NP', '-NIM', nt, [node('*T*', '', filler, [])]) | L0], L).
relative_clause_to_inf_top_layer(L, [node('ILYR', '', nt, CL) | L]) -->
  relative_clause_to_inf_top_layer([], IL),
  relative_clause_to_inf_top_tail([node('ILYR', '', nt, IL)], CL).

relative_clause_to_inf_top_tail(L, [node('CONJP', '', nt, [node('ILYR', '', nt, IL), CONJ]) | L]) -->
  conj(CONJ),
  relative_clause_to_inf_top_layer([], IL).
relative_clause_to_inf_top_tail(L0, L) -->
  punc('non_final', L0, L1),
  relative_clause_to_inf_top_layer([], IL),
  relative_clause_to_inf_top_tail([node('CONJP', '', nt, [node('ILYR', '', nt, IL)]) | L1], L).

