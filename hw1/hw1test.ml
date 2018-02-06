let my_subset_test0 = not (subset [3][2;4521;42])
let my_subset_test1 = subset [][2;4521;42]
let my_subset_test2 = subset [3][3]
let my_subset_test3 = subset [3;3;1][3;1]
let my_subset_test4 = not (subset [3][])


let my_equal_sets_test0 = equal_sets [] []
let my_equal_sets_test1 = not (equal_sets [2;4] [1])
let my_equal_sets_test0 = equal_sets [2;3;4;4;2] [2;3;4]
let my_equal_sets_test0 = not (equal_sets [4] [])


let my_set_union_test0 = equal_sets(set_union [] [])[]
let my_set_union_test1 = equal_sets(set_union [2;3;4;4] [2;2;2])[2;3;4]
let my_set_union_test2 = equal_sets(set_union [2] [1;3;4])[1;2;3;4]
let my_set_union_test3 = not (equal_sets(set_union [3;2;4] [1;3])[1;2;3])


let my_set_intersection_test0 = equal_sets (set_intersection [2;3;2][1])[]
let my_set_intersection_test1 = equal_sets (set_intersection [2;3;2][3;4])[3]
let my_set_intersection_test2 = equal_sets (set_intersection [2;3;2][2;3])[2;3]


							     
let my_set_diff_test0 = equal_sets (set_diff [1][1;3])[]
let my_set_diff_test1 = equal_sets (set_diff [4;2;4;2][1;3])[4;2]
let my_set_diff_test2 = equal_sets (set_diff [1;4;2;1][1;3])[4;2]


let my_computed_fixed_point_test0 = computed_fixed_point (=) (fun x -> 2*x-5) 5=5
let my_computed_fixed_point_test1 = computed_fixed_point (=) (fun x -> 3. *. x) 2. = infinity

let my_computed_periodic_point_test0 = computed_periodic_point (=) (fun x -> x - 5) 0 1 = 1 
let my_computed_periodic_point_test1 = computed_periodic_point (=) (fun x -> 2 *x - 2 ) 1 2 = 2

let my_while_away_test0 = while_away (( * ) 2) ((>) 13) 1 = [1;2;4;8]
let my_while_away_test1 = while_away (( + ) 2) ((<) 13) 10 = []
let my_while_away_test2 = while_away (( + ) 2) ((>) 12) 10 = [10]


let my_rle_decode_test0 = rle_decode[] = []
let my_rle_decode_test1 = rle_decode[3,4;0,1] = [4;4;4]
let my_rle_decode_test2 = rle_decode[2,"sda"] = ["sda";"sda"]


type test_nonterminals = | A | B | C | D
let test_rule =
[A, [T 'a'];
 A, [N B];
 A, [T 'a'; N C];
 B, [N B;T 'b'];
 C, [T 'c'];
 C, [T 'c';N B]]

 let test_grammar = A,test_rule
 let my_filter_blind_alleys_test0 = filter_blind_alleys test_grammar =
   ( A,[A,[T 'a']; A,[T 'a'; N C]; C, [T 'c']])
