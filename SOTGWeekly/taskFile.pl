sub order {

  use strict;

  # check that there are no missing records from the data.
  # Delete duplicates and replace missing data with flagged records.

  # local variables

  my $i=0;
  my $year;
  my $day;
  my $second;

  my $lastYear;
  my $lastDay;
  my $lastSecond;

  my $secDiff=0;
  my $refDiff=0;

  my @date;
  my @flag;

  my @calFullTide;
  my @calHalfTide;
  my @calBarometer;
  my @calTemperature;
  my @calAtmosTemperature;

  my ($calFullTideRef, $calHalfTideRef, $calBarometerRef,
      $calTemperatureRef, $calAtmosTemperatureRef, $dateRef) = @_;

  @calFullTide = @$calFullTideRef;
  @calHalfTide = @$calHalfTideRef;
  @calBarometer = @$calBarometerRef;
  @calTemperature = @$calTemperatureRef;
  @calAtmosTemperature = @$calAtmosTemperatureRef;
  @date = @$dateRef;

  while ($i < scalar(@date)) {
    ($year,$day,$second) = split /\./, $date[$i], 3;

    $flag[$i] = 0; 

    if ($i==1) {

      if ($day==$lastDay) {
        $refDiff = $second-$lastSecond;
      }
      else {
        $refDiff = $second+86400-$lastSecond;
      }
    }
    
    if ($i>0){
      
      $secDiff = $second-$lastSecond;
      if ($secDiff < 0) { $secDiff = $secDiff+86400; }
      if (($secDiff != $refDiff) and ($secDiff+86400 != $refDiff)) {

        while ($secDiff > $refDiff) {
	  $lastSecond = $lastSecond+$refDiff;
          $flag[$i] = 1;
          splice @date, $i, 0, "$year.$day.$lastSecond";
          splice @calFullTide, $i, 0, "0.01";
          splice @calHalfTide, $i, 0, "0.01";
          splice @calBarometer, $i, 0, "0.01";
          splice @calTemperature, $i, 0, "0.01";
          splice @calAtmosTemperature, $i, 0, "0.01";
          $secDiff = $second-$lastSecond;
          $i++; 
        }
        $flag[$i] = 0;
       
      }
    }

    $lastYear = $year;
    $lastSecond = $second;
    $lastDay = $day;

    $i++; 
  }

  return  (\@calFullTide, \@calHalfTide, \@calBarometer, \@calTemperature, 
	   \@calAtmosTemperature, \@date, \@flag);
}
#
sub writeTaskFile {

  use strict;
  use Math::Complex;

  # write outa TASK 2000 format file containing the data for processing by 
  # "triplec" B-gauge program. 

  # local variables
  my $i;
  my $j;
  my @calFullTide;
  my @calHalfTide;
  my @calBarometer;
  my @calTemperature;
  my @calAtmosTemperature;
  my @date;
  my @flag;
  my $year;
  my $day;
  my $second;
  my $hour;
  my @output;

  my ($calFullTideRef, $calHalfTideRef, $calBarometerRef, $calTemperatureRef, 
      $calAtmosTemperatureRef, $dateRef, $flagRef, $pcode) = @_;

  @calFullTide = @$calFullTideRef;
  @calHalfTide = @$calHalfTideRef;
  @calBarometer = @$calBarometerRef;
  @calTemperature = @$calTemperatureRef;
  @calAtmosTemperature = @$calAtmosTemperatureRef;
  @date = @$dateRef;
  @flag = @$flagRef;

  #  Write to file using TASK format defined below
  #  Write 20 lines of header
  #  First 8 are blank followed by channel info.
 
  my $fileName="$ENV{HOME}/data/SOTG/$pcode/tira.$pcode";

  open (FNAME,">$fileName") || die "Couldn't open $fileName: $!";
  for $j ( 0 .. 8 ) {
    print FNAME "\n";
  }
  
  print FNAME " Channel  1   Sequence\n";
  print FNAME " Channel  2   Flag\n";
  print FNAME " Channel  3   Year\n";
  print FNAME " Channel  4   Day\n";
  print FNAME " Channel  5   Hour/Min/Second\n";
  print FNAME " Channel  6   Sea temperature from full tide sensor\n";
  print FNAME " Channel  7   Pressure for full tide (millibars) - 1000\n";
  print FNAME " Channel  8   Pressure for half tide (millibars) - 1000\n";
  print FNAME " Channel  9   Atmospheric temperature\n";
  print FNAME " Channel  10  Atmospheric pressure (millibars)\n";
  print FNAME "\n";

  # Write array
  for $j ( 0 .. $#calFullTide ) {
    ($year,$day,$second) = split /\./, $date[$j], 3;
  #  Convert seconds since midnight to hour plus fraction of hour
   $hour = ($second - $second%3600)/3600 + ($second%3600)/3600;
    if ($pcode eq "STH"){
      push @output, ( $j+1, $flag[$j], $year, $day, $hour, $calTemperature[$j],
           $calFullTide[$j]-1000, 
	   $calHalfTide[$j]-1000,
           $calAtmosTemperature[$j], $calBarometer[$j] );
    }
    else {
# NB for Port Stanley, atmospheric pressure - 1000 is required due to spline
# parameters. This is not be generally true so check for Ascension or other
# ports which are added at a later date.
      push @output, ( $j+1, $flag[$j], $year, $day, $hour, $calTemperature[$j],
           $calFullTide[$j]-1000, 
	   $calHalfTide[$j]-1000,
           $calAtmosTemperature[$j], $calBarometer[$j]-1000 );
    }

    printf FNAME "%6d%2d%5d%4d%7.3f%8.2f%8.2f%8.2f%8.2f%8.2f\n",
    $output[0],$output[1],$output[2],$output[3],$output[4],$output[5],
    $output[6],$output[7],$output[8],$output[9];

  # Reset array to empty
    for $i ( 0 .. 9 ) {
      pop @output;
    }
    
  }

  # Now close the file
  close(FNAME) || die "Couldn't close $fileName: $!";

  # Move on to next filename
  shift(@ARGV);
  close(FNAME);
}
