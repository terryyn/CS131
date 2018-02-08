type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

let rec convert_rule x g = match g with 
| []->[]
| h::t -> if fst h = x then (snd h)::(convert_rule x t) else convert_rule x t;;


let convert_grammar g =
  fst g,fun nt -> convert_rule nt (snd g);;
 

let rec parse_prefix gram = 
    let rec rule_matcher rule_function  rule accept derivation frag =  match rule with 
            | [] -> accept derivation frag
            | head::rest -> match frag with (*have to match rule first or sometimes when the suffix is empty the function returns none instead of calling accpet *)
                | [] -> None
                | h::tail ->  match rule with
                        | [] -> None 
                        | (T t)::t_rule -> if h = t then rule_matcher rule_function t_rule accept derivation tail else None
                        | (N n)::t_rule -> matcher n rule_function (rule_function n) (rule_matcher rule_function t_rule accept) derivation frag
   
    and matcher symb rule_fun rule_list accept derivation frag = 
        match rule_list with 
            | []-> None 
            | h_rule::t_rule -> (* pass the rule into derivation if accepted *)
                let result = rule_matcher rule_fun h_rule accept (derivation@[symb,h_rule]) frag in
                match result with 
                    | None -> matcher symb rule_fun t_rule accept derivation frag
                    | Some n -> Some n
   in
   
   let rules = snd gram (fst gram)
   and rule_func = snd gram
   in 
   fun acceptor frag -> matcher (fst gram) rule_func rules acceptor [] frag
    
