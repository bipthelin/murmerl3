murmerl3
========

Pure erlang implementation of the MurmurHash3 algorithm.

MurmurHash3 is a hash-function that's suitable for non cryptographic
situations. Such as hash-based lookups.

Currently only the 32-bit version is implemented

Usage
-----

`murmerl3:hash_32(Data)` hash Data with an initial seed of 0.

`murmerl3:hash_32(Data, Seed)` hash Data with the given seed.

``` erlang

1> murmerl3:hash_32("The quick brown fox jumps over the lazy dog").
776992547

2> murmerl3:hash_32("The quick brown fox jumps over the lazy dog", 666).
3231564089

```

