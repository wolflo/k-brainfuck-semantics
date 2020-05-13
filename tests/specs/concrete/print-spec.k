module PRINT-SPEC
  imports BRAINFUCK

  rule
    <bf>
      <k>
        .:Cmd
      =>
        .K
      ...</k>
      <ptr> 0:Int </ptr>
      <mem> 0 |-> 97 </mem>
      <env> DEFAULT </env>
      <input> .List </input>
      <output>
        .List
      =>
        ListItem("a")
      </output>
    </bf>

endmodule
