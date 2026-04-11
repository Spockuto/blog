# Strong First or Weak First?

Try it yourself: [interactive calculator](https://llm-spec.pages.dev/)

When building an agent that generates code through multiple LLM calls, you face a choice: use a strong (expensive) model for the initial generation and fix bugs with a cheaper model, or generate cheaply and bring in the strong model to fix what broke?

At first glance, this looks like a simple pricing comparison. But several compounding effects make it surprisingly non-trivial. Let's build a mathematical model for it.

## The Two Strategies

**Strategy A (Strong &rarr; Weak):** Pay upfront for high-quality generation, then mop up residual bugs cheaply.

**Strategy B (Weak &rarr; Strong):** Generate cheaply, then deploy the strong model to fix what broke.

## Why It's Not Obvious

A strong model doesn't just produce *fewer* bugs &mdash; it produces fewer *hard* bugs. The bugs left by a strong model tend to be edge cases (off-by-one, missing imports) that a weak model can handle. The bugs left by a weak model are often architectural &mdash; wrong algorithm, subtle race conditions &mdash; which a weak model *also* can't fix.

Each fix attempt means feeding the full context back (growing token count), running the code (latency), and risking *new* bugs (regressions). The total cost isn't just generation + \\(N \times\\) fix_cost. It's more like a geometric series where each iteration has a probability of spawning further iterations.

And crucially: input and output tokens are priced differently.

## The Parameters

| Variable | Meaning |
| :--- | :--- |
| \\(c_m^{in},\\; c_m^{out}\\) | Input / output cost per token for model \\(m\\) |
| \\(L_0\\) | Initial prompt tokens |
| \\(G_0\\) | Output tokens for initial generation |
| \\(G\\) | Output tokens per fix attempt |
| \\(E\\) | Error trace tokens added per iteration |
| \\(q_m, \\;\phi_m\\) | Bug count and hard-bug fraction from model \\(m\\) |
| \\(p_m^e, \\;p_m^h\\) | Probability model \\(m\\) fixes an easy / hard bug per attempt |

We expect: \\(q_w > q_s\\), \\(\phi_w > \phi_s\\), \\(p_s^e > p_w^e\\), and \\(p_s^h \gg p_w^h\\).

## The Simplified Model (v1)

Assume constant context size (no growth between iterations), no regressions, no caching.

Each bug of difficulty \\(d\\) takes \\(1 / p_{fix}(m, d)\\) attempts in expectation (geometric distribution). The total expected fix iterations:

\\[I = \frac{(1 - \phi)\\, q}{p^e} + \frac{\phi\\, q}{p^h}\\]

With constant context \\(L_1 = L_0 + G_0\\), the cost per attempt is \\(c_m^{in} L_1 + c_m^{out} G\\). So:

**Strategy A** (strong generates, weak fixes):
\\[C_A = \underbrace{c_s^{in} L_0 + c_s^{out} G_0}_{\text{generation}} \\;+\\; I_A \cdot (c_w^{in} L_1 + c_w^{out} G)\\]

**Strategy B** (weak generates, strong fixes):
\\[C_B = \underbrace{c_w^{in} L_0 + c_w^{out} G_0}_{\text{generation}} \\;+\\; I_B \cdot (c_s^{in} L_1 + c_s^{out} G)\\]

Strategy A wins when:

\\[(c_s^{out} - c_w^{out}) G_0 + (c_s^{in} - c_w^{in}) L_0 \\;<\\; I_B(c_s^{in} L_1 + c_s^{out} G) - I_A(c_w^{in} L_1 + c_w^{out} G)\\]

The left side is the **generation premium**. The right side is the **fix savings**. Strategy A wins when the fix savings exceed the generation premium.

## Adding Context Growth (v2)

Now each attempt adds \\(\Delta = G + E\\) tokens to the context. Label all attempts globally as \\(t = 1, 2, \ldots, T\\). Attempt \\(t\\) sees context \\(L_1 + (t-1)\Delta\\).

The total cost of the fix phase:
\\[C_{fix} = T\\,(c^{in} L_1 + c^{out} G) \\;+\\; c^{in}\\,\frac{\Delta}{2}\\,T(T-1)\\]

Since \\(T = \sum_{i=1}^{n} N_i\\) where each \\(N_i \sim \text{Geom}(p_i)\\):

\\[\mathbb{E}[T] = I = \sum_i \frac{1}{p_i}, \qquad \text{Var}(T) = V = \sum_i \frac{1 - p_i}{p_i^2}\\]

Taking expectations:

\\[\boxed{\mathbb{E}[C_{fix}] = I\\,(c^{in} L_1 + c^{out} G) + c^{in}\\,\frac{\Delta}{2}\\,(I^2 + V - I)}\\]

The first term is the v1 answer (linear in \\(I\\)). The second term is the **context growth penalty** &mdash; and it's **quadratic** in \\(I\\).

## The Key Insight

The context growth penalty for each strategy:

| | Coefficient | Quadratic Term |
| :--- | :---: | :---: |
| Strategy A | \\(c_w^{in} \cdot \frac{\Delta}{2}\\) | \\(I_A^2 + V_A - I_A\\) |
| Strategy B | \\(c_s^{in} \cdot \frac{\Delta}{2}\\) | \\(I_B^2 + V_B - I_B\\) |

<mark>Strategy B gets hit twice:</mark>

1. **Higher coefficient** &mdash; the strong model's input price \\(c_s^{in}\\) multiplies the quadratic term.
2. **\\(I_B\\) is often still large** &mdash; even though the strong model fixes each bug faster, the weak model produces *many more* bugs. The product can keep \\(I_B\\) comparable to \\(I_A\\).

Meanwhile, Strategy A's quadratic term is multiplied by the *cheap* \\(c_w^{in}\\). Even if \\(I_A\\) is somewhat large, the dollar cost of that context bloat is small.

<mark>Strategy B forces the expensive model to read the most context.</mark> The strong model arrives late, when \\(L_t\\) is large, and pays its high input rate on all of it.

