# Pipespect
Inspect a chain of piped bash commands. Useful for debugging long chains of piped commands.

# Example usages
## Debug if chain of pipes correctly converts `foo bar` into `foo-baz`
Running this:
```
./pipespect.sh 'echo "foo bar" | sed "s/bar/baz/g" | tr " " "-"'
```
Will output:
```
foo-baz

↑ tr " " "-"

foo baz

↑ sed "s/bar/baz/g"

foo bar

↑ echo "foo bar"

```

## Debug a chain of piped commands that check how many times `GPL` is referred to in the `LICENCE` of this project
Running this:
```
./pipespect.sh 'ls | grep "LIC" | xargs grep GPL | wc -l'
```
Will output:
```
7

↑ wc -l

  Developers that use the GNU GPL protect your rights with two steps:
  For the developers' and authors' protection, the GPL clearly explains
authors' sake, the GPL requires that modified versions be marked as
have designed this version of the GPL to prohibit the practice for those
of the GPL, as needed to protect the freedom of users.
make it effectively proprietary.  To prevent this, the GPL assures that
For more information on this, and how to apply and follow the GNU GPL, see

↑ xargs grep GPL

LICENSE

↑ grep "LIC"

LICENSE
pipespect.sh
README.md
test

↑ ls

```

## Debug a chain somewhere in your bash script
A script like this:
```
counts=$(echo "foo bar 124 ff1 foo foo1 foo bar4 baz" \
  | tr ' ' '\n' \
  | sed 's/bar/baz/g' \
  | grep -E '^(foo|baz)$' \
  | sort \
  | uniq -c
)
```
can be easily pipe-spected by changing it to:
```
counts=$(pipespect --verbose << EOM
echo "foo bar 124 ff1 foo foo1 foo bar4 baz" \
  | tr ' ' '\n' \
  | sed 's/bar/baz/g' \
  | grep -E '^(foo|baz)$' \
  | sort \
  | uniq -c
EOM
)
```
