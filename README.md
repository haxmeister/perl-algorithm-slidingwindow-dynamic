# Algorithm::SlidingWindow::Dynamic

Generic, dynamically sized sliding window.

## SYNOPSIS

```perl
use Algorithm::SlidingWindow::Dynamic;

my $w = Algorithm::SlidingWindow::Dynamic->new;

$w->push(1, 2, 3);        # window: 1 2 3
my $a = $w->shift;        # removes 1, window: 2 3
my $b = $w->pop;          # removes 3, window: 2

$w->push(qw(a b c));      # window: 2 a b c
my $ev = $w->slide('d');  # evicts 2, window: a b c d

my @vals = $w->values;    # (a, b, c, d)
```

## DESCRIPTION

This module provides a generic, count-based sliding window over a sequence of
values. The window stores arbitrary Perl scalars and supports efficient
addition and removal of elements at either end.

The API is intentionally small and is designed to support common
sliding-window and two-pointer algorithms. The window may grow or shrink
dynamically, and operations that remove elements return the removed values,
which is useful when maintaining external state such as running sums or
counts.

The module does not impose a fixed capacity or eviction policy. Instead,
window size is controlled explicitly by the caller through the use of
`push`, `shift`, `pop`, and `slide` operations. This makes the module
suitable for both variable-length windows and fixed-length rolling windows.

The window is count-based only; it does not track time or perform
time-based expiration. Any ordering, comparison, or aggregation logic is
left to user code.

All core operations run in O(1) amortized time using an internal circular
buffer.

## METHODS

### new(%args)

Creates a new sliding window.

Optional arguments:

- `alloc` — initial internal allocation size (integer ≥ 1)
- `values` — array reference of initial values to push

### push(@items)

Appends one or more items to the right (newest end) of the window.

Each call increases the window size by the number of items added.
No items are removed by this operation.

### shift

Removes and returns the oldest item from the left (oldest end) of the window.

Decreases the window size by one. Returns `undef` if the window is empty.

### pop

Removes and returns the newest item from the right (newest end) of the window.

Decreases the window size by one. Returns `undef` if the window is empty.

### slide($item)

Advances the window by one position.

If the window is non-empty, removes the oldest item and appends `$item` as
the newest item. The window size remains unchanged. The removed item is
returned.

If the window is empty, behaves like `push($item)` and returns `undef`.

### size

Returns the number of items currently stored in the window.

### is_empty

Returns true if the window is empty, false otherwise.

### oldest

Returns the oldest item without removing it, or `undef` if the window is
empty.

### newest

Returns the newest item without removing it, or `undef` if the window is
empty.

### get($index)

Returns the item at logical index `$index`, where index `0` refers to the
oldest item and `size - 1` refers to the newest item.

Returns `undef` if the index is out of range.

### values

Returns all items currently in the window, ordered from oldest to newest.

### clear

Removes all items from the window. After this call, the window size is zero.

## EXAMPLES

### Shortest Subarray With Sum >= K (Non-Negative Values)

```perl
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

print shortest_subarray_at_least_k([2, 3, 1, 2, 4, 3], 7), "\n";
```

### Fixed-Length Rolling Window

```perl
my $w = Algorithm::SlidingWindow::Dynamic->new;

$w->push(10);
$w->push(20);
$w->push(30);

my $evicted = $w->slide(40);
my @vals    = $w->values;   # (20, 30, 40)
```

## LIMITATIONS

- This module implements a count-based sliding window only. It does not provide
  time-based expiration.
- The module does not perform aggregation, comparison, or ordering of values.
- Some algorithms (for example, shortest-subarray problems with arbitrary
  negative values) may require additional data structures.

## SEE ALSO

- Algorithm::SlidingWindow

## AUTHOR

Joshua Day

## LICENSE

This library is free software; you may redistribute it and/or modify it under
the same terms as Perl itself.
