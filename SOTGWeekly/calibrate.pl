sub calibrateTemperature {
#  use strict;
  use Math::Complex;

  # calibrate the full and half tide and the atmospheric pressure sensors
  # Implemented from PJK's PHP code based on tech group PDFs
  # See http://bitech1.nbi.ac.uk/cals/digiquartz/ for calibrations
  # For St. Helena see 52804.pdf for the full tide sensor and 52806.pdf for
  # the half tide sensor. Barometer is 51453.pdf.
  # For Port Stanley full: 47594.pdf, half: 47598.pdf, barom: 39329.pdf
  # For Ascension full: 52798.pdf, half: 52802.pdf, barom: 40396.pdf.

  # calibrate the temperature sensor

  my @calTemperatureFreq;
  my @calTemperature;
  my %sensorCal;
  my $i=0;
  my $xx;

  my (@args) = @_;

  my $uncalTemperatureFreqRef = $args[0];
  my (@uncalTemperatureFreq) = @$uncalTemperatureFreqRef;
  my $pcode = $args[1];
  my $sensor = $args[2];

  my $uncalTemp;
  my $temp;

  my (%u);
  my (%y1);
  my (%y2);
  my (%y3);

# For solving cubic
  my $a1;
  my $a2;
  my $a3;
  my $Q;
  my $R;
  my $S;
  my $T;
  my $u1;
  my $u2;
  my $u3;

  my $arrayLength = scalar(@uncalTemperatureFreq);

  if ($pcode eq "STH") {
  # Temporarily set temperature constant at 25C
  # The frequency at 25C is 171915.51 Hz

    # Frequencies for 25C
#    $sensorCal{full}{STH}= 171915.51;
#    $sensorCal{half}{STH}= 171038.81;
#    $sensorCal{barom}{STH}= 169985.88;
#
#    while ($i<=$arrayLength) {
#      $calTemperatureFreq[$i] = $sensorCal{$sensor}{$pcode};
#      $i++;
#    }

    $i=0;
    while ($i<=$arrayLength-1) {
      if (($sensor eq "full") or ($sensor eq "half")){
        $uncalTemp=substr $uncalTemperatureFreq[$i],0,4;
      }
      elsif ($sensor eq "barom"){
        $uncalTemp=substr $uncalTemperatureFreq[$i],4,4;
      }
      else {
        die "Unknown sensor: $sensor";
      }

#      if ($sensor ne "barom") {print "$uncalTemp\n";}
      if ($sensor eq "barom") {
        if ($uncalTemp<5000){
          $calTemperatureFreq[$i] = ($uncalTemp*10 + 153000000)/900;
        }
        else {
          $calTemperatureFreq[$i] = ($uncalTemp*10 + 152900000)/900;
        }
      $sensorCal{barom}{STH}= 169985.88;
      $calTemperatureFreq[$i] = $sensorCal{$sensor}{$pcode};
    }
    else {
      if ($uncalTemp<9000){
        $calTemperatureFreq[$i] = ($uncalTemp*10 + 154700000)/900;
      }
      else {
        $calTemperatureFreq[$i] = ($uncalTemp*10 + 154600000)/900;
      }
    }

      $xx = 1.0e6/$calTemperatureFreq[$i];

      $u{full}{STH} = $xx - 5.823115;
      $y1{full}{STH} = -4033.597;
      $y2{full}{STH} = -10769.51;
      $y3{full}{STH} = 0;
 
      $u{half}{STH} = $xx - 5.852973;
      $y1{half}{STH} = -4007.901;
      $y2{half}{STH} = -10855.87;
      $y3{half}{STH} = 0;
 
      $u{barom}{STH} = $xx - 5.889287;
      $y1{barom}{STH} = -3951.799;
      $y2{barom}{STH} = -11829.43;
      $y3{barom}{STH} = -76570.32;
 
# For half tide need to calculate frequency assuming that temperature
# is the same as at the full sensor
      if ($sensor eq "half"){
        $temp = $y1{full}{$pcode}*$u{full}{$pcode} +
                $y2{full}{$pcode}*$u{full}{$pcode}**2 + 
                $y3{full}{$pcode}*$u{full}{$pcode}**3;
      }
      else {
        $temp = $y1{$sensor}{$pcode}*$u{$sensor}{$pcode} +
                $y2{$sensor}{$pcode}*$u{$sensor}{$pcode}**2 + 
                $y3{$sensor}{$pcode}*$u{$sensor}{$pcode}**3;
      }
#      print "$sensor: $temp $calTemperatureFreq[$i] $uncalTemp \n";
      $calTemperature[$i] = $temp;

# Calculate frequency for half tide 
      if ($sensor eq "half"){
# Solve cubic equation of the form D^3+a1*D^2+a2*D+a3=0

        $a1 = $y2{$sensor}{$pcode};
        $a2 = $y1{$sensor}{$pcode};
        $a3 = -$temp;

        $Q = (3*$a2-$a1**2)/9;
        $R = (9*$a1*$a2 - 27*$a3 - 2*$a1**3)/54;
        $S = ($R + sqrt($Q**3 + $R**2))**(1/3);
        $T = ($R - sqrt($Q**3 + $R**2))**(1/3);

        $u1 = $S+$T-$a1/3;
        $u2 = -0.5*($S+$T)-$a1/3 + 0.5*i*sqrt(3)*($S-$T);
        $u3 = -0.5*($S+$T)-$a1/3 - 0.5*i*sqrt(3)*($S-$T);

#        print "$sensor: $temp $calTemperatureFreq[$i] ",1.0e6/(($u3->Re())+5.852973),"\n";
        $calTemperatureFreq[$i] = 1.0e6/(($u3->Re())+5.852973);
      }

      $i++;
    }

  }
  elsif ($pcode eq "STN") {
  
    $i=0;
    while ($i<=$arrayLength-1) {
      #print "$i $uncalTemperatureFreq[$i]\n";
      if (($sensor eq "full") or ($sensor eq "half")){
        $uncalTemp=substr $uncalTemperatureFreq[$i],0,4;
      }
      elsif ($sensor eq "barom"){
        $uncalTemp=substr $uncalTemperatureFreq[$i],4,4;
      }
      else {
        die "Unknown sensor: $sensor";
      }

      $calTemperatureFreq[$i] = ($uncalTemp*1000 + 150000000)/900;

      $xx = 1.0e6/$calTemperatureFreq[$i];

      $u{full}{STN} = $xx - 5.865469;
      $y1{full}{STN} = -3938.830;
      $y2{full}{STN} = -11624.06;
      $y3{full}{STN} = 0;
 
      $u{half}{STN} = $xx - 5.840499;
      $y1{half}{STN} = -3954.996;
      $y2{half}{STN} = -9953.464;
      $y3{half}{STN} = 0;
 
      $u{barom}{STN} = $xx - 5.888218;
      $y1{barom}{STN} = -3944.243;
      $y2{barom}{STN} = -9512.474;
      $y3{barom}{STN} = -79482.70;
 
# For half tide need to calculate frequency assuming that temperature
# is the same as at the full sensor
      if ($sensor eq "half"){
        $temp = $y1{full}{$pcode}*$u{full}{$pcode} +
                $y2{full}{$pcode}*$u{full}{$pcode}**2 + 
                $y3{full}{$pcode}*$u{full}{$pcode}**3;
      }
      else {
        $temp = $y1{$sensor}{$pcode}*$u{$sensor}{$pcode} +
                $y2{$sensor}{$pcode}*$u{$sensor}{$pcode}**2 + 
                $y3{$sensor}{$pcode}*$u{$sensor}{$pcode}**3;
      }
      $calTemperature[$i] = $temp;
#      print "$sensor: $temp $calTemperatureFreq[$i] \n";

# Calculate frequency for half tide 
      if ($sensor eq "half"){
# Solve cubic equation of the form D^3+a1*D^2+a2*D+a3=0

        $a1 = $y2{$sensor}{$pcode};
        $a2 = $y1{$sensor}{$pcode};
        $a3 = -$temp;

        $Q = (3*$a2-$a1**2)/9;
        $R = (9*$a1*$a2 - 27*$a3 - 2*$a1**3)/54;
        $S = ($R + sqrt($Q**3 + $R**2))**(1/3);
        $T = ($R - sqrt($Q**3 + $R**2))**(1/3);

        $u1 = $S+$T-$a1/3;
        $u2 = -0.5*($S+$T)-$a1/3 + 0.5*i*sqrt(3)*($S-$T);
        $u3 = -0.5*($S+$T)-$a1/3 - 0.5*i*sqrt(3)*($S-$T);

#        print "$temp $calTemperatureFreq[$i] ",1.0e6/($u3+5.840499),"\n";
        $calTemperatureFreq[$i] = 1.0e6/(($u3->Re())+5.840499);
      }

      $i++;
    }
  
  }
  elsif ($pcode eq "ASC") {
  
    $i=0;
    while ($i<=$arrayLength-1) {
      if (($sensor eq "full") or ($sensor eq "half")){
        $uncalTemp=substr $uncalTemperatureFreq[$i],0,4;
      }
      elsif ($sensor eq "barom"){
        $uncalTemp=substr $uncalTemperatureFreq[$i],4,4;
      }
      else {
        die "Unknown sensor: $sensor";
      }

      $calTemperatureFreq[$i] = ($uncalTemp*1000 + 150000000)/900;

      $xx = 1.0e6/$calTemperatureFreq[$i];

      $u{full}{ASC} = $xx - 5.888566;
      $y1{full}{ASC} = -3952.707;
      $y2{full}{ASC} = -8216.861;
      $y3{full}{ASC} = 0;
 
      $u{half}{ASC} = $xx - 5.885643;
      $y1{half}{ASC} = -3991.858;
      $y2{half}{ASC} = -9495.301;
      $y3{half}{ASC} = 0;
 
      $u{barom}{ASC} = $xx - 5.868378;
      $y1{barom}{ASC} = -3940.583;
      $y2{barom}{ASC} = -12200.66;
      $y3{barom}{ASC} = -74718.35;
 
# For half tide need to calculate frequency assuming that temperature
# is the same as at the full sensor
      if ($sensor eq "half"){
        $temp = $y1{full}{$pcode}*$u{full}{$pcode} +
                $y2{full}{$pcode}*$u{full}{$pcode}**2 + 
                $y3{full}{$pcode}*$u{full}{$pcode}**3;
      }
      else {
        $temp = $y1{$sensor}{$pcode}*$u{$sensor}{$pcode} +
                $y2{$sensor}{$pcode}*$u{$sensor}{$pcode}**2 + 
                $y3{$sensor}{$pcode}*$u{$sensor}{$pcode}**3;
      }
      $calTemperature[$i] = $temp;
#      print "$sensor: $temp $calTemperatureFreq[$i] \n";

# Calculate frequency for half tide 
      if ($sensor eq "half"){
# Solve cubic equation of the form D^3+a1*D^2+a2*D+a3=0

        $a1 = $y2{$sensor}{$pcode};
        $a2 = $y1{$sensor}{$pcode};
        $a3 = -$temp;

        $Q = (3*$a2-$a1**2)/9;
        $R = (9*$a1*$a2 - 27*$a3 - 2*$a1**3)/54;
        $S = ($R + sqrt($Q**3 + $R**2))**(1/3);
        $T = ($R - sqrt($Q**3 + $R**2))**(1/3);

        $u1 = $S+$T-$a1/3;
        $u2 = -0.5*($S+$T)-$a1/3 + 0.5*i*sqrt(3)*($S-$T);
        $u3 = -0.5*($S+$T)-$a1/3 - 0.5*i*sqrt(3)*($S-$T);

#        print "$temp $calTemperatureFreq[$i] ",1.0e6/($u3+5.840499),"\n";
        $calTemperatureFreq[$i] = 1.0e6/(($u3->Re())+5.840499);
      }

      $i++;
    }
  
  }
  else {
    die "No temperature calibration data for $pcode.";
  }
 
  return (\@calTemperature, \@calTemperatureFreq);

}
#
sub calibratePressure {
  use strict;

  # calibrate the full and half tide and the atmospheric pressure sensors
  # Implemented from PJK's PHP code based on tech group PDFs
  # See http://bitech1.nbi.ac.uk/cals/digiquartz/ for calibrations
  # For St. Helena see 52804.pdf for the full tide sensor and 52806.pdf for
  # the half tide sensor. Barometer is 51453.pdf.
  # For Port Stanley full: 47594.pdf, half: 47598.pdf, barom: 39329.pdf
  # For Ascension full: 52798.pdf, half: 52802.pdf, barom: 40396.pdf.

  my $tt;
  my (@t);
  my $xx;

  my $i=0;
  my (@calPressure);
  my (%u);

  my $c;
  my (%c1);
  my (%c2);
  my (%c3);

  my $d;
  my (%d1);
  my (%d2);

  my $t0;
  my (%t1);
  my (%t2);
  my (%t3);
  my (%t4);
  my (%t5);

  my ($uncalPressureRef,$calTemperatureFreqRef,$sensor,$pcode) = @_;

  my (@uncalPressure) = @$uncalPressureRef;
  my $arrayLength = @uncalPressure;

  my (@u0) = @$calTemperatureFreqRef;

  if ($pcode eq "STH"){

    while ($i<=$arrayLength-1){
      $t[$i] = 1.0e6*900/$uncalPressure[$i];
      $xx = 1.0e6/$u0[$i];
      $u{full}{STH}[$i] = $xx - 5.823115;
      $u{half}{STH}[$i] = $xx - 5.852973;
      $u{barom}{STH}[$i] = $xx - 5.889287;
      $i++;
    }
  
    $c1{full}{STH} = 159.5939;
    $c2{full}{STH} = 9.109378;
    $c3{full}{STH} = -150.7572;
  
    $c1{half}{STH} = 156.9344;
    $c2{half}{STH} = 6.747811;
    $c3{half}{STH} = -193.8653;
  
    $c1{barom}{STH} = 98.64581;
    $c2{barom}{STH} = 5.247898;
    $c3{barom}{STH} = -4.290904;
  
    $d1{full}{STH} = 0.040102;
    $d2{full}{STH} = 0.0;
  
    $d1{half}{STH} = 0.040277;
    $d2{half}{STH} = 0.0;
  
    $d1{barom}{STH} = 0.0303598;
    $d2{barom}{STH} = 0.0;
  
    $t1{full}{STH} = 27.82787;
    $t2{full}{STH} = 0.715570;
    $t3{full}{STH} = 19.05110;
    $t4{full}{STH} = 4.353405;
    $t5{full}{STH} = 0.0;
  
    $t1{half}{STH} = 27.76589;
    $t2{half}{STH} = 0.760686;
    $t3{half}{STH} = 19.08705;
    $t4{half}{STH} = 17.35064;
    $t5{half}{STH} = 0.0;
  
    $t1{barom}{STH} = 27.7378;
    $t2{barom}{STH} = 0.6948245;
    $t3{barom}{STH} = 21.37803;
    $t4{barom}{STH} = -83.26278;
    $t5{barom}{STH} = 230.2109;
  }
  elsif ($pcode eq "STN"){

    while ($i<=$arrayLength-1){
      $t[$i] = 1.0e6*900/$uncalPressure[$i];
      $xx = 1.0e6/$u0[$i];
      $u{full}{STN}[$i] = $xx - 5.865469;
      $u{half}{STN}[$i] = $xx - 5.840499;
      $u{barom}{STN}[$i] = $xx - 5.888218;
      $i++;
    }
  
    $c1{full}{STN} = 170.1850;
    $c2{full}{STN} = 19.33537;
    $c3{full}{STN} = -179.2651;
  
    $c1{half}{STN} = 158.1860;
    $c2{half}{STN} = 19.04567;
    $c3{half}{STN} = -250.4845;
  
    $c1{barom}{STN} = 79.69945;
    $c2{barom}{STN} = 8.584987;
    $c3{barom}{STN} = -65.22164;
  
    $d1{full}{STN} = 0.053872;
    $d2{full}{STN} = 0.0;
  
    $d1{half}{STN} = 0.051338;
    $d2{half}{STN} = 0.0;
  
    $d1{barom}{STN} = 0.0317997;
    $d2{barom}{STN} = 0.0;
  
    $t1{full}{STN} = 24.77546;
    $t2{full}{STN} = 0.553960;
    $t3{full}{STN} = 18.30473;
    $t4{full}{STN} = -4.457570;
    $t5{full}{STN} = 0.0;
  
    $t1{half}{STN} = 25.14587;
    $t2{half}{STN} = 0.622776;
    $t3{half}{STN} = 20.03718;
    $t4{half}{STN} = 53.83743;
    $t5{half}{STN} = 0.0;
  
    $t1{barom}{STN} = 25.65153;
    $t2{barom}{STN} = 0.7074395;
    $t3{barom}{STN} = 16.71619;
    $t4{barom}{STN} = -76.69237;
    $t5{barom}{STN} = 297.3296;
  }
  elsif ($pcode eq "ASC"){

    while ($i<=$arrayLength-1){
      $t[$i] = 1.0e6*900/$uncalPressure[$i];
      $xx = 1.0e6/$u0[$i];
      $u{full}{ASC}[$i] = $xx - 5.888566;
      $u{half}{ASC}[$i] = $xx - 5.885643;
      $u{barom}{ASC}[$i] = $xx - 5.868378;
      $i++;
    }
  
    $c1{full}{ASC} = 157.5165;
    $c2{full}{ASC} = 6.291081;
    $c3{full}{ASC} = -154.3899;
  
    $c1{half}{ASC} = 156.0824;
    $c2{half}{ASC} = 5.891324;
    $c3{half}{ASC} = -185.9152;
  
    $c1{barom}{ASC} = 90.58498;
    $c2{barom}{ASC} = 10.81598;
    $c3{barom}{ASC} = -55.17671;
  
    $d1{full}{ASC} = 0.037188;
    $d2{full}{ASC} = 0.0;
  
    $d1{half}{ASC} = 0.042935;
    $d2{half}{ASC} = 0.0;
  
    $d1{barom}{ASC} = 0.0385970;
    $d2{barom}{ASC} = 0.0;
  
    $t1{full}{ASC} = 27.74250;
    $t2{full}{ASC} = 0.594122;
    $t3{full}{ASC} = 16.69608;
    $t4{full}{ASC} = -14.78994;
    $t5{full}{ASC} = 0.0;
  
    $t1{half}{ASC} = 27.82972;
    $t2{half}{ASC} = 0.738496;
    $t3{half}{ASC} = 19.69450;
    $t4{half}{ASC} = 28.21768;
    $t5{half}{ASC} = 0.0;
  
    $t1{barom}{ASC} = 24.71486;
    $t2{barom}{ASC} = 0.6063469;
    $t3{barom}{ASC} = 16.84818;
    $t4{barom}{ASC} = -77.31372;
    $t5{barom}{ASC} = 96.72570;
  }
  else {
    die "No pressure calibration data for $pcode.";
  }

# Equations (from pdf files)

  $i=0;
  while ($i<=$arrayLength-1) {
    $c = $c1{$sensor}{$pcode} + $c2{$sensor}{$pcode}*$u{$sensor}{$pcode}[$i] 
	+ $c3{$sensor}{$pcode}*$u{$sensor}{$pcode}[$i]**2;
    $d = $d1{$sensor}{$pcode} + $d2{$sensor}{$pcode}*$u{$sensor}{$pcode}[$i];
    $t0 = $t1{$sensor}{$pcode} + $t2{$sensor}{$pcode}*$u{$sensor}{$pcode}[$i] 
	+ $t3{$sensor}{$pcode}*$u{$sensor}{$pcode}[$i]**2 
	+ $t4{$sensor}{$pcode}*$u{$sensor}{$pcode}[$i]**3 
	+ $t5{$sensor}{$pcode}*$u{$sensor}{$pcode}[$i]**4;

    $tt = $t0**2/$t[$i]**2;
    $calPressure[$i] = $c*(1-$tt)*(1-($d*(1-$tt)));
# Convert to mb 
    $calPressure[$i] = $calPressure[$i]*68.94757;
    $i++;
  }

  return (\@calPressure);

}

