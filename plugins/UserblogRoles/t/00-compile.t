# Copyright (C) 2001-2009 Six Apart, Ltd.
#
# Licensed under the same terms as Perl itself.

use strict;
use warnings;

use lib 'plugins/UserblogRoles/lib', 't/lib', 'lib', 'extlib';
use Test::More tests => 2;
use MT::Test;
use MT;

require_ok('UserblogRoles::Util');
ok (MT->component ('UserblogRoles'), "Plugin loaded");
