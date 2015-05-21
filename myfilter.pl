#!/usr/bin/perl
# MySQL_Binlog_Table_Filter
# By Chen.Zhidong
# njutczd+gmail.com

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
use strict;
use Getopt::Long;

my $version = "1.0";

my %opt = (
		"tables"=>"",
		"enable-drop"=>0,
		"enable-truncate"=>0,
		"src"=>"",
	);

GetOptions(\%opt,
		"tables=s",
		"enable-drop",
		"enable-truncate",
		"src=s",
		"help"
	) || die usage();

sub usage {
	print "\n".
	"    MySQL Exported Binlog Filter $version\n".
	"    Options:\n".
	"        --tables <tablenames>       export tables in tablenames, deliminate by ","\n".
	"        --enable-drop               enable DROP, optional, default disabled\n".
	"        --enable-truncate           enable TRUNCATE, optional, default disabled\n".
	"        --src <exported sql file>   read from sql file\n".
	"        --help                      print help message\n".
	"\n".
	"    Example:\n".
	"        $0 --tables hello,hi --enable-drop --enable-truncate --src src.sql\n".
	"\n";
	exit;
}

if(defined $opt{'help'} && $opt{'help'}) { usage(); }

if($opt{'tables'} eq "" || $opt{'src'} eq "")
{
	usage();
}

open(FILE,"<",$opt{'src'}) || die "can not open file $opt{'src'}\n";

my @tables=split(/,/,$opt{'tables'});

my $block="";
my $line="";
my $end_log_pos=0;
my $matchfilter=0;

while($line=<FILE>)
{
	if($line ne "")
	{
		if($line =~ /^\/\*/)
		{
			#do nothing
		}
		elsif($line =~ /^#\d+.+end_log_pos (\d+) .*/)
		{
			#determin end_log_pos
			$end_log_pos=$1;
			$block.=$line;
		}
		elsif($line =~ /# at (\d+)/)
		{
			if($end_log_pos == $1 && $matchfilter)
			{
				#meet end_log_pos and print if table matches
				$block.=$line;
				print $block;
			}
			#clean variables
			$block="";
			$end_log_pos=0;
			$matchfilter=0;
		}
		else
		{
			if($line =~ /^ *update ([a-z_]+) .+/i)
			{
				#update
				if ($1 ~~ @tables)
				{
					$block.=$line;
					$matchfilter=1;
				}
			}
			elsif($line =~ /^ *insert into `?([a-z_]+)`? .+/i)
			{
				#insert
				if ($1 ~~ @tables)
				{
					$block.=$line;
					$matchfilter=1;
				}
			}
			elsif($line =~ /^ *delete from `?([a-z_]+)`? .+/i)
			{
				#delete
				if ($1 ~~ @tables)
				{
					$block.=$line;
					$matchfilter=1;
				}
			}
			elsif($opt{'enable-drop'} && $line =~ /^ *drop table `?([a-z_]+)`?.*/i)
			{
				#drop
				if ($1 ~~ @tables)
				{
					$block.=$line;
					$matchfilter=1;
				}
			}
			elsif($opt{'enable-truncate'} && $line =~ /^ *truncate table `?([a-z_]+)`?.*/i)
			{
				#truncate
				if ($1 ~~ @tables)
				{
					$block.=$line;
					$matchfilter=1;
				}
			}
			elsif($line =~ /^ *alter table `?([a-z_]+)`? .+/i)
			{
				#alter
				if ($1 ~~ @tables)
				{
					$block.=$line;
					$matchfilter=1;
				}
			}
			elsif($line =~ /^ *create table `?([a-z_]+)`? .+/)
			{
				#create table
				if ($1 ~~ @tables)
				{
					$block.=$line;
					$matchfilter=1;
				}
			}
			elsif($line =~ /^ *create (unique index|index) .+ on `?([a-z_]+)`? .+/i)
			{
				#create index
				if ($1 ~~ @tables)
				{
					$block.=$line;
					$matchfilter=1;
				}
			}
			elsif($line =~/^ *create view .+ from `?([a-z_]+)`? .+/i)
			{
				#create view
				if ($1 ~~ @tables)
				{
					$block.=$line;
					$matchfilter=1;
				}
			}
			else
			{
				$block.=$line;
			}
		}
	}
}

close FILE;
