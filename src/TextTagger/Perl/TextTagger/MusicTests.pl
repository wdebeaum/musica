#!/usr/bin/perl -CSD

use utf8;

print "\${^UNICODE}=${^UNICODE}\n\$^V=${^V}\n";

use lib '../../../';
use lib '../';
use Data::Dumper;
use Term::ANSIColor qw(:constants);
use TextTagger::Util qw(structurally_equal);
use TextTagger::CombineTags qw(combine_tags);
use TextTagger::Tags2Trips qw(sortTags tags2trips);
use TextTagger::RomanNumerals qw(tag_roman_numerals);
use TextTagger::Music qw(tag_music);

use strict vars;

my @tests = (
  # CwC_MUSICA_AnnotatedDialogs_20161118.docx
  # Dialogue 0
  { text => 'Give me a two five one (ii-V-I) progression.',
    tags => [
      { type => 'sense',
        start => 10, end => 13, lex => 'two',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 2 },
	}
      },
      { type => 'sense',
        start => 14, end => 18, lex => 'five',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	}
      },
      { type => 'sense',
        start => 19, end => 22, lex => 'one',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	}
      },
      { type => 'sense',
        start => 10, end => 22, lex => 'two five one',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 2 },
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	    }
	  ]
	}
      },
#      { type => 'number',
#        start => 24, end => 26, lex => 'ii',
#	'domain-specific-info' => {
#	  domain => 'general',
#	  type => 'roman-numeral',
#	  case => 'lower',
#	  value => 2
#	}
#      },
      { type => 'sense',
        start => 24, end => 26, lex => 'ii',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 2 },
	  quality => 'minor',
	  'intervals-above-bass' => [
	    { type => 'interval',
	      quality => 'perfect', 'scale-degree-span' => 5 },
	    { type => 'interval',
	      quality => 'minor', 'scale-degree-span' => 3 }
	  ]
	}
      },
#      { type => 'number',
#        start => 27, end => 28, lex => 'V',
#	'domain-specific-info' => {
#	  domain => 'general',
#	  type => 'roman-numeral',
#	  case => 'upper',
#	  value => 5
#	}
#      },
      { type => 'sense',
        start => 27, end => 28, lex => 'V',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
#	  'intervals-above-bass' => [
#	    { type => 'interval',
#	      quality => 'perfect', 'scale-degree-span' => 5 },
#	    { type => 'interval',
#	      quality => 'major', 'scale-degree-span' => 3 }
#	  ]
	}
      },
