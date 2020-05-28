requires "../../lemmas.k"

// fails on haskell backend with
// [Error] Critical: Haskell Backend execution failed with code 137 and produced no output
module SHIFT-SPEC
  imports BRAINFUCK

// need to convince prover that if a loop terminates, the value at P == 0

  rule
    <bf>
      <k>
        [ - > + < ]
      =>
        .K
      </k>
      <ptr> P </ptr>
      <mem>
        P |-> (M1 => 0)
        P +Int 1 |-> (M2 => chop (M2 +Int M1) pow8)
      </mem>
      <env> DEFAULT </env>
      <input> .List </input>
      <output> .List </output>
    </bf>
  requires
    P >=Int 0 andBool P <Int 29999
    andBool M1 >=Int 0 andBool M1 <Int pow8
    /* andBool M1 >=Int 5 andBool M1 <Int 8 */
    andBool M2 >=Int 0 andBool M2 <Int pow8

endmodule
