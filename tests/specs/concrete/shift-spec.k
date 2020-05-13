module SHIFT-SPEC
  imports BRAINFUCK

  rule
    <bf>
      <k>
        [->+<]
      =>
        .K
      </k>
      <ptr> 0:Int </ptr>
      <mem>
        0 |-> 255
      =>
        0 |-> 0
        1 |-> 255
      </mem>
      <env> DEFAULT </env>
      <input> .List </input>
      <output> .List </output>
    </bf>

endmodule
