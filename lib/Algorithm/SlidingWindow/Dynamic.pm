package Algorithm::SlidingWindow::Dynamic;

use strict;
use warnings;
use Carp qw(croak);

our $VERSION = '0.003';

sub new {
    my ($class, %args) = @_;

    my $alloc = exists $args{alloc} ? $args{alloc} : 8;
    _check_alloc($alloc);

    my $self = bless {
        buf  => [ (undef) x $alloc ],
        head => 0,
        size => 0,
    }, $class;

    if (exists $args{values}) {
        croak "values must be an arrayref" if ref($args{values}) ne 'ARRAY';
        $self->push(@{ $args{values} });
    }

    return $self;
}

sub size { $_[0]->{size} }

sub is_empty { $_[0]->{size} == 0 ? 1 : 0 }

sub oldest {
    my ($self) = @_;
    return undef if $self->{size} == 0;
    return $self->{buf}[ $self->{head} ];
}

sub newest {
    my ($self) = @_;
    return undef if $self->{size} == 0;
    my $cap = _cap($self);
    my $idx = ($self->{head} + $self->{size} - 1) % $cap;
    return $self->{buf}[$idx];
}

sub get {
    my ($self, $index) = @_;
    return undef if !defined $index;
    return undef if $index !~ /\A\d+\z/;
    return undef if $index >= $self->{size};

    my $idx = ($self->{head} + $index) % _cap($self);
    return $self->{buf}[$idx];
}

sub values {
    my ($self) = @_;
    my $n = $self->{size};
    return () if $n == 0;

    my $cap  = _cap($self);
    my $head = $self->{head};
    my $buf  = $self->{buf};

    return map { $buf->[ ($head + $_) % $cap ] } (0 .. $n - 1);
}

sub clear {
    my ($self) = @_;
    my $cap = _cap($self);

    for (my $i = 0; $i < $cap; $i++) {
        $self->{buf}[$i] = undef;
    }

    $self->{head} = 0;
    $self->{size} = 0;
    return $self;
}

sub push {
    my ($self, @items) = @_;
    return $self if !@items;

    for my $item (@items) {
        $self->_ensure_capacity_for(1);
        my $cap  = _cap($self);
        my $tail = ($self->{head} + $self->{size}) % $cap;
        $self->{buf}[$tail] = $item;
        $self->{size}++;
    }

    return $self;
}

sub shift {
    my ($self) = @_;
    return undef if $self->{size} == 0;

    my $idx = $self->{head};
    my $val = $self->{buf}[$idx];

    $self->{buf}[$idx] = undef;
    $self->{head} = ($self->{head} + 1) % _cap($self);
    $self->{size}--;

    $self->{head} = 0 if $self->{size} == 0;
    return $val;
}

sub pop {
    my ($self) = @_;
    return undef if $self->{size} == 0;

    my $cap = _cap($self);
    my $idx = ($self->{head} + $self->{size} - 1) % $cap;
    my $val = $self->{buf}[$idx];

    $self->{buf}[$idx] = undef;
    $self->{size}--;

    $self->{head} = 0 if $self->{size} == 0;
    return $val;
}

sub slide {
    my ($self, $item) = @_;

    if ($self->{size} == 0) {
        $self->push($item);
        return undef;
    }

    my $cap = _cap($self);
    my $idx = $self->{head};
    my $old = $self->{buf}[$idx];

    $self->{buf}[$idx] = $item;
    $self->{head} = ($self->{head} + 1) % $cap;

    return $old;
}

sub _cap { scalar @{ $_[0]->{buf} } }

sub _ensure_capacity_for {
    my ($self, $add) = @_;
    my $need = $self->{size} + $add;
    my $cap  = _cap($self);
    return if $need <= $cap;

    my $new_cap = $cap * 2;
    $new_cap *= 2 while $new_cap < $need;

    my @new = (undef) x $new_cap;
    for (my $i = 0; $i < $self->{size}; $i++) {
        $new[$i] = $self->{buf}[ ($self->{head} + $i) % $cap ];
    }

    $self->{buf}  = \@new;
    $self->{head} = 0;
}

sub _check_alloc {
    my ($n) = @_;
    croak "alloc must be integer >= 1" if $n !~ /\A[1-9]\d*\z/;
}

1;
