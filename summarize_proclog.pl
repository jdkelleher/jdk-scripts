#!/usr/bin/perl
#
# 1997-09-25 - JDK - Made it work...
# 1997-10-09 - JDK - Killed time tweaking it...
# 2003-12-29 - JDK - changed the path to perl
#


use Sys::Hostname;
use Time::Local;
use Getopt::Std;

getopts('h');

$Help = $opt_h;

undef $opt_h;


$Usage_Message= '
Usage: summarize_proclog.pl [-h] [logfile]
	-h this message

	If no logfile is specified, defaults to $HOME/.procmail.log
	"-" will cause summarize_proclog.pl to read STDIN

';

if ( $Help ) {
    print $Usage_Message;
    exit 0;
}

$Log_File = shift (@ARGV);

$Log_File ||= "$ENV{HOME}/.procmail.log";

if ( $Log_File eq '-' ) {
    open (LOG,"<&STDIN") or die "Can't open STDIN: $! $Usage_Message";
} else {
    open (LOG,"<$Log_File") or die "Can't open $Log_File: $! $Usage_Message";
}

# $Host = hostname();
# ( $Domain ) = $Host =~ /.*\.(.+\..+)$/;
$Domain = 'susq.com';


%Month = (
	    'Jan' => '00',
	    'Feb' => '01',
	    'Mar' => '02',
	    'Apr' => '03',
	    'May' => '04',
	    'Jun' => '05',
	    'Jul' => '06',
	    'Aug' => '07',
	    'Sep' => '08',
	    'Oct' => '09',
	    'Nov' => '10',
	    'Dec' => '11',
);

while ( <LOG> ) {

    next if /^procmail: /;

    if ( /^From (\S+)  \w\w\w (\w\w\w) {1,2}(\d{1,2}) (\d{2}):(\d{2}):(\d{2}) \d{2}(\d{2})$/ ) {
	$From = $1;
	$Month = $Month{$2};
	$Mday = $3;
	$Hour = $4;
	$Min = $5;
	$Sec = $6;
	$Year = $7;

	$When = timelocal( $Sec, $Min, $Hour, $Mday, $Month, $Year );

	$Log_Start ||= $When;

	# Cleanup from address.
	$From =~ tr/[A-Z]/[a-z]/;	# Un-cap.
	$From =~ s/.*<(.*)>.*/$1/;
	# $From =~ s/\@.*//;		# lose the host part
	$From =~ s/\%.*//;		# lose the indirect host part
	$From =~ s/.*!([^!]+)$/$1/;	# lose the uucp host part

	$From =~ s/\@.*:(.+\@.+)/$1/;	# lose weird stuff

	$From =~ s/\@[\S+]*$Domain$//;	# Strip off local domain.

	$From ||= '<>';			# Replace a null w/ the "null" address.

    }

    elsif ( /^ Subject: (.+)$/ ) {
	$Subject = $1;
    }

    elsif ( /^  Folder: (.+)\s+(\d+)$/ ) {
	$Folder = $1;
	$Size = $2;
	$Folder =~ s/\s+$//;

	$Senders{$From}{'TOT_MESG'} ++ ;
	$Senders{$From}{'TOT_SIZE'} += $Size ;
	$Senders{$From}{'F_TOT_MESG'}{$Folder} ++ ;
	$Senders{$From}{'F_TOT_SIZE'}{$Folder} += $Size ;

	$Tot_Folders{$Folder} ++ ;
	$Tot_Msg ++ ;
	$Tot_Bytes += $Size ;
    }

}

$Log_Finish = $When;

if ($Log_Start == $Log_Finish) {
    $Days_Elapsed = 1;
} else {
    $Days_Elapsed = ($Log_Finish - $Log_Start) / (24*60*60);
}


print "\nProcmail Log Report:\n\n";

( $Sec, $Min, $Hour, $Mday, $Month, $Year) = localtime( $Log_Start );
printf "\n Log Start      : %.4d-%.2d-%.2d %.2d:%.2d:%.2d", $Year+1900, $Month, $Mday, $Hour, $Min, $Sec;
( $Sec, $Min, $Hour, $Mday, $Month, $Year) = localtime( $Log_Finish );
printf "\n Log Finish     : %.4d-%.2d-%.2d %.2d:%.2d:%.2d", $Year+1900, $Month, $Mday, $Hour, $Min, $Sec;

printf "\n Days Elapsed   : %-5.2f", $Days_Elapsed;

printf "\n Total Msgs     : %-5d", $Tot_Msg;
printf "\n Total KB       : %-5d", ($Tot_Bytes / 1024);
printf "\n Avg Msgs/Day   : %-5.2f", ($Tot_Msg / $Days_Elapsed);
printf "\n Avg KB/Day     : %-5.2f", (($Tot_Bytes / 1024) / $Days_Elapsed);
print "\n\n";

print " Folder Summary:\n\n";
foreach $Folder ( sort( keys %Tot_Folders ) ) {
    printf("    %4d messages (%05.2f%%) delivered to \"%s\".\n",
	    $Tot_Folders{$Folder}, (100 * $Tot_Folders{$Folder} / $Tot_Msg),
	    $Folder);
}

print "\n\n";

print " Sender Summary:\n\n";
foreach $From ( sort( keys %Senders ) ) {
    print "    From: \"$From\"\n";
    foreach $Folder ( sort( keys %{ $Senders{$From}{'F_TOT_MESG'} } ) ) {
	printf("\t  %4d (%05.2f%%) message(s) delivered to \"%s\".\n",
		$Senders{$From}{'F_TOT_MESG'}{$Folder},
		(100 * $Senders{$From}{'F_TOT_MESG'}{$Folder} / $Tot_Msg),
		$Folder);
    }
    printf("\t  ----\n\t  %4d (%05.2f%%) total message(s).\n",
	    $Senders{$From}{'TOT_MESG'},
	    (100 * $Senders{$From}{'TOT_MESG'} / $Tot_Msg) );
    print "\n";

}


