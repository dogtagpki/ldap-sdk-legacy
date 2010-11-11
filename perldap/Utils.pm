#############################################################################
# $Id: Utils.pm,v 1.14.2.6 2007/06/14 09:21:15 gerv%gerv.net Exp $
#
# ***** BEGIN LICENSE BLOCK *****
# Version: MPL 1.1/GPL 2.0/LGPL 2.1
#
# The contents of this file are subject to the Mozilla Public License Version
# 1.1 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
# http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
# for the specific language governing rights and limitations under the
# License.
#
# The Original Code is PerLDAP.
#
# The Initial Developer of the Original Code is
# Netscape Communications Corporation.
# Portions created by the Initial Developer are Copyright (C) 2001
# the Initial Developer. All Rights Reserved.
#
# Contributor(s):
#   Clayton Donley
#   Leif Hedstrom <leif@perldap.org>
#
# Alternatively, the contents of this file may be used under the terms of
# either the GNU General Public License Version 2 or later (the "GPL"), or
# the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
# in which case the provisions of the GPL or the LGPL are applicable instead
# of those above. If you wish to allow use of your version of this file only
# under the terms of either the GPL or the LGPL, and not to allow others to
# use your version of this file under the terms of the MPL, indicate your
# decision by deleting the provisions above and replace them with the notice
# and other provisions required by the GPL or the LGPL. If you do not delete
# the provisions above, a recipient may use your version of this file under
# the terms of any one of the MPL, the GPL or the LGPL.
#
# ***** END LICENSE BLOCK *****

# DESCRIPTION
#    Lots of Useful Little Utilities, for LDAP related operations.

require 5.005;
package Mozilla::LDAP::Utils;

use Mozilla::LDAP::API 1.5 qw(:constant);
use Mozilla::LDAP::Conn;
use Exporter;

use strict;
use vars qw($VERSION @ISA %EXPORT_TAGS);

@ISA = qw(Exporter);
$VERSION = "1.5";

%EXPORT_TAGS = (
		all => [qw(normalizeDN
			   isUrl
			   printEntry
			   printentry
			   str2Scope
			   askPassword
			   ldapArgs
			   userCredentials
			   answer)]
		);


# Add Everything in %EXPORT_TAGS to @EXPORT_OK
Exporter::export_ok_tags('all');


#############################################################################
# Normalize the DN string (first argument), and return the new, normalized,
# string (DN). This is useful to make sure that two syntactically
# identical DNs compare (eq) as the same string.
#
sub normalizeDN
{
  my ($dn) = @_;
  my (@vals);

  return "" unless (defined($dn) && ($dn ne ""));

  @vals = Mozilla::LDAP::API::ldap_explode_dn(lc $dn, 0);

  return join(",", @vals);
}


#############################################################################
# Checks if a string is a properly formed LDAP URL.
#
sub isURL
{
  return ldap_is_ldap_url($_[0]);
}


#############################################################################
# Print an entry, in LDIF format. This is sort of obsolete, we encourage
# you to use the :;LDAP::LDIF class instead.
#
sub printEntry
{
  my $entry = $_[0];
  my ($attr);

  local $_;

  print "dn: ", $entry->{"dn"},"\n";
  foreach $attr (@{$entry->{"_oc_order_"}})
    {
      next if ($attr =~ /^_.+_$/);
      next if $entry->{"_${attr}_deleted_"};
      foreach (@{$entry->{$attr}})
	{
	  print "$attr: $_\n";
	}
    }

  print "\n";
}
*printentry = \*printEntry;


#############################################################################
# Convert a "human" readable string to an LDAP scope value
#
sub str2Scope
{
  my ($str) = $_[0];

  return $str if ($str =~ /^[0-9]+$/);

  if ($str =~ /^sub/i)
    {
      return LDAP_SCOPE_SUBTREE;
    }
  elsif ($str =~ /^base/i)
    {
      return LDAP_SCOPE_BASE;
    }
  elsif ($str =~ /^one/i)
    {
      return LDAP_SCOPE_ONELEVEL;
    }

  # Default...
  return LDAP_SCOPE_SUBTREE;
}


#############################################################################
# Ask for a password, without displaying it on the TTY.
#
sub askPassword
{
  my ($prompt) = shift;
  my ($promptstr) = shift;
  my ($hasReadKey) = 0;

  eval "use Term::ReadKey";
  $hasReadKey=1 unless ($@);

  if ($prompt) {
      if ($promptstr) {
          print $promptstr;
      } else {
          print "LDAP password: ";
      }
  }
  if ($hasReadKey)
    {
      ReadMode(2);
      chop($_ = ReadLine(0));
      ReadMode(0);
    }
  else
    {
      system('/bin/stty -echo');
      chop($_ = <STDIN>);
      system('/bin/stty echo');
    }
  print "\n";

  return $_;
}


