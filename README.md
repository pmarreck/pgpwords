# pgpwords

`pgpwords` translates hexadecimal bytes to and from the PGP word list.

The stock PGP word list maps each byte to one of two 256-word tables. Bytes are rendered left-to-right. Byte offset 0 uses the even table, byte offset 1 uses the odd table, and the tables alternate from there. This catches common spoken-word mistakes such as adjacent transpositions, insertions, and deletions when they disturb the expected even/odd sequence.

## Usage

```sh
pgpwords --encode E582
# topmost Istanbul

pgpwords --decode 'topmost Istanbul'
# E582

printf '82e5' | pgpwords --encode -
# miser travesty
```

Hex input is case-insensitive and may contain spaces, colons, hyphens, or underscores as separators. PGP words are case-insensitive.

## Endian Extension

By default, `pgpwords` follows the stock PGP wordlist behavior exactly: no endian marker is emitted or interpreted.

The optional endian extension is for byte streams that represent fingerprints or binary values where byte-order confusion would be costly.

```sh
pgpwords --encode --endian=big E582
# skydive travesty miser

pgpwords --decode --endian=auto 'skydive travesty miser'
# E582
```

`--endian=big` is valid while encoding. It prefixes byte `BE` before the input bytes, with the assumption that the input is already in big-endian order. The marker intentionally shifts every following payload word to the opposite even/odd table.

`--endian=auto` is valid while decoding. It interprets a leading `BE` byte as an extension marker and strips it from the returned hex bytes. Literal payloads that collide with marker prefixes use repeated `00 00` escapes:

```text
BE ...                    marker; return ...
00 00 BE BE ...           escaped literal; return BE ...
00 00 00 00 BE 00 00 BE ... escaped literal; return 00 00 BE ...
```

Malformed escaped prefixes are rejected instead of silently dropping bytes.

## Development

```sh
nix develop
./test
./build
nix flake check
```

The executable lives at `bin/pgpwords` and uses `#!/usr/bin/env luajit` so it can be picked up directly by PATH setups that include this repository's `bin/` directory.

## References

- https://philzimmermann.com/docs/PGP_word_list.pdf
- https://web.mit.edu/network/pgpfone/manual/
