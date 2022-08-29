unit module Command::CanRun;

enum OS <win nix>;

sub can-run(Str:D $command) is export(:MANDATORY) {
    cmd-test(determine-os, $command);
}

sub determine-os is export(:internals)  {
    return nix when $*SPEC.gist.contains('unix', :i);
    return win when $*DISTRO.is-win;
}

multi sub cmd-test(OS:D $os where $os eq nix, Str:D $cmd) {
    my $proc = run('command', '-v', $cmd, :out, :err);
    return  $proc.exitcode ?? False !! True;
}

multi sub cmd-test(OS:D $os where $os eq win, Str:D $cmd) {
    # TODO handle absolute command names
    if $cmd.IO.is-absolute {
        die "Pass only relative command names.";
    }
    my @paths = split ';', %*ENV<PATH>;
    my @e = %*ENV<PATHEXT>:exists ?? split ';', %*ENV<PATHEXT> !! <.com .exe .bat .cmd>;

    for @paths -> $p {
        return True if $p.IO.add($cmd).e;
        for @e -> $e {
            return True if $p.add($cmd.IO.add($e));
        }
    }
    return False;
}



# for future use
#sub paths {
#    split $*DISTRO.path-sep, %*ENV<PATH> ~ $*DISTRO.is-win ?? $*CWD.Str !! '';
#}


=begin pod

=head1 NAME

Command::CanRun - blah blah blah

=head1 SYNOPSIS

=begin code :lang<raku>

use Command::CanRun;

=end code

=head1 DESCRIPTION

Command::CanRun is ...

=head1 AUTHOR

Steve Dondley <s@dondley.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2022 Steve Dondley

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