#      { type => 'number',
#        start => 29, end => 30, lex => 'I',
#	'domain-specific-info' => {
#	  domain => 'general',
#	  type => 'roman-numeral',
#	  case => 'upper',
#	  value => 1
#	}
#      },
      { type => 'sense',
        start => 29, end => 30, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
#	  'intervals-above-bass' => [
#	    { type => 'interval',
#	      quality => 'perfect', 'scale-degree-span' => 5 },
#	    { type => 'interval',
#	      quality => 'major', 'scale-degree-span' => 3 }
#	  ]
	}
      },
      { type => 'sense',
        start => 24, end => 30, lex => 'ii-V-I',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    {
	      type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 2 },
	      quality => 'minor',
	      'intervals-above-bass' => [
		{ type => 'interval',
		  quality => 'perfect', 'scale-degree-span' => 5 },
		{ type => 'interval',
		  quality => 'minor', 'scale-degree-span' => 3 }
	      ]
	    },
	    {
	      type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	    },
	    {
	      type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    }
	  ]
	}
      }
    ]
  },
  { text => 'I don’t like the G-chord.  Add a seventh.',
    tags => [
#      # unfortunately we tag I as a roman numeral... someone down the line will
#      # have to deal with it...
#      { type => 'number',
#        start => 0, end => 1, lex => 'I',
#	'domain-specific-info' => {
#	  domain => 'general',
#	  type => 'roman-numeral',
#	  case => 'upper',
#	  value => 1
#	}
#      },
      { type => 'sense',
        start => 0, end => 1, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
#	  'intervals-above-bass' => [
#	    { type => 'interval',
#	      quality => 'perfect', 'scale-degree-span' => 5 },
#	    { type => 'interval',
#	      quality => 'major', 'scale-degree-span' => 3 }
#	  ]
	}
      },
      { type => 'sense',
        start => 17, end => 24, lex => 'G-chord',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'G' },
	}
      },
      { type => 'sense',
        start => 33, end => 40, lex => 'seventh',
	'penn-pos' => ['NN'], lftype => ['PITCH-INTERVAL'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'interval',
	  'scale-degree-span' => 7
	}
      }
    ]
  },
  { text => 'No, put it on the bottom.', tags => [] },
  # Dialogue 1
  { text => 'give me a 5 note melody in F',
    tags => [
      { type => 'sense',
        start => 27, end => 28, lex => 'F',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'F'
	}
      },
    ]
  },
  { text => 'now vary that rhythm', tags => [] },
  { text => 'put it in a minor key', tags => [] },
  { text => 'extend it', tags => [] },
  # Dialogue 2
  { text => 'Give me the first five notes of Giant Steps in concert pitch', tags => [] },
  { text => 'Transpose notes 4 and 5 up a 3rd',
    tags => [
      { type => 'sense',
        start => 29, end => 32, lex => '3rd',
	'penn-pos' => ['NN'], lftype => ['PITCH-INTERVAL'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'interval',
	  'scale-degree-span' => 3
	}
      },
    ]
  },
  { text => 'Up a Major 3rd',
    tags => [
      { type => 'sense',
        start => 5, end => 14, lex => 'Major 3rd',
	'penn-pos' => ['NN'], lftype => ['PITCH-INTERVAL'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'interval',
	  'scale-degree-span' => 3,
	  quality => 'major'
	}
      },
    ]
  },
  { text => 'I don’t like that.',
    tags => [
#      # FIXME I don't like that "I" is interpreted as a roman numeral here
#      { type => 'number',
#        start => 0, end => 1, lex => 'I',
#	'domain-specific-info' => {
#	  domain => 'general',
#	  type => 'roman-numeral',
#	  case => 'upper',
#	  value => 1
#	}
#      },
      { type => 'sense',
        start => 0, end => 1, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
#	  'intervals-above-bass' => [
#	    { type => 'interval',
#	      quality => 'perfect', 'scale-degree-span' => 5 },
#	    { type => 'interval',
#	      quality => 'major', 'scale-degree-span' => 3 }
#	  ]
	}
      },
    ]
  },
  { text => 'Transpose the 3rd note up a half step',
    tags => [
      { type => 'sense',
        start => 14, end => 17, lex => '3rd',
	'penn-pos' => ['NN'], lftype => ['PITCH-INTERVAL'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'interval',
	  'scale-degree-span' => 3
	}
      },
# not sure about this yet
#      { type => 'sense',
#        start => 28, end => 37, lex => 'half step',
#	'penn-pos' => ['NN'], lftype => ['PITCH-INTERVAL'],
#	'domain-specific-info' => {
#	  domain => 'music',
#	  type => 'interval',
#	  semitones => 1
#	}
#      },
    ]
  },
  { text => 'Increase it one more half step',
    tags => [
    ]
  },
  { text => 'Now, lower the last note a half-step',
    tags => [
    ]
  },
  # Dialogue 3
  { text => 'Generate a chord progression in C Major',
    tags => [
      # FIXME should I be trying to tag this as a key instead of a chord?
      { type => 'sense',
        start => 32, end => 39, lex => 'C Major',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'major',
	}
      },
    ]
  },
  { text => 'Change the three to a Dominant Seventh chord.',
    tags => [
# Technically this is what they meant, but I have a hard time justifying
# tagging an isolated number as specifically a chord
#      { type => 'sense',
#        start => 11, end => 16, lex => 'three',
#	'penn-pos' => ['NN'], lftype => ['CHORD'],
#	'domain-specific-info' => {
#	  domain => 'music',
#	  type => 'chord',
#	  root => { type => 'pitch', 'scale-degree' => 3 },
#	}
#      },
      { type => 'sense',
        start => 22, end => 44, lex => 'Dominant Seventh chord',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  quality => 'dominant',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'Now change the second chord to a Dominant Seventh chord.',
    skip => 1,
    tags => [
      # NOTE: in this case, "the second chord" is actually the second chord in
      # the progression, not a chord with a second interval
      { type => 'sense',
        start => 33, end => 55, lex => 'Dominant Seventh chord',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  quality => 'dominant',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'Change the rhythm to quarter notes.', tags => [] },
  # Dialogue 4
  { text => 'In G Major, play a two-five-one.',
    tags => [
      # FIXME key vs. chord (see above)
      { type => 'sense',
        start => 3, end => 10, lex => 'G Major',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'G' },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 19, end => 22, lex => 'two',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 2 },
	}
      },
      { type => 'sense',
        start => 23, end => 27, lex => 'five',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	}
      },
      { type => 'sense',
        start => 28, end => 31, lex => 'one',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	}
      },
      { type => 'sense',
        start => 19, end => 31, lex => 'two-five-one',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 2 },
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	    }
	  ]
	}
      },
    ]
  },
  { text => 'Half note, half note, whole note.', tags => [] },
  { text => 'Now add a two-five-one of the four chord. Same rhythm.',
    tags => [
      { type => 'sense',
        start => 10, end => 13, lex => 'two',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 2 },
	}
      },
      { type => 'sense',
        start => 14, end => 18, lex => 'five',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	}
      },
      { type => 'sense',
        start => 19, end => 22, lex => 'one',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	}
      },
      { type => 'sense',
        start => 10, end => 22, lex => 'two-five-one',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 2 },
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	    }
	  ]
	}
      },
      # TODO "four chord"
    ]
  },
  # Dialogue 5
  { text => 'Play the chord changes from dialogue 4.', tags => [] },
  { text => 'Generate a bebop melody over that progression.', tags => [] },
  { text => 'Transpose the first note of measure three up an octave.',
    tags => [
      # TODO should I tag "octave"? as an interval or a unit?
    ]
  },
  # Dialogue 6
  { text => 'Play the first four measures of Blues for Alice.', tags => [] },
  { text => 'Add the next chord in that progression.', tags => [] },
  { text => 'Now play a melody over those changes.', tags => [] },
  # Dialogue 7
  { text => 'Play the chords and melody from dialogue 6', tags => [] },
  { text => 'That’s Charlie Parker’s Melody. Generate an original melody starting in measure three.', tags => [] },
  # Dialogue 8
  { text => 'Pull up the chord changes for Anthropology.', tags => [] },
  { text => 'Now generate a contrafact over those changes.', tags => [] },
  # 20170204-More MUSCIA vocab.docx
  # Score
  { text => 'The measure at the beginning of the score', tags => [] },
  # Measure
  { text => 'The end of measure 2', tags => [] },
  { text => 'In the first measure', tags => [] },
  # Note
  # Pitch
  { text => 'Move the D down a half step.',
    tags => [
      { type => 'sense',
        start => 9, end => 10, lex => 'D',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'D',
	}
      },
    ]
  },
  { text => 'The note a half step down from the C.',
    tags => [
      { type => 'sense',
        start => 35, end => 36, lex => 'C',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'C',
	}
      },
    ]
  },
  # Octave
  { text => 'C4',
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'C4',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'C',
	  octave => 4
	}
      },
      { type => 'sense',
        start => 0, end => 2, lex => 'C4',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'A3',
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'A3',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'A',
	  octave => 3
	}
      },
    ]
  },
  { text => 'B5',
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'B5',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'B',
	  octave => 5
	}
      },
    ]
  },
  { text => 'Place the A in octave 4.',
    tags => [
      { type => 'sense',
        start => 10, end => 11, lex => 'A',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'A',
	}
      },
    ]
  },
  { text => 'Move the B up an octave.',
    tags => [
      { type => 'sense',
        start => 9, end => 10, lex => 'B',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'B',
	}
      },
    ]
  },
  { text => 'Two steps up from middle C',
    tags => [
      { type => 'sense',
        start => 18, end => 26, lex => 'middle C',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'C',
	  octave => 4
	}
      },
    ]
  },
  # Duration
  { text => 'Make the A a half note.',
    tags => [
      { type => 'sense',
        start => 9, end => 10, lex => 'A',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'A',
	}
      },
    ]
  },
  # Accidental
  { text => 'A#',
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'A#',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'A',
	  'semitones-above-natural' => 1
	}
      },
    ]
  },
  { text => 'A sharp',
    tags => [
      { type => 'sense',
        start => 0, end => 7, lex => 'A sharp',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'A',
	  'semitones-above-natural' => 1
	}
      },
    ]
  },
  { text => 'Ab',
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'Ab',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'A',
	  'semitones-above-natural' => -1
	}
      },
    ]
  },
  { text => 'A flat',
    tags => [
      { type => 'sense',
        start => 0, end => 6, lex => 'A flat',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'A',
	  'semitones-above-natural' => -1
	}
      },
    ]
  },
  { text => 'A natural',
    tags => [
      { type => 'sense',
        start => 0, end => 9, lex => 'A natural',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'A',
	  'semitones-above-natural' => 0
	}
      },
    ]
  },
  { text => 'Add a double sharp to the A',
    tags => [
      { type => 'sense',
        start => 6, end => 18, lex => 'double sharp',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  'semitones-above-natural' => 2
	}
      },
      { type => 'sense',
        start => 26, end => 27, lex => 'A',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'A',
	}
      },
    ]
  },
  { text => 'The C is a double flat',
    tags => [
      { type => 'sense',
        start => 4, end => 5, lex => 'C',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'C',
	}
      },
      { type => 'sense',
        start => 11, end => 22, lex => 'double flat',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  'semitones-above-natural' => -2
	}
      },
    ]
  },
  # Wikipedia
  # https://en.wikipedia.org/wiki/Chord_names_and_symbols_(popular_music)
  # intro
  { text => 'C augmented seventh',
    tags => [
      { type => 'sense',
        start => 0, end => 19, lex => 'C augmented seventh',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'augmented',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'augmented' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'Caug7',
    tags => [
      { type => 'sense',
        start => 0, end => 5, lex => 'Caug7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'augmented',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'augmented' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'C+7',
    tags => [
      { type => 'sense',
        start => 0, end => 3, lex => 'C+7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'augmented',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'augmented' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'G/B bass',
    tags => [
      { type => 'sense',
        start => 0, end => 8, lex => 'G/B bass',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'G' },
	  bass => { type => 'pitch', letter => 'B' },
	}
      },
    ]
  },
  { text => 'C–E–G♯–B♭',
    tags => [
      { type => 'sense',
        start => 0, end => 1, lex => 'C',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'C',
	}
      },
      { type => 'sense',
        start => 2, end => 3, lex => 'E',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'E',
	}
      },
      { type => 'sense',
        start => 4, end => 6, lex => 'G♯',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'G',
	  'semitones-above-natural' => 1
	}
      },
      { type => 'sense',
        start => 7, end => 9, lex => 'B♭',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'B',
	  'semitones-above-natural' => -1
	}
      },
      { type => 'sense',
        start => 0, end => 9, lex => 'C–E–G♯–B♭',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch-sequence',
	  members => [
	    { type => 'pitch', letter => 'C' },
	    { type => 'pitch', letter => 'E' },
	    { type => 'pitch', letter => 'G', 'semitones-above-natural' => 1 },
	    { type => 'pitch', letter => 'B', 'semitones-above-natural' => -1 }
	  ]
	}
      }
    ]
  },
  { text => 'C – Am – Dm – G7',
    tags => [
      # FIXME should we delete the pitch sense of 'C' here or leave it ambiguous?
      { type => 'sense',
        start => 0, end => 1, lex => 'C',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'C'
	}
      },
      { type => 'sense',
        start => 0, end => 1, lex => 'C',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' }
	}
      },
      { type => 'sense',
        start => 4, end => 6, lex => 'Am',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'A' },
	  quality => 'minor',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 9, end => 11, lex => 'Dm',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'D' },
	  quality => 'minor',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 14, end => 16, lex => 'G7',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'G',
	  octave => 7
	}
      },
      { type => 'sense',
        start => 14, end => 16, lex => 'G7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'G' },
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
      { type => 'sense',
        start => 0, end => 16, lex => 'C – Am – Dm – G7',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', letter => 'C' }
	    },
	    { type => 'chord',
	      root => { type => 'pitch', letter => 'A' },
	      quality => 'minor',
	      'intervals-above-root' => [
		{ type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', letter => 'D' },
	      quality => 'minor',
	      'intervals-above-root' => [
		{ type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', letter => 'G' },
	      'intervals-above-root' => [
		{ type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
		{ type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	      ]
	    }
	  ]
	}
      }
    ]
  },
  # "odd"
  { text => 'Am+',
    tags => [
      { type => 'sense',
        start => 0, end => 3, lex => 'Am+',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'A' },
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'augmented' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'F/A',
    tags => [
      { type => 'sense',
        start => 0, end => 3, lex => 'F/A',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'F' },
	  bass => { type => 'pitch', letter => 'A' },
	}
      },
    ]
  },
  # This example is actually kind of dependent on the flat being superscript
  # along with the 5 it precedes. Without that it might be an A flat chord,
  # with a redundantly explicit 5th. But that redundancy might be enough to
  # convince a reader that the flat is meant to be superscript.
  # OTOH it might be the pitch A flat in octave 5.
  { text => 'A♭5',
    skip => 1,
    tags => [
      { type => 'sense',
        start => 0, end => 3, lex => 'A♭5',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'A',
	  'semitones-above-natural' => -1,
	  octave => 5
	}
      },
      { type => 'sense',
        start => 0, end => 3, lex => 'A♭5',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'A', 'semitones-above-natural' => -1 },
	  quality => 'major'
	}
      },
      # the actual meaning in context
      { type => 'sense',
        start => 0, end => 3, lex => 'A♭5',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'A' },
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'diminished' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  # Chord quality
  { text => 'Cm7',
    tags => [
      { type => 'sense',
        start => 0, end => 3, lex => 'Cm7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'minor',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'CmM7',
    tags => [
      { type => 'sense',
        start => 0, end => 4, lex => 'CmM7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'minor',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  # Major, minor, augmented, and diminished chords
  { text => 'C+M7',
    tags => [
      { type => 'sense',
        start => 0, end => 4, lex => 'C+M7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'augmented',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'augmented' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  # Altered fifths
  { text => 'CM♯5',
    tags => [
      { type => 'sense',
        start => 0, end => 4, lex => 'CM♯5',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'augmented',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'augmented' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'CM+5',
    tags => [
      { type => 'sense',
        start => 0, end => 4, lex => 'CM+5',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'augmented',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'augmented' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'Cmajaug5',
    tags => [
      { type => 'sense',
        start => 0, end => 8, lex => 'Cmajaug5',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'augmented',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'augmented' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'Cm♭5',
    tags => [
      { type => 'sense',
        start => 0, end => 4, lex => 'Cm♭5',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'diminished',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'diminished' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'Cm°5',
    tags => [
      { type => 'sense',
        start => 0, end => 4, lex => 'Cm°5',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'diminished',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'diminished' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'Cmindim5',
    tags => [
      { type => 'sense',
        start => 0, end => 8, lex => 'Cmindim5',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'diminished',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'diminished' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  # TODO both 7 and 5 intervals specified (or multiple intervals in general)
  { text => 'CM7+5',
    skip => 1,
    tags => [
      { type => 'sense',
        start => 0, end => 5, lex => 'CM7+5',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'augmented',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'augmented' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'CM7♯5',
    skip => 1,
    tags => [
      { type => 'sense',
        start => 0, end => 5, lex => 'CM7♯5',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'augmented',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'augmented' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'Cmaj7aug5',
    skip => 1,
    tags => [
      { type => 'sense',
        start => 0, end => 9, lex => 'Cmaj7aug5',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'augmented',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'augmented' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'CM7',
    tags => [
      { type => 'sense',
        start => 0, end => 3, lex => 'CM7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'major',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  # Rules to decode chord names and symbols
  # 1. General rule to interpret existing information about chord quality
  { text => 'Cm',
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'Cm',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'minor',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'Cm3',
    tags => [
      { type => 'sense',
        start => 0, end => 3, lex => 'Cm3',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'minor',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'C+',
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'C+',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'augmented',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'augmented' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'C+5',
    tags => [
      { type => 'sense',
        start => 0, end => 3, lex => 'C+5',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'augmented',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'augmented' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'Cm/M7',
    tags => [
      { type => 'sense',
        start => 0, end => 5, lex => 'Cm/M7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'minor',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'CMM7',
    tags => [
      { type => 'sense',
        start => 0, end => 4, lex => 'CMM7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'major',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'Cm6',
    tags => [
      { type => 'sense',
        start => 0, end => 3, lex => 'Cm6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'minor',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'CmM6',
    tags => [
      { type => 'sense',
        start => 0, end => 4, lex => 'CmM6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'minor',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'C+m7',
    tags => [
      { type => 'sense',
        start => 0, end => 4, lex => 'C+m7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'augmented',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'augmented' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'CM11',
    tags => [
      { type => 'sense',
        start => 0, end => 4, lex => 'CM11',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'major',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 11, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 9, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'CMP11',
    tags => [
      { type => 'sense',
        start => 0, end => 5, lex => 'CMP11',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'major',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 11, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 9, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  # 2. General rule to deduce missing information about chord quality
  { text => 'major third',
    tags => [
      { type => 'sense',
        start => 0, end => 11, lex => 'major third',
	'penn-pos' => ['NN'], lftype => ['PITCH-INTERVAL'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'interval',
	  'scale-degree-span' => 3,
	  quality => 'major',
	}
      },
    ]
  },
  { text => 'perfect fifth',
    tags => [
      { type => 'sense',
        start => 0, end => 13, lex => 'perfect fifth',
	'penn-pos' => ['NN'], lftype => ['PITCH-INTERVAL'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'interval',
	  'scale-degree-span' => 5,
	  quality => 'perfect',
	}
      },
    ]
  },
  { text => 'C minor seventh',
    tags => [
      { type => 'sense',
        start => 0, end => 15, lex => 'C minor seventh',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'minor',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'minor 3rd',
    tags => [
      { type => 'sense',
        start => 0, end => 9, lex => 'minor 3rd',
	'penn-pos' => ['NN'], lftype => ['PITCH-INTERVAL'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'interval',
	  'scale-degree-span' => 3,
	  quality => 'minor',
	}
      },
    ]
  },
  { text => 'perfect 5th',
    tags => [
      { type => 'sense',
        start => 0, end => 11, lex => 'perfect 5th',
	'penn-pos' => ['NN'], lftype => ['PITCH-INTERVAL'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'interval',
	  'scale-degree-span' => 5,
	  quality => 'perfect',
	}
      },
    ]
  },
  { text => 'minor 7th',
    tags => [
      { type => 'sense',
        start => 0, end => 9, lex => 'minor 7th',
	'penn-pos' => ['NN'], lftype => ['PITCH-INTERVAL'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'interval',
	  'scale-degree-span' => 7,
	  quality => 'minor',
	}
      },
    ]
  },
  # 3. Specific rules
  { text => 'Cdim7',
    tags => [
      { type => 'sense',
        start => 0, end => 5, lex => 'Cdim7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'diminished',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'diminished' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'diminished' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'diminished 5th',
    tags => [
      { type => 'sense',
        start => 0, end => 14, lex => 'diminished 5th',
	'penn-pos' => ['NN'], lftype => ['PITCH-INTERVAL'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'interval',
	  'scale-degree-span' => 5,
	  quality => 'diminished',
	}
      },
    ]
  },
  { text => 'diminished 7th',
    tags => [
      { type => 'sense',
        start => 0, end => 14, lex => 'diminished 7th',
	'penn-pos' => ['NN'], lftype => ['PITCH-INTERVAL'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'interval',
	  'scale-degree-span' => 7,
	  quality => 'diminished',
	}
      },
    ]
  },
  { text => 'C seventh',
    tags => [
      { type => 'sense',
        start => 0, end => 9, lex => 'C seventh',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'C7',
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'C7',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'C',
	  octave => 7
	}
      },
      { type => 'sense',
        start => 0, end => 2, lex => 'C7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'C6',
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'C6',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'C',
	  octave => 6
	}
      },
      { type => 'sense',
        start => 0, end => 2, lex => 'C6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
#	  quality => 'major',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'CM6',
    tags => [
      { type => 'sense',
        start => 0, end => 3, lex => 'CM6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'major',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'Cadd6',
    tags => [
      { type => 'sense',
        start => 0, end => 5, lex => 'Cadd6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'major 2nd',
    tags => [
      { type => 'sense',
        start => 0, end => 9, lex => 'major 2nd',
	'penn-pos' => ['NN'], lftype => ['PITCH-INTERVAL'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'interval',
	  'scale-degree-span' => 2,
	  quality => 'major',
	}
      },
    ]
  },
  { text => 'perfect 4th',
    tags => [
      { type => 'sense',
        start => 0, end => 11, lex => 'perfect 4th',
	'penn-pos' => ['NN'], lftype => ['PITCH-INTERVAL'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'interval',
	  'scale-degree-span' => 4,
	  quality => 'perfect',
	}
      },
    ]
  },
  { text => 'major 6th',
    tags => [
      { type => 'sense',
        start => 0, end => 9, lex => 'major 6th',
	'penn-pos' => ['NN'], lftype => ['PITCH-INTERVAL'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'interval',
	  'scale-degree-span' => 6,
	  quality => 'major',
	}
      },
    ]
  },
  { text => 'C2',
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'C2',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => 'C',
	  octave => 2
	}
      },
      { type => 'sense',
        start => 0, end => 2, lex => 'C2',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 2, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'Csus2',
    tags => [
      { type => 'sense',
        start => 0, end => 5, lex => 'Csus2',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 2, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'Cdom7',
    tags => [
      { type => 'sense',
        start => 0, end => 5, lex => 'Cdom7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'dominant',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'major 9th',
    tags => [
      { type => 'sense',
        start => 0, end => 9, lex => 'major 9th',
	'penn-pos' => ['NN'], lftype => ['PITCH-INTERVAL'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'interval',
	  'scale-degree-span' => 9,
	  quality => 'major',
	}
      },
    ]
  },
  { text => 'perfect 11th',
    tags => [
      { type => 'sense',
        start => 0, end => 12, lex => 'perfect 11th',
	'penn-pos' => ['NN'], lftype => ['PITCH-INTERVAL'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'interval',
	  'scale-degree-span' => 11,
	  quality => 'perfect',
	}
      },
    ]
  },
  { text => 'major 13th',
    tags => [
      { type => 'sense',
        start => 0, end => 10, lex => 'major 13th',
	'penn-pos' => ['NN'], lftype => ['PITCH-INTERVAL'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'interval',
	  'scale-degree-span' => 13,
	  quality => 'major',
	}
      },
    ]
  },
  { text => 'CMM6',
    tags => [
      { type => 'sense',
        start => 0, end => 4, lex => 'CMM6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'major',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'CMm7',
    tags => [
      { type => 'sense',
        start => 0, end => 4, lex => 'CMm7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'major',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'Cmm7',
    tags => [
      { type => 'sense',
        start => 0, end => 4, lex => 'Cmm7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'minor',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'Co7',
    tags => [
      { type => 'sense',
        start => 0, end => 3, lex => 'Co7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'diminished',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'diminished' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'diminished' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'Coo7',
    tags => [
      { type => 'sense',
        start => 0, end => 4, lex => 'Coo7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'diminished',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'diminished' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'diminished' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'Cø7',
    tags => [
      { type => 'sense',
        start => 0, end => 3, lex => 'Cø7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'half-diminished',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'diminished' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'Com7',
    tags => [
      { type => 'sense',
        start => 0, end => 4, lex => 'Com7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'half-diminished',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'diminished' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  # Examples
  { text => 'CM',
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'CM',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'major',
	}
      },
    ]
  },
  { text => 'Cmaj',
    tags => [
      { type => 'sense',
        start => 0, end => 4, lex => 'Cmaj',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'major',
	}
      },
    ]
  },
  { text => 'Cmin',
    tags => [
      { type => 'sense',
        start => 0, end => 4, lex => 'Cmin',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'minor',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'Caug',
    tags => [
      { type => 'sense',
        start => 0, end => 4, lex => 'Caug',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C'},
	  quality => 'augmented',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'augmented' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'Cdim',
    tags => [
      { type => 'sense',
        start => 0, end => 4, lex => 'Cdim',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'diminished',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'diminished' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'Cmaj6',
    tags => [
      { type => 'sense',
        start => 0, end => 5, lex => 'Cmaj6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'major',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'Cmin6',
    tags => [
      { type => 'sense',
        start => 0, end => 5, lex => 'Cmin6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'minor',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'Cmaj7',
    tags => [
      { type => 'sense',
        start => 0, end => 5, lex => 'Cmaj7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'major',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
    ]
  },
  { text => 'Cmin7',
    tags => [
      { type => 'sense',
        start => 0, end => 5, lex => 'Cmin7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'minor',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'Cø',
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'Cø',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'half-diminished',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'diminished' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'Cminmaj7',
    tags => [
      { type => 'sense',
        start => 0, end => 8, lex => 'Cminmaj7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'minor',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'Cmin/maj7',
    tags => [
      { type => 'sense',
        start => 0, end => 9, lex => 'Cmin/maj7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'minor',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'Cmin(maj7)',
    skip => 1,
    tags => [
      { type => 'sense',
        start => 0, end => 10, lex => 'Cmin(maj7)',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'minor',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  { text => 'Cm(M7)',
    skip => 1,
    tags => [
      { type => 'sense',
        start => 0, end => 6, lex => 'Cm(M7)',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', letter => 'C' },
	  quality => 'minor',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
    ]
  },
  # Examples from my Music Theory notebook (MUR111 final exam study guide)
  # (with some liberties taken WRT dashes and sub/superscript)
  # Chords
  { text => 'I',
    tags => [
      { type => 'sense',
        start => 0, end => 1, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      }
    ]
  },
  { text => 'I6',
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'I6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      }
    ]
  },
  { text => 'I-6-4',
    tags => [
      { type => 'sense',
        start => 0, end => 5, lex => 'I-6-4',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	  inversion => 2,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' }
	  ]
	}
      }
    ]
  },
  { text => 'ii',
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'ii',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 2 },
	  quality => 'minor',
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      }
    ]
  },
  { text => 'ii6',
    tags => [
      { type => 'sense',
        start => 0, end => 3, lex => 'ii6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 2 },
	  quality => 'minor',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      }
    ]
  },
  { text => 'ii6 V I',
    tags => [
      { type => 'sense',
        start => 0, end => 3, lex => 'ii6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 2 },
	  quality => 'minor',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
      { type => 'sense',
        start => 4, end => 5, lex => 'V',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 6, end => 7, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 0, end => 7, lex => 'ii6 V I',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 2 },
	      quality => 'minor',
	      inversion => 1,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    }
	  ]
	}
      }
    ]
  },
  { text => 'ii7',
    tags => [
      { type => 'sense',
        start => 0, end => 3, lex => 'ii7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 2 },
	  quality => 'minor',
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      }
    ]
  },
  { text => 'ii-6-5',
    tags => [
      { type => 'sense',
        start => 0, end => 6, lex => 'ii-6-5',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 2 },
	  quality => 'minor',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      }
    ]
  },
  { text => 'ii-6-5 V I',
    tags => [
      { type => 'sense',
        start => 0, end => 6, lex => 'ii-6-5',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 2 },
	  quality => 'minor',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
      { type => 'sense',
        start => 7, end => 8, lex => 'V',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 9, end => 10, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 0, end => 10, lex => 'ii-6-5 V I',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 2 },
	      quality => 'minor',
	      inversion => 1,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
		{ type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    }
	  ]
	}
      }
    ]
  },
  { text => 'ii-4-2',
    tags => [
      { type => 'sense',
        start => 0, end => 6, lex => 'ii-4-2',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 2 },
	  quality => 'minor',
	  inversion => 3,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 2, quality => 'major' }
	  ]
	}
      }
    ]
  },
  { text => 'iiø4-2',
    tags => [
      { type => 'sense',
        start => 0, end => 6, lex => 'iiø4-2',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 2 },
	  quality => 'half-diminished',
	  inversion => 3,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 2, quality => 'major' }
	  ]
	}
      }
    ]
  },
  { text => 'iii',
    tags => [
      { type => 'sense',
        start => 0, end => 3, lex => 'iii',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 3 },
	  quality => 'minor',
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      }
    ]
  },
  { text => 'IV',
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'IV',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 4 },
	  quality => 'major',
	}
      }
    ]
  },
  { text => 'IV V I',
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'IV',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 4 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 3, end => 4, lex => 'V',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 5, end => 6, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 0, end => 6, lex => 'IV V I',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 4 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    }
	  ]
	}
      }
    ]
  },
  { text => 'IV6',
    tags => [
      { type => 'sense',
        start => 0, end => 3, lex => 'IV6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 4 },
	  quality => 'major',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      }
    ]
  },
  { text => 'iv6',
    tags => [
      { type => 'sense',
        start => 0, end => 3, lex => 'iv6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 4 },
	  quality => 'minor',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      }
    ]
  },
  { text => 'IV-6-4',
    tags => [
      { type => 'sense',
        start => 0, end => 6, lex => 'IV-6-4',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 4 },
	  quality => 'major',
	  inversion => 2,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' }
	  ]
	}
      }
    ]
  },
  { text => 'iv-6-4',
    tags => [
      { type => 'sense',
        start => 0, end => 6, lex => 'iv-6-4',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 4 },
	  quality => 'minor',
	  inversion => 2,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' }
	  ]
	}
      }
    ]
  },
  { text => 'I IV-6-4 I',
    tags => [
      { type => 'sense',
        start => 0, end => 1, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 2, end => 8, lex => 'IV-6-4',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 4 },
	  quality => 'major',
	  inversion => 2,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' }
	  ]
	}
      },
      { type => 'sense',
        start => 9, end => 10, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 0, end => 10, lex => 'I IV-6-4 I',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 4 },
	      quality => 'major',
	      inversion => 2,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
		{ type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    }
	  ]
	}
      }
    ]
  },
  { text => 'V',
    tags => [
      { type => 'sense',
        start => 0, end => 1, lex => 'V',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	}
      },
    ]
  },
  { text => 'V6',
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'V6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      }
    ]
  },
  { text => 'V6 V I',
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'V6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 3, end => 4, lex => 'V',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 5, end => 6, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 0, end => 6, lex => 'V6 V I',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	      inversion => 1,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    }
	  ]
	}
      }
    ]
  },
  { text => 'V7',
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'V7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      }
    ]
  },
  { text => 'V-6-5',
    tags => [
      { type => 'sense',
        start => 0, end => 5, lex => 'V-6-5',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'diminished' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      }
    ]
  },
  { text => 'V-4-3',
    tags => [
      { type => 'sense',
        start => 0, end => 5, lex => 'V-4-3',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	  inversion => 2,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      }
    ]
  },
  { text => 'V-4-2',
    tags => [
      { type => 'sense',
        start => 0, end => 5, lex => 'V-4-2',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	  inversion => 3,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 4, quality => 'augmented' },
	    { type => 'interval', 'scale-degree-span' => 2, quality => 'major' }
	  ]
	}
      }
    ]
  },
  { text => 'V-4-3 - I6',
    tags => [
      { type => 'sense',
        start => 0, end => 5, lex => 'V-4-3',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	  inversion => 2,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 8, end => 10, lex => 'I6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 0, end => 10, lex => 'V-4-3 - I6',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	      inversion => 2,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
		{ type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	      inversion => 1,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    }
	  ]
	}
      }
    ]
  },
  { text => 'vi',
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'vi',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 6 },
	  quality => 'minor',
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      }
    ]
  },
  { text => 'viio6',
    # this is a diminished chord on s.d. 7 that is then inverted once, not an inverted minor chord with a lowered 6th interval
    tags => [
      { type => 'sense',
        start => 0, end => 5, lex => 'viio6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 7 },
	  quality => 'diminished',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      }
    ]
  },
  { text => 'V-6-4-5-3',
    tags => [
      { type => 'sense',
        start => 0, end => 5, lex => 'V-6-4',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 }, # !
	  quality => 'major',
	  inversion => 2,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' }
	  ]
	}
      },
      { type => 'sense',
        start => 6, end => 9, lex => '5-3',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 0, end => 9, lex => 'V-6-4-5-3',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 }, # !
	      quality => 'major',
	      inversion => 2,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
		{ type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	    }
	  ]
	}
      }
    ]
  },
  # Chord progressions
  { text => 'I viio6 I6', # tonic voice exchange
    tags => [
      { type => 'sense',
        start => 0, end => 1, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 2, end => 7, lex => 'viio6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 7 },
	  quality => 'diminished',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 8, end => 10, lex => 'I6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 0, end => 10, lex => 'I viio6 I6',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 7 },
	      quality => 'diminished',
	      inversion => 1,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	      inversion => 1,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    }
	  ]
	}
      }
    ]
  },
  { text => 'ii I6 ii6', # predominant voice exchange
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'ii',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 2 },
	  quality => 'minor',
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 3, end => 5, lex => 'I6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 6, end => 9, lex => 'ii6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 2 },
	  quality => 'minor',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
      { type => 'sense',
        start => 0, end => 9, lex => 'ii I6 ii6',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 2 },
	      quality => 'minor',
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	      inversion => 1,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 2 },
	      quality => 'minor',
	      inversion => 1,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	      ]
	    }
	  ]
	}
      }
    ]
  },
  { text => 'I V-4-3 I6', # 10-10-10
    tags => [
      { type => 'sense',
        start => 0, end => 1, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 2, end => 7, lex => 'V-4-3',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	  inversion => 2,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 8, end => 10, lex => 'I6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 0, end => 10, lex => 'I V-4-3 I6',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	      inversion => 2,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
		{ type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	      inversion => 1,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    }
	  ]
	}
      }
    ]
  },
  { text => 'V-6-4 V-4-2 I6', # avoided cadence
    tags => [
      { type => 'sense',
        start => 0, end => 5, lex => 'V-6-4',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	  inversion => 2,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' }
	  ]
	}
      },
      { type => 'sense',
        start => 6, end => 11, lex => 'V-4-2',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	  inversion => 3,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 4, quality => 'augmented' },
	    { type => 'interval', 'scale-degree-span' => 2, quality => 'major' }
	  ]
	}
      },
      { type => 'sense',
        start => 12, end => 14, lex => 'I6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 0, end => 14, lex => 'V-6-4 V-4-2 I6',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	      inversion => 2,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
		{ type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	      inversion => 3,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
		{ type => 'interval', 'scale-degree-span' => 4, quality => 'augmented' },
		{ type => 'interval', 'scale-degree-span' => 2, quality => 'major' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	      inversion => 1,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    }
	  ]
	}
      }
    ]
  },
  { text => 'I ii-4-2 V-6-5 I', # lazy bass (major)
    tags => [
      { type => 'sense',
        start => 0, end => 1, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 2, end => 8, lex => 'ii-4-2',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 2 },
	  quality => 'minor',
	  inversion => 3,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 2, quality => 'major' }
	  ]
	}
      },
      { type => 'sense',
        start => 9, end => 14, lex => 'V-6-5',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'diminished' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 15, end => 16, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 0, end => 16, lex => 'I ii-4-2 V-6-5 I',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 2 },
	      quality => 'minor',
	      inversion => 3,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
		{ type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 2, quality => 'major' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	      inversion => 1,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
		{ type => 'interval', 'scale-degree-span' => 5, quality => 'diminished' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    }
	  ]
	}
      }
    ]
  },
  { text => 'i iiø4-2 V-6-5 i', # lazy bass (minor)
    tags => [
      { type => 'sense',
        start => 0, end => 1, lex => 'i',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'minor',
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 2, end => 8, lex => 'iiø4-2',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 2 },
	  quality => 'half-diminished',
	  inversion => 3,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 2, quality => 'major' }
	  ]
	}
      },
      { type => 'sense',
        start => 9, end => 14, lex => 'V-6-5',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'diminished' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 15, end => 16, lex => 'i',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'minor',
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 0, end => 16, lex => 'i iiø4-2 V-6-5 i',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'minor',
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 2 },
	      quality => 'half-diminished',
	      inversion => 3,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
		{ type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 2, quality => 'major' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	      inversion => 1,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
		{ type => 'interval', 'scale-degree-span' => 5, quality => 'diminished' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'minor',
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    }
	  ]
	}
      }
    ]
  },
  { text => 'I6 viio6 I V-4-3 I6 IV viio6 I', # ascending major scale in melody
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'I6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 3, end => 8, lex => 'viio6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 7 },
	  quality => 'diminished',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 9, end => 10, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 11, end => 16, lex => 'V-4-3',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	  inversion => 2,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 17, end => 19, lex => 'I6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 20, end => 22, lex => 'IV',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 4 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 23, end => 28, lex => 'viio6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 7 },
	  quality => 'diminished',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 29, end => 30, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 0, end => 30, lex => 'I6 viio6 I V-4-3 I6 IV viio6 I',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	      inversion => 1,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 7 },
	      quality => 'diminished',
	      inversion => 1,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	      inversion => 2,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
		{ type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	      inversion => 1,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 4 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 7 },
	      quality => 'diminished',
	      inversion => 1,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    }
	  ]
	}
      }
    ]
  },
  { text => 'I V I V-4-3 I6 IV V-4-3 I', # alternative version of above
    tags => [
      { type => 'sense',
        start => 0, end => 1, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 2, end => 3, lex => 'V',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 4, end => 5, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 6, end => 11, lex => 'V-4-3',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	  inversion => 2,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 12, end => 14, lex => 'I6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 15, end => 17, lex => 'IV',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 4 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 18, end => 23, lex => 'V-4-3',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	  inversion => 2,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 24, end => 25, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 0, end => 25, lex => 'I V I V-4-3 I6 IV V-4-3 I',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	      inversion => 2,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
		{ type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	      inversion => 1,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 4 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	      inversion => 2,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
		{ type => 'interval', 'scale-degree-span' => 4, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    }
	  ]
	}
      }
    ]
  },
  { text => 'I iii IV I V7 I V7 I', # descending (Puff the Magic Dragon)
    tags => [
      { type => 'sense',
        start => 0, end => 1, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 2, end => 5, lex => 'iii',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 3 },
	  quality => 'minor',
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 6, end => 8, lex => 'IV',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 4 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 9, end => 10, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 11, end => 13, lex => 'V7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
      { type => 'sense',
        start => 14, end => 15, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 16, end => 18, lex => 'V7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
      { type => 'sense',
        start => 19, end => 20, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 0, end => 20, lex => 'I iii IV I V7 I V7 I',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 3 },
	      quality => 'minor',
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 4 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
		{ type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
		{ type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    }
	  ]
	}
      }
    ]
  },
  # Chord progressions not on test
  { text => 'I vi ii V7 I', # descending 5ths
    tags => [
      { type => 'sense',
        start => 0, end => 1, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 2, end => 4, lex => 'vi',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 6 },
	  quality => 'minor',
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 5, end => 7, lex => 'ii',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 2 },
	  quality => 'minor',
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 8, end => 10, lex => 'V7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
      { type => 'sense',
        start => 11, end => 12, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 0, end => 12, lex => 'I vi ii V7 I',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 6 },
	      quality => 'minor',
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 2 },
	      quality => 'minor',
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
		{ type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    }
	  ]
	}
      }
    ]
  },
  { text => 'I vi IV V', # descending 3rds
    tags => [
      { type => 'sense',
        start => 0, end => 1, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 2, end => 4, lex => 'vi',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 6 },
	  quality => 'minor',
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 5, end => 7, lex => 'IV',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 4 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 8, end => 9, lex => 'V',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 0, end => 9, lex => 'I vi IV V',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 6 },
	      quality => 'minor',
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 4 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	    }
	  ]
	}
      }
    ]
  },
  { text => 'vi V I', # Zarathustra
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'vi',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 6 },
	  quality => 'minor',
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 3, end => 4, lex => 'V',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 5, end => 6, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 0, end => 6, lex => 'vi V I',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 6 },
	      quality => 'minor',
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    }
	  ]
	}
      }
    ]
  },
  { text => 'I IV6 I6', # alternate 345 (not 10-10-10)
    tags => [
      { type => 'sense',
        start => 0, end => 1, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 2, end => 5, lex => 'IV6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 4 },
	  quality => 'major',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 6, end => 8, lex => 'I6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 0, end => 8, lex => 'I IV6 I6',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 4 },
	      quality => 'major',
	      inversion => 1,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	      inversion => 1,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    }
	  ]
	}
      }
    ]
  },
  { text => 'IV6 V-6-5 I', # stepwise bass
    tags => [
      { type => 'sense',
        start => 0, end => 3, lex => 'IV6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 4 },
	  quality => 'major',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 4, end => 9, lex => 'V-6-5',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'diminished' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 10, end => 11, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 0, end => 11, lex => 'IV6 V-6-5 I',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 4 },
	      quality => 'major',
	      inversion => 1,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	      inversion => 1,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'minor' },
		{ type => 'interval', 'scale-degree-span' => 5, quality => 'diminished' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    }
	  ]
	}
      }
    ]
  },
  # Cadences
  { text => 'IV I', # plagal
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'IV',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 4 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 3, end => 4, lex => 'I',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 1 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 0, end => 4, lex => 'IV I',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 4 },
	      quality => 'major',
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 1 },
	      quality => 'major',
	    }
	  ]
	}
      }
    ]
  },
  { text => 'iv6 V', # phrygian
    tags => [
      { type => 'sense',
        start => 0, end => 3, lex => 'iv6',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 4 },
	  quality => 'minor',
	  inversion => 1,
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
      { type => 'sense',
        start => 4, end => 5, lex => 'V',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	}
      },
      { type => 'sense',
        start => 0, end => 5, lex => 'iv6 V',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 4 },
	      quality => 'minor',
	      inversion => 1,
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 6, quality => 'major' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	    }
	  ]
	}
      }
    ]
  },
  { text => 'V7 vi', # deceptive
    tags => [
      { type => 'sense',
        start => 0, end => 2, lex => 'V7',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 5 },
	  quality => 'major',
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	  ]
	}
      },
      { type => 'sense',
        start => 3, end => 5, lex => 'vi',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', 'scale-degree' => 6 },
	  quality => 'minor',
	  'intervals-above-bass' => [
	    { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
	    { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	  ]
	}
      },
      { type => 'sense',
        start => 0, end => 5, lex => 'V7 vi',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 5 },
	      quality => 'major',
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 7, quality => 'minor' },
		{ type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
	      ]
	    },
	    { type => 'chord',
	      root => { type => 'pitch', 'scale-degree' => 6 },
	      quality => 'minor',
	      'intervals-above-bass' => [
		{ type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
		{ type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
	      ]
	    }
	  ]
	}
      }
    ]
  },
);
=begin
  templates for making tests

  { text => '', tags => [] },
  { text => '',
    tags => [
    ]
  },
      { type => 'sense',
        start => 0, end => , lex => '',
	'penn-pos' => ['NN'], lftype => ['PITCH'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'pitch',
	  letter => '',
	  'semitones-above-natural' => 
	}
      },
      { type => 'sense',
        start => 0, end => , lex => '',
	'penn-pos' => ['NN'], lftype => ['PITCH-INTERVAL'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'interval',
	  'scale-degree-span' => ,
	  quality => ,
	  'semitones-above-natural' => 
	}
      },
      { type => 'sense',
        start => 0, end => , lex => '',
	'penn-pos' => ['NN'], lftype => ['CHORD'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'chord',
	  root => { type => 'pitch', },
	  quality => 'major',
	  'intervals-above-root' => [
	    { type => 'interval', 'scale-degree-span' => 5 },
	    { type => 'interval', 'scale-degree-span' => 3 }
	  ]
	}
      },
      { type => 'sense',
        start => 0, end => , lex => '',
	'penn-pos' => ['NN'], lftype => ['SEQUENCE'],
	'domain-specific-info' => {
	  domain => 'music',
	  type => 'progression',
	  members => [
	  ]
	}
      }
