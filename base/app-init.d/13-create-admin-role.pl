#!/usr/bin/env perl

use strict;
use warnings;
use File::Basename;
use lib "/opt/otrs";
use lib "/opt/otrs" . "/Kernel/cpan-lib";
use lib "/opt/otrs" . "/Custom";
use Kernel::System::ObjectManager;
use Kernel::System::SysConfig;
use Data::Dumper;

local $Kernel::OM = Kernel::System::ObjectManager->new(
    "Kernel::System::Log" => {
        LogPrefix => "LigeroInstall",
    },
);

my $GroupObject = $Kernel::OM->Get("Kernel::System::Group");

# Cria a role "Administradores"
my $RoleID = $GroupObject->RoleAdd(
    Name    => "admin-ligero",
    Comment => "Administradores Ligero",
    ValidID => 1,
    UserID  => 1
);

my $Success = $GroupObject->PermissionRoleUserAdd(
    UID    => 1,
    RID    => $RoleID,
    Active => 1,
    UserID => 1
);

1;

