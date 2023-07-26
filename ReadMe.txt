Data Quality Assurance/Quality Control for long-term ecological monitoring datasets -- SITE LEVEL


Scripts built here create tables and figures to be used in data qaqc reporting by the Inventory and 
Monitoring Division of NPS. 
This toolkit may be used for other ecological datasets, however some consideration should be given 
to their basic form. The underlying assumption of every function here is that there are within the 
data multiple visits to a single location across years - i.e., that it is a monitoring dataset. 
Missing value and outlier summaries may be compiled for any ecological dataset, however resample rate 
and variance summaries require duplication of sampling effort at a single site within a year. 


Each file in site_level_qaqc should produce ONE figure or table,
though often figures will be multi-panel


The input dataset MUST BE SUMMARIZED TO THE SAME LEVEL 
i.e. all plot-level, all transect-level, all sub-plot-level.

E.g., KLMN surveys mature trees on either stream bank at each transect 
along a reach, for a total of 22 trees (max) per reach. These can be 
qaqc'ed as an individual dataset (transect-level legacy tree completeness/
resample rate/variance) or can be summarized to the reach level and the 
selected summary stat (likely average) qaqc'ed. 


Parameters to define:
- Park: The four-letter park code, to be used for grouping 
- Unit: the ID column, the site code that identifies where data were collected
- Date: the date, in mm/dd/yyyy format 
- Ten_Duplicate*: partial-site resample events, may be of only a single 
  parameter or several, noted in a binary 0/1 format
- Site_Duplicate*: whole-site resample events noted in a binary 0/1 format
* duplicate columns are used in resample rate and variance calculations, 
  but are not necessary for missing values and outliers. 



Key to files in this collection:

   ##  TABLES  ##
Missing_tbl.R
write.csv (unformatted) and save_html (formatted) output options for a table 
of // Percent Completeness of the Data at the Scale Of Analysis // 
where the scale of analysis is set by the input dataset selected by the user. 

Resamp_tbl.R
write.csv (unformatted) and save_html (formatted) output options for a table 
of // Resample Rate of both Site-Wide and Parameter-Specific Duplicates //
Both site and ten duplicates (whole site repeat measures and single or several 
variable repeat measured) are included in calculations

Outliers_tbl.R
TWO FILES
write.csv (unformatted) and save_html (formatted) output options for a table 
of // Rate and Number of Outliers in each Variable Cluster //  Columns are,
In order:
Vital sign abbreviation, number of records, number of outlying records, percent
outlying, and a list of column names in the vital sign group. 
AND
write.csv (unformatted) and save_html (formatted) output options for a table 
of // Number of Outliers in Each Park and Year // 


   ##  FIGURES  ##
Outliers_scatter.R
Scatterplots! Each parameter (e.g. Nitrogen, wood volume, HBI score) is a 
separate plot, points are color coded by unit (park)

Var_Interann_line.R
Line plots! Each parameter is a separate file, each park is a separate panel, 
and the change at each sampling unit

Var_Resamp_box.R
Boxplots! side-by-side comparison of CV for 10% vs site resamples, should I do a 
paired t test to say concretely they are/n't different?