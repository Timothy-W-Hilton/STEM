This repository provides the source code for the The Sulfur Transport
and dEposition Model (STEM).

STEM is an Eulerian atmospheric transport and chemistry model
developed at
the
[University of Iowa](https://cgrer.uiowa.edu/projects/chemical-transport-model).
STEM has successfully simulated aerosol distribution and outflow over
Asia as well as atmospheric trace gas concentrations over North
America.

Song and Carmichael (2001) provides a detailed conceptual description
of the STEM modeling framework.  The other references below describe
subsequent enhancements to the model as well as modeling studies that
employed it.

This source code repository also contains an adjoint model developed
to quantitatively estimate STEM parameter values as well as surface
fluxes that optimally match atmospheric observations.  For more
information about the STEM adjoint please see: Daescu and Carmichael,
2003; Hakami et al., 2005; Sandu et al., 2005; Chai et al., 2006

### Credits ###

If presenting or publishing STEM simulations, in addition to the appropriate citations from the list below please acknowledge the [University of Iowa Center for Global & Regional Environmental Research](https://cgrer.uiowa.edu) and the [Carmichael Group](https://www.engineering.uiowa.edu/faculty-staff/gregory-carmichael) for their work developing the STEM framework.

### Branches ###

IMPORTANT: It is very likely that you do not want the "master" branch
from this repository.

There are several parallel branches in this repository configured for
different computing platforms.  The 'master' branch contains the
common roots of those branches but is not currently useful for
simulations.

1. GNU_compilers: STEM configured to compile with
   the [GNU Fortran compiler](https://gcc.gnu.org/fortran/) and run
   at [PIC](https://www.pic.es).  Also contains edits to adjust the
   surface COS flux at each time step to use the previous time step's
   simulated COS concentration rather than an assumed COS
   concentration.
2. NERSC_fwd: STEM configured to compile with the Intel Fortran
   compiler (ifort) and run at NERSC (http://www.nersc.gov).
2. adjust_COS_to_previous_tstep_gara_domain:

### Prerequisites for a STEM simulation ###

1. Set the STEM domain dimensions in Include/aqms.param
2. Compile and link STEM
3. assemble driver data, specified by ["logical names"](https://www.cmascenter.org/ioapi/documentation/all_versions/html/LOGICALS.html) according to [EDSS/Models-3 I/O API](https://www.cmascenter.org/ioapi/documentation/all_versions/html/index.html) convention.  STEM needs these input files
   * METEO2D: 2-dimensional meteorology
   * METEO3D: 3-dimensional meteorology
   * DOMAIN (a.k.a. TOPO): latitude, longitude, and topography
   * EMHOURLY: surface emissions
   * INITF: initial species concentrations
   * BDF: lateral boundary conditions
   * TOPBND: vertical (i.e. top) boundary conditions
4. create a run file that specifies the logical names for driver data

### Running STEM ###

The STEM source builds two executables: *_main.exe and *_fun.exe,
where * represents a prefix specific to the simulation.  main.exe sets
up the model domain and writes some initialization data to disk.
fun.exe then reads those data and computes transport for each model
grid cell and time step.  fun.exe may be run in parallel, with
multipile processors computing several grid cells/time steps
simultaneously.  Therefore, main.exe must be run before parallel
fun.exe tasks are dispatched.

So, the sequence for running a STEM simulation goes something like:

1. run *_main.exe
2. run *_fun.exe, possibly in parallel.

There is no need to re-run *_main.exe unless the STEM domain or
initial conditions have changed.

### References ###

Campbell, J. E., G. R. Carmichael, Y. Tang, T. Chai, S. A. Vay, Y.-H. Choi, G. W. Sachse, H. B. Singh, J. L. Schnoor, J. Woo, J. M. Vukovich, D. G. Streets, L. G. Huey, and C. O. Stanier (2007), Analysis of anthropogenic CO2 signal in ICARTT using a regional chemical transport model and observed tracers, Tellus B, 59(2), 199-210, http://dx.doi.org/10.1111/j.1600-0889.2006.00239.x.

Carmichael, G. R., Y. Tang, G. Kurata, I. Uno, D. Streets, J.-H. Woo, H. Huang, J. Yienger, B. Lefer, R. Shetter, D. Blake, E. Atlas, A. Fried, E. Apel, F. Eisele, C. Cantrell, M. Avery, J. Barrick, G. Sachse, W. Brune, S. Sandholm, Y. Kondo, H. Singh, R. Talbot, A. Bandy, D. Thorton, A. Clarke, and B. Heikes (2003), Regional-scale chemical transport modeling in support of the analysis of observations obtained during the TRACE-P experiment, Journal of Geophysical Research: Atmospheres, 108(D21), http://dx.doi.org/10.1029/2002JD003117.

Carmichael, G. R., B. Adhikary, S. Kulkarni, A. D’Allura, Y. Tang, D. Streets, Q. Zhang, T. C. Bond, V. Ramanathan, A. Jamroensan, and P. Marrapu (2009), Asian Aerosols: Current and Year 2030 Distributions and Implications to Human Health and Regional Climate Change, Environmental Science & Technology, 43(15), 5811-5817, http://dx.doi.org/10.1021/es8036803.

Daescu, D. N., and G. R. Carmichael (2003), An Adjoint Sensitivity Method for the Adaptive Location of the Observations in Air Quality Modeling, Journal of the Atmospheric Sciences, 60(2), 434–450, http://dx.doi.org/10.1175/1520-0469(2003)060<0434:AASMFT>2.0.CO;2.

Hakami, A., D. K. Henze, J. H. Seinfeld, T. Chai, Y. Tang, G. R. Carmichael, and A. Sandu (2005), Adjoint inverse modeling of black carbon during the Asian Pacific Regional Aerosol Characterization Experiment, Journal of Geophysical Research: Atmospheres, 110(D14), http://dx.doi.org/10.1029/2004JD005671.

Kulkarni, S., N. Sobhani, J. P. Miller-Schulze, M. M. Shafer, J. J. Schauer, P. A. Solomon, P. E. Saide, S. N. Spak, Y. F. Cheng, H. A. C. Denier van der Gon, Z. Lu, D. G. Streets, G. Janssens-Maenhout, C. Wiedinmyer, J. Lantz, M. Artamonova, B. Chen, S. Imashev, L. Sverdlik, J. T. Deminter, B. Adhikary, A. D’Allura, C. Wei, and G. R. Carmichael (2015), Source sector and region contributions to BC and PM2.5 in Central Asia, Atmospheric Chemistry and Physics, 15(4), 1683-1705, http://dx.doi.org/10.5194/acp-15-1683-2015.

Sandu, A., D. N. Daescu, G. R. Carmichael, and T. Chai (2005), Adjoint sensitivity analysis of regional air quality models, Journal of Computational Physics, 204(1), 222-252, http://dx.doi.org/http://dx.doi.org/10.1016/j.jcp.2004.10.011.

Song, C. H., and G. R. Carmichael (2001), A three-dimensional modeling investigation of the evolution processes of dust and sea-salt particles in east Asia, Journal of Geophysical Research: Atmospheres, 106(D16), 18131-18154, http://dx.doi.org/10.1029/2000JD900352.

Tang, Y., G. R. Carmichael, I. Uno, J.-H. Woo, G. Kurata, B. Lefer, R. E. Shetter, H. Huang, B. E. Anderson, M. A. Avery, A. D. Clarke, and D. R. Blake (2003), Impacts of aerosols and clouds on photolysis frequencies and photochemistry during TRACE-P: 2. Three-dimensional study using a regional chemical transport model, Journal of Geophysical Research: Atmospheres, 108(D21), http://dx.doi.org/10.1029/2002JD003100.

Tang, Y., G. R. Carmichael, J. H. Seinfeld, D. Dabdub, R. J. Weber, B. Huebert, A. D. Clarke, S. A. Guazzotti, D. A. Sodeman, K. A. Prather, I. Uno, J.-H. Woo, J. J. Yienger, D. G. Streets, P. K. Quinn, J. E. Johnson, C.-H. Song, V. H. Grassian, A. Sandu, R. W. Talbot, and J. E. Dibb (2004), Three-dimensional simulations of inorganic aerosol distributions in east Asia during spring 2001, Journal of Geophysical Research: Atmospheres, 109(D19), http://dx.doi.org/10.1029/2003JD004201.
