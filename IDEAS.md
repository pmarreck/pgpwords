# Ideas

## Opt-in Checksum Extension

Add an explicit, non-default checksum mode for spoken/transcribed byte streams.

Sketch:

- Encode with an option such as `--checksum=crc16:N`.
- After every `N` payload bytes, insert a 2-byte checksum for that block.
- Decode with the same explicit option, verify each block, and strip checksum bytes from output.
- Keep default behavior as stock PGP wordlist encoding with no checksum interpretation.

Rationale:

- PGP wordlist even/odd parity catches many transpositions, insertions, and deletions, but same-parity substitutions can still decode as different valid bytes.
- A block checksum could catch byte substitutions and other block-local corruption.
- A 2-byte checksum preserves even/odd phase after each block; a 1-byte checksum would shift phase after every block unless that shift were made deliberate.

Open questions:

- Algorithm: CRC-16, Fletcher-16, truncated cryptographic hash, or something else.
- Block size: fixed default versus required explicit `N`.
- Decode behavior: buffer one block before emitting verified payload, or stream optimistically and report later failures.
- Header/self-description: not possible without more marker/escape machinery if backward compatibility with stock PGP words remains mandatory.
- Interaction with `--endian=auto` / `--endian=big`: checksum should likely cover payload bytes after removing extension markers, but this needs a written rule before implementation.

Constraint:

Do not add `--checksum=auto` unless a real self-describing extension header exists. Otherwise the decoder would be guessing protocol state from ordinary byte values.
