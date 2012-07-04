sub readOracle {

  # query the database for the records since the last file read

  use strict;
  use DBI;

  # local variables
  my @date;
  my @uncalFullTide;
  my @uncalHalfTide;
  my @uncalBarometer;
  my @uncalTemperature;
  my $i=0;
  my $j;
  my $lengthRow;
  my @lastRow;

  my (@args) = @_;
  my $firstDate = $args[0];
  my $pcode = $args[1];
  
  my $dbh = DBI->connect('DBI:Oracle:', 'user', 'pass',
	{ RaiseError => 1, AutoCommit => 0 }) 
	or die $DBI::errstr;

  my $statement = qq{
	alter session set nls_date_format='yyyy.ddd.sssss'
  };
  my $sth = $dbh->prepare($statement);
  my $rc = $sth->execute;

  $statement = qq{
	select datim, fulltide, halftide, barom, tempvals 
	from cobsadmin.sotgmail
	where pcode='$pcode' 
	and datim > to_date ('$firstDate','yyyy.ddd.sssss') 
	order by datim
  };
  $sth = $dbh->prepare($statement);
  $rc = $sth->execute;

  ROW: while ( my @row = $sth->fetchrow_array ) {
# Check that the values from the database are numeric
    $j=1;
    $lengthRow = $#row;
    while ( $j <= $lengthRow ){
      if (defined $row[$j]) {
        $_ = $row[$j];
      }
      else{
        warn "Missing data:- date:$row[0] record:$i field:$j\n";
        next ROW;
      }
      $_ = $row[$j];
      if (/.[^\d.]/){
        warn "Problem with data:- date: $row[0] record:$i field:$j data:$row[$j]\n";
        next ROW if /.[^\d.]/;
      }
      $j++;
    }
    $date[$i] = $row[0];
    $uncalFullTide[$i] = $row[1];
    $uncalHalfTide[$i] = $row[2];
    $uncalBarometer[$i] = $row[3];
    $uncalTemperature[$i] = $row[4];

    $i++;
    @lastRow = @row;
  }

  $sth->finish;
  $rc = $dbh->disconnect or warn $dbh->errstr;
  
#  $i=58;
#  while ( $i<=61 ){
#    print "$date[$i] $uncalFullTide[$i] $uncalHalfTide[$i] $uncalBarometer[$i] $uncalTemperature[$i]\n";
#    $i++;
#  }
  return ( \@date, \@uncalFullTide, \@uncalHalfTide,
	 \@uncalBarometer, \@uncalTemperature );

}
