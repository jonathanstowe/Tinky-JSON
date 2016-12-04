#!/usr/bin/env perl6

use v6.c;

use Test;

use Tinky::JSON;

my $json = q:to/FOO/;
{
    "name" : "Test Workflow",
    "initial-state" : "new",
    "states" : [ "new", "open", "rejected", "in-progress", "stalled", "complete" ],
    "transitions" : [
        {
            "name" : "open",
            "from" : "new",
            "to"   : "open"
        },
        {
            "name" : "reject",
            "from" : "new",
            "to"   : "rejected"
        },
        {
            "name" : "reject",
            "from" : "open",
            "to"   : "rejected"
        },
        {
            "name" : "reject",
            "from" : "stalled",
            "to"   : "rejected"
        },
        {
            "name" : "stall",
            "from" : "open",
            "to"   : "stalled"
        },
        {
            "name" : "stall",
            "from" : "in-progress",
            "to"   : "stalled"
        },
        {
            "name" : "unstall",
            "to"   : "in-progress",
            "from" : "stalled"
        },
        {
            "name" : "take",
            "from" : "open",
            "to"   : "in-progress"
        },
        {
            "name" : "complete",
            "from" : "open",
            "to"   : "complete"
        },
        {
            "name" : "complete",
            "from" : "open",
            "to"   : "complete"
        },
        {
            "name" : "complete",
            "from" : "in-progress",
            "to"   : "complete"
        }
    ]
}
FOO

say $json;

my $workflow;

lives-ok { 
    $workflow = Tinky::JSON::Workflow.from-json($json) ;
    }, "can make the object okay";

is $workflow.states.elems, 6, "got the expected number of states";
is $workflow.transitions.elems, 11, "got the expected number of transitions";


for $workflow.transitions -> $t {
    ok $workflow.states.grep( {  $t.from ===  $_ }), "from of transition is an existing state";
    ok $workflow.states.grep( {  $t.to ===  $_ }), "to of transition is an existing state";

}

my $workflow2 = Tinky::JSON::Workflow.from-json($json) ;

ok $workflow2.states.map(*.WHICH).none ⊆ $workflow.states.map(*.WHICH).any, "differ";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
