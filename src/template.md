# Markdown Template 
+ [Heading](./template.md#heading)
+ [Emphasis](./template.md#emphasis)
+ [Blockquotes](./template.md#blockquotes)
+ [Lists](./template.md#lists)
+ [Latex](./template.md#latex)
+ [Codes](./template.md#codes) 
+ [Tables](./template.md#tables)
+ [Links](./template.md#links)
+ [Images](./template.md#images)
+ [Footnotes](./template.md#footnotes)
+ [Task lists](./template.md#task-lists)
+ [Blog Specific](./template.md#blog-specific)

# Heading

```markdown
# h1 Heading
## h2 Heading
### h3 Heading
#### h4 Heading
##### h5 Heading
###### h6 Heading
```

--- 

# h1 Heading
## h2 Heading
### h3 Heading
#### h4 Heading
##### h5 Heading
###### h6 Heading

# Emphasis

```markdown
**This is bold text**

__This is bold text__

*This is italic text*

_This is italic text_

~~Strikethrough~~
```

---

**This is bold text**

__This is bold text__

*This is italic text*

_This is italic text_

~~Strikethrough~~


## Horizontal Rules
```markdown
___
---
***
```
___
---
***


# Blockquotes

```markdown
> Blockquotes can also be nested...
>> ...by using additional greater-than signs right next to each other...
> > > ...or with spaces between arrows.
```

---

> Blockquotes can also be nested...
>> ...by using additional greater-than signs right next to each other...
> > > ...or with spaces between arrows.

# Lists

```markdown
Unordered

+ Create a list by starting a line with `+`, `-`, or `*`
+ Sub-lists are made by indenting 2 spaces:
  - Marker character change forces new list start:
    * Ac tristique libero volutpat at
    + Facilisis in pretium nisl aliquet
    - Nulla volutpat aliquam velit
+ Very easy!

Ordered

1. Lorem ipsum dolor sit amet
2. Consectetur adipiscing elit
3. Integer molestie lorem at massa

1. You can use sequential numbers...
1. ...or keep all the numbers as `1.`

Start numbering with offset:

57. foo
1. bar
```

---

Unordered

+ Create a list by starting a line with `+`, `-`, or `*`
+ Sub-lists are made by indenting 2 spaces:
  - Marker character change forces new list start:
    * Ac tristique libero volutpat at
    + Facilisis in pretium nisl aliquet
    - Nulla volutpat aliquam velit
+ Very easy!

Ordered

1. Lorem ipsum dolor sit amet
2. Consectetur adipiscing elit
3. Integer molestie lorem at massa

1. You can use sequential numbers...
1. ...or keep all the numbers as `1.`

Start numbering with offset:

57. foo
1. bar

# Latex

~~~markdown
* Inline equations are replaced with `\\(` *text* `\\)`

```
    \\( \mathbb{N} = \{ a \in \mathbb{Z} : a > 0 \} \\)
```

\\(\mathbb{N} = \{ a \in \mathbb{Z} : a > 0 \}\\)

* Block equations are replaced with `\\[` *text* `\\]`

```
    \\[ \mathbb{N} = \{ a \in \mathbb{Z} : a > 0 \} \\]
```

\\[\mathbb{N} = \{ a \in \mathbb{Z} : a > 0 \}\\]

~~~

---

* Inline equations are replaced with `\\(` *text* `\\)`

```
    \\( \mathbb{N} = \{ a \in \mathbb{Z} : a > 0 \} \\)
```

\\(\mathbb{N} = \{ a \in \mathbb{Z} : a > 0 \}\\)

* Block equations are replaced with `\\[` *text* `\\]`

```
    \\[ \mathbb{N} = \{ a \in \mathbb{Z} : a > 0 \} \\]
```

\\[\mathbb{N} = \{ a \in \mathbb{Z} : a > 0 \}\\]

# Codes

~~~markdown
Inline ` code `

Indented code

    // Some comments
    line 1 of code
    line 2 of code
    line 3 of code


Block code "fences"

```
Sample text here...
```

Syntax highlighting

```  js
var foo = function (bar) {
  return bar++;
};

console.log(foo(5));
```

[Rust specific mdbook configuration](https://rust-lang.github.io/mdBook/format/mdbook.html)
~~~

---

Inline `code`

Indented code

    // Some comments
    line 1 of code
    line 2 of code
    line 3 of code


Block code "fences"

```
Sample text here...
```

Syntax highlighting

``` js
var foo = function (bar) {
  return bar++;
};

console.log(foo(5));
```

[Rust specific mdbook configuration](https://rust-lang.github.io/mdBook/format/mdbook.html)


# Tables

```markdown
| Option | Description |
| ------ | ----------- |
| data   | path to data files to supply the data that will be passed into templates. |
| engine | engine to be used for processing templates. Handlebars is the default. |
| ext    | extension to be used for dest files. |

Right aligned columns

| Option | Description |
| ------:| -----------:|
| data   | path to data files to supply the data that will be passed into templates. |
| engine | engine to be used for processing templates. Handlebars is the default. |
| ext    | extension to be used for dest files. |
```

---

| Option | Description |
| ------ | ----------- |
| data   | path to data files to supply the data that will be passed into templates. |
| engine | engine to be used for processing templates. Handlebars is the default. |
| ext    | extension to be used for dest files. |

Right aligned columns

| Option | Description |
| ------:| -----------:|
| data   | path to data files to supply the data that will be passed into templates. |
| engine | engine to be used for processing templates. Handlebars is the default. |
| ext    | extension to be used for dest files. |

# Links

```markdown
[link text](http://dev.nodeca.com)

[link with title](http://nodeca.github.io/pica/demo/ "title text!")

Autoconverted link https://github.com/nodeca/pica (enable linkify to see)

```

---

[link text](http://dev.nodeca.com)

[link with title](http://nodeca.github.io/pica/demo/ "title text!")

Autoconverted link https://github.com/nodeca/pica (enable linkify to see)

# Images
```markdown
![Minion](https://octodex.github.com/images/minion.png)
```

---

![Minion](https://octodex.github.com/images/minion.png)

# [Footnotes](https://github.com/markdown-it/markdown-it-footnote)

```markdown
Footnote 1 link[^first].

Footnote 2 link[^second].

Inline footnote^[Text of inline footnote] definition.

Duplicated footnote reference[^second].

[^first]: Footnote **can have markup**

    and multiple paragraphs.

[^second]: Footnote text.
```

---

Footnote 1 link[^first].

Footnote 2 link[^second].

Inline footnote^[Text of inline footnote] definition.

Duplicated footnote reference[^second].

[^first]: Footnote **can have markup**

    and multiple paragraphs.

[^second]: Footnote text.

# Task Lists

~~~markdown
Task lists can be used as a checklist of items that have been completed.
Example:

```
- [x] Complete task
- [ ] Incomplete task
```

This will render as:

> - [x] Complete task
> - [ ] Incomplete task
~~~

---

Task lists can be used as a checklist of items that have been completed.
Example:

```
- [x] Complete task
- [ ] Incomplete task
```

This will render as:

> - [x] Complete task
> - [ ] Incomplete task

# Blog Specific

Things to figure out 
- [ ] How to add date / time for the blog. Shortcut for adding current time
- [ ] Adding the coffee place and template
