#!/usr/bin/env perl
use Text::Markdown 'markdown';

my $filename = "README.md";
my $lang = $ENV{APP_DefaultLanguage};
my $subject = 'Welcome to LigeroSmart';

if(-r "README.$lang.md") {
    if($lang == 'pt_BR') {
        $subject = 'Bem-vindo ao LigeroSmart';
    }
    $filename = "README.$lang.md";
}

my $readme;
open(my $fh, '<', $filename) or die "cannot open file $filename";
{
    local $/;
    $readme = <$fh>;
}
close($fh);

my $header = "MIME-Version: 1.0
From: LigeroSmart Feedback <contato\@complemento.net.br>
To: Your Ligero System <ligero\@localhost>
Subject: $subject
Content-Type: text/html; charset=\"UTF-8\"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<style>
*{
font-family: Arial;
}
</style>
</head>
<body>
";

my $htmlContent = markdown($readme);

my $footer = '</body></html>';

my $mail = join('', $header, $htmlContent, $footer);

my $msgfile = '/tmp/welcome.msg';
open(my $fh, '>', $msgfile) or die "cannot open file '$msgfile' $!";
print $fh $mail;
close $fh;

system("otrs.Console.pl Maint::PostMaster::Read < $msgfile");
