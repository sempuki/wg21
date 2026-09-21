// Document formatting rules
// Requires the Noto font families (e.g. `brew install --cask
// font-noto-serif font-noto-sans font-noto-sans-mono`).
#let font-serif = "Noto Serif"
#let font-sans = "Noto Sans"
#let font-mono = "Noto Sans Mono"
#let font-size = 10pt

#let link-blue = rgb("#0000EE")
#let diff-green = rgb("#BAECBF")
#let diff-red = rgb("#F7D0CC")
#let quote-gray = rgb("#D1D9E0")
#let quote-stroke = 0.25em

#set page("us-letter", margin: 0.75in)
#set heading(numbering: "1.1 ")
#show heading: set block(below: 1em)
#show heading.where(level: 1): set block(above: 2.2em)
#show heading.where(level: 2): set block(above: 2em)
#show heading.where(level: 3): set text(size: 1.25em)
#show heading.where(level: 3): set block(above: 1.8em)
#show heading.where(level: 4): set text(size: 1.15em)
#show heading.where(level: 4): set block(above: 1.6em)
#set par(justify: true, spacing: 1.8em, leading: 0.8em)
#set text(
  size: font-size,
  font: font-serif,
  hyphenate: false,
)

#set list(marker: [--])
#show list: set block(above: 1.2em, below: 1.2em)

#show raw: set text(size: font-size, font: font-mono)
#show raw.where(block: true): set block(breakable: false)
#show raw.where(block: true): set par(leading: 0.65em)
#show raw.where(block: false): box

// prevent linebreak in the middle of grammar terms
#show emph: box

#show link: set text(fill: link-blue)
#show link: it => underline(stroke: link-blue, it)

#set quote(block: true)
#show quote: it => block(
  above: 1em,
  outset: (left: -quote-stroke, right: 0pt),
  inset: (left: 1em, y: 0.8em),
  stroke: (
    left: (
      thickness: quote-stroke,
      paint: quote-gray,
      cap: "round",
    ),
  ),
  it,
)


#set sub(baseline: 0em) // hacky!
#set highlight(top-edge: 8.5pt, bottom-edge: -2pt)
#set underline(stroke: (paint: black, thickness: 0.5pt), offset: 1.5pt)
#set strike(stroke: (paint: black, thickness: 0.5pt), offset: -2.5pt)

#let ins(body) = highlight(fill: diff-green, underline(body))
#let del(body) = highlight(fill: diff-red, strike(body))
#let replace(before, after) = del(before) + ins(after)
#let nobreak(body) = block(breakable: false, body)
#let eelis(section, ..p) = {
  let url = "https://eel.is/c++draft/" + section
  let txt = "[" + section + "]"
  if p.pos().len() > 0 {
    let pp = p.pos().map(str).join(".")
    url += "#" + pp
    txt += " paragraph " + pp
  }
  link(url, txt)
}
#let grammar(body) = par(
  justify: false,
  hanging-indent: 2em,
  text(font: font-sans, style: "oblique", body),
)

#set document(
  title: "Const/Mutable Extended Lambda Captures",
  author: ("Ryan McDougall", "Lakshay Garg"),
  keywords: ("C++29", "lambda", "capture", "mutable", "const"),
)
#title()
#table(
  columns: 2,
  inset: (left: 0%, y: 4pt),
  stroke: none,
  "Document", link("https://wg21.link/P2034")[P2034R9],
  "Date", datetime.today().display(),
  "Audience", "CWG",
  "Project", [ISO/IEC JTC1/SC22/WG21 14882: Programming Language -- C++],

  table.cell(rowspan: 2)[Authors],
  [Ryan McDougall `<mcdougall.ryan@gmail.com>`],
  [Lakshay Garg `<lakshayg.xyz@gmail.com>`],

  "GitHub Issue", link("https://wg21.link/P2034/github"),
  "Source", link("https://github.com/sempuki/wg21/tree/master/p2034"),
)

#outline(depth: 2)
#pagebreak()

// Table header highlight
#set table(
  stroke: 0.5pt,
  fill: (x, y) => if y == 0 { quote-gray },
)

#set heading(numbering: none, outlined: true)

= Revision History

#set heading(outlined: false)

== Changes from R8

- Added @sec-reference-lifetime[Section]: a `const&` capture can bind a temporary, whose lifetime then follows the
  closure object's. One question on how the wording reads across a return is put to CWG.
- Rebased the proposed wording from N5008 onto @N5054, and narrowed the declaration-order claim in
  @sec-remaining-gaps[Section] per @P3847.
- Corrected and tightened the standard citations throughout; no design change.

== Changes from R7: #link("https://wiki.isocpp.org/2026-06_Brno:EvolutionWorkingGroup:P2034R6")[EWG Discussion]

- Changed audience to CWG: EWG forwarded the paper for inclusion in C++29 (2026-06 Brno; polls above). The qualifier
  spellings are unchanged; EWG reached no consensus to allow or substitute `[=mutable]`, `[&const]`, or `[=const]`.
- Completed the proposed wording, drafting the previously deferred parts: the qualified capture-defaults, the
  logical-`const` specification of `[const&]`, and the non-implicit capture of `*this`. Unified the qualified by-copy
  member type with `auto` deduction, and added a "Wording Design" section as a guide to the normative changes.
- Dropped the restriction on `mutable` captures in `constexpr`/`consteval` lambdas as unnecessary
  (#eelis("expr.const") already governs it), and expanded the design discussion ("Recaptures", "Redundant Default
  Captures", "Const Capture By-reference").

== Changes from R6: #link("https://wiki.isocpp.org/2026-03_Croydon:EvolutionWorkingGroup:P2034R6")[EWG Discussion]

- Restructured the motivation into an initial const-correctness case and a subsequent symmetry-and-simplicity case.
- Added the "Lambdas Are Syntactic Sugar for Function Objects" argument, with standard, compiler, reflection, and
  implementation evidence.
- Committed const capture to a genuine `const` member (option 3) and unified the mutable and const NSDM type deduction.
- Added the capture-defaults matrix (`[const =]`, `[mutable =]`, `[const&]`).
- Specified const-reference capture as logical const, consistent with the unspecified representation of reference
  captures.
- Added "Consequences of a `const` Member" and "Teaching `const` Capture".
- TODO: complete the proposed wording for the capture-defaults and reference cases.

== Changes from R5: #link("https://wiki.isocpp.org/2025-11_Kona:EWGP2034Notes")[EWG Discussion]

- Incorporate extensions into the main proposal.
- Add discussion of capture defaults to the proposal.
- Rearranged some sections and updated links.
- Add wording for:
  - mutable captures
  - const-ref captures
  - const-ref capture-default
  - const specifier

== Changes from R4: #link("https://wiki.isocpp.org/2025-06_Sofia:NotesEWGP2034")[EWG Discussion]

- Implementation experience.

== Changes from R3: #link("https://wiki.isocpp.org/2024-03_Tokyo:NotesEWGIP2034R2")[EWG-I Discussion]

- Meta-motivation: safety and security -- const should be easier to get right and harder to get wrong.
- Cleaned up some examples.

== Changes from R2

- Update author email addresses.
- Rename `any_invocable` to `move_only_function`.

== Changes from R1

- Add discussion of const captures on move construction and assignment.
- Add vocabulary type `as_mutable`.
- Add alternative implementation strategy for const members.
- Selective move feature in top section.

== Changes from R0: #link("https://wiki.isocpp.org/2020-02_Prague:P2034R0SG17")[Concerns from EWG-I]

- Interactions with `this` pointer.
- Interactions with init-capture packs.
- Clarify const as it applies to pointers.
- Add const-reference use case.
- Expanded prose.

#pagebreak()

#set heading(outlined: true)

= Polls

#set heading(outlined: false)

== 2026-06 Brno, R7

D2034R7 should be modified to also allow `[=mutable]`, `[&const]`, and `[=const]` in addition to `[mutable=]`,
`[const&]`, and `[const=]`, with the same semantics respectively: _Not consensus_

#table(
  columns: 5,
  [SF], [F], [N], [A], [SA],
  [1], [2], [6], [8], [2],
)

D2034R7 should be modified to replace `[mutable=]`, `[const&]`, and `[const=]` with `[=mutable]`, `[&const]`, and
`[=const]` respectively: _Not consensus_

#table(
  columns: 5,
  [SF], [F], [N], [A], [SA],
  [2], [0], [9], [7], [1],
)

Forward D2034R7 (as on the wiki) to CWG for inclusion in C++29: _Consensus_

#table(
  columns: 5,
  [SF], [F], [N], [A], [SA],
  [4], [13], [2], [1], [2],
)

== 2026-03 Croydon, R6

P2034R6 should include default mutable captures: _Strong Consensus in favor_

#table(
  columns: 5,
  [SF], [F], [N], [A], [SA],
  [3], [28], [4], [0], [0],
)

P2034R6 should explore making const-capture equivalent to a const member: _Strong Consensus in favor_

#table(
  columns: 5,
  [SF], [F], [N], [A], [SA],
  [8], [25], [1], [2], [0],
)

Encourage more work in the direction of P2034R6: _Strong Consensus in favor_

#table(
  columns: 5,
  [SF], [F], [N], [A], [SA],
  [14], [26], [2], [0], [0],
)

== 2025-11 Kona, R5

We \[EWG\] encourage further work on this paper towards C++29: _Strong Consensus_

#table(
  columns: 5,
  [SF], [F], [N], [A], [SA],
  [21], [27], [5], [0], [0],
)

