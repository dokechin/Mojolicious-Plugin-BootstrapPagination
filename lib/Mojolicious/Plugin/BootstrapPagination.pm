package Mojolicious::Plugin::BootstrapPagination;
use Mojo::Base 'Mojolicious::Plugin';
use POSIX( qw/ceil/ );
use Mojo::ByteStream 'b';

use strict;
use warnings;

our $VERSION = "0.05";

# Homer: Well basically, I just copied the plant we have now.
#        Then, I added some fins to lower wind resistance.  
#        And this racing stripe here I feel is pretty sharp.
# Burns: Agreed.  First prize!
sub  register{
  my ( $self, $app, $args ) = @_;
  $args ||= {};

  $app->helper( bootstrap_pagination => sub{
      my ( $self, $actual, $count, $opts ) = @_;
      $count = ceil($count);
      return "" unless $count > 1;
      $opts = {} unless $opts;
      my $round = $opts->{round} || 4;
      my $param = $opts->{param} || "page";
      my $class = $opts->{class}  || "";
      if ($class ne ""){
          $class = " " . $class;
      }
      my $outer = $opts->{outer} || 2;
      my @current = ( $actual - $round .. $actual + $round );
      my @first   = ( $round > $actual ? (1..$round * 3 ) : (1..$outer) );
      my @tail    = ( $count - $round < $actual ? ( $count - $round * 2 + 1 .. $count ) : 
          ( $count - $outer + 1 .. $count ) );
      my @ret = ();
      my $last = undef;
      foreach my $number( sort { $a <=> $b } @current, @first, @tail ){
        next if $last && $last == $number;
        next if $number <= 0 ;
        last if $number > $count;
        push @ret, ".." if( $last && $last + 1 != $number );
        push @ret, $number;
        $last = $number;
      }
      
      my $html = "<ul class=\"pagination$class\">";
      if( $actual == 1 ){
        $html .= "<li class=\"disabled\"><a href=\"#\" >&laquo;</a></li>";
      } else {
        $html .= "<li><a href=\"" . $self->url_for->query( $param => $actual - 1 ) . "\" >&laquo;</a></li>";
      }
      foreach my $number( @ret ){
        if( $number eq ".." ){
          $html .= "<li><a href=\"#\" >..</a></li>";
        } elsif( $number == $actual ) {
        $html .= "<li class=\"disabled\"><a href=\"#\">$number</a></li>";
        } else {
          $html .= "<li><a href=\"" . $self->url_for->query( $param => $number ) ."\">$number</a></li>";
        }
      }
      if( $actual == $count ){
        $html .= "<li class=\"disabled\"><a href=\"" . $self->url_for->query( $param => $actual + 1 ) . "\" >&laquo;</a></li>";
      } else {
        $html .= "<li><a href=\"" . $self->url_for->query( $param => $actual + 1 ) . "\" >&raquo;</a></li>";
      }
      $html .= "</ul>";
      return b( $html );
    } );

}

1;
__END__

=encoding utf-8

=head1 NAME

Mojolicious::Plugin::PageNavigator - Page Navigator plugin for Mojolicious

=head1 SYNOPSIS

  # Mojolicious::Lite
  plugin 'bootstrap_nagination'

  # Mojolicious
  $self->plugin( 'bootstrap_nagination' );

=head1 DESCRIPTION

L<Mojolicious::Plugin::BootstrapPagination> generates standard page navigation bar, like 
  
<<  1  2 ... 11 12 13 14 15 ... 85 86 >>

=head1 HELPERS

=head2 bootstrap_pagination

  %= bootstrap_nagination( $current_page, $total_pages, $opts );

=head3 Options

Options is a optional ref hash.

  %= bootstrap_nagination( $current_page, $total_pages, {
      round => 4,
      outer => 2,
      class => 'pagination-lg',
      param => 'page' } );

=over 1

=item round

Number of pages arround the current page. Default: 4.

=item outer

Number of outer window pages (first and last pages). Default 2.

=item param

Name of param for query url. Default: 'page'

=back

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>,L<Mojolicious::Plugin::PageNavigator>.


=head1 LICENSE

Copyright (C) dokechin.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

dokechin E<lt>E<gt>

=cut

