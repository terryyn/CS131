type test_nonterminal =  |S | NP | VP | Verb | Noun
let accept_all derivation string  = Some(derivation, string)
let rec accept_lastnp derivation string = match derivation with
   | []-> Some(derivation, string)
   | h::t ->  match t with
        | [] -> if fst h = NP then Some(derivation, string) else None
        | _ -> accept_lastnp t string


let gram_fun = function
  | S -> [[N NP;N VP];[N NP; N VP ; N NP]]
  | NP -> [[N Noun;N Verb];[N Noun]]
  | VP -> [[N Verb; N Noun] ; [N Verb]]
  | Noun -> [[T "A"];[T "B"];[T "C"];[T "D"];[T "E"]]
  | Verb -> [[T "read"];[T "have"];[T "do"];[T "eat"]]

let test_grammar = (S, gram_fun)

let test_1 = parse_prefix test_grammar accept_all ["A";"read";"B"] = Some ([(S, [N NP; N VP]); (NP, [N Noun]); (Noun, [T "A"]); (VP, [N Verb; N Noun]);
(Verb, [T "read"]); (Noun, [T "B"])],[])



let test_2 = parse_prefix test_grammar accept_lastnp ["A";"read";"B"] = None
