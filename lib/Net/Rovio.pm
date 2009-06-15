package Net::Rovio;

=head1 NAME

Net::Rovio - A Perl module for Rovio manipulation

=head1 SYNOPSIS

  use Net::Rovio;
  my $rovio = Net::Rovio->new('my-rovio.ath.cx', 'admin', 'password');
  $rovio->light('on');
  sleep 1;
  $rovio->camera_head('mid');
  sleep 1;
  $rovio->camera_head('up');
  sleep 1;
  $rovio->camera_head('mid');
  sleep 1;
  $rovio->camera_head('down');
  sleep 1;
  $rovio->light('off');
  $rovio->dock();
  

=head1 DESCRIPTION

Use Net::Rovio to control your Rovio robot from Perl. Uses basic Rovio API commands.

=head1 FUNCTIONS

=over 4

=item * $object = Net::Rovio->new('hostname'[, 'username', 'password'])

Opens the Rovio for communication.

=item * $object->send('file'[, 'GET data'])

Requests 'file' with 'GET data' from your robot.

=item * $object->camera_head('up'|'down'|'mid')

Moves the camera head to the up, down, or middle position.

=item * $object->light('on'|'off')

Turns the headlight on/off.

=item * $object->dock()

Sends the Rovio to its charging base.

=item * $object->halt()

Sends the Rovio a halt message.

=back

=head1 DEPENDENCIES

WWW::Mechanize

=head1 TODO

Motions

  $object->move('left')

=head1 AUTHOR

Ivan Greene (ivantis@ivantis.net)

=head1 SEE ALSO

WWW::Mechanize

=cut

use strict;
use warnings;
use WWW::Mechanize;
use vars qw($VERSION);
$VERSION = "0.8.1";

sub new {
  my $package = shift;
  my $self;
  $self->{'opened'} = 1;
  $self->{'host'} = $_[0];
  if ($_[1] ne "" && $_[2] ne "") {
    $self->{'auth'} = 1;
    $self->{'username'} = $_[1];
    $self->{'password'} = $_[2];
  }
  return bless($self, $package);
}

sub send {
  my $self = shift;
  if ($self->{'opened'}) {
    if ($_[0] ne "") {
      my $request = WWW::Mechanize->new();
      my $auth;
      if ($self->{'auth'}) {
        $request->credentials($self->{'username'}, $self->{'password'});
      }
      my $file = $_[0];
      my $GET = $_[1];
      if ($GET eq "") {
        $GET = " ";
      }
      $request->get('http://'.$self->{'host'}.'/'.$file.'?'.$GET);
    } else {
      warn "Usage: send('file.cgi'[, 'GET data'])\n";
    }
  } else {
    warn "You have not yet opened a connection\n";
  }
}

sub camera_head {
  my $self = shift;
  if ($_[0] =~ /down/i) {
    $self->send('rev.cgi', 'Cmd=nav&action=18&drive=12');
  } elsif ($_[0] =~ /mid/i) {
    $self->send('rev.cgi', 'Cmd=nav&action=18&drive=13');
  } elsif ($_[0] =~ /up/i) {
    $self->send('rev.cgi', 'Cmd=nav&action=18&drive=11');
  } else {
    warn "Invalid argument for camera_head()\n";
  }
}

sub halt {
  my $self = shift;
  $self->send("/rev.cgi", "Cmd=nav&action=17");
}

sub dock {
  my $self = shift;
  $self->send("/rev.cgi", "Cmd=nav&action=13");
}

sub light {
  my $self = shift;
  if ((!$_[0]) or ($_[0] =~ /off/i)) {
    $self->send("/rev.cgi", "Cmd=nav&action=19&LIGHT=0");
  } else {
    $self->send("/rev.cgi", "Cmd=nav&action=19&LIGHT=1");
  }
}

1;
__END__
