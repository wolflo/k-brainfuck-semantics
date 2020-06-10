module HELLO-WORLD-SPEC
  imports BRAINFUCK

  rule
    <bf>
      <k>
        + + + + + + + + [ > + + + + [ > + + > + + + > + + + > + < < < < - ] > + > + > - > > + [ < ] < - ] > > . > - - - . + + + + + + + . . + + + . > > . < - . < . + + + . - - - - - - . - - - - - - - - . > > + . > + + .
      =>
        .K
      </k>
      <ptr>
        0
      =>
        6
      </ptr>
      <mem>
        .Map
      =>
        0 |-> 0
        1 |-> 0
        2 |-> 72
        3 |-> 100
        4 |-> 87
        5 |-> 33
        6 |-> 10
      </mem>
      <env> DEFAULT </env>
      <input> .List </input>
      <output>
        .List
      =>
        ListItem("H")
        ListItem("e")
        ListItem("l")
        ListItem("l")
        ListItem("o")
        ListItem(" ")
        ListItem("W")
        ListItem("o")
        ListItem("r")
        ListItem("l")
        ListItem("d")
        ListItem("!")
        ListItem("\n")
      </output>
    </bf>

endmodule
