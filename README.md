sotgWeekly - version 1.10 15 September 2003

A tool to process "fast" Southern Ocean tide gauge data from the Coastal 
Observatory database so that it can be sent to the University of Hawaii on a
weekly basis.

SYNOPSIS

        ./sotgWeekly.pl <port_code>

DESCRIPTION

Emails are received hourly from Southern Ocean tide B-gauges. The emails contain pressure data from the full and half tide sensors along with temperature and barometer readings. These emails are banked in the Coastal Observatory Oracle database (cobsadmin.sotgmail) with an email identification tag and a time stamp.

sotgWeekly takes an argument of <port_code> which must be one of:
STH for St. Helena,
ASC for Ascension Island or
STN for Port Stanley

At present the St. Helena calibration assumes a fixed temperature (and hence a fixed frequency) for the barometer since the overspill on the temperature channel makes reconstructing temperature too difficult. In v0.99 "proper" temperature calibration was added for Port Stanley and this should also work for Ascension (when the gauge is fixed). The calibration values need to be checked for Ascension however.

The "lastDate.txt" file is read from the $HOME/data/SOTG/<port_code>/ directory. The time stamp in that file has the format yyyy.ddd.sssss and gives the date of the last email read from the database when the program was last run. If the program is run for the first time, the file must contain the date after which data is to be processed.

Data since lastDate is read and calibrated. A TASK format file is then produced which will be subsequently processed with a "triplec" type program to convert the B-gauge data to sea level. The TASK file is checked for data continuity and missing data replaced with -999.99 and flagged with a 1 in channel 2.

Finally a new lastDate.txt file is written containing the time stamp of the last email processed.

Changelog:

v1.10 15 September 2003.
Altered St. Helena code to calibrate temperature for half and full tide
sensors. The calibration for the barmometer is still not carried out due to
overspill problem and defaults to a fixed temperature of 25C. The full and
half tide calibration is still a bit of a bodge since it assumes a temperature
range that fits with the chosen frequencies - in practice it is hard to see
that this temperature range exceeded.

V1.00 22 April 2003. 
Bug fixed in renaming old lastDate.txt file to lastDate.txt.bak. Updated to
version 1.00 as now fully operational for St. Helena and Port Stanley.
 
AUTHOR

Simon Holgate <simonh@pol.ac.uk>

