use strict;
use warnings;
use Test::More;

use t::Util;
use List::Util qw/sum/;

use Data::ChangeFinder;

my @data = load_csv();

my $smooth_term = 3;
my $threshold = -1.0;

my $outlier = Data::ChangeFinder->new(28, 0.05);
my $score   = Data::ChangeFinder->new(28, 0.05);

my @outlier_buf;

my $filename = "$FindBin::Bin/y.csv";
my $csv = Text::CSV->new({binary => 1});
open my $fh, '<', $filename;

my $idx = 0;
for my $row (@data) {
    my $y = $row->{y};
    my $o = $outlier->next($y);
    push @outlier_buf, $o;
    shift @outlier_buf if @outlier_buf > $smooth_term;
    my $sum = sum @outlier_buf;
    my $s = $score->next($sum / scalar(@outlier_buf));
    my @refval = @{ $csv->getline($fh) };
    #is $o, $refval[1], "[$idx] outlier is match, $o";
    #is $s, $refval[2], "[$idx] score is match, $s";
    print "${y},${o},${s}\n";
    $idx++;
    last if $idx > 1;
}

close $fh;

done_testing;
