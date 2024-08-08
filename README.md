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
> echo "foo bar" 
foo bar

> sed "s/bar/baz/g" 
foo baz

> tr " " "-"
foo-baz
```

## Debug a chain of piped commands that check how many times `GPL` is referred to in the `LICENCE` of this project
Running this:
```
./pipespect.sh 'ls | grep "LIC" | xargs grep GPL | wc -l'
```
Will output:
```
> ls 
LICENSE
pipespect.sh
README.md

> grep "LIC" 
LICENSE

> xargs grep GPL 
  Developers that use the GNU GPL protect your rights with two steps:
  For the developers' and authors' protection, the GPL clearly explains
authors' sake, the GPL requires that modified versions be marked as
have designed this version of the GPL to prohibit the practice for those
of the GPL, as needed to protect the freedom of users.
make it effectively proprietary.  To prevent this, the GPL assures that
For more information on this, and how to apply and follow the GNU GPL, see

> wc -l
7
```
