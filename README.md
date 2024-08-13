# Pipespect
Inspect a chain of piped bash commands. Useful for debugging long chains of piped commands.

# Example usages
## Debug a one-liner chain of pipes
Before:
```
echo "foo baz bar" | tr " " "\n" | sort | head -n1
```
After:
```
./pipespect.sh 'echo "foo baz bar" | tr " " "\n" | sort | head -n1'
```
Output:
```
bar
baz
foo

↑ sort

foo
baz
bar

↑ tr " " "\n"

foo baz bar

↑ echo "foo baz bar"
```

## Debug a multiline chain of pipes
Before:
```
first=$(
  echo "foo baz bar" \
  | tr ' ' '\n' \
  | sort \
  | head -n1
)
echo "First alphabetically: $first"
```
After:
```
sorted=$(
pipespect --verbose << EOM
  echo "foo baz bar" \
  | tr ' ' '\n' \
  | sort \
  | head -n1
EOM
)
echo "First alphabetically: $first"
```
Output:
```
>>>>>>> echo "foo baz bar" | tr ' ' '\n' | sort | head -n1
bar

↑ head -n1

bar
baz
foo

↑ sort

foo
baz
bar

↑ tr ' ' '\n'

foo baz bar

↑ echo "foo baz bar"

=======
First alphabetically: bar
```
