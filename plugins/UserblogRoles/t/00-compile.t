use strict;
use warnings;

use lib 'plugins/UserblogRoles/lib', 't/lib', 'lib', 'extlib';
use Test::More tests => 2;
use MT::Test;
use MT;

require_ok('UserblogRoles::Util');
ok (MT->component ('UserblogRoles'), "Plugin loaded");
