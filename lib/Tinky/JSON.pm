use v6;

use Tinky;
use JSON::Unmarshal:ver(v0.07);
use JSON::Class;
use JSON::Name;

class Tinky::JSON {



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
    }


}
# vim: expandtab shiftwidth=4 ft=perl6
