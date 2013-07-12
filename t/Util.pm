package t::Util;

use strict;
use warnings;

use Text::CSV;
use FindBin;

use base 'Exporter';

our @EXPORT = qw/load_csv/;

my $csv = Text::CSV->new({ binary => 1 });

sub load_csv {
    my $filename = "$FindBin::Bin/stock.2432.csv";
    my @list;
    open my $fh, '<', $filename;

    my @colref = @{ $csv->getline($fh) };
    my $idx = 0;
    my %cols; # x,s,M,m,y,o
    $cols{$_} = $idx++ for (@colref);
    while (my $row = $csv->getline($fh)) {
        push @list, {
            x => $row->[$cols{x}],
            s => $row->[$cols{s}],
            M => $row->[$cols{M}],
            m => $row->[$cols{m}],
            y => $row->[$cols{y}],
            o => $row->[$cols{o}],
        };
    }
    close $fh;

    return @list;
}


1;
