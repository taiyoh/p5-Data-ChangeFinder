package Data::ChangeFinder;
use 5.008005;
use strict;
use warnings;

use Math::Matrix;
use Math::Trig 'pi';
use List::Util 'max';

our $VERSION = "0.01";

sub new {
    my ($package, $term, $r) = @_;

    return bless {
        term  => $term,
        r     => $r,
        data  => [],
        mu    => 0,
        sigma => 0,
        c     => [map { rand } 1 .. $term]
    }, $package;
}

sub next {
    my ($self, $x) = @_;

    my $len = @{ $self->{data} };
    my $r   = $self->{r};

    # update mu
    $self->{mu} = (1 - $r) * $self->{mu} + $r * $x;

    # update c
    my $_c = $self->{c};
    my $data = $self->{data};

    for my $j (0 .. ($self->{term} - 1)) {
        if ($data->[$len - 1 - $j]) {
            $_c->[$j] = (1 - $r) * $_c->[$j] + $r * ($x - $self->{mu}) * $data->[$len - 1 - $j] - $self->{mu};
        }
    }

    my $cc = _zero_matrix($self->{term});

    for my $j (0 .. ($self->{term} - 1)) {
        for my $i (0 .. ($self->{term} - 1)) {
            $cc->[$j][$i] = $cc->[$i][$j] = $_c->[$i - $j];
        }
    }
    my $_c_vec = Math::Matrix->new($_c);
    my $w = Math::Matrix->new(@$cc)->invert->multiply($_c_vec->transpose);
    my $xt = my $idx = 0;
    for my $v (@{ $self->{data} }) {
        $xt += $w->[$idx++] * ($v - $self->{mu});
    }
    $self->{sigma} = (1 - $self->{r}) * $self->{sigma} + $self->{r} * ($x - $xt) * ($x - $xt);

    push @{ $self->{data} }, $x;
    shift @{ $self->{data} } if scalar(@{ $self->{data} }) > $self->{term};

    return _scope(_prob($xt, $self->{sigma}, $x));
}

sub smooth {
    my ($self, $size) = @_;

    my $_end = @{ $self->{data} };
    my $_begin = max($_end - $size, 0);
    my @list = splice @{ $self->{data} }, $_begin, $_end;
    my $ret = 0;
    for my $v (@list) {
        $ret += $v;
    }
    return $ret / ($_end - $_begin);
}

sub show_status {
    my $self = shift;
    return {
        sigma => $self->{sigma},
        mu    => $self->{mu},
        data  => $self->{data},
        c     => $self->{c}
    };
}

sub _zero_matrix {
    my $term = shift;
    [ map { [map { 0 } 1 .. $term] } 1 .. $term ];
}

sub _prob {
    my ($mu, $sigma, $v) = @_;

    return 0 if $sigma == 0;
    exp(-0.5 * ($v - $mu) ** 2 / $sigma) / ((2 * pi) ** 0.5 * $sigma ** 0.5);
}

sub _score {
    my $p = shift;
    ($p <= 0) ? 0 : - log($p);
}

1;
__END__

=encoding utf-8

=head1 NAME

Data::ChangeFinder - It's new $module

=head1 SYNOPSIS

    use Data::ChangeFinder;

=head1 DESCRIPTION

Data::ChangeFinder is ...

=head1 LICENSE

Copyright (C) taiyoh.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

taiyoh E<lt>sun.basix@gmail.comE<gt>

=cut
