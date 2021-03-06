#!/usr/bin/perl5
#############################################################################
# $Id: conn.pl,v 1.6 2007/06/19 11:27:05 gerv%gerv.net Exp $
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
# Netscape Communications Corp.
# Portions created by the Initial Developer are Copyright (C) 2001
# the Initial Developer. All Rights Reserved.
#
# Contributor(s):
#   Clayton Donley
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
#    Test most (all?) of the LDAP::Mozilla::Conn methods. This code
#    needs to be rewritten to use the standard test harness in Perl...

use Getopt::Std;			# To parse command line arguments.
use Mozilla::LDAP::Conn;		# Main "OO" layer for LDAP
use Mozilla::LDAP::Utils;		# LULU, utilities.
use Mozilla::LDAP::API;

use strict;
no strict "vars";


# Uncomment for somewhat more verbose messages from core modules
#$LDAP_DEBUG = 1;


#################################################################################
# Configurations, modify these as needed.
#
$BASE	= "dc=netscape,dc=com";
$PEOPLE	= "ou=people";
$GROUPS	= "ou=groups";
$UID	= "leif-test";
$CN	= "test-group-1";


#################################################################################
# Constants, shouldn't have to edit these...
#
$APPNAM	= "conn.pl";
$USAGE	= "$APPNAM -b base -h host -D bind -w pswd -P cert";


#################################################################################
# Check arguments, and configure some parameters accordingly..
#
if (!getopts('b:h:D:p:s:w:P:'))
{
   print "usage: $APPNAM $USAGE\n";
   exit;
}
%ld = Mozilla::LDAP::Utils::ldapArgs(undef, $BASE);
$BASE = $ld{"base"};
Mozilla::LDAP::Utils::userCredentials(\%ld) unless $opt_n;


#################################################################################
# Get an LDAP connection
#
sub getConn
{
  my ($conn);

  if ($main::reuseConn)
    {
      if (!defined($main::mainConn))
	{
	  $main::mainConn = new Mozilla::LDAP::Conn(\%main::ld);
	  die "Could't connect to LDAP server $main::ld{host}"
	    unless $main::mainConn;
	}
      return $main::mainConn;
    }
  else
    {
      $conn = new Mozilla::LDAP::Conn(\%main::ld);
      die "Could't connect to LDAP server $main::ld{host}" unless $conn;
    }

  return $conn;
}


#################################################################################
# Some small help functions...
#
sub dotPrint
{
  my ($str) = shift;

  print $str . '.' x (20 - length($str));
}

