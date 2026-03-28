---
category: minorAnalysis
---
* The `java/potentially-weak-cryptographic-algorithm` query no longer flags Elliptic Curve algorithms (`EC`, `ECDSA`, `ECDH`, `EdDSA`, `Ed25519`, `Ed448`, `XDH`, `X25519`, `X448`), HMAC-based algorithms (`HMACSHA1`, `HMACSHA256`, `HMACSHA384`, `HMACSHA512`), or PBKDF2 key derivation as potentially insecure. These are modern, secure algorithms recommended by NIST and other standards bodies. Previously, these algorithms were not included in the secure algorithm whitelist, causing false positives when using standard Java cryptographic APIs such as `KeyPairGenerator.getInstance("EC")` or `new SecretKeySpec(key, "HMACSHA256")`.
* The `Signature.getInstance(...)` method is now modeled as a `CryptoAlgoSpec` sink, alongside the existing `Signature` constructor sink. This ensures that algorithm strings passed to `Signature.getInstance(...)` are also checked by the query.
