requires "syntax.k"

module BRAINFUCK-TYPES
    imports BRAINFUCK-SYNTAX

  syntax Op ::= "INCVAL"
              | "DECVAL"
              | "INCPTR"
              | "DECPTR"
              | "READ"
              | "PRINT"
              | "LOOP" Exp

  syntax ErrorCode ::= ".ErrorCode"
                     | "EOF"
                     | "WORD_OVERFLOW"
                     | "MEMORY_OVERFLOW"

  // Envs
  syntax Env
  syntax Int ::= EnvInt "<" Env ">"   [function]
  syntax EnvInt ::= "MemorySize"
                  | "WordSize"
                  | "EOFValue"

  syntax Bool ::= EnvBool "<" Env ">" [function]
  syntax EnvBool ::= "WrapMemory"
                   | "WrapWords"
                   | "EOFNoOp"

endmodule
