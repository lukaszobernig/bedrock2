Require Import coqutil.sanity coqutil.Macros.subst coqutil.Macros.unique.
Require Coq.Strings.String.
Require Import Coq.Numbers.BinNums.

Module Import bopname.
  Inductive bopname := add | sub | mul | mulhuu | divu | remu | and | or | xor | sru | slu | srs | lts | ltu | eq.
End bopname.
Notation bopname := bopname.bopname.

Module access_size.
  Variant access_size := one | two | four | word.
  Scheme Equality for access_size.
End access_size. Notation access_size := access_size.access_size.

Module expr.
  Inductive expr  : Type :=
  | literal (v: Z)
  | var (x: String.string)
  | load (_ : access_size) (addr:expr)
  | inlinetable (_ : access_size) (table: list Byte.byte) (index: expr)
  | op (op: bopname) (e1 e2: expr)
  | ite (c e1 e2: expr). (* if-then-else expression ("ternary if") *)

  Local Notation C0 := (expr.literal Z0).
  Local Notation C1 := (expr.literal (Zpos xH)).

  Notation not e := (expr.op bopname.eq e C0) (only parsing).

  Notation to_bool e := (expr.op bopname.ltu C0 e) (only parsing).

  (* lazy and/or always return 0 or 1 (like in C),
     even if (some of) their arguments are non-boolean *)

  Notation lazy_and e1 e2 := (ite e1 (to_bool e2) C0).
  Notation lazy_or e1 e2 := (ite e1 C1 (to_bool e2)).

End expr. Notation expr := expr.expr.

Module cmd.
  Inductive cmd :=
  | skip
  | set (lhs : String.string) (rhs : expr)
  | unset (lhs : String.string)
  | store (_ : access_size) (address : expr) (value : expr)
  | stackalloc (lhs : String.string) (nbytes : Z) (body : cmd)
  (* { lhs = alloca(nbytes); body; /*allocated memory freed right here*/ } *)
  | cond (condition : expr) (nonzero_branch zero_branch : cmd)
  | seq (s1 s2: cmd)
  | while (test : expr) (body : cmd)
  | call (binds : list String.string) (function : String.string) (args: list expr)
  | interact (binds : list String.string) (action : String.string) (args: list expr).
End cmd. Notation cmd := cmd.cmd.

Definition func : Type := String.string * (list String.string * list String.string * cmd).
#[deprecated(note="Use bedrock2.Syntax.func instead.")]
Notation function := func.
#[deprecated(note="Use bedrock2.Syntax.func instead.")]
Notation bedrock_func := func.

Module Coercions.
  Import String.
  Coercion expr.var : string >-> expr.
  Coercion expr.literal : Z >-> expr.
  Coercion name_of_func (f : func) := fst f.
End Coercions.
