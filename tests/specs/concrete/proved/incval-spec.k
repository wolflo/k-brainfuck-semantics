module INCVAL-SPEC
  imports BRAINFUCK

  rule
    <bf>
      <k>
        +
      =>
        .K
      ...</k>
      <ptr> 0 </ptr>
      <mem>
        .Map
      =>
        0 |-> 1
      </mem>
      <env> DEFAULT </env>
      <input> .List </input>
      <output> .List </output>
    </bf>

endmodule