== 2025-06 Sofia, R4

EWG encourages more work in the direction of Partially Mutable Lambda Captures: _Consensus_

#table(
  columns: 5,
  [SF], [F], [N], [A], [SA],
  [1], [10], [4], [2], [1],
)

EWG encourages more work in the direction of Partially Mutable Lambda Captures, including extensions: _Stronger
consensus_

#table(
  columns: 5,
  [SF], [F], [N], [A], [SA],
  [2], [15], [3], [1], [0],
)

== 2024-03 Tokyo, R2

EWGI believes P2034R3 should include a `const` qualifier for lambda captures: _Barely consensus_ (Comment: motivation
could be better)

#table(
  columns: 5,
  [SF], [F], [N], [A], [SA],
  [2], [4], [4], [1], [0],
)

EWGI believes P2034R3 is sufficiently well developed, EWGI forwards it to EWG: _Consensus_

#table(
  columns: 5,
  [SF], [F], [N], [A], [SA],
  [3], [7], [0], [0], [0],
)

#pagebreak()

#set heading(numbering: "1.1 ", outlined: true)
#counter(heading).update(0)

= Background

Lambdas were introduced in @N2550, and while previous drafts (@N2529) considered mutable capture by value, the original
wording left captures entirely const. @N2658 restored mutability for _all_ captures by allowing the `mutable` keyword
on the call operator.

`std::move_only_function` (@P0288, C++23), and since then `std::copyable_function` (@P2548) and `std::function_ref`
(@P0792) in C++26, improved on `std::function` by respecting the `const` qualifier on their call signature (e.g.
`move_only_function<void(int) const>`). A `const`-qualified call type binds only to lambdas that are not marked
`mutable` (#eelis("func.wrap.move.ctor")).

A type is #link("https://isocpp.org/wiki/faq/const-correctness#mutable-data-members")["logically const"] when some of
its members (a cache, a mutex, an accumulator) can be mutated without changing the object's observable state; such
members are declared `mutable` so that a `const` object can still update them.

These standard types, and any other const-correct callable wrapper, cannot hold a logically const lambda today,
because a lambda has no way to declare a `mutable` member:

```cpp
move_only_function<void() const> f =
    [buf]() mutable { /* ... */ };  // error: a mutable lambda has a non-const call operator
```

= Initial Motivation: Const-correctness <sec-initial-motivation>

Type-erased callables like these are common in asynchronous systems. Users enclose their operations in lambdas and
place them in a concurrent queue to be processed elsewhere. Performance often matters in these systems, and an
operation may need its own mutable state: reusable scratch memory, or an accumulator carried across calls.

```cpp
struct MyRealtimeHandler {
  Callback callback_;
  State state_;
  mutable Buffer accumulator_;

  void operator()(Timestamp t) const {
    callback_(state_, accumulator_, t);
  }
};

concurrent::queue<move_only_function<void(Timestamp) const>> queue;
queue.push(MyRealtimeHandler{f, s});
```

Lambdas in such cases require workarounds: abandoning logical const correctness, abandoning ownership, or introducing
wrapper types that change how `const` propagates. Strict ownership matters because the handler runs asynchronously, and
const correctness matters for memory- and thread-safety.

However if we expand lambdas to allow mutable capture, then only the logically mutable non-static data members become
mutable, and the rest of the captures can remain const. The idea is illustrated below.

#table(
  columns: (1.1fr, 1fr),
  align: bottom,
  [Before], [After],
  [
    ```cpp
    struct A {
      State state;
      mutable Buffer buf;
      void operator()() const {
        // ...
      }
    };

    // manual bespoke type
    move_only_function<void() const> f =
      A{s, b};
    ```
  ],
  [
    ```cpp
    move_only_function<void() const> f =
      [s, mutable b] { /* ... */ };
    ```
  ],

  [
    ```cpp
    template <typename T>
    class as_owned_mutable {
      mutable T value;
     public:
      T& ref() const {
        return value;
      }
    };

    // new vocabulary type
    move_only_function<void() const> f =
      [s, b = as_owned_mutable<Buffer>{}]() {
        auto& buffer = b.ref();
        // ...
      };
    ```
  ],
  [
    ```cpp
    move_only_function<void() const> f =
      [s, mutable b] {

        // ...
      };
    ```
  ],

  [
    ```cpp
    // loss of const correctness
    move_only_function<void()> f =
      [s, b]() mutable {
        // ...
      };
    ```
  ],
  [
    ```cpp
    move_only_function<void() const> f =
      [s, mutable b] {
        // ...
      };
    ```
  ],

  [
    ```cpp
    // loss of ownership
    move_only_function<void() const> f =
      [s, buf_ptr = &b]() {
        // ...
      };
    ```
  ],
  [
    ```cpp
    move_only_function<void() const> f =
      [s, mutable b] {
        // ...
      };
    ```
  ],
)

The proposal lets programmers apply `const` to lambda captures precisely, where today they would either:

1. declare the whole lambda `mutable`, or
2. wrap individual captures in types that add or remove `const`.

A direct spelling improves the safety and security of such code, especially for programmers who know `const` but not
the wrapper idioms. Avoiding wrappers also keeps captures short and easier to read.

The reverse case (most captures modifiable, one `const`) benefits the same way. Today the choices are to leave the
would-be `const` capture modifiable, which is less safe, or to use `std::cref`, which gives up ownership (a lifetime
risk) and takes a more verbose spelling.

#table(
  columns: (1.3fr, 1fr),
  align: bottom,
  [Before], [After],
  [
    ```cpp
    template <typename T>
    class as_owned_const {
      T value;
     public:
      const T& ref() const {
        return value;
      }
    };

    // new vocabulary type
    move_only_function<void()> f =
      [s, b = as_owned_const<Buffer>{}] mutable {
        auto& buffer = b.ref();
        // ...
      };
    ```
  ],
  [
    ```cpp
    move_only_function<void()> f =
      [s, const b] mutable {
        // ...
      };
    ```
  ],

  [
    ```cpp
    // loss of const correctness
    move_only_function<void()> f =
      [s, b]() mutable {
        // b can be mutated
      };
    ```
  ],
  [
    ```cpp
    move_only_function<void()> f =
      [s, const b] mutable {
        // ...
      };
    ```
  ],

  [
    ```cpp
    // loss of ownership
    move_only_function<void()> f =
      [s, b = std::cref(buf)]() mutable {
        // ...
      };
    ```
  ],
  [
    ```cpp
    move_only_function<void()> f =
      [s, const b] mutable {
        // ...
      };
    ```
  ],
)

= Subsequent Motivation: Symmetry and Simplicity

Our initial motivation needs only a handful of `const`/`mutable` combinations. In subsequent meetings, however, EWG
expressed interest in symmetry and simplicity for their own sake, and asked the authors to investigate the design
space.

A recurring view in those discussions is that lambda syntax should be orthogonal to the other ways of declaring
callable types. The authors agree, and have investigated every combination of `const` and `mutable` on captures and on
the call operator.

= Design

All combinations are included for symmetry and conceptual simplicity, even where a combination does not yet have an
obviously strong use case of its own.

== Summary

`const` and `mutable` extend cleanly to lambda captures. The design is easy to implement, follows the language's
direction, and matches the common model of a lambda as shorthand for an object of a callable struct:

- By-copy captures can be prefixed by `const` or `mutable`, and this results in the non-static data member (NSDM)
  (#eelis("expr.prim.lambda.capture", 10)) being declared as `const` or `mutable` respectively, and initialized with the
  expression it captures. Specializing a capture with `const` or `mutable` this way is an opt-in request with
  predictable behavior (that is the same as if they had declared the callable type manually).

- By-reference captures do not necessarily generate non-static data members (NSDM), and are unaffected by the call
  operator qualification due to the shallow propagation of `const`. `const&` captures are useful as read-only views,
  but `mutable` references do not exist.

== Const Lambdas

A lambda's function call operator is already `const` (unless the lambda is declared `mutable` (#eelis(
  "expr.prim.lambda.closure",
  7,
))), but today this default cannot be spelled. We propose allowing it to be stated explicitly.

This introduces no new behavior; it makes the existing default explicit. It is self-documenting and completes the
symmetry with `mutable`: both qualifiers on the call operator can be written, just as both can now qualify a capture.

=== Syntax

```cpp
[]() const {}  // identical to []() {}
```

In the examples that follow, we write the call operator's qualifier explicitly for clarity.

== Mutable Capture By-copy

We propose a new form of by-copy capture called "mutable capture", which allows lambda captures to be `mutable`
qualified, as shown below. The standard mandates that by-copy captures create a non-static data member (NSDM) in the
closure type (#eelis("expr.prim.lambda.capture", 10)). A mutable capture, in addition to defining a NSDM, would have the
effect of declaring it `mutable`.

=== Syntax

#table(
  columns: (auto, 1fr),
  [Capture Syntax], [Description],
  [```cpp [mutable x]() const {}```], [simple capture of `x` by copy; the NSDM is `mutable`],
  [```cpp [mutable x...]() const {}```], [simple capture of pack `x`; each NSDM is `mutable`],
  [```cpp [mutable x = init]() const {}```], [init-capture initialized from `init`; the NSDM is `mutable`],
  [```cpp [mutable ...xs = init]() const {}```], [init-capture pack (@P0780); each NSDM is `mutable`],
)

=== Applicability

