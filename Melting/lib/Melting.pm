package Melting;

use 5.00000;
use strict;
use warnings;
use IPC::Run 'run';

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Melting ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
  calc get_melting get_enthalpy get_entropy get_seq set_target set_oligo_conc set_sodium_conc set_seq
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
 new	
);

our $VERSION = '0.01';

# default values
my $bin = "melting";
my $lib = "/usr/local/share/MELTING/Data";
my $target = "dnarna";
my $oligo_conc = "0.0000025"; # 2.5uM in M
my $sodium_conc = "0.05"; # 50mM in M

sub new {
 my $class = shift;
 my $userbin = shift;
 my $userlib = shift;
 my $self = {
    _bin => $userbin || $bin,
    _lib => $userlib || $lib,
    _seq => undef,
    _target => $target,
    _oligo_conc => $oligo_conc,
    _sodium_conc => $sodium_conc,
    _enthalpy => undef,
    _entropy => undef,
    _melting => undef,
 };
 bless $self, $class;
 return $self;
}

sub calc {
 my $self = shift;
 my $bin = $self->{_bin};
 my $lib = $self->{_lib};
 my $seq = $self->{_seq} || die "You must provide a sequence to test!";
 $seq = uc($seq);
 my $target = $self->{_target};
 my $oligo_conc = $self->{_oligo_conc};
 my $sodium_conc = $self->{_sodium_conc};

 # now run
 run [ $bin, "-S $seq", "-H $target", "-P $oligo_conc", "-E Na=$sodium_conc", "-NNPath $lib" ], ">" , \my $output;

 # parse the output into the object
 $self = &_parse_output($self,$output);
 return $self;
}

sub _parse_output {
 my $self = shift;
 my $output = shift;
  
 if ($output =~ /Enthalpy : (.+) cal\/mol.+\nEntropy : (.+) cal\/mol.+\nMelting temperature : (.+) degrees/) {
  $self->{_enthalpy} = $1;
  $self->{_entropy} = $2;
  $self->{_melting} = $3;
 }
 else {
  die "ERROR: Something went wrong parsing the following output:\n$output\n";
 }
 return $self;
}

sub get_melting {
   my $self = shift;
   return $self->{_melting};
}

sub get_enthalpy {
   my $self = shift;
   return $self->{_enthalpy};
}

sub get_entropy {
   my $self = shift;
   return $self->{_entropy};
}

sub get_seq {
   my $self = shift;
   return $self->{_seq};
}

sub set_target {
   my $self = shift;
   my $target = shift;
   $self->{_target} = $target;
}

sub set_oligo_conc {
   my $self = shift;
   my $oligo_conc = shift;
   $self->{_oligo_conc} = $oligo_conc;
}

sub set_sodium_conc {
   my $self = shift;
   my $sodium_conc = shift;
   $self->{_sodium_conc} = $sodium_conc;
}

sub set_seq {
   my $self = shift;
   my $seq = shift;
   $self->{_seq} = $seq;
}

1;
__END__

=head1 NAME

Melting - Perl extension for calculating Melting temperature using the MELTING software

=head1 SYNOPSIS

  use Melting;
  my $sequence = "CTGAAATACATATATAAGAAGGTCATTGT";

  my $melt = Melting->new("/usr/local/bin/melting");
  $melt->set_seq($sequence);
  $melt->calc();

  my $tm = $melt->get_melting();

  print $tm . "\n";

=head1 DESCRIPTION

This is a simple module to act as an interface to the MELTING software.
You can calculate melting temperatures for multiple molecules and target types.
For more information on the underlying software, see the documentation for MELTING.
Links for MELTING can be found at:
Paper: https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-13-101
Homepage: https://sourceforge.net/projects/melting

=head2 EXPORT

=over

=item new([binary,library])

Make a new melting object. If the melting binary is not on your $PATH then supply it as as argument along with the path to the thermodynamic parameters.

=item set_seq($seq)

Set the input sequence to be $seq

=item set_target($target)

Set the input target to be $target (see MELTING documentation for valid targets)

=item set_oligo_conc($oc)

Set the oligo concentration in M to be $oc

=item calc()

Perform the calculation

=item get_melting()

Get the melting temperature from the calculation

=item get_enthalpy()

Get the enthalpy data from the calculation

=item get_entropy()

Get the entropy data from the calculation

=item get_seq()

Get the currently set sequence

=back


=head1 SEE ALSO

Documentation for the MELTING software

=head1 AUTHOR

Richard Francis, E<lt>richard.francis@pyctx.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 by Richard Francis

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.16.3 or,
at your option, any later version of Perl 5 you may have available.


=cut
