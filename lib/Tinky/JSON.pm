use v6;

use Tinky;
use JSON::Unmarshal:ver(v0.07);
use JSON::Class;
use JSON::Name;

=begin pod

=head1 NAME

Tinky::JSON - create a L<Tinky|https://github.com/jonathanstowe/Tinky> workflow from JSON

=head1 SYNOPSIS

=begin code

=end code

=head1 DESCRIPTION





=end pod

class Tinky::JSON {

    class X::NoState is X::Fail {
        has Str $.name is required;
        method message() returns Str {
            "There is no state '{ $!name }' in this workflow";
        }
    }

    class State is Tinky::State does JSON::Class {
    }


    state %states;
    sub deserialise-state(Str $name) {
        %states{$name} //= Tinky::JSON::State.new(:$name);
    }

    class Transition is Tinky::Transition does JSON::Class {
        has Tinky::JSON::State $.from is unmarshalled-by(&deserialise-state);
        has Tinky::JSON::State $.to is unmarshalled-by(&deserialise-state);
    }

    sub deserialise-states(@names) {
        my @states = @names.map(&deserialise-state);
        @states;
    }


    class Workflow is Tinky::Workflow does JSON::Class {

        method from-json(|c) {
            %states = ();
            self.JSON::Class::from-json(|c);
        }

        has State $.initial-state is unmarshalled-by(&deserialise-state);
        has Tinky::JSON::State @.states is unmarshalled-by(&deserialise-states);
        has Tinky::JSON::Transition @.transitions;

        method state(Str:D $state) returns State {
            self.states.first({ $_ ~~ $state }) // X::NoState.new(name => $state).throw;
        }

        multi method enter-supply(Str:D $state) returns Supply {
            self.state($state).?enter-supply();
        }

        multi method leave-supply(Str:D $state) returns Supply {
            self.state($state).?leave-supply();
        }

        multi method transitions-for-state(Str:D $state) {
            self.transitions-for-state(self.state($state));
        }

        multi method find-transition(Str:D $from, Str:D $to) {
            self.find-transition(self.state($from), self.state($to));
        }
    }

    role Object does Tinky::Object {
        has $.foodle;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
