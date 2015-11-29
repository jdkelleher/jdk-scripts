#!/usr/bin/perl -s

use diagnostics;
use warnings;

use File::Basename;

$verbose |= 0;
$encode = 1;
$inplace |= 0;
$dryrun |= 0;

if ( scalar(@ARGV) < 1 ) {
	print "Usage: ", basename($0), " [-verbose] [-inplace] [-dryrun] file1 [file2 ...]\n";
}

foreach $file (@ARGV) {

	next if (! -e $file);

#	$identify_output = `identify -format '%[EXIF:DateTimeOriginal] %e' '$file' 2> /dev/null`;
#
#	chomp($identify_output);
#	# print "\"$identify_output\"\n";
#	#if ($identify_output !~ /^\d{4}:\d{2}:\d{2} \d{2}:\d{2}:\d{2}\. \S+/) {
#	if ($identify_output =~ /^(\d{4}):(\d{2}):(\d{2}) (\d{2}):(\d{2}):(\d{2})\. (\S+)/) {
#		# ($date, $time, $extension) = split(/\s/, $identify_output);
#		# ($year, $month, $day) = split(/:/, $date);
#		# ($hour, $minute, $second) = split(/:/, $time);
#		$year = $1;
#		$month = $2;
#		$day = $3;
#		$hour = $4;
#		$minute = $5;
#		$second = $6;
#		$extension = $7;
#		print $file, ":\t", $extension, "\t", join("-", $year, $month, $day), " ", join(":",
#			$hour, $minute, $second), "\n" if ($verbose);
#	} else {
#		print "Error: Could not identify ${file}.\n";
#		next;
#	}


#	exif:DateTimeOriginal=2004:11:05 13:30:43

	my $identify_status = 0;
	if ( not open( IDENTIFY, "identify -format '%[EXIF:*]EXT %e' '$file' |" ) ) {
		print "Error: Could not identify ${file}.\n";
		next;
	}
	while ( <IDENTIFY> ) {
		chomp;
		if ( /^exif:DateTimeOriginal=(\d{4}):(\d{2}):(\d{2}) (\d{2}):(\d{2}):(\d{2})/ ) {
			$year = $1;
			$month = $2;
			$day = $3;
			$hour = $4;
			$minute = $5;
			$second = $6;
			$identify_status++;
			print $file, ":\t", join("-", $year, $month, $day), " ", join(":", $hour, $minute, $second), "\n" if ($verbose);
		}
		if ( /^EXT (.+)/ ) {
			$extension = $1;
			$identify_status++;
			print $file, ":\t", $extension, "\n" if ($verbose);
		}
	}
	if ( $identify_status < 2 ) {
		print "Error: Could not obtain necessary data to rename ${file}.\n";
		next;
	}
	# print $file, ":\t", $extension, "\t", join("-", $year, $month, $day), " ", join(":", $hour, $minute, $second), "\n" if ($verbose);

	if ($encode) {

		$year = $year;
		$month = pack("c", $month+96);	# Month is 1-12
		$day = $day;
		$hour = pack("c", $hour+96);	# Hour is 0-23
		$minute = $minute;
		$second = $second;
		$extension = $extension;

		print $file, ":\t", join("", $year, $month, $day, $hour, $minute, $second), '.',
			$extension, "\n" if ($verbose);

	}

	$newfile = join("", $year, $month, $day, $hour, $minute, $second) . '.' . $extension;

	$i = 1;
	while ( -f $newfile ) {
		$newfile = join("", $year, $month, $day, $hour, $minute, $second) . "-${i}" . '.' . $extension;
		$i++;
	}

	if ($inplace) {
		print "mv ", $file, , " ", $newfile, "\n" if ($verbose);
		system("mv", $file, $newfile) if (not $dryrun);
	} else {
		print "cp -p ", $file, " ", $newfile, "\n" if ($verbose);
		system("cp", $file, $newfile) if (not $dryrun);
	}


}
