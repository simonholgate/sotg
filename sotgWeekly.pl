#!/usr/bin/perl -w

# sotgWeekly <port_code>
#
# Intended to be called weekly from a cron job to process 'fast' sea levels
# for the University of Hawaii.
#
# Queries database and gathers pressure and temperature data for the Southern
# Ocean tide gauge whose port code is given on the command line. The emails
# since the program was last called are processed. The temperatures and
# pressures are calibrated into physical units then a TASK format file
# is written out along with and appropriate control file. The TASK format file
# is intended to be processed with a "triplec" type B-gauge program to convert
# pressures to sea levels.
#
 
use strict;

# subroutines
do "/users/simonh/bin/perl/SOTGWeekly/setEnv.pl";
do "/users/simonh/bin/perl/SOTGWeekly/calibrate.pl";
do "/users/simonh/bin/perl/SOTGWeekly/lastDate.pl";
do "/users/simonh/bin/perl/SOTGWeekly/readOracle.pl";
do "/users/simonh/bin/perl/SOTGWeekly/taskFile.pl";

my $i=0;
my $flagRef=0;
my $pcode = $ARGV[0];

setEnv();
my $firstDate = readLastDate($pcode);

my($dateRef,$uncalFullTideRef,$uncalHalfTideRef,$uncalBarometerRef,
	$uncalTemperatureFreqRef) = readOracle($firstDate,$pcode);

# calibrate temperature
# temperatures for both sensors and atmosphere temporarily fixed at 25C
my ($calFullTemperatureRef, $calFullTemperatureFreqRef) = 
	calibrateTemperature($uncalTemperatureFreqRef,$pcode,'full');
my ($calHalfTemperatureRef, $calHalfTemperatureFreqRef) = 
	calibrateTemperature($uncalTemperatureFreqRef,$pcode,'half');
my ($calAtmosTemperatureRef, $calAtmosTemperatureFreqRef) = 
	calibrateTemperature($uncalTemperatureFreqRef,$pcode,'barom');

# calibrate barometer
# send uncalibrated temperature when sorted out
my $calBarometerRef = calibratePressure ($uncalBarometerRef,
	$calAtmosTemperatureFreqRef,'barom',$pcode);

# calibrate full and half tide sensors
# send uncalibrated temperature when sorted out
my $calFullTideRef = calibratePressure ($uncalFullTideRef,
	$calFullTemperatureFreqRef, 'full',$pcode);
my $calHalfTideRef = calibratePressure ($uncalHalfTideRef,
	$calHalfTemperatureFreqRef, 'half',$pcode);

# check continuity of data for TASK file and pad for missing data

($calFullTideRef, $calHalfTideRef, $calBarometerRef, $calFullTemperatureRef, 
  $calAtmosTemperatureRef, $dateRef, $flagRef) = 
  order($calFullTideRef, $calHalfTideRef, $calBarometerRef, 
        $calFullTemperatureRef, $calAtmosTemperatureRef, $dateRef);

# write out TASK format file

writeTaskFile($calFullTideRef, $calHalfTideRef, $calBarometerRef,
      $calFullTemperatureRef, $calAtmosTemperatureRef, $dateRef, 
      $flagRef, $pcode);

# write out control file

my (@date) = @$dateRef;
my $lastDate = $date[$#date];
#print "$lastDate\n";
writeLastDate($lastDate,$pcode);

__END__
#===============================================================================
#==== Documentation
#===============================================================================
=pod

=head1 NAME

sotgWeekly - version 1.10 15 September 2003

A tool to process "fast" Southern Ocean tide gauge data from the Coastal 
Observatory database so that it can be sent to the University of Hawaii on a
weekly basis.

=head1 SYNOPSIS

        ./sotgWeekly.pl <port_code>

=head1 DESCRIPTION

Emails are received hourly from Southern Ocean tide B-gauges. The emails contain pressure data from the full and half tide sensors along with temperature and barometer readings. These emails are banked in the Coastal Observatory Oracle database (cobsadmin.sotgmail) with an email identification tag and a time stamp.

sotgWeekly takes an argument of <port_code> which must be one of:
STH for St. Helena,
ASC for Ascension Island or
STN for Port Stanley

At present the St. Helena calibration assumes a fixed temperature (and hence a fixed frequency) for the barometer since the overspill on the temperature channel makes reconstructing temperature too difficult. In v0.99 "proper" temperature calibration was added for Port Stanley and this should also work for Ascension (when the gauge is fixed). The calibration values need to be checked for Ascension however.

The "lastDate.txt" file is read from the $HOME/data/SOTG/<port_code>/ directory. The time stamp in that file has the format yyyy.ddd.sssss and gives the date of the last email read from the database when the program was last run. If the program is run for the first time, the file must contain the date after which data is to be processed.

Data since lastDate is read and calibrated. A TASK format file is then produced which will be subsequently processed with a "triplec" type program to convert the B-gauge data to sea level. The TASK file is checked for data continuity and missing data replaced with -999.99 and flagged with a 1 in channel 2.

Finally a new lastDate.txt file is written containing the time stamp of the last email processed.

=head2 Changelog:

v1.10 I<15 September 2003.>
Altered St. Helena code to calibrate temperature for half and full tide
sensors. The calibration for the barmometer is still not carried out due to
overspill problem and defaults to a fixed temperature of 25C. The full and
half tide calibration is still a bit of a bodge since it assumes a temperature
range that fits with the chosen frequencies - in practice it is hard to see
that this temperature range exceeded.

V1.00 I<22 April 2003.> 
Bug fixed in renaming old lastDate.txt file to lastDate.txt.bak. Updated to
version 1.00 as now fully operational for St. Helena and Port Stanley.
 
=head1 AUTHOR

Simon Holgate <simonh@pol.ac.uk>

=cut