A mutable capture is permitted on a mutable lambda: well-formed, although redundant in effect. Note however that
```cpp [x]() mutable {}``` and ```cpp [mutable x]() mutable {}``` are different types.

#table(
  columns: (auto, 1fr, 1fr),
  align: horizon,
  fill: (x, y) => if x == 0 or y == 0 { quote-gray },
  [], [```cpp () const```], [```cpp () mutable```],

  [```cpp [x]```],
  [```cpp
  struct X {
    int x;
    void operator()() const;
  };
  ```],
  [```cpp
  struct X {
    int x;
    void operator()();
  };
  ```],

  [```cpp [mutable x]```],
  [```cpp
  struct X {
    mutable int x;
    void operator()() const;
  };
  ```],
  [```cpp
  struct X {
    mutable int x;
    void operator()();
  };
  ```],
)

== Const Capture By-copy <sec-const-bycopy>

We propose a new form of by-copy capture called "const capture", which allows lambda captures to be `const` qualified,
as shown below. The standard mandates that by-copy captures create a non-static data member (NSDM) in the closure type
(#eelis("expr.prim.lambda.capture", 10)). A const capture, in addition to defining a NSDM, would have the effect of
declaring it `const`.

=== Syntax

#table(
  columns: (auto, 1fr),
  [Capture Syntax], [Description],
  [```cpp [const x]() mutable {}```], [simple capture of `x` by copy; the NSDM is `const`],
  [```cpp [const x...]() mutable {}```], [simple capture of pack `x`; each NSDM is `const`],
  [```cpp [const x = init]() mutable {}```], [init-capture initialized from `init`; the NSDM is `const`],
  [```cpp [const ...xs = init]() mutable {}```], [init-capture pack (@P0780); each NSDM is `const`],
)

=== Applicability

A const capture is permitted on a const lambda: well-formed, although redundant in effect. Note however that
```cpp [x]() const {}``` and ```cpp [const x]() const {}``` are different types, and const members carry other
consequences: see @sec-const-consequences[Section].

#table(
  columns: (auto, 1fr, 1fr),
  align: horizon,
  fill: (x, y) => if x == 0 or y == 0 { quote-gray },
  [], [```cpp () const```], [```cpp () mutable```],

  [```cpp [x]```],
  [```cpp
  struct X {
    int x;
    void operator()() const;
  };
  ```],
  [```cpp
  struct X {
    int x;
    void operator()();
  };
  ```],

  [```cpp [const x]```],
  [```cpp
  struct X {
    const int x;
    void operator()() const;
  };
  ```],
  [```cpp
  struct X {
    const int x;
    void operator()();
  };
  ```],
)

== Mutable Capture By-reference <sec-mutable-byref>

We explicitly disallow capture of the form ```cpp [mutable& x]```: the grammar admits no such _simple-capture_, since
`mutable` references are not permitted by the language (#eelis("dcl.stc", 8)). It would also have nothing to do: the
call operator's `const` never reaches through a reference, so `[&x]` already modifies `x` on a `const` lambda.

Note that this is not the same as mutable capture of a reference type:

```cpp
T& x = ...;
auto f = [mutable x]() { }; // closure type gets a `mutable T x;` member
```

== Const Capture By-reference <sec-const-byref>

Capture by copy is made `const` by the call operator; capture by reference is not. Two things stand in the way:

First, the `const` on the call operator is _shallow_: it stops you from reassigning a captured pointer or reference, but
says nothing about what that pointer or reference binds to. Capturing a pointer declares a member of that pointer type
(#eelis("expr.prim.lambda.capture", 10)), so `const` qualifies the pointer, not its pointee.

```cpp
int i = 5;
int* p = &i;
auto l = [p]() const { *p = 0; };      // ok: const does not reach the pointee
auto x = [p]() const { p = nullptr; }; // error: the captured pointer is const
```

Second, a reference capture need not produce a member at all: the standard leaves unspecified whether one is declared
(#eelis("expr.prim.lambda.capture", 12)), and only by-copy captures are rewritten into member accesses (#eelis(
  "expr.prim.lambda.capture",
  11,
)), so there is nothing for `const` to attach to.

Capturing by `const` reference is nonetheless useful for read-only access to an object too large to copy, but today it
takes `std::cref` or `std::as_const`, neither as concise nor as discoverable as `const&`.

```cpp
auto a = [x = std::cref(x)] { return x.get().size(); };  // today: the member is a reference_wrapper
auto b = [const& x] { return x.size(); };                 // proposed
```

We therefore depart from analogy with struct members briefly, and define the meaning of `[const& x]` directly: within
the body, `x` is a `const` lvalue reference, and any nested lambda that re-captures it observes that `const` (see
@sec-recaptures[Section]). The usual reference-lifetime caveats apply (@sec-reference-lifetime[Section]). The call
operator's `const` is shallow on references, so it never reaches the referent, which is also why `[mutable&]` would
add nothing (@sec-mutable-byref[Section]).

=== Syntax

#table(
  columns: (auto, 1fr),
  [Capture Syntax], [Description],
  [```cpp [const& x]() mutable {}```], [simple capture of `x` by `const` reference],
  [```cpp [const& x...]() mutable {}```], [simple capture of pack `x`, each by `const` reference],
  [```cpp [const& x = init]() mutable {}```], [init-capture binding a `const` reference to `init`],
  [```cpp [const& ...xs = init]() mutable {}```], [init-capture pack (@P0780), each binding a `const` reference],
)

=== Applicability

Unlike the by-copy forms, a `const&` capture of a non-`const` object is never redundant. On a `const` lambda
```cpp [x]``` already stops the body from modifying `x`, so ```cpp [const x]``` adds nothing to what the body may do.
(It is not a no-op: the `const` lambda leaves the member itself non-`const`, so the two spellings still differ in the
member's type and in the closure's; see @sec-const-bycopy[Section] and @sec-const-consequences[Section].) A `const`
lambda does nothing at all for ```cpp [&x]```, because the call operator's `const` does not reach the referent, so `x`
stays modifiable. `[const& x]` is the only way to ask for a `const` view, and it asks for the same thing on either kind
of lambda. The cells below give the meaning of `x` in the body rather than a desugared `struct`, since a reference
capture need not declare a member to show.

#table(
  columns: (auto, 1fr, 1fr),
  align: horizon,
  fill: (x, y) => if x == 0 or y == 0 { quote-gray },
  [], [```cpp () const```], [```cpp () mutable```],

  [```cpp [&x]```], [`x` is a modifiable lvalue], [`x` is a modifiable lvalue],
  [```cpp [const& x]```], [`x` is a `const` lvalue], [`x` is a `const` lvalue],
)

The table assumes a non-`const` `x`, which is where the two forms differ. If `x` is itself `const`, ```cpp [&x]```
already binds a reference to `const` and ```cpp [const& x]``` means the same thing; the capture is then redundant
because the object is already `const`.

== Capture Defaults

The capture-defaults `[=]` and `[&]` may be qualified by `const` or `mutable`, applying the qualifier to every
implicitly-captured entity. For symmetry with the explicit reference default `[const&]`, the copy defaults are spelled
with an explicit `=`:

#table(
  columns: (auto, 1fr, 1fr),
  align: horizon,
  fill: (x, y) => if x == 0 or y == 0 { quote-gray },
  [], [`=` (by copy)], [`&` (by reference)],
  [(unqualified)], [```cpp [=]```], [```cpp [&]```],
  [`const`], [```cpp [const =]```], [```cpp [const&]```],
  [`mutable`], [```cpp [mutable =]```], [ill-formed],
)

`[const =]` captures every implicitly-captured entity by `const` copy, `[mutable =]` by `mutable` copy, and `[const&]`
by `const` reference. `[mutable&]` is ill-formed: the grammar admits no such _capture-default_, since `mutable`
references do not exist (#eelis("dcl.stc", 8)).

The current grammar admits only `&` and `=` as a _capture-default_ (#eelis("expr.prim.lambda.capture")). We extend it:

#grammar[
  capture-default: \
  capture-default-qualifier#sub[opt] \= \
  `const`#sub[opt] &
]

#grammar[
  capture-default-qualifier: \
  `const` \
  `mutable`
]

This is unambiguous: `const` and `mutable` are keywords, and the trailing `=` or `&` fixes the capture kind.