=cut

my $pretty = 0;
my $format = undef;
my $USAGE = <<EOU;
USAGE: 
  ./MusicTests.pl [options] [first-test-index [last-test-index]]

Runs all the tests if no test indices are supplied. If only first-test-index is
supplied, runs only that test (even if it would normally be skipped). If
last-test-index is also supplied, runs all the tests in the range, inclusive.
Note that options must occur first, before any indices.

Options:

--help
  	Prints this help text and exits.
--format=native|lattice
	Prints the correct output tags from each test after running the test,
	in the selected format. "lattice" is what TRIPS uses, "native" is
	closer to TextTagger's internal data structures.
--pretty
	(only useful with --format) Adds whitespace to the formatted output
	tags to make them easier to read.

Output:

Each selected test prints one line to STDOUT:

√ 123. foo bar
A BBB  CCCCCCC

A = test status (√=passed; X=failed; E=errored; S=skipped)
B = test index
C = input text

Failed tests also print a colorized diff of the actual and expected tags, in
Perl format (this isn't affected by --format). Errored tests print the error
message.

After all tests finish, a summary is printed, counting how many tests had each
status.
EOU

while (@ARGV and $ARGV[0] =~ /^--/) {
  $_ = shift @ARGV;
  if (/^--help$/) {
    print $USAGE;
    exit;
  } elsif (/^--format=(native|lattice)$/) {
    $format = $1;
  } elsif (/^--pretty$/) {
    $pretty = 1;
  } else {
    die "Invalid argument: $_\n$USAGE";
  }
}

if (@ARGV == 1) {
  @tests = ($tests[$ARGV[0]]);
} elsif (@ARGV == 2) {
  @tests = @tests[$ARGV[0]..$ARGV[1]];
}

my @key_order = qw(domain type start end lex penn-pos lftype domain-specific-info root bass letter scale-degree octave scale-degree-span semitones-above-natural quality inversion intervals-above-bass intervals-above-root case value);
my %ordered_keys = ();
for (@key_order) { $ordered_keys{$_} = 1; }

$Data::Dumper::Deepcopy = 1;
$Data::Dumper::Sortkeys = sub {
  my $h = shift;
  [
    (map { exists($h->{$_}) ? ($_) : () } @key_order),
    sort { $a cmp $b } grep { !exists($ordered_keys{$_}) } keys %$h
  ]
};

# this function is evil
sub printdiff {
  my ($x, $y) = @_;
  $^F = 7; # prevent 4 more fd's from being closed when we exec diff
  pipe READX, WRITEX;
  pipe READY, WRITEY;
  my $xpid = fork;
  if ($xpid == 0) { # x writer child
    close READX;
    close READY;
    close WRITEY;
    print WRITEX $x;
    close WRITEX;
    exit;
  }
  my $ypid = fork;
  if ($ypid == 0) { # y writer child
    close READX;
    close READY;
    close WRITEX;
    print WRITEY $y;
    close WRITEY;
    exit;
  }
  close WRITEX;
  close WRITEY;
  my $xfd = fileno(READX);
  my $yfd = fileno(READY);
  system("diff -u /dev/fd/$xfd /dev/fd/$yfd | perl -p -e 'use Term::ANSIColor qw(:constants); \$_=\"\" if (/^--- |^\\+\\+\\+ /); s/^-.*/RED . \$& . RESET/gem; s/^\\+.*/GREEN . \$& . RESET/gem;'");
  close READX;
  close READY;
  waitpid $xpid, 0;
  waitpid $ypid, 0;
}

my ($passed, $failed, $errored, $skipped) = (0,0,0,0);
my $i = $ARGV[0] || 0;
for my $test (@tests) {
  print BOLD, BLUE, "  $i. " . $test->{text} . "\r";
  if ($test->{skip} && !(@ARGV == 1 && $ARGV[0] == $i)) {
    # test was marked to be skipped, and was not the only test we were asked to
    # run
    print BLUE, "S\n", RESET;
    $skipped++;
  } else {
    eval {
      my @tags = @{tag_roman_numerals(+{}, $test->{text})};
      @tags = @{tag_music(+{}, $test->{text}, @tags)};
      # use this instead if you want to test roman-numeral tags too
      #push @tags, @{tag_music(+{}, $test->{text}, @tags)};
      @tags = sortTags(@tags);
      if (structurally_equal(\@tags, $test->{tags})) {
	$passed++;
	print GREEN, "√\n", RESET;
      } else {
	$failed++;
	print RED, "X\n", RESET;
	#print Data::Dumper->Dump([\@tags], ['*actual']);
	printdiff(Data::Dumper->Dump([\@tags], ['*actual']), Data::Dumper->Dump([$test->{tags}], ['*expect']));
      }
      1
    } || do {
      $errored++;
      print YELLOW, "E\n", WHITE, "$@\n", RESET;
    };
  }
  if ($format) {
    my $combined_tags =
      ($format eq 'lattice' ? # only lattice format requires combining tags
	[sortTags(combine_tags(+{}, @{$test->{tags}}))] :
	$test->{tags});
    my $kqml = join('', map { KQML::KQMLAsString($_) . "\n" }
			    tags2trips($combined_tags, $format));
    if ($pretty) {
      $kqml =~ s/((?<=\()| )(?=:|\()/
	my $b4 = $`;
	if ($b4 =~ m!:[a-z-]+$!) {
	  ' '
	} else {
	  my $indent = scalar(@{[$b4 =~ m!\(!g]}) - scalar(@{[$b4 =~ m!\)!g]});
	  "\n" . ('  'x$indent)
	}
      /ge;
    }
    print RESET, $kqml;
  }
  $i++;
}
print BOLD, "Summary:\n", GREEN, "  passed:  $passed\n", RED, "  failed:  $failed\n", YELLOW, "  errored: $errored\n", BLUE, "  skipped: $skipped\n", RESET;

