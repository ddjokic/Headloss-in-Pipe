Headloss in pipes
======================

Octave/Matlab Script to calculate pipe H-Q curve, using <u>Darcy-Weisbach formula</u>.

file: dwheadloss.m</p>
language: octave (matlab can be used)</p>
units: mm, m, cSt, cum/h (cubic meter per hour)</p>
results: txt file, dxf and png graphs</p>
<u>Note:</u> pressure loss is expressed as Head Loss in meters</p> 

Open file "dwcurve.m" in text editor and edit variables - pipe inner diameter, roughness, number and type of valves and fittings, pipe tag etc. Note that viscosity, Pipe ID, Pipe roughness, Flow and "OtherIDmm (Reducer/Enlargement ID)" can not be "0". Variable marked as "User" allows user to input total K-factor for unlisted fitting(s). Run file in octave.</p>
If you do not like provided Local (Minor) Losses, just input number of all fittings as '0' and your preferable total loss (sum of number_of_fitting * K-factor) as "User" loss. </p>
Friction coefficient in turbulent regime is calculated by use of [Colebrook Equation](http://en.wikipedia.org/wiki/Colebrook%E2%80%93White_equation#Colebrook_equation). Solution in Octave is obtained using [fzero](http://octave.sourceforge.net/octave/function/fzero.html) function.</p>Results are written to "txt", "png" and "dxf"- file. Filename is composed from LineTag and variable name.</p>
Good online reference of Darcy-Weisbach equation can be found [here](http://en.wikipedia.org/wiki/Darcy–Weisbach_equation).</p>

Example:</p>
**pipe tag: FiFi200**</p>
results: FiFi200-Results.txt</p>
Reynolds number: rey-FiFi200.png and dxf</p>
Velocity:velocity-FiFi200.png and dxf </p>
Headloss diagram: headloss-FiFi200.png and dxf</p>
All diagrams are given as function of flow (f(Q))</p>

<u>Edit, ddjokic, Feb-2013:</u></p>
Files "LossFactorCalc.ods" and "LossFactorCalc.xls" added to enable user to manipulate predefined k-factors for each fitting,
except Contraction and Enlargement, which must be calculated by main script. See workbook "Notes" for more.</p>
Files ods and xls are the same - use one or the other, depending on your spreadsheet program.</p>
</p>

<u>Edit Mar-2013</u>: as all three of you do not feel confortable to input data in main script, from editor, folder zXLS had
been added, with template file(s) in xls and ods format and octave script dwflocsv.m, capable to read data in comma separated 
format. Read sort of manual in worksheet "Note" and edit your data in worksheet "input". </p>

Script comes with **ABSOLUTELY NO WARRANTY**.</p>

Copyright © 2012 - 2013 D. Djokic