Following the C++20 deprecation of implicitly capturing `*this` under `[=]` (#eelis("depr.capture.this")), a qualified
capture-default does not implicitly capture `*this`; it must be captured explicitly:

```cpp
struct X {
  int x;
  void f() {
    auto a = [mutable =] { return x; };        // error: *this is not captured implicitly
    auto b = [mutable =, this] { return x; };  // OK: this captured explicitly
  }
};
```

A qualified capture-default applies its qualifier only to the entities it captures implicitly; an explicitly-listed
`this` or `*this` is captured by its own rules and is unaffected by the default's qualifier. Combined with
@sec-this[Section], where `this` and `*this` may not themselves be qualified, this settles every combination: an
explicitly-listed `this` or `*this` is captured as it is today whatever the default says, and a _qualified_ `this` or
`*this` is ill-formed wherever it appears.

```cpp
struct X {
  int x;
  void f() {
    auto a = [mutable =, this] { return x; };   // OK: implicit captures are mutable; this as today
    auto b = [const =, *this] { return x; };    // OK: implicit captures are const; *this copied as today
    auto c = [const&, *this] { return x; };     // OK: const-reference views; *this copied as today
    auto d = [mutable =, const this] { };       // error: this may not be qualified
    auto e = [const =, mutable *this] { };      // error: *this may not be qualified
  }
};
```

=== Redundant Default Captures

Today, `[=, x]` is ill-formed: under the `=` default `x` is already captured by copy, so naming it again by copy is
redundant, and the language rejects it (#eelis("expr.prim.lambda.capture", 2)). We keep that principle and extend it to
the qualified defaults.

The default governs everything captured _implicitly_; an explicit capture in the same list overrides it for one named
entity and carries its own qualifier; and the single thing you cannot write is an explicit capture that does _exactly_
what the default already does. Under each default the one redundant (and therefore ill-formed) form is:

#table(
  columns: (auto, 1fr),
  fill: (x, y) => if y == 0 { quote-gray },
  [Capture-default], [Redundant (ill-formed) explicit capture],
  [```cpp [=]```], [```cpp [=, x]```],
  [```cpp [mutable =]```], [```cpp [mutable =, mutable x]```],
  [```cpp [const =]```], [```cpp [const =, const x]```],
  [```cpp [&]```], [```cpp [&, &x]```],
  [```cpp [const&]```], [```cpp [const&, const& x]```],
)

Pairing each of the five capture-defaults with the five ways to write a single named capture (`x`, `mutable x`,
`const x`, `&x`, `const& x`) gives twenty-five combinations: the five above are redundant, and the other twenty
compose, with an explicit capture overriding the default for its own entity and carrying its own qualifier. A few:

#table(
  columns: (auto, 1fr),
  fill: (x, y) => if y == 0 { quote-gray },
  [Capture], [Effect],
  [```cpp [mutable =, const x]```], [implicit captures mutable; `x` a `const` member],
  [```cpp [const =, mutable x]```], [implicit captures `const`; `x` mutable],
  [```cpp [=, &x]```], [captured by copy; `x` by reference],
  [```cpp [&, x]```], [captured by reference; `x` a copy],
  [```cpp [const&, x]```], [`const`-reference views; `x` a copy],
  [```cpp ...```], [...],
)

So a default carries the common case while one entity is named as the exception, without spelling out every capture by
hand. This is the case raised in @sec-initial-motivation[Section]: most captures modifiable, one `const`, or the
reverse.

== Captures of `this` <sec-this>

