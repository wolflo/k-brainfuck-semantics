module INCPTR-SPEC
  imports BRAINFUCK

  rule
    <bf>
      <k>
        >
      =>
        .K
      </k>
      <ptr>
        P:Int
      =>
        P +Int 1
      </ptr>
      <mem> .Map </mem>
      <env> DEFAULT </env>
      <input> .List </input>
      <output> .List </output>
    </bf>
  requires P >=Int 0 andBool P <Int 29999

endmodule