#############################################################################
# Handle some standard LDAP options, and construct a nice little structure
# that we can use later on. We really should have some appropriate defaults,
# perhaps from an Mozilla::LDAP::Config module.
#
sub ldapArgs
{
  my ($bind, $base) = @_;
  my (%ld);

  $main::opt_v = $main::opt_n if defined($main::opt_n);
  $main::opt_p = LDAPS_PORT if (!defined($main::opt_p) &&
				defined($main::opt_P) &&
				($main::opt_P ne ""));

  $ld{"host"} = $main::opt_h || "ldap";
  $ld{"port"} = $main::opt_p || LDAP_PORT;
  $ld{"base"} = $main::opt_b || $base || $ENV{'LDAP_BASEDN'};
  $ld{"root"} = $ld{"base"};
  $ld{"bind"} = $main::opt_D || $bind || "";
  $ld{"pswd"} = $main::opt_w || "";
  $ld{"cert"} = $main::opt_P || "";
  $ld{"certname"} = $main::opt_N || "";
  $ld{"keypwd"} = $main::opt_W || "";
  $ld{"starttls"} = (defined($main::opt_Z) ? 1 : 0);
  $ld{"scope"} = (defined($main::opt_s) ? $main::opt_s : LDAP_SCOPE_SUBTREE);
  $ld{"vers"} = (defined($main::opt_V) && $main::opt_V eq "2") ?
    LDAP_VERSION2 : LDAP_VERSION3;

  if (($ld{"bind"} ne "") && ($ld{"pswd"} eq ""))
    {
      $ld{pswd} = askPassword(1);
    }

  if (($ld{"certname"} ne "") && ($ld{"keypwd"} eq ""))
    {
      $ld{keypwd} = askPassword(1, "Enter PIN for " . $ld{"certname"} . ": ");
    }

  return %ld;
}


#############################################################################
# Try to find a user to bind as, and possibly ask for the password. Pass
# a pointer to the hash array with LDAP parameters to this function.
#
sub userCredentials
{
  my ($ld) = @_;
  my ($conn, $entry, $pswd, $search);

  if ($ld->{"bind"} eq "")
    {
      my ($base) = $ld->{"base"} || $ld->{"root"};

      $conn = Mozilla::LDAP::Conn->new($ld);
      die "Couldn't connect to LDAP server " . $ld->{"host"} unless $conn;

      $search = "(&(objectclass=inetOrgPerson)(uid=$ENV{USER}))";
      $entry = $conn->search($base, "subtree", $search, 0, ("uid"));
      return 0 if (!$entry || $conn->nextEntry());

      $conn->close();
      $ld->{"bind"} = $entry->getDN();
    }

  if ($ld->{"pswd"} eq "")
    {
      $ld->{"pswd"} = Mozilla::LDAP::Utils::askPassword(1);
    }
}


#############################################################################
# Ask a Y/N question, return "Y" or "N".
#
sub answer
{
  die "Default string must be Y or N."
    unless (($_[0] eq "Y") || ($_[0] eq "N"));

  chop($_ = <STDIN>);

  return $_[0] if /^$/;
  return "Y" if /^[yY]/;
  return "N" if /^[nN]/;
}


#############################################################################
# Mandatory TRUE return value.
#
1;


#############################################################################
# POD documentation...
#
__END__

=head1 NAME

  Mozilla::LDAP::Utils.pm - Collection of useful little utilities.

=head1 SYNOPSIS

  use Mozilla::LDAP::Utils;

=head1 ABSTRACT


=head1 DESCRIPTION


=head1 OBJECT CLASS METHODS

=over 13

=item B<normalizeDN>

This function will remove all extraneous white spaces in the DN, and also
change all upper case characters to lower case. The only argument is the
DN string to normalize, and the return value is the new, clean DN.

=back

=head1 EXAMPLES

There are plenty of examples to look at, in the examples directory. We are
adding more examples every day (almost).

=head1 INSTALLATION

Installing this package is part of the Makefile supplied in the
package. See the installation procedures which are part of this package.

=head1 AVAILABILITY

This package can be retrieved from a number of places, including:

    http://www.mozilla.org/directory/
    Your local CPAN server

=head1 CREDITS

Most of this code was developed by Leif Hedstrom, Netscape Communications
Corporation. 

=head1 BUGS

None. :)

=head1 SEE ALSO

L<Mozilla::LDAP::Conn>, L<Mozilla::LDAP::Entry>, L<Mozilla::LDAP::API>, and
of course L<Perl>.

=cut
