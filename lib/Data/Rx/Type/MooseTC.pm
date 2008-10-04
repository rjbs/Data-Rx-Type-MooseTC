use strict;
use warnings;
package Data::Rx::Type::MooseTC;
# ABSTRACT: experimental / proof of concept Rx types from Moose types

use Carp ();
use Moose::Util::TypeConstraints ();

=head1 SYNOPSIS

  use Data::Rx;
  use Data::Rx::Type::MooseTC;
  use Test::More tests => 2;

  my $rx = Data::Rx->new({
    prefix  => {
      moose => 'tag:rjbs.manxome.org,2008-10-04:rx/moose/',
    },
    type_plugins => [ 'Data::Rx::Type::MooseTC' ]
  });

  my $array_of_int = $rx->make_schema({
    type       => '/moose/tc',
    moose_type => 'ArrayRef[Int]',
  });

  ok($array_of_int->check([1]), "[1] is an ArrayRef[Int]");
  ok(! $array_of_int->check( 1 ), "1 is not an ArrayRef[Int]");

=head1 WARNING

This module is primarly provided as a proof of concept and demonstration of
user-written Rx type plugins.  It isn't meant to be used for serious work.
Moose type constraints may change their interface in the future.

=cut

sub type_uri { 'tag:rjbs.manxome.org,2008-10-04:rx/moose/tc' }

sub new_checker {
  my ($class, $arg, $rx) = @_;

  Carp::croak("no type supplied for $class") unless my $mt = $arg->{moose_type};

  my $tc;

  if (ref $mt) {
    $tc = $mt;
  } else {
    package Moose::Util::TypeConstraints; # SUCH LONG IDENTIFIERS

    $tc = find_or_parse_type_constraint( normalize_type_constraint_name($mt) );
  }

  Carp::croak("could not make Moose type constraint from $mt")
    unless $tc->isa('Moose::Meta::TypeConstraint');

  my $self = { tc => $tc };
  bless $self => $class;

  return $self;
}

sub check {
  my ($self, $value) = @_;

  return unless $self->{tc}->check($value);
}

1;
