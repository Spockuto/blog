# It's Not Lupus — Diagnosing with House MD Data

Try it yourself: [house-md-diagnostics.pages.dev](https://house-md-diagnostics.pages.dev/)

What if you could feed symptoms into a machine and get back the differential diagnosis *House* would run? Not a generic medical model, but one that actually thinks like each doctor on the show — House's reckless leaps, Cameron's empathy-driven hunches, Foreman's methodical process?

That's what I built: a diagnostic engine trained on 176 parsed episodes of House MD, eight seasons of symptoms, misdiagnoses, red herrings, and last-minute saves.

## The Data

Every episode was parsed into structured data: the patient's symptoms (in order of appearance), every diagnosis each doctor suggested, whether it was correct, the treatments attempted, and the outcomes. The database tracks 9 doctors across ~300 unique symptoms and hundreds of diseases.

The schema links everything:

```sql
episode_symptoms   -- which symptoms appeared in which episode
diagnoses          -- who suggested what, with reasoning and correctness
doctor_disease_affinity  -- how often each doctor suggests each disease
doctor_symptom_patterns  -- when doctor X sees symptom Y, what do they reach for?
```

Some episodes have red herrings flagged — symptoms that were present but irrelevant. And key clues — the one symptom that finally cracked the case. These flags let the engine learn which symptoms actually matter.

## The Scoring Algorithm

Given a set of symptoms and a doctor, the engine produces a ranked list of diagnoses. The score for each disease is a weighted sum of three signals:

**Episode overlap (50%):** How many of the input symptoms appeared in past episodes where this disease was the diagnosis? If you enter "fever, rash, joint pain" and those exact three showed up in S03E14 where the answer was sarcoidosis, that's a strong match.

**Doctor affinity (20%):** How often does *this specific doctor* suggest this disease? House reaches for autoimmune conditions. Wilson sees cancer. Foreman suspects infections. The affinity is normalized against each doctor's most-suggested disease.

**Symptom patterns (30%):** When this doctor has seen this specific symptom before, what disease did they reach for? This captures individual diagnostic fingerprints — the same cough might make House think vasculitis while Cameron thinks allergic reaction.

The weights are:

```typescript
const WEIGHTS = {
  episode: 0.5,   // past case similarity
  affinity: 0.2,  // doctor's diagnostic tendencies
  pattern: 0.3    // symptom-specific associations
};
```

The final score is clamped to [0, 1] and the top 10 diagnoses are returned with supporting evidence — which episodes matched, what reasoning was used, and a generated explanation if no direct reasoning exists in the data.

## The Decision Tree

Beyond flat scoring, the engine builds a decision tree showing how each doctor would approach the case. Each branch represents a doctor, and their diagnoses are ranked underneath. This makes it easy to see where the doctors agree (convergent diagnoses are likely correct) and where they diverge (which is where House episodes get interesting).

Adding a new symptom recomputes the tree in real-time, showing a delta — how the scores shifted. This mimics the show's pattern where a new test result reshuffles the entire differential.

## What I Learned

The most interesting finding: the doctors are surprisingly predictable. House suggests rare autoimmune diseases at 3x the rate of any other doctor. Wilson's cancer suggestion rate is genuinely higher than average. And the "correct" diagnosis is almost never the first one suggested — the data confirms the show's dramatic structure isn't just TV drama, it's baked into every episode.

The engine doesn't pretend to be medically accurate. It's a pattern matcher over TV show data. But the scoring approach — combining case similarity, individual tendencies, and symptom-specific associations — generalizes nicely to any domain where you have experts with different biases making decisions under uncertainty.