A capture may name either `this` or `*this`. Both denote the same entity, the object `*this`
(#eelis("expr.prim.lambda.capture", 4)), but they capture it differently. `[this]` captures it _by reference_: a
capture of that form is not a capture by copy (#eelis("expr.prim.lambda.capture", 10, 2)), and the standard leaves
unspecified whether a member is declared for it at all (#eelis("expr.prim.lambda.capture", 12)). `[*this]` captures it
_by copy_, declaring an unnamed non-static data member of the enclosing class type
(#eelis("expr.prim.lambda.capture", 10)). We recommend disallowing `const` and `mutable` on all four spellings
(`[const this]`, `[mutable this]`, `[const *this]`, and `[mutable *this]`) until experience is accrued.

`[mutable this]` aside, these are deferrals: the qualifier would mean what it means everywhere else in this paper, and
the obstacle is only the wording we would have to write for a capture with no demonstrated demand.

#table(
  columns: (auto, 1fr, 1fr),
  align: horizon,
  fill: (x, y) => if x == 0 or y == 0 { quote-gray },
  [], [what the qualifier would mean], [why not now],

  [```cpp [mutable this]```],
  [nothing: `[this]` captures by reference, and the call operator's `const` never reaches the referent, so the
    enclosing object is already modifiable],
  [the same reason `[mutable& x]` is not proposed (@sec-mutable-byref[Section]): there is nothing for it to do, and
    `mutable` references do not exist (#eelis("dcl.stc", 8))],

  [```cpp [const this]```],
  [a `const` view of the enclosing object, as `[const& x]` gives for a named `x`],
  [it would need a direct definition of the kind `[const& x]` needs (@sec-const-byref[Section]), but for an entity the
    body reaches implicitly rather than by name],

  [```cpp [const *this]```, ```cpp [mutable *this]```],
  [a `const` or `mutable` copy of the object, as `[const x]` and `[mutable x]` give for a named `x`],
  [that copy is an unnamed member, reached by rewriting each odr-use of `*this`
    (#eelis("expr.prim.lambda.capture", 11)) rather than through an _id-expression_, so the const-propagation wording
    this paper threads through #eelis("expr.prim.id.unqual", 4) and the nested re-capture rule
    (#eelis("expr.prim.lambda.capture", 14)) would not reach it without a special case. `mutable` would need no such
    wording, but we would rather defer both than admit one qualifier on `*this` and not the other],
)

Deferring costs little: both requests already have a spelling under this proposal.

```cpp
struct X {
  int x;
  void f() {
    auto a = [const& self = *this] { return self.x; };  // a `const` view of the enclosing object
    auto b = [const self = *this] { return self.x; };   // a `const` copy of it
    auto c = [const this] { return x; };                // ill-formed: this may not be qualified
  }
};
```

If those _init-captures_ see use, a later paper can add the shorter spellings; nothing here prevents that.

== Deducing the NSDM Type

A by-copy capture requires a non-static data member (#eelis("expr.prim.lambda.capture", 10)); the question is its type.
The two existing capture forms deduce it by different rules. This proposal changes neither, and leaves an unqualified
by-copy capture exactly as it is today; it settles only which of the two rules a _qualified_ capture should follow.

A _simple-capture_ keeps the captured entity's type, retaining its cv-qualifiers: the member type is the referenced type
if the entity is a reference to an object, an lvalue reference to the referenced function type if it is a reference to a
function, and the entity's type otherwise (#eelis("expr.prim.lambda.capture", 10)). Capturing a `const T` therefore
yields a `const` member. This is deliberate. @CWG756 (whose title states the question it raised) asked whether a
closure member should drop the captured entity's cv-qualifiers, and @N2927 resolved that it should not, giving such a
member "the type of the corresponding captured entity". Capture is therefore cv-faithful, so that
`decltype`, overload resolution, and template argument deduction inside the lambda agree with the enclosing scope.

An _init-capture_ instead behaves "as if it declares ... a variable of the form `auto` _init-capture_ `;`" (#eelis(
  "expr.prim.lambda.capture",
  6,
)), so its type is deduced by `auto`, which strips top-level cv-qualifiers and references (#eelis(
  "dcl.type.auto.deduct",
  3,
), #eelis("temp.deduct.call", 2, 3)).

The two rules, side by side:

#table(
  columns: (auto, 1fr, 1fr),
  align: horizon,
  fill: (x, y) => if x == 0 or y == 0 { quote-gray },
  [Entity type of `x`], [```cpp [x]``` (simple-capture)], [```cpp [y = x]``` (init-capture)],
  [```cpp T```], [```cpp T```], [```cpp T```],
  [```cpp const T```], [```cpp const T```], [```cpp T```],
  [```cpp volatile T```], [```cpp volatile T```], [```cpp T```],
  [```cpp T&```], [```cpp T```], [```cpp T```],
  [```cpp const T&```], [```cpp const T```], [```cpp T```],
  [```cpp T(&)()```], [```cpp T(&)()```], [```cpp T(*)()```],
)

The `const T&` row is the rule @sec-recaptures[Section] depends on: a copy taken of a `const` view is itself `const`.

=== `mutable const T`

Applying `mutable` to the cv-preserving simple-capture type can instead yield an ill-formed `mutable const T` --
consider for example the following (which is easy to reach in generic code or after a refactor):

```cpp
const int x = 5;
auto f = [mutable x]() { x = 0; };  // ??
```

Because an init-capture deduces by `auto`, it is not affected by this problem: `[mutable x = e]` is
`mutable auto x = e;`, and `[const x = e]` is `const auto x = e;`. `auto` never produces a top-level `const`, so
`mutable` never collides with one.

That leaves two candidate rules for a qualified simple-capture:

#table(
  columns: (auto, auto, 1fr, 1fr),
  align: horizon,
  [Entity type of `x`], [Capture], [(1) preserve cv-qualifiers], [(2) deduce by `auto`],
  [```cpp T```], [```cpp [mutable x]```], [```cpp mutable T```], [```cpp mutable T```],
  [```cpp T```], [```cpp [const x]```], [```cpp const T```], [```cpp const T```],
  [```cpp const T```], [```cpp [const x]```], [```cpp const T```], [```cpp const T```],
  [```cpp const T```], [```cpp [mutable x]```], [`mutable const T` (ill-formed)], [```cpp mutable T```],
  [```cpp volatile T```], [```cpp [mutable x]```], [```cpp mutable volatile T```], [```cpp mutable T```],
)

1. Simple-capture: _preserve the entity's cv-qualifiers, then add the requested qualifier_. Adding `mutable` over a
  `const` entity forms `mutable const T`, which is ill-formed; the rule would simply accept the error. This is
  faithful to cv-preservation but surprising and fragile: whether `[mutable x]` compiles depends on a cv-qualifier the
  author may not control.
2. Init-capture: _deduce by `auto` rules, then apply the requested qualifier_, exactly as an init-capture does. `auto`
  deduction drops any top-level cv-qualifiers, so `mutable` never collides with a `const`; `const` then adds one. This
  is uniform across both qualifiers and both capture forms.

=== The Adopted Rule

We adopt (2). A programmer who writes `mutable` or `const` on a capture is requesting a customization, so faithfully
preserving the source cv-qualifiers (the simple-capture default) is neither expected nor useful. Deducing as an
init-capture does makes a qualified simple-capture and the corresponding init-capture produce the same member, and
removes the `mutable const T` hazard.

For an entity of type `T`:

- `mutable` produces a `mutable` member of type `std::remove_cvref_t<T>`, and
- `const` produces a member of type `const std::remove_cvref_t<T>`.

Stripping all top-level cv-qualifiers, `volatile` included, is exactly what `auto` deduction does, so a qualified
simple-capture and the corresponding init-capture deduce the same member type even for a `volatile` entity. The one
exception is a reference to a function, which the type rule settles before the qualified branches apply: the
simple-capture keeps a reference, while the init-capture decays to a pointer.

The qualifier is a genuine member qualifier: the closure is exactly the struct a programmer would hand-write, so
`decltype`, overload resolution, and reflection (@P2996) all observe the real member type.

== Recaptures <sec-recaptures>

`[const& x]` gives the body a `const` view of the original object. Nesting raises the question of what an _inner_
lambda sees when it re-captures `x`:

```cpp
auto outer = [const& x] {          // x is a const view of the original
  auto inner = [x] { /* ... */ };  // inner makes its own copy of x
};
```

`inner` copies `x`, and because it copies from a `const` view the copy is itself `const`, by the same long-standing
rule (@CWG756, @N2927) that makes `[x]` of a `const` variable produce a `const` member. The consequence shows when the
inner lambda is `mutable`:

```cpp
auto outer = [const& x] {
  auto inner = [x]() mutable { x = 0; };   // ill-formed: inner's copy is const
};
```

Letting `inner` mutate its own copy would contradict the `const` view `[const& x]` promised one line above. The
original object is untouched either way, but a modifiable copy appearing from a `const` capture is the kind of surprise
`const` exists to prevent. The `const` carries through any depth of nesting, including through intervening
plain-reference captures: a `[const& x]` several levels out still yields a `const` copy at the bottom.

None of the following are special cases; each follows from two facts: a `const`-reference view is `const`, and a copy
of a `const` view is `const`. The first column is the nesting, read outermost-to-innermost; the second is what the
innermost `x` is.

#table(
  columns: (auto, auto, 1fr),
  align: (left, left, left),
  [Nesting], [Innermost `x`], [Why],
  [```cpp [const& x]{ x; }```], [`const` lvalue], [the `const`-reference view],
  [```cpp [const& x]{ [&x]{ x; } }```], [`const` lvalue], [the view stays `const` through nesting],
  [```cpp [const& x]{ [x]{ x; } }```], [`const` copy], [a copy of a `const` view is `const`],
  [```cpp [const& x]{ [x]() mutable { x = 0; } }```], [ill-formed], [the `const` copy cannot be made mutable],
  [```cpp [const& x]{ [&x]{ [x]() mutable {} } }```], [`const` copy], [`const` carries through the plain-`&` middle],
  [```cpp [&x]{ [x]() mutable { x = 0; } }```], [OK], [no `const&` anywhere; an ordinary modifiable copy],
)

`[const& x]` behaves the same on a `const` or a `mutable` lambda, because the `const` belongs to the view of the
object rather than to a member supplied by the call operator. And because there is no by-copy member, there is nothing
to move or copy when the closure is moved, subject to the usual reference-lifetime caveat.

== Reference Captures of Temporaries <sec-reference-lifetime>

`[const& x = init]` can bind to a temporary. The language already permits this, but it is newly easy to write: today it
takes an initializer that is already `const` (say, a function returning `const T`), since `auto&` will not bind to a
non-`const` prvalue, which is why ```cpp [&x = f()]``` is normally an error. `[const& x = bar()]` works with any
ordinary `bar()`. This proposal turns an obscure corner into an idiomatic spelling, so the lifetime question deserves
an answer, and, as the end of this section shows, a warning.

```cpp
const Foo cf();                 // returns a `const` prvalue
Foo f();                        // returns an ordinary prvalue

auto a = [&x = cf()] { };       // the corner that exists today: `auto&` deduces `const Foo&`, which binds
auto b = [&x = f()] { };        // error today: `auto&` will not bind to a non-`const` prvalue
auto c = [const& x = f()] { };  // proposed: binds, whatever `f` returns
```

The answer follows from the existing rules. An _init-capture_ behaves as if it declares a variable of the form `auto`
_init-capture_ `;`, and for a capture by reference "the variable's lifetime ends when the closure object's lifetime
ends" (#eelis(
  "expr.prim.lambda.capture",
  6,
)); a temporary bound to that reference persists for the lifetime of the reference (#eelis("class.temporary", 6)). The
temporary therefore lives exactly as long as the closure object whose _init-capture_ created it.

```cpp
{
  auto f = [const& v = bar()] { use(v); };
  f();                    // OK: the temporary is alive for as long as f is
}                         // f destroyed, then the temporary
```

Three consequences follow, and they settle the questions this form raises:

- *The temporary belongs to one closure object.* It is tied to the closure whose _init-capture_ created it; the closure
  type and any copies get no claim on it.
- *Copying extends nothing.* A copy binds its own reference directly to the same object. Lifetime extension applies
  where a reference binds to a _temporary_ (#eelis("class.temporary", 6)); binding a further reference to an
  already-bound object is not such a case and does not lengthen anything.
- *A copy that outlives the original dangles.* The temporary dies with the original closure, leaving any surviving copy
  referring to a destroyed object, the ordinary consequence of a reference outliving its referent.

The dangerous case is returning such a closure:

```cpp
auto make() {
  return [const& v = bar()] { use(v); };  // the temporary does not survive the return
}

auto g = make();
g();                                      // dangling
```

By guaranteed copy elision the closure object is the caller's, but the temporary was materialized in the callee's frame
and is destroyed when `make` returns. This is diagnosable, and is diagnosed: for the spelling reachable today, Clang
reports _"returning address of local temporary object"_ with the note _"captured by reference via initialization of
lambda capture"_. GCC does not accept that spelling at all (it rejects ```cpp [&x = g()]``` for a `const`-returning
`g`, though it accepts the equivalent ```cpp auto& x = g();```), so the existing form is barely exercised. The same
happens without lambdas, though: a returned aggregate with a reference member bound to a temporary loses that temporary
at the return, on both GCC and Clang. This is how reference lifetime behaves across a return generally, and closures
merely inherit it.

We would welcome CWG's view on how the wording is meant to be read here. Taken literally, it appears to say something
else: if the returned closure object's lifetime is the caller's, then so is the _init-capture_ variable's (#eelis(
  "expr.prim.lambda.capture",
  6,
)), and the temporary bound to it persists for the lifetime of that reference (#eelis("class.temporary", 6)), which
would require the temporary to outlive the frame it was materialized in. We may be reading it wrongly. If we are not,
it seems better handled as a core issue than as part of this paper. Either way the behavior is reachable in C++26 and
is not introduced by this proposal; we raise it because this proposal makes it much easier to encounter.

== Interaction with `consteval` and `constexpr` Lambdas

A `mutable` capture raises no new question for a `constexpr` or `consteval` lambda. Mutating and reading local state
during constant evaluation has been allowed since C++14 (@N3652), and a `mutable` data member is part of that: a
function object with a `mutable` member can be evaluated at compile time today:

```cpp
struct Counter {
  mutable int n = 0;
  constexpr int operator()() const { return ++n; }
};

constexpr int f() {
  Counter c;
  return c() + c();          // reads and writes the mutable member at compile time
}
static_assert(f() == 3, ""); // OK since C++14
```

The lambda spelling has worked since lambdas became usable in constant expressions in C++17: an ordinary `mutable`
lambda already holds state it mutates and reads.

```cpp
constexpr int g() {
  auto counter = [n = 0]() mutable { return ++n; };
  return counter() + counter();
}
static_assert(g() == 3);     // OK since C++17
```

Writing `[mutable n]` declares the same kind of member as the `mutable` lambda above and behaves the same way. The one
case that does not work, reading a `mutable` member of an object that already existed before the evaluation began,
fails for a hand-written `mutable` member in exactly the same way. So a `mutable` capture needs no rule of its own, and
this paper adds none.

== Implementation Experience

Ville Voutilainen implemented an earlier revision of this proposal in GCC as a proof of concept, with regression tests,
and reported:

#quote[
  In general, the implementation was very straightforward, after discussing the approach with the maintainer, and coming
  to the conclusion that it's simply a matter of adjusting the types of the capture members of lambda for const, and the
  storage-class-specifier for mutable. The implementation effort was a matter of a single afternoon.
]

The change reduces to adjusting capture-member types and storage-class-specifiers, which is itself evidence for
@thesis[Section]: the closure is already a class, and the proposal only sets qualifiers on its members. The
implementation is available on #link("https://github.com/villevoutilainen/gcc/tree/lambda-p2034")[GitHub] and can be
tried on #link("https://godbolt.org/z/9fcoYeMMf")[Compiler Explorer].

= Concerns

== Consequences of Const Members <sec-const-consequences>

Because a const capture makes the member genuinely `const`, it carries the ordinary consequences of a `const` data
member, and nothing lambda-specific. A `const` member is copied rather than moved by the defaulted move constructor,
because a `const` object cannot be moved from. The move constructor initializes each member from the corresponding
member of an xvalue referring to its parameter (#eelis("class.copy.ctor", 15)), so a `const M` member yields a
`const M` xvalue, which cannot bind to `M(M&&)` (#eelis("class.copy.ctor", 9)); the copy constructor is selected
instead.

The closure's move constructor is therefore `noexcept` only when the member's _copy_ constructor is, which, for any
type whose copy allocates, it is not. Containers notice: `std::vector` reallocation uses `move_if_noexcept`, so a
closure holding a `const` member whose copy can throw (e.g. `std::string`) is copied, not moved, on every growth:

```cpp
auto concatWith(const std::string x) {  // note the const
  return [x] (std::string y) {          // deduces a `const std::string` NSDM, as `[const x]` would
    return x + y;
  };
}

int main() {
  using Concat = decltype(concatWith(""));
  std::vector<Concat> concats;
  concats.emplace_back(concatWith("A"));
  concats.emplace_back(concatWith("B")); // vector realloc: all elements are copied.
  concats.emplace_back(concatWith("C")); // if Concat had a nothrow move ctor, this
  concats.emplace_back(concatWith("D")); // would have been a move instead.
}
```

This regression is not introduced by the proposal: `[x]` of a `const std::string` already produces a `const` member with
exactly this behavior today (@CWG756, @N2927). A const capture only makes the request explicit. Two further
consequences follow from the same class rule:

- *Assignment.* A `const` member also deletes copy and move assignment (#eelis("class.copy.assign", 7)). This is inert
  while lambdas delete assignment regardless (#eelis("expr.prim.lambda.closure", 17)), but @P3963 (approved by EWG)
  restores it for ordinary captures; a const capture then correctly opts back out, exactly as a `const` member of a
  hand-written callable would.
- *Move-only captures.* For a move-only captured type the `const` member cannot be copied (the type is move-only) and
  cannot be moved (a `const` object can only be copied from), so the closure is non-movable. This is a diagnosed error
  at the use site rather than a silent pessimization.

For instance, const-capturing a `unique_ptr` yields a closure that cannot be stored in a `move_only_function`:

```cpp
move_only_function<int()> f =
  [const p = std::make_unique<int>(42)] { return *p; };
  // error: the closure has a const std::unique_ptr<int> member, which can be
  //        neither moved (it is const) nor copied (unique_ptr is move-only),
  //        so the closure is non-movable and move_only_function cannot store it.
```

These are the ordinary properties of a `const` member, faithfully modeled (@thesis[Section]). The alternative, a
non-`const` member behind a `const` spelling, would trade a teachable rule for a hidden one.

== Teaching Const Capture

`const` capture behaves as a `const` member because it is one; the rules for using it well are the rules for any `const`
member.

- Use `const` capture for owned state that is genuinely immutable. Its cost is the cost of a `const` member, no more
  and no less.
- A closure headed for a reallocating container, or one that must be assignable, pays for a `const` capture of an
  expensive-to-copy type on every move; if that cost matters, do not `const`-capture that member.
- Never `const`-capture a move-only type you must move out of; the closure becomes non-movable.
- To read an object without owning a copy, capture by `const` reference rather than by `const` value; there is then no
  member to move, subject to the usual reference-lifetime caveat.
- "`const` within the body but a movable member" is a different feature (logical rather than physical `const`), and
  `[const x]` does not mean it; spelling it `const` would give the keyword two meanings.

== East v. West Const

In both East-`const` (`int const x`) and West-`const` (`const int x`) styles, the `const` appears before the
identifier; `[const x]` is consistent with both.

== Pointer to Const v. Const Pointer

Current lambda behavior mandates bitwise `const`: qualifying a captured pointer yields a `const` pointer, and the
pointee stays writable. The captured member has the captured entity's type (#eelis("expr.prim.lambda.capture", 10)), so
the `const` applies to the pointer. This proposal continues that rule and does not modify it.

```cpp
auto c = [const x = ptr]() {
  *x = {};      // ok
  x = nullptr;  // error
};
```

== Static Call Operator

A lambda whose call operator is `static` (#link("https://wg21.link/p1169")[P1169]) has no object parameter and may not
have a _lambda-capture_ (#eelis("expr.prim.lambda.general", 4)), so a `const` or `mutable` capture cannot co-occur with
a `static` call operator; the combination is ill-formed.

```cpp
auto f = [const x]() static { };  // ill-formed: static permits no captures
```

= Lambdas Are Syntactic Sugar for Function Objects <thesis>

C++ has converged on lambdas as sugar for a hand-written function object; this proposal only lets the sugar express
qualifications the desugared class already supports.

1. *The standard specifies the closure as a class.*
  - #eelis("expr.prim.lambda.closure", 1) -- "a unique, unnamed non-union class type"
  - #eelis("expr.prim.lambda.capture", 10), @CWG756 as resolved by @N2927 -- by-copy captures are non-static data
    members that retain the entity's cv-qualifiers
  - #eelis("expr.prim.lambda.closure", 7) -- the call operator is a member; special members are "implicitly defined as
    usual"
  - #eelis("expr.prim.lambda.capture", 6), @N3610, @N3648 -- an init-capture is defined as an `auto` variable
    declaration
  - @N3649 -- a generic lambda's call operator is a member template

2. *Compilers represent it as a class.*
  - Clang: the closure is a `CXXRecordDecl`, each capture a `FieldDecl`, the call operator a `CXXMethodDecl` (#link(
      "https://clang.llvm.org/doxygen/classclang_1_1CXXRecordDecl.html",
    )[CXXRecordDecl], #link("https://clang.llvm.org/doxygen/ASTLambda_8h_source.html")[ASTLambda.h])
  - GCC: Ville Voutilainen's proof-of-concept for this proposal was "adjusting the types of the capture members ... and
    the storage-class-specifier for mutable" -- "a single afternoon" (#link(
      "https://github.com/villevoutilainen/gcc/tree/lambda-p2034",
    )[branch])

3. *Reflection exposes the captures as ordinary members.*
  - @P2996 -- `nonstatic_data_members_of` enumerates a closure's captures; `type_of` and `is_mutable_member` report each
    member's type and `mutable`-ness
  - if a capture spelled `const` did not produce a `const` member, reflection would report the wrong type, so the
    member must be real

4. *Each revision has closed a gap with ordinary classes, never opened one.*
  - @CWG756, @N2927 -- cv-faithful capture members (C++11)
  - @N3649, @N3610, @N3648 -- generic lambdas and init-captures (C++14)
  - @P0428, @P0780 -- explicit template parameters for generic lambdas, and pack-expansion init-captures (C++20)
  - @P0624 -- captureless lambdas default-constructible and assignable (C++20)
  - @P2996 -- reflection over closure members (C++26)
  - @P3847 -- explicit captures declared in lexical order (C++29)
  - @P3963 -- copy and move assignment for captured lambdas (EWG-approved, pending CWG)

5. *It is the orthogonal design.*
  - `const`, `mutable`, and reference qualifiers mean on a capture exactly what they mean on a member. There is no
    separate set of lambda rules to learn; the function object the lambda lowers to already defines them

You can run this code today:

```cpp
#include <experimental/meta>
#include <iostream>

template <typename L, std::size_t I>
void print_capture() {
    constexpr auto ctx = std::meta::access_context::unchecked();
    constexpr auto m   = std::meta::nonstatic_data_members_of(^^L, ctx)[I];
    constexpr auto t   = std::meta::type_of(m);
    if constexpr (std::meta::is_mutable_member(m))
        std::cout << "mutable ";
    std::cout << std::meta::display_string_of(t) << '\n';
}

template <typename L>
void print_captures() {
    constexpr auto ctx  = std::meta::access_context::unchecked();
    constexpr auto size = std::meta::nonstatic_data_members_of(^^L, ctx).size();
    std::cout << "capture count: " << size << '\n';
    [&]<std::size_t... I>(std::index_sequence<I...>) {
        (print_capture<L, I>(), ...);
    }(std::make_index_sequence<size>{});
}

int main() {
    auto lam = [x = 42, y = 3.14, z = true]() { return x; };
    print_captures<decltype(lam)>();
    return 0;
}
```

(#link("https://godbolt.org/z/K8xYP47sP")[Compiler Explorer]: x86-64 clang, `-freflection-latest -std=c++26`)

This proposal completes the model the language has converged on since C++11: it lets the programmer spell the `const`
and `mutable` members the desugared function object could always have held.

== Remaining Gaps <sec-remaining-gaps>

The standard deliberately withholds three structural guarantees an ordinary class would give:

1. the declaration order of capture members is unspecified, except that members introduced for explicit captures
  follow the order of those captures (#eelis("expr.prim.lambda.capture", 15)),
2. the implementation may vary their size, alignment, trivial-copyability, and standard-layout-ness
  (#eelis("expr.prim.lambda.closure", 4)), and
3. the closure type is not an aggregate (#eelis("expr.prim.lambda.closure", 4)).

None of this is in tension with `const` capture meaning a `const` member: the cv-qualification of a member is a semantic
property, independent of where the member sits or whether the type is an aggregate.

Beyond those structural freedoms, a closure is not interchangeable with a hand-written function object in three further
ways.

1. *Special members, with captures.* A closure with captures has no default constructor and a deleted copy assignment
  operator (#eelis("expr.prim.lambda.closure", 17)); a hand-written struct would have both defaulted. This paper leaves
  these properties alone, and the language is already closing them on the same trajectory as everything else:
  captureless lambdas gained them in C++20 (@P0624), and @P3963 would restore assignment for captured lambdas.
2. *Anonymity.* A closure type is unique and unnamable: it cannot be forward-declared, and a programmer cannot add data
  members, member functions, base classes, or constructors to it. This is inherent to a lambda being an _expression_
  rather than a class definition; the sugar generates a fixed shape.
3. *The conversion a struct lacks.* A captureless closure converts to a function pointer (#eelis(
    "expr.prim.lambda.closure",
    11,
  )), a divergence in the opposite direction: an affordance no plain struct has.

The thesis is that the closure _is_ a class with a function object's member semantics, and that `const` and `mutable`
on a capture should mean what they mean on a member. A lambda is still not a way to write an arbitrary class; these
residual differences are what make it worth having.

= Wording Design

The feature is small, and so is most of the wording: in the common case it sets a cv-qualification and a
storage-class-specifier on members the closure already declares. This section is a guide to how the normative changes
are organized and why they take the shape they do. It covers the design of the _wording_, as distinct from the design
of the feature above. It is written for readers following the proposed wording closely.

The changes touch five subclauses:

- #eelis("expr.prim.id.unqual"): the type of a name that resolves to a `const`-reference capture;
- #eelis("expr.prim.lambda.general"): the `const` _lambda-specifier_;
- #eelis("expr.prim.lambda.closure"): a note that the `const` _lambda-specifier_ has no effect;
- #eelis("expr.prim.lambda.capture"): the bulk, covering grammar, the qualified members, the capture-default rules, and
  nested re-capture; and
- #eelis("cpp.predefined"): the feature-test macro.

== The by-copy member carries most of the feature

By-copy capture already declares a non-static data member for each capture (#eelis("expr.prim.lambda.capture", 10)); all
this proposal adds there is that member's cv-qualification and whether it is `mutable`. That one paragraph does most of
the work.

The member type is stated as prose rather than as `std::remove_cvref_t<T>`, because #eelis("expr") cannot depend on the
library. The two qualified cases reduce to a single helper: from the existing cv-faithful captured type _U_, form _V_ by
removing top-level cv-qualifiers; a mutable capture yields _V_ (declared `mutable`), a const capture yields
`const`-qualified _V_. _V_ is exactly what `auto` deduction produces, which is why a qualified simple-capture and the
corresponding init-capture agree, except for a reference to a function, which the first sentence of the type rule
settles before _V_ is reached.

Two terms, _captured mutably_ and _captured by const copy_, are defined there rather than inlined, because two later
places refer to them: the member's `mutable` storage class and the nested re-capture rule (#eelis(
  "expr.prim.lambda.capture",
  14,
)). Each term is defined over both the explicit capture (the _capture_ begins with the keyword) and the implicit
capture (the qualified _capture-default_), so one term serves both `[mutable x]` and `[mutable =]`.

Function references are the one by-copy capture whose member is a reference rather than a value. A reference member can
be neither `const`-qualified nor `mutable` (#eelis("basic.type.qualifier", 1), #eelis("dcl.stc", 8)), so the qualifier
is simply inert there. The type rule needs no exception, since it settles the function-reference case before reaching
the qualified branches; the `mutable` storage class excludes it explicitly, and a note records why.

== The `const` specifier and the specifier constraints

The `const` _lambda-specifier_ introduces no behavior (the call operator is already `const` unless `mutable` or
`static` is present), so the closure-type wording gains only a note saying so (#eelis("expr.prim.lambda.closure", 7)),
and the specifier constraints in #eelis("expr.prim.lambda.general", 4) gain only the entry forbidding `const` alongside
an explicit object parameter and the mutual exclusion of `const`, `mutable`, and `static`.

== `const&` has no member to qualify

A reference capture need not create a member at all (#eelis("expr.prim.lambda.capture", 12)), so `const` has nothing to
attach to. The `const` is therefore a property of the name's _type_, and the one place that already determines the type
of a captured name is #eelis("expr.prim.id.unqual", 4). We add a paragraph there: when a name resolves to an entity
captured by `const` reference anywhere in the enclosing chain of lambdas, its type is `const`-qualified.

We add a separate paragraph rather than widen the existing by-copy rule. Widening was tried, by changing that rule's
trigger from "captured by copy" to "captured", and it breaks: the rule names "the member that the capture would
create" in the innermost capturing lambda, and a reference capture creates no member, so the rule contradicts itself
whenever that innermost lambda captures by reference. Keeping the by-copy rule untouched and adding a parallel rule for
the reference case avoids the contradiction.

Re-capture is where this needs care. The behavior (a copy of a `const` view is itself `const`, to any nesting depth)
is described in @sec-recaptures[Section]; the wording achieves it in the re-capture rule (#eelis(
  "expr.prim.lambda.capture",
  14,
)), which propagates the `const` by asking whether the entity would have `const`-qualified type within the enclosing
lambda, a question it answers through #eelis("expr.prim.id.unqual"). That phrasing is what carries the `const` through
any number of plain-reference intermediaries, but it also makes the two paragraphs refer to each other. The reference is
well-founded: each step moves one lambda outward and terminates at the outermost. Still, it is the part of the wording
most worth a second look, and CWG may prefer to restate it as a single inductive definition.

== Capture-defaults reduce to one redundancy rule

The existing #eelis("expr.prim.lambda.capture", 2) forbids an explicit capture that matches the _capture-default_,
phrased two ways: a prohibition for `&`, a whitelist for `=`. With qualifiers, the clean generalization is a single
prohibition, that an explicit _simple-capture_ may not capture an entity in exactly the way the default already would.
This reproduces today's diagnostics, treats all five defaults uniformly, and leaves combinations like
`[mutable =, const x]` well-formed, which a whitelist would not.

The qualified defaults also do not implicitly capture `*this` (#eelis("expr.prim.lambda.capture", 7)), continuing the
direction of the C++20 deprecation; the unqualified `=` and `&` are unchanged.

== What needed no wording

Some cases are handled by omission. The grammar offers no production for a qualified `this` or `*this`, so
`[const this]` and the like are ill-formed with no constraint required. The representation of reference captures remains
unspecified, so `[const&]` declares no member and needs no member wording. And the `const` _lambda-specifier_, being
inert, changes no rule beyond the note added above.

A `mutable` capture on a `constexpr` or `consteval` lambda likewise needs no constraint of its own; the existing rules
in #eelis("expr.const") already settle it. The lvalue-to-rvalue conversion that reads a member is permitted, among other
cases, on "a non-volatile glvalue of literal type that refers to a non-volatile object whose lifetime began within the
evaluation of _E_" (#eelis("expr.const.core", 2, 10, 3)), an allowance not conditioned on the `mutable` qualifier, so
a `mutable` member is readable whenever the closure was constructed within the evaluation, the usual case for a
closure built and called in one constant expression. A `mutable` subobject is excluded only from the _other_ allowance
(#eelis("expr.const.core", 2, 10, 2)), for a glvalue referring to an object "usable in constant expressions": the
definition of _potentially usable in constant expressions_ admits only a "non-mutable subobject"
(#eelis("expr.const.init", 8, 5)), so a `mutable` member of a closure that already existed before the evaluation
cannot be read.
Both outcomes match a hand-written `mutable` member, so an unmarked but constexpr-suitable lambda is left to fail
naturally at use rather than at declaration.

The lifetime of a temporary bound by a `const&` capture also needs no wording of its own
(@sec-reference-lifetime[Section]). An _init-capture_ is already specified as a variable declaration
(#eelis("expr.prim.lambda.capture", 6)), so the ordinary rule for a reference bound to a temporary
(#eelis("class.temporary", 6)) reaches it unchanged; this proposal widens what such a capture can bind to, not how long
the bound object lives. One reading of those two rules together, for the case where the closure is returned, is put to
CWG in that section.

#set heading(numbering: none, outlined: true)

= Proposed Wording

Changes are relative to @N5054, using the #ins[insert] and #del[strike] convention.

== [expr.prim.id.unqual]

#nobreak[
  === Change #eelis("expr.prim.id.unqual", 4)
  #quote[
    If
    - the _unqualified-id_ appears in a _lambda-expression_ at program point P,
    - the entity is a local entity or a variable declared by an _init-capture_,
    - naming the entity within the _compound-statement_ of the innermost enclosing _lambda-expression_ of P, but not in
      an unevaluated operand, would refer to an entity captured by copy in some intervening _lambda-expression_, and
    - P is in the function parameter scope, but not the _parameter-declaration-clause_, of the innermost such
      _lambda-expression_ _E_,

    then the type of the expression is the type of a class member access expression naming the non-static data member
    that would be declared for such a capture in the object parameter of the function call operator of _E_.

    \[_Note 3:_ If _E_ is not declared `mutable` #ins[and the entity is not captured mutably (#eelis(
        "expr.prim.lambda.capture",
      )) by _E_], the type of such an identifier will typically be `const` qualified. --- _end note_\]
  ]
]

#nobreak[
  === Add a paragraph after #eelis("expr.prim.id.unqual", 4)
  #quote[
    #ins[Otherwise, if
      - the _unqualified-id_ appears in a _lambda-expression_ at program point P,
      - the entity is a local entity or a variable declared by an _init-capture_,
      - naming the entity within the _compound-statement_ of the innermost enclosing _lambda-expression_ of P, but not
        in an unevaluated operand, would refer to an entity captured by const reference (#eelis(
          "expr.prim.lambda.capture",
        )) in some intervening _lambda-expression_, and
      - P is in the function parameter scope, but not the _parameter-declaration-clause_, of the innermost such
        _lambda-expression_,

      then the type of the expression is the `const`-qualified type of the entity.]
  ]
]

== [expr.prim.lambda.general]

=== Change #eelis("expr.prim.lambda.general")
#quote[#grammar[
  lambda-specifier: \
  `consteval` \
  `constexpr` \
  #ins[`const`] \
  `mutable` \
  `static`
]]

=== Change #eelis("expr.prim.lambda.general", 4)
#quote[
  A _lambda-specifier-seq_ shall contain at most one of each _lambda-specifier_ and shall not contain both `constexpr`
  and `consteval`. If the _lambda-declarator_ contains an explicit object parameter, then no _lambda-specifier_ in the
  _lambda-specifier-seq_ shall be #ins[`const`,] `mutable`, or `static`. The _lambda-specifier-seq_ shall #del[not
    contain both `mutable` and `static`] #ins[contain at most one of `const`, `mutable`, or `static`]. If the
  _lambda-specifier-seq_ contains `static`, there shall be no _lambda-capture_.
]

== [expr.prim.lambda.closure]

#nobreak[
  === Add a note to #eelis("expr.prim.lambda.closure", 7)
  #quote[
    ... It is a non-static member function or member function template that is declared `const` if and only if the
    _lambda-expression_'s _parameter-declaration-clause_ is not followed by `mutable` and the _lambda-declarator_ does
    not contain an explicit object parameter. ...

    #ins[\[_Note_: The `const` _lambda-specifier_ has no additional effect; the function call operator is declared
      `const` if and only if `mutable` and `static` are not specified, regardless of whether `const` is present. ---
      _end note_\]]
  ]
]

