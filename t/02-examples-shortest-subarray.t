use strict;
use warnings;
use Test::More;
use Algorithm::SlidingWindow::Dynamic;

sub shortest_subarray_at_least_k {
    my ($nums, $k) = @_;

    my $w   = Algorithm::SlidingWindow::Dynamic->new;
    my $sum = 0;
    my $best;

    for my $x (@$nums) {
        die "negative values not supported" if $x < 0;

        $w->push($x);
        $sum += $x;

        while ($w->size > 0 && $sum >= $k) {
            my $len = $w->size;
            $best = $len if !defined($best) || $len < $best;

            my $removed = $w->shift;
            $sum -= $removed;
        }
    }

    return defined($best) ? $best : -1;
}

is(shortest_subarray_at_least_k([2,3,1,2,4,3],7), 2, 'example from POD');
done_testing;
