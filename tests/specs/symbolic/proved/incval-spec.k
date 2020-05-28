module INCVAL-SPEC
  imports BRAINFUCK

  rule
    <bf>
      <k>
        +
      =>
        .K
      </k>
      <ptr> P:Int </ptr>
      <mem>
        P |-> N:Int
      =>
        P |-> chop (N +Int 1) pow8
      </mem>
      <env> DEFAULT </env>
      <input> .List </input>
      <output> .List </output>
    </bf>
  requires N >=Int 0 andBool N <Int 256
    andBool P >=Int 0 andBool P <Int 30000

endmodule