== [expr.prim.lambda.capture]

=== Change #eelis("expr.prim.lambda.capture")
#quote[
  #grammar[
    capture-default: \
    #ins[capture-default-qualifier#sub[opt]] \= \
    #ins[`const`#sub[opt]] &
  ]

  #grammar[
    #ins[capture-default-qualifier:] \
    #ins[`const`] \
    #ins[`mutable`]
  ]

  #grammar[
    simple-capture: \
    #ins[`mutable`#sub[opt]] identifier ...#sub[opt] \
    #ins[`const` identifier ...#sub[opt]] \
    #ins[`const`#sub[opt]] & identifier ...#sub[opt] \
    this \
    \*this
  ]

  #grammar[
    init-capture: \
    #ins[`mutable`#sub[opt]] ...#sub[opt] identifier initializer \
    #ins[`const` ...#sub[opt] identifier initializer] \
    #ins[`const`#sub[opt]] & ...#sub[opt] identifier initializer
  ]
]

#nobreak[
  === Change #eelis("expr.prim.lambda.capture", 2)
  #quote[
    #del[If a _lambda-capture_ includes a _capture-default_ that is `&`, no identifier in a _simple-capture_ of that
      _lambda-capture_ shall be preceded by `&`. If a _lambda-capture_ includes a _capture-default_ that is `=`, each
      _simple-capture_ of that _lambda-capture_ shall be of the form "`&` _identifier_ ...#sub[_opt_]", "`this`", or
      "`* this`".]
    #ins[If a _lambda-capture_ includes a _capture-default_, no _simple-capture_ of that _lambda-capture_ shall be of
      the form]
    #ins[
      - "_identifier_ ...#sub[_opt_]" if the _capture-default_ is `=`,
      - "`mutable` _identifier_ ...#sub[_opt_]" if the _capture-default_ is `mutable =`,
      - "`const` _identifier_ ...#sub[_opt_]" if the _capture-default_ is `const =`,
      - "`&` _identifier_ ...#sub[_opt_]" if the _capture-default_ is `&`, or
      - "`const &` _identifier_ ...#sub[_opt_]" if the _capture-default_ is `const &`.
    ]
  ]
]

