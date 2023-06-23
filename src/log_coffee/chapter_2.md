# Sweet Jesus, Pooh! That's Not Honey! - You're Eating Recursion!

Most of the time, using Rust is just bliss. But today, it took us for a ride. We were reviewing some code (simplified for the blog) and stumbled upon a nested `enum` that looked like this 

``` rust
#[derive(Debug)]
enum Tree {
    Leaf,
    SubTree(Vec<Tree>),
}
```
Assume `Leaf` is a placeholder to hold some data and thus the `enum` allows you to create a [`Rose`](https://en.wikipedia.org/wiki/Rose_tree) tree. Now, we have a function `create_nested_tree` that accepts a single parameter `depth` as input and creates a flat `Tree` with depth `depth` and a `Leaf` at the end.

```rust
fn create_nested_tree(depth : i32) -> Tree {
    let mut tree = Tree::Leaf;
    for _ in 0..depth {
        tree = Tree::SubTree(vec![tree]);
    }
    tree
}

fn main() {
    println!("{:#?}", create_nested_tree(5));
}

```
This would produce the following output.
```
SubTree(
    [
        SubTree(
            [
                SubTree(
                    [
                        SubTree(
                            [
                                SubTree(
                                    [
                                        Leaf,
                                    ],
                                ),
                            ],
                        ),
                    ],
                ),
            ],
        ),
    ],
)
```

As one behaves when they see deeply nested structures, We tried giving a large `depth` (*50_000*) to see what happens. 

```rust
fn main() {
    println!("{:#?}", create_nested_tree(50_000));
}
```
And there we go,

```
thread 'main' has overflowed its stack
fatal runtime error: stack overflow
Aborted (core dumped)
```

Initially, we immediately suspected the `fmt::Debug` hitting a recursive call and was causing the stack overflow. So, we removed the `println!` from `main` and included a `println!` in `create_nested_tree` before returning to value to isolate the issue. (What's a debugger?)

> Note that the function `create_nested_tree` iteratively creates the nested `Tree` and there shouldn't be any concern of stack overflow. 

```rust
#[derive(Debug)]
enum Tree {
    Leaf,
    SubTree(Vec<Tree>),
}

fn create_nested_tree(depth : i32) -> Tree {
    let mut tree = Tree::Leaf;
    for _ in 0..depth {
        tree = Tree::SubTree(vec![tree]);
    }
    println!("End of create_nested_tree");
    tree
}

fn main() {
    let _ = create_nested_tree(50_000);
}
```
But to our surprise, 
```
End of create_nested_tree

thread 'main' has overflowed its stack
fatal runtime error: stack overflow
Aborted (core dumped)
```

There is no operation happening after returning the value and the code still stack overflows after the return. To debug, we created the [MIR](https://blog.rust-lang.org/2016/04/19/MIR.html) of our code and looked at `create_nested_tree`.

```bash
cargo rustc -- --emit=mir

fn create_nested_tree(_1: i32) -> Tree {
    debug depth => _1;                   // in scope 0 at src/main.rs:7:23: 7:28
    let mut _0: Tree;                    // return place in scope 0 at src/main.rs:8:9: 8:17
    
    // for loop logic (removed for brevity)

    bb10: {
        _29 = const false;               // scope 1 at src/main.rs:13:5: 13:9
        _29 = const false;               // scope 0 at src/main.rs:14:1: 14:2
        return;                          // scope 0 at src/main.rs:14:2: 14:2
    }

    bb11 (cleanup): {
        resume;                          // scope 0 at src/main.rs:7:1: 14:2
    }

    bb12 (cleanup): {
        drop(_0) -> bb11;                // scope 0 at src/main.rs:14:1: 14:2
    }

    bb13 (cleanup): {
        switchInt(_29) -> [false: bb11, otherwise: bb12]; // scope 0 at src/main.rs:14:1: 14:2
    }
}
```

<mark>And there is our culprit block `bb12`. Once the variable `_0` ie `tree` in our code goes out of scope (return to main), the code invokes cleanup of memory of local variables and tries to drop `_0`.</mark>

But why would dropping a value cause a stack overflow? If not anything, we are trying to free memory. This is where the beauty of the Rust implementation and my loss of hair kicks in

> When an initialized variable in Rust goes out of scope or a temporary is no longer needed its destructor is run. The assignment also runs the destructor of its left-hand operand, unless it's an uninitialized variable. If a struct variable has been partially initialized, only its initialized fields are dropped. The destructor of a type consists of
> * Calling its std::ops::Drop::drop method, if it has one.
> * Recursively running the destructor of all of its fields.
>   * The fields of a struct, tuple, or enum variant are dropped in declaration order.
>   * The elements of an array or owned slice are dropped from the first element to the last.
>   * The captured values of a closure are dropped in an unspecified order.
>   * Trait objects run the destructor of the underlying type.
>   * Other types don't result in any further drops.

Source: [Destructors](https://web.mit.edu/rust-lang_v1.25/arch/amd64_ubuntu1404/share/doc/rust/html/reference/destructors.html)

<mark>Following the description of Destructor, since we don't have our Drop implementation, it tries to drop the values `Leaf` and `SubTree` in the enum. However, the nested nature of the `enum` recursively places drop calls on the stack and hence causes the stack overflow</mark>

Finally an explanation, but how do we solve this? By implementing our own `Drop` implementation which isn't recursive.

```rust
impl Drop for Tree {
    fn drop(&mut self) {
        let mut stack = vec![*self];
        while let Some(mut node) = stack.pop() {
            match node {
                Tree::Leaf => {}
                Tree::SubTree(ref mut children) => {
                    stack.extend(children.drain(..));
                }
            }
            // This is safe to drop
            let _ = std::mem::replace(&mut node, Tree::Leaf);
        }
    }
}
```
Rough logic behind the code 
* Create our stack (ironic) and push the entire tree.
* Keep popping the values of the stack until its empty
  * If the node is a `Leaf`, you don't need to do anything since Rust can drop it safely.
  * If the node is a `SubTree(Vec<Tree>)`, we collect all the subtrees in the vec and push them into the stack. This is achieved by `children.drain(..)`. Now, we have to make `node` safe to drop. Luckily, Rust saves us again here, since it allocates the same amount of memory for each value type in an `enum` and so we can easily replace the value at `node` with a `Tree::Leaf`

Given this, when the stack is empty, all references of `Tree::SubTree` would have been replaced by `Tree::Leaf` and the tree would be safe to drop without any recursion. Or so I thought. 

```
error[E0507]: cannot move out of `*self` which is behind a mutable reference
 --> src/main.rs:9:30
  |
9 |         let mut stack = vec![*self];
  |                              ^^^^^ move occurs because `*self` has type `Tree`, which does not implement the `Copy` trait
```

Couple of things to unpack here,
* We can't do `#[derive(Copy, Clone)]` since we have a Vec which does not implement Copy (as it rightfully should).
* Should we even implement Copy here? Can I do something else to make it work?

<mark> Luckily yes, by using a wrapper struct we can get out of this issue. </mark>

```rust
#[derive(Debug)]
enum Tree {
    Leaf,
    SubTree(Vec<Tree>),
}

#[derive(Debug)]
struct Head(Tree);
```
Now we can implement `Drop` for the wrapper `Head` in the same way and adapt our `create_nested_tree` slightly,
```rust
impl Drop for Head {
    fn drop(&mut self) {
        // We can solve the *self issue here by taking
        // advantage of Rust allocating the same
        // amount of memory for each value of the 
        // enum and thus swapping self.0 with 
        // `Head(Tree::Leaf)` allows a safe drop.

        let mut tree = Tree::Leaf;
        std::mem::swap(&mut self.0, &mut tree);

        // Now we proceed to drop the bulk of the tree 
        // as we implemented before.

        let mut stack = vec![tree];
        while let Some(mut node) = stack.pop() {
            match node {
                Tree::Leaf => {}
                Tree::SubTree(ref mut children) => {
                    stack.extend(children.drain(..));
                }
            }
            let _ = std::mem::replace(&mut node, Tree::Leaf);
        }
    }
}

fn create_nested_tree(depth: i32) -> Head {
    let mut tree = Tree::Leaf;
    for _ in 0..depth {
        tree = Tree::SubTree(vec![tree]);
    }
    Head(tree) // returning Head(Tree) instead of Tree
}
```

Our new tree now looks like this 
```
Head(
    SubTree(
        [
            SubTree(
                [
                    SubTree(
                        [
                            SubTree(
                                [
                                    SubTree(
                                        [
                                            Leaf,
                                        ],
                                    ),
                                ],
                            ),
                        ],
                    ),
                ],
            ),
        ],
    ),
)
```

And finally our working code. You can try running it yourself with the &#9654; button at the top and feel the relief.
```rust
#[derive(Debug)]
enum Tree {
    Leaf,
    SubTree(Vec<Tree>),
}

#[derive(Debug)]
struct Head(Tree);

impl Drop for Head {
    fn drop(&mut self) {
        let mut current = Tree::Leaf;
        std::mem::swap(&mut self.0, &mut current);

        let mut stack = vec![current];

        while let Some(mut node) = stack.pop() {
            match node {
                Tree::Leaf => {}
                Tree::SubTree(ref mut children) => {
                    stack.extend(children.drain(..));
                }
            }
            let _ = std::mem::replace(&mut node, Tree::Leaf);
        }
    }
}

fn create_nested_tree(depth: i32) -> Head {
    let mut tree = Tree::Leaf;
    for _ in 0..depth {
        tree = Tree::SubTree(vec![tree]);
    }
    Head(tree)
}

fn main() {
    let _ = create_nested_tree(50_000);
    println!("End of program");
}
```
*Fin. Guess I will have some &#x1F980; soup now*

## Update (23/06/2023)

After sitting on it for a while, we can actually do it without a wrapper.

```rust
#[derive(Debug)]
enum Tree {
    Leaf,
    SubTree(Vec<Tree>),
}

impl Drop for Tree {
    fn drop(&mut self) {
        let mut stack = vec![];

        match self {
            Tree::Leaf => {}
            Tree::SubTree(ref mut children) => {
                stack.extend(children.drain(..));

                while let Some(mut node) = stack.pop() {
                    match node {
                        Tree::Leaf => {}
                        Tree::SubTree(ref mut children) => {
                            stack.extend(children.drain(..));
                        }
                    }
                    let _ = std::mem::replace(&mut node, Tree::Leaf);
                }
            }
        }
    }
}

fn create_nested_tree(depth: i32) -> Tree {
    let mut tree = Tree::Leaf;
    for _ in 0..depth {
        tree = Tree::SubTree(vec![tree]);
    }
    tree
}

fn main() {
    let _ = create_nested_tree(50_000);
    println!("End of program");
}
```

*I didn't deserve the &#x1F980; soup*