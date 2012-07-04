sub setEnv {
  use strict;

  # test to see if oracle has been setup, if not set it up 
  # assumes linux at present
  if ($ENV{NERCARCH} eq "linux") {
 
    unless (grep /SETUP_ORACLE/, keys %ENV){
      $ENV{ORACLE_ULOGIN} = "oracle/ulogin";
      $ENV{SETUP_ORACLE} = "8.1.7";
      $ENV{ORACLE_USERID} = "user/pass";
      $ENV{ORACLE_PAGER} = "more";
      $ENV{ORACLE_SID} = "AAA";
      $ENV{ORACLE_DOC} = "/packages/oracle/product/8.1.7/oracle_doc";
      $ENV{ORACLE_HOME} = "/packages/oracle/product/8.1.7";
      $ENV{ORACLE_LPPROG} = "lpr";
      $ENV{ORACLE_BASE} = "/packages/oracle";
      $ENV{ORACLE_LPSTAT} = "lpq";
      $ENV{SQLPATH}=
        "/users/simonh/sql:/users/simonh:/packages/oracle/ncs/nercsql";
      $ENV{NERC_ORANCS}="/packages/oracle/ncs";
      $ENV{TNS_ADMIN}="/packages/oracle/product/8.1.7/network/admin";
      $ENV{NLS_DATE_FORMAT}="DD-MON-FXYYYY";
      $ENV{TWO_TASK}="BIA";
      $ENV{NERC_SQL}="/packages/oracle/ncs/nercsql";
      $ENV{SDD_HOME}="/packages/oracle/product/8.1.7/dict50/admin";
      my $LD_LIBRARY_PATH = $ENV{LD_LIBRARY_PATH};
      $ENV{LD_LIBRARY_PATH}=
	$LD_LIBRARY_PATH.":/packages/oracle/product/8.1.7/lib";
      my $PATH = $ENV{PATH};
      $ENV{PATH}=
        $PATH.":/users/simonh/bin/:/packages/oracle/product/8.1.7/bin";
    }
  }
  else { 
    unless (grep /SETUP_ORACLE/, keys %ENV){
      die "Not using linux: need to setup Oracle first";
    }
  }

}
