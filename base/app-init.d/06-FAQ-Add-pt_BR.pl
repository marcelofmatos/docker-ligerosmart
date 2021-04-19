#!/usr/bin/env perl

use strict;
use warnings;
use File::Basename;
use lib "/opt/otrs";
use lib "/opt/otrs" . "/Kernel/cpan-lib";
use lib "/opt/otrs" . "/Custom";
use Kernel::System::ObjectManager;
use Kernel::System::FAQ;
local $Kernel::OM = Kernel::System::ObjectManager->new(
    "Kernel::System::Log" => {
        LogPrefix => "LigeroInstall",
    },
);

# get current FAQ languages
my %CurrentLanguages = Kernel::System::FAQ->LanguageList(
    UserID => 1,
);

# use reverse hash for easy lookup
my %ReverseLanguages = reverse %CurrentLanguages;

# check if language is already defined
if ( !$ReverseLanguages{"pt_BR"} ) {
    # add language
    my $Success = Kernel::System::FAQ->LanguageAdd(
        Name   => "pt_BR",
        UserID => 1,
    );
}
1;
