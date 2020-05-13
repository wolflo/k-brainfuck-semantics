module LOOP-ZERO-INC-SPEC
  imports BRAINFUCK

  rule
    <bf>
      <k>
        [+]
      =>
        .K
      </k>
      <ptr> P:Int </ptr>
      <mem>
        P |-> (N:Int => 0)
      </mem>
      <env> DEFAULT </env>
      <input> .List </input>
      <output> .List </output>
    </bf>
  requires P >=Int 0 andBool P <Int 30000
    andBool N >=Int 0 andBool N <Int 256

endmodule
