[Brainfuck](https://en.wikipedia.org/wiki/Brainfuck) is a notoriously tiny programming language made up of eight commands:
- `+`: Increment the value of the current memory cell
- `-`: Decrement the value of the current memory cell
- `>`: increment the memory pointer
- `<`: decrement the memory pointer
- `[`: if the value of the current memory cell is zero, jump to the matching `]`. Else, continue to the next instruction
- `]`: if the value of the current memory cell is nonzero, jump back to the matching `[`. Else, continue to the next instruction


The [K framework](http://www.kframework.org/) is a "rewrite-based executable semantic framework in which programming languages, type systems and formal analysis tools can be defined". By defining the syntax and semantics of a language in K, you can derive a parser, interpreter, model checker, debugger, symbolic execution engine, and more.


This repo contains a K definition of the Brainfuck language as well as some example Brainfuck programs and specifications used to formally verify properties of these programs.


## Usage
The K tool is required, and can be built using the instructions [here](https://github.com/kframework/k) or installed from a [release](https://github.com/kframework/k/releases).

Build the semantics:
```
kompile brainfuck.k --backend {llvm|java|haskell}
```
The llvm backend is the default, and only supports concrete execution (`krun`). The Haskell backend only supports symbolic execution (`kprove`) and the java backend supports both, but is slowly being deprecated. If you run into issues, especially proving a spec, consider trying to `kompile` with a different backend. You will also need some different lemmas for proofs with the Haskell and Java backends.

Run a Brainfuck program:
```
krun tests/hello_world.bf
```
Note that the syntax definition currently does not support the "comments anywhere" standard used in Brainfuck, so comments will need to be removed or converted to C-style comments (`// comment`, `/* long comment */`).

Verify a formal specification of a program:
```
kprove tests/specs/concrete/proved/hello-world-spec.k
```

You may also want to include some [lemmas](tests/specs/lemmas.k) to allow K to reason about more complex programs:
```
kprove tests/specs/symbolic/draft/shift-spec.k --def-module LEMMAS
```

## Details
- [brainfuck.k](brainfuck.k) defines the semantics of the language
- [syntax.k](syntax.k) defines the syntax of the language
- [types.k](types.k) defines the types used in the semantics
- [data.k](data.k) defines helper functions used in the semantics


There are a [number](https://esolangs.org/wiki/Brainfuck#Implementation_issues) of different implementations for the Brainfuck language.
This implementation attempts to support most of these alternatives.
[types.k](types.k) contains definitions of `EnvInt` and `EnvBool` which can be used to determine the memory size, word size, whether to wrap memory or memory cells, and what to do when reading EOF.
Two example usages of these implementation changes are shown in [data.k](data.k).


The default implementation uses an 8-bit word size and 30000 cell memory size, wraps overflowed words, does not wrap overflowed memory (fails on memory over/underflow), and writes 0 to the current cell if input is empty on a read instruction.

## Resources and previous work
- K formalizations of several esoteric programming languages, including Brainfuck: [esolang-semantics](https://github.com/ellisonch/esolang-semantics)
- The semantics of the Ethereum Virtual Machine, which was used as the primary K reference: [evm-semantics](https://github.com/kframework/evm-semantics)
