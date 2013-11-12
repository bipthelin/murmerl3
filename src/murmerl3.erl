%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Copyright (c) 2013, Bip Thelin
%%%
%%% Permission to use, copy, modify, and/or distribute this software for any
%%% purpose with or without fee is hereby granted, provided that the above
%%% copyright notice and this permission notice appear in all copies.
%%%
%%% THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
%%% WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
%%% MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
%%% ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
%%% WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
%%% ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
%%% OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
%%%
%%% @doc This is a pure erlang implementation of the MurmurHash3
%%%      (https://code.google.com/p/smhasher/wiki/MurmurHash3)
%%%      MurmurHash3 is suitable for generating well-distributed
%%%      non-cryptographic hashes.
%%%
%%%      This version is based on the supposedly final rev 136.
%%% @end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%_* Module declaration ===============================================
-module(murmerl3).

%%%_* Exports ==========================================================
-export([hash_32/1]).
-export([hash_32/2]).

%%%_* Macros ===========================================================
-define(c1_32,      16#cc9e2d51).
-define(c2_32,      16#1b873593).
-define(n_32,       16#e6546b64).
-define(mask_32(X), ((X) band 16#FFFFFFFF)).

%%%_* Code =============================================================
%%%_ * API -------------------------------------------------------------
hash_32(Data)                             -> hash_32(Data, 0).
hash_32(Data, Seed) when is_integer(Data) ->
    hash_32(integer_to_list(Data), Seed);
hash_32(Data, Seed) when is_list(Data)    ->
    hash_32(list_to_binary(Data), Seed);
hash_32(Data, Seed) when is_binary(Data)  ->
    Hash =
        case hash_32_aux(Seed, Data) of
            {H, []} -> H;
            {H, T}  -> H bxor ?mask_32(rotl32(
                                  ?mask_32(swap_uint32(T) * ?c1_32)
                                , 15) * ?c2_32)
        end,
    fmix32(Hash bxor byte_size(Data)).

%%%_* Private functions ================================================
hash_32_aux(H0, <<K:8/little-unsigned-integer-unit:4, T/binary>>) ->
    K1 = ?mask_32(rotl32(?mask_32(K * ?c1_32), 15) * ?c2_32),
    hash_32_aux(?mask_32(rotl32((H0 bxor K1), 13) * 5 + ?n_32), T);
hash_32_aux(H, T) when byte_size(T) > 0 -> {H, T};
hash_32_aux(H, _)                       -> {H, []}.

fmix32(H0)   ->
    xorbsr((?mask_32(xorbsr( (?mask_32(xorbsr(H0, 16) * 16#85ebca6b))
                           , 13 ) * 16#c2b2ae35)), 16).

swap_uint32(<< V1:8/little-unsigned-integer
             , V2:8/little-unsigned-integer
             , V3:8/little-unsigned-integer >>) ->
    ((V3 bsl 16) bxor (V2 bsl 8)) bxor V1;
swap_uint32( <<V1:8/little-unsigned-integer
           , V2:8/little-unsigned-integer>> )   ->
    (V2 bsl 8) bxor V1;
swap_uint32(<<V1:8/little-unsigned-integer>>)   ->
    0 bxor V1.

xorbsr(H, V) -> H bxor (H bsr V).
rotl32(X, R) -> ?mask_32((X bsl R) bor (X bsr (32 - R))).

%%%_* Tests ============================================================
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

hash_32_test() ->
    ?assertEqual(hash_32(""),          0),
    ?assertEqual(hash_32("", 1),       1364076727),
    ?assertEqual(hash_32("Some Data"), hash_32("Some Data", 0)),
    ?assertEqual(hash_32("0"),         3530670207),
    ?assertEqual(hash_32("01"),        1642882560),
    ?assertEqual(hash_32("012"),       3966566284),
    ?assertEqual(hash_32("0123"),      3558446240),
    ?assertEqual(hash_32("01234"),     433070448).

-endif.

%%%_* Emacs ============================================================
%%% Local Variables:
%%% allout-layout: t
%%% erlang-indent-level: 4
%%% End:
