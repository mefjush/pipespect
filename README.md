# Pipespect
Inspect a chain of piped bash commands

# Example usage
Running this in the root of the project:
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