sub attributeEQ
{
  my (@a, @b);
  my ($i);

  @a = @{$_[0]};
  @b = @{$_[1]};
  return 1 if (($#a < 0) && ($#b < 0));
  return 0 unless ($#a == $#b);

  @a = sort(@a);
  @b = sort(@b);
  for ($i = 0; $i <= $#a; $i++)
    {
      return 0 unless ($a[$i] eq $b[$i]);;
    }

  return 1;             # We passed all the tests, we're ok.
}


#################################################################################
# Test adding, deleting and retrieving entries.
#
$filter = "(uid=$UID)";
undef $reuseConn;
$conn = getConn();
$nentry = Mozilla::LDAP::Conn->newEntry();

$hash = { "dn"		=> "uid=$UID, $PEOPLE, $BASE",
	  "objectclass"	=> [ "top", "person", "inetOrgPerson", "mailRecipient" ],
	  "uid"		=> [ $UID ],
	  "sn"		=> [ "Hedstrom" ],
	  "givenName"	=> [ "Leif" ],
	  "mail"	=> [ "leif\@ogre.com" ],
	  "cn"		=> [ "Leif Hedstrom", "Leif P. Hedstrom" ],
	  "description"	=> [ "Hockey Goon", "LDAP dolt" ]
	  };

$ent = $conn->search($ld{root}, $ld{scope}, $filter);
$conn->delete($ent->getDN()) if $ent;

$nentry->setDN("uid=$UID, $PEOPLE, $BASE");
$nentry->{objectclass} = [ "top", "person", "inetOrgPerson", "mailRecipient" ];
$nentry->addValue("uid", $UID);
$nentry->addValue("sn", "Hedstrom");
$nentry->addValue("givenName", "Leif");
$nentry->addValue("cn", "Leif Hedstrom");
$nentry->addValue("cn", "Leif P. Hedstrom");
$nentry->addValue("cn", "The Swede");
($nentry->size("cn") != 3) && die "Entry->addValue() is broken!\n";
$nentry->addValue("mail", "leif\@ogre.com");
$nentry->setValue("description", "Hockey Goon", "LDAP dolt");
$nentry->setValue("jpegPhoto", "Before-Bin: f?????  :After-Bin");

dotPrint("Conn/newEntry");
$conn->add($nentry) || print "not ";
print "ok\n";

dotPrint("Conn/delete");
$conn->delete($nentry) || print "not ";
print "ok\n";

dotPrint("Conn/add");
$conn->add($nentry) || print "not ";
print "ok\n";

dotPrint("Conn/delete-2");
$conn->delete($nentry) || print "not ";
print "ok\n";

dotPrint("Conn/add-with-hash");
$conn->add($hash) || print "not ";
print "ok\n";

$nentry->addValue("description", "Solaris rules");
$nentry->addValue("description", "LDAP weenie");
dotPrint("Conn/add+update");
$conn->update($nentry) || print "not ";
print "ok\n";

dotPrint("Conn/delete(DN)");
$conn->delete($nentry->getDN()) || print "not ";
print "ok\n";

$conn->add($nentry) || die "Can't create entry again...\n";
dotPrint("Conn/search");
$ent = $conn->search($ld{root}, $ld{scope}, $filter);
$err = 0;
foreach (keys (%{$nentry}))
{
  $err = 1 unless (defined($ent->{$_})
		   && attributeEQ($nentry->{$_}, $ent->{$_}));
}
print "not " if $err;
print "ok\n";

$conn->close();


#################################################################################
# Test LDAP URL handling.
#
$conn = getConn();

$url1 = "ldap:///" . $ld{root} . "??sub?$filter";
$url2 = "ldaps:///" . $ld{root} . "??sub?$filter";
$badurl1 = "ldap:" . $ld{root} . "??sub?$filter";
$badurl2 = "http://" . $ld{root} . "??sub?$filter";

dotPrint("Conn/isURL");
print "not " unless ($conn->isURL($url1) && $conn->isURL($url2) &&
		     !$conn->isURL($badurl2) && !$conn->isURL($badurl1));
print "ok\n";

dotPrint("Conn/searchURL");
$ent = $conn->searchURL($url1);
$err = 0;
foreach (keys (%{$nentry}))
{
  
  $err = 1 unless (defined($ent->{$_})
		   && attributeEQ($nentry->{$_}, $ent->{$_}));
}
print "not " if $err;
print "ok\n";

$conn->close();


#################################################################################
# Test some small internal stuff.
#
$conn = getConn();

$ent = $conn->search($ld{root}, $ld{scope}, $filter);
print "Can't locate entry again" unless $ent;

dotPrint("Conn/getLD+getRes");
$err = 0;
$cld = $conn->getLD();
$res = $conn->getRes();

$err = 1 unless $cld;
$err = 1 unless $res;

$count = Mozilla::LDAP::API::ldap_count_entries($cld, $res);
$err = 1 unless ($count == 1);
print "not " if $err;
print "ok\n";

$conn->close();


#################################################################################
# Test browse and compare methods.
#
$conn = getConn();

dotPrint("Conn/browse");
$ent = $conn->browse($nentry->getDN());
print "not " unless $ent;
print "ok\n";

dotPrint("Conn/compare");
print "not " unless $conn->compare($nentry->getDN(), "SN", "Hedstrom");
print "ok\n";

$conn->close();


#################################################################################
# Test the simple authentication method
#
$conn = new Mozilla::LDAP::Conn($ld{host}, $ld{port});
$ent = $conn->search($ld{root}, $ld{scope}, $filter);
die "Can't locate entry again" unless $ent;

dotPrint("Conn/simpleAuth");
$err = 0;
$conn->simpleAuth($ld{bind}, $ld{pswd}) || ($err = 1);
$ent = $conn->search($ld{root}, $ld{scope}, $filter);
$err = 1 unless $ent;
print "not " if $err;
print "ok\n";

$conn->close();


#################################################################################
# Test the modifyRDN functionality
#
$conn = getConn();
$ent = $conn->search($ld{root}, $ld{scope}, $filter);
die "Can't locate entry again" unless $ent;

dotPrint("Conn/modifyRDN");
$err = 0;
$rdn = "uid=$UID-rdn";
$conn->modifyRDN($rdn, $ent->getDN()) || ($err = 1);

$filter = "($rdn)";
$ent = $conn->search($ld{root}, $ld{scope}, $filter);
$err = 1 unless $ent;
print "not " if $err;
print "ok\n";

$conn->delete($ent->getDN()) if $ent;


#################################################################################
# Test error handling (ToDo!)
#
