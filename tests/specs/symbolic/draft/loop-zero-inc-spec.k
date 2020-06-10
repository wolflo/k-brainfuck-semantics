requires "../../lemmas.k"

module LOOP-ZERO-INC-SPEC
  imports BRAINFUCK

  rule
    <bf>
      <k>
        [ + ]
      =>
        .K
      </k>
      <ptr> P:Int </ptr>
      <mem>
        /* P |-> (N:Int => 0) */
        P |-> (N:Int => chop (N +Int 3) pow8)
      </mem>
      <env> DEFAULT </env>
      <input> .List </input>
      <output> .List </output>
    </bf>
  requires P >=Int 0 andBool P <Int 30000
    andBool N >=Int 253 andBool N <Int pow8
    /* andBool N ==Int 244 */

endmodule
