---
title: Okasaki's PFDS, Chapter 4
author: Brian
date: 2015-11-08
tags: fp, haskell, okasaki, lazy, strict
---

This post contains my solutions to the exercises in chapter 4 of Okasaki's "Purely Functional Data Structures".
The latest source code can be found in [my GitHub repo](https://github.com/stappit/okasaki-pfds).

Notation
--------

Okasaki uses `$` to indicate suspensions.
But beware!
Haskell also has this symbol but it means something completely different, namely function application.
In symbols:

```haskell
($) :: (a -> b) -> a -> b
($) f a = f a
```

We can use it like any other function in haskell.
For example:

```haskell
two = (1 +) $ 1
```

It has nothing to do with suspensions, evaluation, forcing, etc.

It is also important to note that a 'list' in haskell is not what Okasaki calls a 'list'.
He would call haskell's lists 'streams'.
We will stick with haskell's notation, calling Okasaki's list a 'strict list'.

Exercise 1
----------

Show that both definitions of `drop` are equivalent.

Solution 1
----------

The code in this solution is NOT Haskell.

For convenience, we give names to the three different functions.

```
fun drop (0, s)            = s
  | drop (n, $Nil)         = $Nil
  | drop (n, $Cons (x, s)) = drop (n-1, s)
```

```
fun lazy dropA (0, s)            = s
       | dropA (n, $Nil)         = $Nil
       | dropA (n, $Cons (x, s)) = dropA (n-1, s)
```

```
fun lazy dropB (n, s) = drop (n, s)
```

The proof proceeds in three steps.

Lemma
:   Let `s` be a suspension.
    Then `$force s` is equivalent to `s`.

Proof.
Suppose `s` is `$e` for some expression `e`.
Then `$force s` $\cong$ `$force $e` $\cong$ `$e` $\cong$ `s`.

□

Lemma
:   `dropA` is equivalent to `drop`

Proof.
We prove this by induction on $n$.

For the base step, `dropA (0, s)` = `$force s` $\cong` `s` = `drop (0, s)`, where the middle equivalence follows by the previous lemma.

Note that `dropA (n, $Nil)` = `$force $Nil` = `$Nil` = `drop (n, $Nil)` follows by the previous lemma.
Now suppose `dropA (n, s)` $\cong$ `drop (n, s)` for some $n \in \mathbb N$ and any stream `s`.
We can write `s` as `$Cons (x, s')`.
Then `dropA (n+1, s)` = `dropA (n+1, $Cons (x, s'))` = `$force dropA (n, s')` $\cong$ `dropA (n, s')` $\cong$ `drop (n, s')` = `drop (n+1, s)`.

□

Lemma
:   `dropA` is equivalent to `dropB`

Proof.
Using the previous two lemmas, we obtain `dropB (n, s)` = `$force drop (n, s)` = `$force dropA (n, s)` = `dropA (n, s)` for any $n \in \mathbb N$ and any stream `s`.

□

Exercise 2
----------

Implement insertion sort on streams and show that extracting the first $k$ elements takes only $\mathcal O (nk)$ time, where $n$ is the length of the input list.

Solution 2
----------

See [source](https://github.com/stappit/okasaki-pfds/blob/70501d73d4cf242bfd0128308fa635e7ca95ceef/src/Chap04/Exercise02.hs).
Note that lists in Haskell are what Okasaki calls streams, so we need no special annotations or data structures.

Let $T (n, k)$ be the asymptotic complexity of computing `take k $ sort xs`, where `xs` is a list of length $n$.
By definition of `take`, $T (n, 0) = \mathcal O (1)$ and $T (0, k) = T (0, 0)$.

In `take k $ sort xs` the function `take k` needs to put `sort xs` into weak head normal form.
Let $S (m)$ be the complexity of puting `sort ys` into weak head normal form for a list `ys` of length $m$.
Clearly $S (0) = \mathcal O (1)$.
Since `sort (y:ys) = ins y $ sort ys`, we have $S (m) = S (m-1) + \mathcal O (1)$, since `ins y` only needs to put `sort ys` into weak head normal form.
This is solved by $S (m) = \mathcal O (m)$.

Now, `take k $ sort xs = take k $ y : ys = y : take (k-1) ys`, where `sort xs = y : ys`.
Thus $T (n, k) = T (n-1, k-1) + \mathcal O (n)$.
This recurrence is solved by $T (n, k) = \mathcal O (nk)$.
