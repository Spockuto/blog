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

Now each attempt adds \\(\Delta = G + E\\) tokens to the context. But how context accumulates depends on the agent architecture.

### Shared Conversation

All fix attempts happen in one continuous thread. Context never resets. Attempt \\(t\\) sees context \\(L_1 + (t-1)\Delta\\).

The total cost of the fix phase:
\\[C_{fix} = T\\,(c^{in} L_1 + c^{out} G) \\;+\\; c^{in}\\,\frac{\Delta}{2}\\,T(T-1)\\]

Since \\(T = \sum_{i=1}^{n} N_i\\) where each \\(N_i \sim \text{Geom}(p_i)\\):

\\[\mathbb{E}[T] = I = \sum_i \frac{1}{p_i}, \qquad \text{Var}(T) = V = \sum_i \frac{1 - p_i}{p_i^2}\\]

Taking expectations:

\\[\mathbb{E}[C_{fix}] = I\\,(c^{in} L_1 + c^{out} G) + c^{in}\\,\frac{\Delta}{2}\\,(I^2 + V - I)\\]

The \\(I^2\\) term means cost grows **quadratically** with total iterations. Bug 10's context includes all attempts from bugs 1&ndash;9.

### Fresh Context Per Bug

A well-designed agent resets context after each bug is fixed. Bug \\(i\\) gets a fresh conversation starting from \\(L_1\\). Only retries *within that bug* accumulate context.

For a single bug with fix probability \\(p_i\\), the number of attempts \\(N_i\\) is geometric. The expected cost:

\\[\mathbb{E}[\text{Cost}_i] = \frac{c^{in} L_1 + c^{out} G}{p_i} + c^{in}\\,\Delta\\,\frac{1 - p_i}{p_i^2}\\]

Summing across all bugs:

\\[\mathbb{E}[C_{fix}] = I\\,(c^{in} L_1 + c^{out} G) + c^{in}\\,\Delta\\, V\\]

The \\(I^2\\) cross-bug term vanishes. The penalty depends only on \\(V\\) (within-bug retry variance), not the square of total iterations. This makes the strategy comparison much tighter.

### Comparing the Two Models

| Context Model | Penalty Term |
| :--- | :--- |
| Shared conversation | \\(c^{in} \cdot \frac{\Delta}{2} \cdot (I^2 + V - I)\\) |
| Fresh per bug | \\(c^{in} \cdot \Delta \cdot V\\) |

The shared model has the \\(I^2\\) term &mdash; cross-bug context accumulation. The fresh model eliminates it entirely. In practice, most well-designed agents reset context between bugs, making the fresh model more realistic.

## Prompt Caching

Most providers offer prompt caching: repeated input prefixes are charged at a discount \\(\alpha\\) (typically 0.1, i.e. 90% off). Each fix attempt after the first reuses the previous input as a cached prefix, paying full price only on the new \\(\Delta\\) tokens.

The total input cost splits into new tokens (full price) and cached tokens (discounted):

\\[\text{new: } c^{in}(L_1 + (T-1)\Delta) \qquad \text{cached: } \alpha\\, c^{in}\left[(T-1)L_1 + \Delta\\,\frac{(T-1)(T-2)}{2}\right]\\]

The quadratic growth term is now multiplied by \\(\alpha\\) instead of 1. With \\(\alpha = 0.1\\), the context penalty drops by ~90%.

<mark>Caching benefits Strategy B more</mark> (it had the larger penalty). But caching only works within the same model &mdash; the generation-to-fix handoff always breaks the cache, so the first fix attempt pays full price on \\(L_1\\).

## Insights

<mark>Strategy B gets hit twice:</mark>

1. **Higher coefficient** &mdash; the strong model's input price \\(c_s^{in}\\) multiplies the penalty term.
2. **\\(I_B\\) is often still large** &mdash; even though the strong model fixes each bug faster, the weak model produces *many more* bugs. The product can keep \\(I_B\\) comparable to \\(I_A\\).

Meanwhile, Strategy A's penalty is multiplied by the *cheap* \\(c_w^{in}\\). Even if \\(I_A\\) is somewhat large, the dollar cost of that context bloat is small.

<mark>Strategy B forces the expensive model to read the most context.</mark> This holds under both context models, but the effect is dramatic in shared conversation mode.

## Related Work

**LLM Routing & Cascading:** [De Koninck et al. (ICLR 2025)](https://arxiv.org/abs/2410.10347) unify routing (pick one model) and cascading (try cheap first, escalate) into a single framework, achieving 97% of GPT-4 accuracy at 24% of the cost. However, these approaches assume fixed per-query cost and don't model context accumulation across iterations.

**Budget Reallocation:** [The Larger the Better? (2024)](https://arxiv.org/html/2404.00725v2) shows that given the same compute budget, running a smaller model multiple times can match or surpass a larger model. Closest in spirit to our model, but doesn't formalize the input/output cost asymmetry or context growth.

**The Advisor Pattern:** [Anthropic](https://www.anthropic.com/research/building-effective-agents) uses a cheap model as executor with Opus as an on-demand advisor. Sonnet + Opus advisor gains 2.7 points on SWE-bench at 11.9% less cost than Opus end-to-end. This is a third strategy &mdash; not Strategy A or B, but "weak does everything, strong reviews intermittently" &mdash; which sidesteps the context growth penalty by only invoking the expensive model on sparse planning checkpoints.

## Assumptions & Limitations

- **Constant \\(\Delta\\):** Every attempt adds the same tokens. In practice, error traces vary and later attempts may produce longer outputs.
- **No regressions:** Fixing a bug never introduces a new one. Real agents have regression rates that would add a branching factor.
- **Fixed cache rate:** The model uses a single \\(\alpha = 0.1\\) discount. Real caching has a TTL (e.g. 5 minutes) and the discount may vary by provider.
- **Uniform bug difficulty:** Bugs are either easy or hard. A continuous difficulty distribution would be more realistic but doesn't change the qualitative result.