#nobreak[
  === Change #eelis("expr.prim.lambda.capture", 6)
  #quote[
    An _init-capture_ inhabits the lambda scope of the _lambda-expression_. An _init-capture_ without ellipsis behaves
    as if it declares and explicitly captures a variable of the form "`auto` _init-capture_ `;`" #ins[ignoring any
      leading `mutable` keyword], except that:

    - if the capture is by copy (see below), the non-static data member declared for the capture and the variable are
      treated as two different ways of referring to the same object, which has the lifetime of the non-static data
      member, and no additional copy and destruction is performed, and
    - if the capture is by reference, the variable's lifetime ends when the closure object's lifetime ends.
  ]
]

#nobreak[
  === Change #eelis("expr.prim.lambda.capture", 7)
  #quote[
    ... the entity is said to be _implicitly captured_ by each intervening _lambda-expression_ with an associated
    _capture-default_ that does not explicitly capture it#ins[, except that `*this` is not implicitly captured by a
      _lambda-expression_ whose _capture-default_ is `const =`, `mutable =`, or `const &`]. The implicit capture of
    `*this` is deprecated when the _capture-default_ is `=`; see #eelis("depr.capture.this"). ...
  ]
]

#nobreak[
  === Change #eelis("expr.prim.lambda.capture", 10)
  #quote[
    An entity is _captured by copy_ if
    - it is implicitly captured, the _capture-default_ is #replace[`=`][`=`, `mutable =`, or `const =`], and the
      captured entity is not `*this`, or
    - it is explicitly captured with a capture that is not of the form `this`, `&` _identifier_ ...#sub[_opt_],
      #ins[`const &` _identifier_ ...#sub[_opt_]] #replace[or][,] `&` ...#sub[_opt_] _identifier initializer_ #ins[or
        `const &` ...#sub[_opt_] _identifier initializer_].

    #ins[An entity captured by copy is _captured mutably_ if it is explicitly captured by a _capture_ that begins with
      `mutable`, or it is implicitly captured and the _capture-default_ is `mutable =`.]

    #ins[An entity captured by copy is _captured by const copy_ if it is explicitly captured by a _capture_ that begins
      with `const`, or it is implicitly captured and the _capture-default_ is `const =`.]

    For each entity captured by copy, an unnamed non-static data member is declared in the closure type. #del[The type
      of such a data member is the referenced type if the entity is a reference to an object, an lvalue reference to
      the referenced function type if the entity is a reference to a function, or the type of the corresponding
      captured entity otherwise.] #ins[The type of such a data member is an
      lvalue reference to the referenced function type if the entity is a reference to a function. Otherwise, letting
      _U_ be the referenced type if the entity is a reference to an object and the type of the entity otherwise, and _V_
      be _U_ with any top-level cv-qualifiers removed, it is]
    #ins[
      - _V_, if the entity is captured mutably,
      - `const`-qualified _V_, if the entity is captured by const copy, or
      - _U_ otherwise.
    ]
    #ins[If the entity is captured mutably and is not a reference to a function, the data member is declared `mutable`.]
    #ins[\[_Note_: For an entity that is a reference to a function, the data member is a reference, which can be neither
      `const`-qualified nor `mutable` (#eelis("basic.type.qualifier"), #eelis("dcl.stc")); a `const` or `mutable`
      capture of such an entity therefore has no effect on the data member. --- _end note_\]]
    A member of an anonymous union shall not be captured by copy.
  ]
]

