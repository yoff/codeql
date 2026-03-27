---
category: minorAnalysis
---
* The `java/potentially-weak-cryptographic-algorithm` query no longer flags Elliptic Curve algorithms (`EC`, `ECDSA`, `ECDH`, `EdDSA`, `Ed25519`, `Ed448`, `XDH`, `X25519`, `X448`) as potentially insecure. These are modern, secure algorithms recommended by NIST SP 800-57 and other standards bodies. Previously, these algorithms were not included in the secure algorithm whitelist, causing false positives when using standard Java cryptographic APIs such as `KeyPairGenerator.getInstance("EC")`.
