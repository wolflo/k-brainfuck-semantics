module BRAINFUCK-SYNTAX
  imports DOMAINS-SYNTAX

  syntax Cmd ::= "+"
              | "-"
              | ">"
              | "<"
              | ","
              | "."

  syntax While ::= "[" "]"
                | "[" Exp "]"

  syntax Exp ::= Cmd
               | While
               | Exp Exp [left]

endmodule