#nobreak[
  === Change #eelis("expr.prim.lambda.capture", 12)
  #quote[
    An entity is _captured by reference_ if it is implicitly or explicitly captured but not captured by copy.
    #ins[An entity captured by reference is _captured by const reference_ if it is either explicitly captured with a
      `const &` capture, or it is implicitly captured and the _capture-default_ is `const &`.]
    It is unspecified whether additional unnamed non-static data members are declared in the closure type for entities
    captured by reference. If declared, such non-static data members shall be of literal type.
  ]
]

#nobreak[
  === Change #eelis("expr.prim.lambda.capture", 14)
  #quote[
    If a _lambda-expression_ `m2` captures an entity and that entity is captured by an immediately enclosing
    _lambda-expression_ `m1`, then `m2`'s capture is transformed as follows:

    - If `m1` captures the entity by copy, `m2` captures the corresponding non-static data member of `m1`'s closure
      type; if `m1` is not `mutable` #ins[and the entity is not captured mutably], the non-static data member is
      considered to be const-qualified.
    - If `m1` captures the entity by reference, `m2` captures the same entity captured by `m1`. #ins[If an
        _id-expression_ naming the entity within the _compound-statement_ of `m1` would have const-qualified type
        (#eelis("expr.prim.id.unqual")), then the entity is considered to be const-qualified for the determination of
        the type of any non-static data member declared for `m2`'s capture (#eelis("expr.prim.lambda.capture", 10)).]
  ]
]

== Feature-Test Macro

On adoption, bump `__cpp_lambdas` in #eelis("cpp.predefined") to the value corresponding to this paper.

= Thanks

Thanks to Patrick McMichael for suggesting the idea; to Nevin Liber and Matt Calabrese for important corrections; to
Nevin Liber, Davis Herring, Barry Revzin, and Victoria Tsai for examples and suggestions; to Hana Dušíková and Ville
Voutilainen for observing that the `constexpr`/`consteval` restriction was unnecessary; to Yihan Wang for raising the
lifetime of a `const&` capture bound to a temporary, which became @sec-reference-lifetime[Section]; to Lakshay Garg for
catching that the rationale for disallowing a qualified `this` contradicted the treatment of `[const& x]`, and for
several other corrections; to Ville Voutilainen for the exploratory implementation; and to Daveed Vandevoorde for
feedback on the wording.

#pagebreak()

#bibliography("references.bib", style: "references.csl")
