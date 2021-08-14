#!/usr/bin/env perl
use strict;
use warnings;

my ($list,$store,$output) = @ARGV;

open LI,"<$list" or die($!);
open OUT,">$output" or die($!);
print OUT "Sample\tLocusNum\tHeterozygosity\n";

while (<LI>){
	chomp;
	my @ID = split /\s+/,$_;
	my @tag = qw{F M C};
	foreach my $i (0..2){
	my $id = $ID[$i];
	my $total = 0;
	my $hete = 0;

	if ($tag[$i] eq 'CCC'){
		my $file = "$store/r$ID[2].cpie";
		open IN,"<$file" or die($!);
		while (my $line = <IN>){
			chomp($line);
			next if ($line =~ /^#/);
			my @data = split /[\t\/;]/,$line;
			$total+=1;
			unless ($data[10] eq $data[11]){
				$hete++;
			}
		}
	}else{
		my $file = "$store/$ID[$i].tsv";
		open IN,"<$file" or die($!);
		while (my $line = <IN>){
			chomp($line);
	        	my @data = split /\t/,$line;
	                next if ($data[3] eq '.' or $data[3] < 100);
	                my @tM = splice @data,4;
	                my %Dep;
	                my $depcheck = 1;
	                for (@tM){
	                        my $depsum = 0;
	                        my @Depinfo = split /[;,]/,$_;
	                        for my $i (1..scalar @Depinfo - 1){
	                                if ($Depinfo[$i] eq '.'){$Depinfo[$i] = 0;}
	                                $Dep{$i - 1} += $Depinfo[$i];
	                                $depsum += $Depinfo[$i];
	                        }
	                        if ($depsum <= 50){
	                                $depcheck *= 0;
	                        }else{
	                                $depcheck *= 1;
	                        }
	                }
	                next if ($depcheck == 0);
			$total += 1;
	
        	        my @values = sort {$b<=>$a} values %Dep;
        	        if (scalar @values > 1){
        	                if ($values[1] > $values[0] * 0.1){
        	                        $hete++;
        	                }
        	        }
		}
		close IN;
	}
	if ($total > 0){
		print OUT "$id\t$hete/$total\t",sprintf("%.3f", $hete/$total),"\n";
	}else{
		print OUT "$id\t$hete/$total\t","NA","\n";
	}
	}
}
close LI;
close OUT;
