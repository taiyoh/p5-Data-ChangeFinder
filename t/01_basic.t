use strict;
use warnings;
use Test::More;

use t::Util;
use List::Util qw/sum/;

use Data::ChangeFinder;

my @data = load_csv();

my $smooth_term = 3;
#my $threshold = -1.0;

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
    my $s = $score->next(sum(@outlier_buf) / scalar(@outlier_buf));
    my @refval = @{ $csv->getline($fh) };
    my $err_val = 0.00000001;
    ok( $refval[1] - $err_val <= $o && $o <= $refval[1] + $err_val );
    ok( $refval[2] - $err_val <= $s && $s <= $refval[2] + $err_val );
    $idx++;
}

close $fh;

done_testing;
