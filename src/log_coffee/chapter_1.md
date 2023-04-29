# Why u so mean?

For a quadratic equation of the form \\( x^2 + Bx + C = 0\\), the roots of the equation is given by \\[\frac{-B \\pm \sqrt{B^2 - 4C}}{2}\\] where 
* sum of the roots = \\(-B \\)
* product of the roots = \\(C\\)

This is the representation everyone is most familiar with and widely used in high school. However, recently another representation has been proposed which offers much more intuition and further simplifies the equation. 

Let the Arithimetic Mean of the roots be \\( M = -B / 2\\). Simplyfying the roots, we have 
\\[\frac{-B \\pm \sqrt{B^2 - 4C}}{2}\\]
\\[(-B/2) \pm \sqrt{B^2/4 - 4C/4}\\]
\\[(-B/2) \pm \sqrt{(-B/2)^2 - C}\\]
\\[M \pm \sqrt{M^2 - C}\\]

This representation for roots is much more simpler, as one needs to just evaluate the mean in the beginning to solve the roots of the equation.

## Why?
Since the roots are equidistant from their mean, let's represent the roots as \\(M + u\\) and \\(M - u\\)
Hence, product of the roots \\[C = (M + u)(M-u)\\]
\\[C = M^2 - u^2\\]
\\[u^2 = M^2 - C\\]
\\[u = \sqrt{M^2 - C}\\]
Substituting \\(u\\) in the roots, we have the roots \\(M + \sqrt{M^2 - C}\\) and \\(M - \sqrt{M^2 - C}\\)


> An interesting result which is much more obvious this way.
If the roots are real, then 
\\[M^2 - C \gt 0\\]
\\[M \gt \sqrt{C}\\]
\\[M \gt GM \\] where GM is the geomertric mean of roots given by \\(\sqrt{C}\\)

Credits to [Po-Shen Loh](https://www.poshenloh.com/) for this improved and intuitive representation.
