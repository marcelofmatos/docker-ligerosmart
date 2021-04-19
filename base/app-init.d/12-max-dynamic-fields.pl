#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename;
use lib "/opt/otrs";
use lib "/opt/otrs" . "/Kernel/cpan-lib";
use lib "/opt/otrs" . "/Custom";
use Kernel::System::ObjectManager;
use Kernel::System::Service;
use Kernel::System::CustomerUser;
use Kernel::System::LinkObject;
use Kernel::System::FAQ;
use Kernel::System::SysConfig;
use Data::Dumper;
local $Kernel::OM = Kernel::System::ObjectManager->new(
    "Kernel::System::Log" => {
        LogPrefix => "LigeroInstall",
    },
);

# Obtem Settings
my %Setting = $Kernel::OM->Get("Kernel::System::SysConfig")->SettingGet(
    Name    => "PreferencesGroups###DynamicFieldsOverviewPageShown",
    Default => 1,
);

$Setting{EffectiveValue}->{Data}->{"2000"} = "2000";

$Setting{EffectiveValue}->{DataSelected} = "2000";

my $ExclusiveLockGUID = $Kernel::OM->Get("Kernel::System::SysConfig")->SettingLock(
    UserID    => 1,
    Force     => 1,
    DefaultID => $Setting{DefaultID},
);

my $Success = $Kernel::OM->Get("Kernel::System::SysConfig")->SettingUpdate(
    Name              => "PreferencesGroups###DynamicFieldsOverviewPageShown",
    EffectiveValue    => $Setting{EffectiveValue},
    ExclusiveLockGUID => $ExclusiveLockGUID,
    UserID            => 1,
);

$Success = $Kernel::OM->Get("Kernel::System::SysConfig")->SettingUnlock(
    UserID    => 1,
    DefaultID => $Setting{DefaultID},
);

my %DeploymentResult = $Kernel::OM->Get("Kernel::System::SysConfig")->ConfigurationDeploy(
    Comments      => "Update 2000 Lines",
    UserID        => 1,
    Force         => 1,
    DirtySettings => ["PreferencesGroups###DynamicFieldsOverviewPageShown"],
);
    
1;
