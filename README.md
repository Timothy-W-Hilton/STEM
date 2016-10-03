This repository provides the source code for the The Sulfur Transport
and dEposition Model (STEM).

STEM is an Eulerian atmospheric transport and chemistry model
developed at
the
[University of Iowa](https://cgrer.uiowa.edu/projects/chemical-transport-model).
STEM has successfully simulated aerosol distribution and outflow over
Asia as well as atmospheric trace gas concentrations over North
America.

Carmichael et al. (2001) provides a detailed conceptual description of
the STEM modeling framework.  The other references below describe
subsequent enhancements to the model as well as modeling studies that
employed it.

This source code repository also contains an adjoint model developed
to quantitatively estimate STEM parameter values as well as surface
fluxes that optimally match atmospheric observations.  More
information about the STEM adjoint please see: Daescu and Carmichael,
2003; Hakami et al., 2005; Sandu et al., 2005; Chai et al., 2006

### References ###

```html
<div class="references">
<p>Campbell, J. E., G. R. Carmichael, Y. Tang, T. Chai, S. A. Vay, Y.-H. Choi, G. W. Sachse, H. B. Singh, J. L. Schnoor, J. Woo, J. M. Vukovich, D. G. Streets, L. G. Huey, and C. O. Stanier (2007), Analysis of anthropogenic CO<span class="math"><em></em><sub>2</sub></span> signal in ICARTT using a regional chemical transport model and observed tracers, <em>Tellus B</em>, <em>59</em>(2), 199–210, doi:<a href="http://dx.doi.org/10.1111/j.1600-0889.2006.00239.x">10.1111/j.1600-0889.2006.00239.x</a>.</p>
<p>Carmichael, G. R., Y. Tang, G. Kurata, I. Uno, D. Streets, J.-H. Woo, H. Huang, J. Yienger, B. Lefer, R. Shetter, D. Blake, E. Atlas, A. Fried, E. Apel, F. Eisele, C. Cantrell, M. Avery, J. Barrick, G. Sachse, W. Brune, S. Sandholm, Y. Kondo, H. Singh, R. Talbot, A. Bandy, D. Thorton, A. Clarke, and B. Heikes (2003), Regional-scale chemical transport modeling in support of the analysis of observations obtained during the TRACE-P experiment, <em>Journal of Geophysical Research: Atmospheres</em>, <em>108</em>(D21), n/a–n/a, doi:<a href="http://dx.doi.org/10.1029/2002JD003117">10.1029/2002JD003117</a>.</p>
<p>Carmichael, G. R., B. Adhikary, S. Kulkarni, A. D’Allura, Y. Tang, D. Streets, Q. Zhang, T. C. Bond, V. Ramanathan, A. Jamroensan, and P. Marrapu (2009), Asian Aerosols: Current and Year 2030 Distributions and Implications to Human Health and Regional Climate Change, <em>Environmental Science &amp; Technology</em>, <em>43</em>(15), 5811–5817, doi:<a href="http://dx.doi.org/10.1021/es8036803">10.1021/es8036803</a>.</p>
<p>Daescu, D. N., and G. R. Carmichael (2003), An Adjoint Sensitivity Method for the Adaptive Location of the Observations in Air Quality Modeling, <em>Journal of the Atmospheric Sciences</em>, <em>60</em>(2), 434–450, doi:<a href="http://dx.doi.org/10.1175/1520-0469(2003)060&lt;0434:AASMFT&gt;2.0.CO;2">10.1175/1520-0469(2003)060&lt;0434:AASMFT&gt;2.0.CO;2</a>.</p>
<p>Hakami, A., D. K. Henze, J. H. Seinfeld, T. Chai, Y. Tang, G. R. Carmichael, and A. Sandu (2005), Adjoint inverse modeling of black carbon during the Asian Pacific Regional Aerosol Characterization Experiment, <em>Journal of Geophysical Research: Atmospheres</em>, <em>110</em>(D14), n/a–n/a, doi:<a href="http://dx.doi.org/10.1029/2004JD005671">10.1029/2004JD005671</a>.</p>
<p>Kulkarni, S., N. Sobhani, J. P. Miller-Schulze, M. M. Shafer, J. J. Schauer, P. A. Solomon, P. E. Saide, S. N. Spak, Y. F. Cheng, H. A. C. Denier van der Gon, Z. Lu, D. G. Streets, G. Janssens-Maenhout, C. Wiedinmyer, J. Lantz, M. Artamonova, B. Chen, S. Imashev, L. Sverdlik, J. T. Deminter, B. Adhikary, A. D’Allura, C. Wei, and G. R. Carmichael (2015), Source sector and region contributions to BC and PM<span class="math"><em></em><sub>2.5</sub></span> in Central Asia, <em>Atmospheric Chemistry and Physics</em>, <em>15</em>(4), 1683–1705, doi:<a href="http://dx.doi.org/10.5194/acp-15-1683-2015">10.5194/acp-15-1683-2015</a>.</p>
<p>Sandu, A., D. N. Daescu, G. R. Carmichael, and T. Chai (2005), Adjoint sensitivity analysis of regional air quality models, <em>Journal of Computational Physics</em>, <em>204</em>(1), 222–252, doi:<a href="http://dx.doi.org/http://dx.doi.org/10.1016/j.jcp.2004.10.011">http://dx.doi.org/10.1016/j.jcp.2004.10.011</a>.</p>
<p>Song, C. H., and G. R. Carmichael (2001), A three-dimensional modeling investigation of the evolution processes of dust and sea-salt particles in east Asia, <em>Journal of Geophysical Research: Atmospheres</em>, <em>106</em>(D16), 18131–18154, doi:<a href="http://dx.doi.org/10.1029/2000JD900352">10.1029/2000JD900352</a>.</p>
<p>Tang, Y., G. R. Carmichael, I. Uno, J.-H. Woo, G. Kurata, B. Lefer, R. E. Shetter, H. Huang, B. E. Anderson, M. A. Avery, A. D. Clarke, and D. R. Blake (2003), Impacts of aerosols and clouds on photolysis frequencies and photochemistry during TRACE-P: 2. Three-dimensional study using a regional chemical transport model, <em>Journal of Geophysical Research: Atmospheres</em>, <em>108</em>(D21), n/a–n/a, doi:<a href="http://dx.doi.org/10.1029/2002JD003100">10.1029/2002JD003100</a>.</p>
<p>Tang, Y., G. R. Carmichael, J. H. Seinfeld, D. Dabdub, R. J. Weber, B. Huebert, A. D. Clarke, S. A. Guazzotti, D. A. Sodeman, K. A. Prather, I. Uno, J.-H. Woo, J. J. Yienger, D. G. Streets, P. K. Quinn, J. E. Johnson, C.-H. Song, V. H. Grassian, A. Sandu, R. W. Talbot, and J. E. Dibb (2004), Three-dimensional simulations of inorganic aerosol distributions in east Asia during spring 2001, <em>Journal of Geophysical Research: Atmospheres</em>, <em>109</em>(D19), n/a–n/a, doi:<a href="http://dx.doi.org/10.1029/2003JD004201">10.1029/2003JD004201</a>.</p>
</div>
```
