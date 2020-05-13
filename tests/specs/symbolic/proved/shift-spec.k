module SHIFT-SPEC
  imports BRAINFUCK

  rule
    <bf>
      <k>
        [ - > + < ]
      =>
        .K
      </k>
      <ptr> 0 </ptr>
      <mem>
        0 |-> N:Int
      =>
        0 |-> 0
        1 |-> N
      </mem>
      <env> DEFAULT </env>
      <input> .List </input>
      <output> .List </output>
    </bf>
  requires N >Int 0 andBool N <=Int 255

endmodule
