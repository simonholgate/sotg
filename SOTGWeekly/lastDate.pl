sub readLastDate {
  use strict;

  # read in date of last file processed
  # format yyyy.ddd.sssss

  my (@args) = @_;
  my $pcode = $args[0];
  
  my $fileName="$ENV{HOME}/data/SOTG/$pcode/lastDate.txt";

  open (FNAME,$fileName) || die "Couldn't open $fileName: $!";
  my $firstDate = <FNAME>; # Read in line
  chomp $firstDate; # get rid of newline
  close (FNAME) || die "Couldn't close $fileName: $!";

  return $firstDate;
}
#
sub writeLastDate {
  use File::Copy;

  @args = @_;

  my $pcode = $args[1];

  # write out date of last file processed
  # format yyyy.ddd.sssss

  my $fileName="$ENV{HOME}/data/SOTG/$pcode/lastDate.txt";

#  rename $fileName, "$fileName.bak" || die "Couldn't copy to $fileName.bak: $!";
  copy($fileName, "$fileName.bak") || die "Couldn't copy to $fileName.bak: $!";

  open (FILE,">".$fileName) || die "Couldn't open $fileName: $!";
  write (FILE); # write to fileName with format defined below
  close (FILE) || die "Couldn't close $fileName: $!";

}
# Assume left justified 14 character number in the form yyyy.ddd.sssss
format FILE =
@<<<<<<<<<<<<<<
$args[0]
. 
