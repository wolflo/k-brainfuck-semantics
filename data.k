requires "syntax.k"

module BRAINFUCK-DATA
  imports STRING
  imports BRAINFUCK-SYNTAX

  // convert first character of a string to an integer
  syntax Int ::= "ordHead" String [function]
  rule ordHead S => ordChar( substrString(S, 0, 1) )
    requires lengthString( S ) >Int 0
  rule ordHead S => 0
    requires lengthString( S ) ==Int 0

  // increment and decrement integers
  syntax Int ::= "inc" Env Int  [function, functional]
  rule inc ENV I => chop (I +Int 1) (#intSize ENV)
  syntax Int ::= "dec" Env Int  [function, functional]
  rule dec ENV I => chop (I -Int 1) (#intSize ENV)

  // overflow integers
  syntax Int ::= "chop" Int Int [function, functional]
  rule chop I ON => I
    requires I >=Int 0 andBool I <Int ON
  rule chop I ON => I %Int ON
    requires I >=Int ON
  rule chop I ON => chop (ON +Int I) ON
    requires I <Int 0

  // word sizes
  syntax Int ::= "pow8"
               | "pow32"
  rule pow8  => 256         [macro]
  rule pow32 => 4294967296  [macro]

  // Envs
  // TODO:
  // - memory size
  // - memory overflow behavior
  // - cell overflow behavior
  // - empty read behavior
  syntax Int ::= EnvInt "<" Env ">"   [function]
  syntax EnvInt ::= "MemorySize"
                  | "WordSize"

  syntax Bool ::= EnvBool "<" Env ">" [function]
  syntax EnvBool ::= "WrapMemory"

  syntax Int ::= "#intSize" Env [function]
  rule #intSize ENV => pow8  requires WordSize < ENV > ==Int 8
  rule #intSize ENV  => pow32  requires WordSize < ENV > ==Int 32

  syntax Int ::= "#memSize" Env [function]
  rule #memSize ENV => MemorySize < ENV >

  syntax Env ::= "DEFAULT"
  rule MemorySize   < DEFAULT > => 30000
  rule WordSize     < DEFAULT > => 8
  rule WrapMemory   < DEFAULT > => true

  syntax Env ::= "BIT32"
  rule WordSize < BIT32 > => 32

  syntax K ::= "#parseRuntime" String [function]
  rule #parseRuntime S => .K
    requires S ==String ""
  rule #parseRuntime S => (#parseCmd substrString(S, 0, 1)) ~> (#parseRuntime substrString(S, 1, lengthString(S)))
    requires S =/=String ""

  // TODO: find a cleaner way to do this
  syntax Cmd ::= "#parseCmd" String [function]
  rule #parseCmd "+" => +
  rule #parseCmd "-" => -
  rule #parseCmd ">" => >
  rule #parseCmd "<" => <
  rule #parseCmd "," => ,
  rule #parseCmd "." => .:Cmd

endmodule
