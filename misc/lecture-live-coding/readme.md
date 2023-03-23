# Live coding lecture

We will try to find [this vulnerability](https://github.com/advisories/GHSA-gmpq-xrxj-xh8m).

Specifically [this alert lcoation](https://github.com/archesproject/arches/blob/75ce8f7cb9c08caf608569797a40ca9be585b182/arches/app/models/concept.py#L1216).

The fix is [here](https://github.com/archesproject/arches/commit/7ed53e23a616edf3301d95814d9d64de5e3072a9#diff-6c34f3faa78f4c83b9ee63a2f911d34ac78824f88b97525123ff0c3204a7bcf2L1179-R1213).

Setup:

Clone the repo

```bash
gh repo clone archesproject/arches
```

Checkout the commit before the fix (in this case we use the commit from the alert location link)

```bash
git checkout 233b21f
```

Build a database

```bash
gh codeql database create -l python -j 0 -- CVE-2022-41892-vul
```

Start VSCode from the starter repo or from `github/codeql`, and load the database. You should now be able to do explorative queries, for example via the `CodeQL: Quick Query` command.

Iterations:

1. Find calls to `XXX.execute`
   (also finds `util.execute`)

2. Find calls to `cursor.execute`

3. Find calls to `cursor.execute` where the argument is a call to `XXX.format`.

4. Find calls to `cursor.execute` where the argument is reached, by local dataflow, by a call to `XXX.format`.

5. Find dataflow from remote flow sources to the argument of `cursor.execute`.

6. Same as 5, but show the paths.

7. Add a sanitizer, in this case comparison with a string constant.
