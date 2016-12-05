#!/usr/bin/env perl6

use v6.c;

use Test;

use Tinky::JSON;

my $json = $*PROGRAM.parent.child('data/ticket.json').slurp;

my $workflow = Tinky::JSON::Workflow.from-json($json);

for $workflow.states -> $state {
    ok my $found-state = $workflow.state($state.name), "can find '{ $state.name }' by name";
    ok $found-state === $state, "and it is the right one";
    isa-ok $workflow.enter-supply($state.name), Supply, "got enter-supply for that state";
    isa-ok $workflow.leave-supply($state.name), Supply, "got leave-supply for that state";
    is-deeply $workflow.transitions-for-state($state.name), $workflow.transitions-for-state($found-state), "transitions for state returns the same with a string";
}

for $workflow.transitions -> $transition {
    ok $workflow.find-transition($transition.from.name, $transition.to.name) === $workflow.find-transition($transition.from, $transition.to), "find-transition { $transition.name }";

}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
