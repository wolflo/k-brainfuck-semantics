module FOO-SPEC
  imports BRAINFUCK

  rule
    <k>
      , > + ,
    =>
      .K
    </k>
    <ptr>
      0
    =>
      1
    </ptr>
    <mem>
      .Map
    =>
      0 |-> 97
      1 |-> 0
    </mem>
    <env> DEFAULT </env>
    <input>
      ListItem("a")
    =>
      .List
    </input>
    <output> .List </output>
endmodule
