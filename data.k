requires "syntax.k"
requires "types.k"

module BRAINFUCK-DATA
  imports STRING
  imports BRAINFUCK-SYNTAX
  imports BRAINFUCK-TYPES

  // convert first char of a string to an integer
  syntax Int ::= "ordHead" String [function]
  rule ordHead S => ordChar(substrString(S, 0, 1))
    requires lengthString(S) >Int 0
  rule ordHead S => 0
    requires lengthString(S) ==Int 0

  // increment integers
  syntax Int ::= "inc" Int        [function, functional]
  rule inc I => I +Int 1

  // decrement integers
  syntax Int ::= "dec" Int        [function, functional]
  rule dec I => I -Int 1

  // overflow integers
  syntax Int ::= "chop" Int Int   [function, functional]
  rule chop I ON => I
    requires I >=Int 0 andBool I <Int ON
  rule chop I ON => I %Int ON
    requires I >=Int ON
  rule chop I ON => chop (ON +Int I) ON   // I is negative
    requires I <Int 0

  syntax Bool ::= Int "<=" Int "<" Int   [function, functional]
  rule A <= I < B => I >=Int A andBool (I <Int B)

  // word sizes
  syntax Int ::= "pow8"
               | "pow32"
  rule pow8  => 256         [macro]
  rule pow32 => 4294967296  [macro]

  syntax Int ::= "#intSize" Env       [function]
  rule #intSize ENV => pow8   requires WordSizeBits < ENV > ==Int 8
  rule #intSize ENV => pow32  requires WordSizeBits < ENV > ==Int 32

  syntax Int ::= "#memSize" Env       [function]
  rule #memSize ENV => MemorySize < ENV >

  syntax Int ::= "#eofVal" Env        [function]
  rule #eofVal ENV => EOFValue < ENV >

  syntax Env ::= "DEFAULT"
  rule WordSizeBits < DEFAULT > => 8
  rule MemorySize   < DEFAULT > => 30000
  rule EOFValue     < DEFAULT > => 0
  rule WrapWords    < DEFAULT > => true
  rule WrapMemory   < DEFAULT > => false
  rule EOFNoOp      < DEFAULT > => false

  // an alternative Env example that doesn't wrap words or memory
  syntax Env ::= "NO_WRAP"
  rule X:EnvInt  < NO_WRAP > => X < DEFAULT >
  rule X:EnvBool < NO_WRAP > => X < DEFAULT >
    requires notBool X ==K WrapWords
    andBool (notBool X ==K WrapMemory)
  rule WrapWords  < NO_WRAP > => false
  rule WrapMemory < NO_WRAP > => false

endmodule
