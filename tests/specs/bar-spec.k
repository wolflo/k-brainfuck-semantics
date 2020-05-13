module BAR-SPEC
  imports BRAINFUCK

  rule
    <bf>
      <k>
        - > + <
      =>
        .K
      </k>
      <ptr>
        P:Int
      </ptr>
      <mem>
      // P |-> 5
      // P +Int 1 |-> (0 => 5)    // this works??
      // as long as we start with P +Int 1 initialized to 0
        P |-> (5 => 4)
        P +Int 1 |-> (0 => 1)
      </mem>
      <env> DEFAULT </env>
      <input> .List </input>
      <output> .List </output>
    </bf>
  requires P >=Int 0 andBool P <Int 29999

endmodule
