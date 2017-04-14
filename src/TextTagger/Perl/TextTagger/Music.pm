package TextTagger::Music;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(tag_music);

use charnames ':full';
use TextTagger::Util qw(match2tag structurally_equal);
use TextTagger::Normalize qw($dash_re);

use utf8;
use strict vars;

#
# data, regexen, and utility functions
#

my @interval_qualities = qw(diminished minor perfect major augmented);
my $interval_quality_re = join('|', @interval_qualities);
my $chord_quality_re = qr/\b(?i:dominant|$interval_quality_re)\b/;
$interval_quality_re = qr/\b(?i:$interval_quality_re)\b/;
my @int_qual = qw(dim min perf maj aug);
my $int_qual_re = '(?i:' . join('|', @int_qual) . ')';
my $ch_qual_re = '(?i:dom|' . join('|', @int_qual) . ')';
my %IQ = (
  "\N{LATIN SMALL LETTER O WITH STROKE}" => 'half-diminished',
  "\N{DEGREE SIGN}" => 'diminished', qw(
  o diminished
  0 diminished
  m minor
  P perfect
  M major
  A augmented
  + augmented
));
# I originally also had this:
#  d diminished 
# But it causes a lot of false positives, and Wikipedia claims it's not used.
my $IQ_re = '(?:' . join('|', keys %IQ) . ')';
$IQ_re =~ s/\+/\\+/g; # escape augmentation +
my %iq2index =
  (map { ($interval_qualities[$_] => $_, $int_qual[$_] => $_) } 0..4);
for (keys %IQ) {
  $iq2index{$_} = $iq2index{$IQ{$_}} if (exists($iq2index{$IQ{$_}}));
}

sub expand_iq {
  my $iq = shift;
  $iq = lc($iq) if (length($iq) > 1);
  if (exists($iq2index{$iq})) {
    return $interval_qualities[$iq2index{$iq}];
  } elsif (exists($IQ{$iq})) {
    return $IQ{$iq};
  } elsif ($iq eq 'dom') {
    return 'dominant';
  } else {
    return $iq;
  }
}

# return the quality of the interval made by inverting an interval with the
# given quality (moving its bottom note up by octaves until it's above the top
# note)
sub invert_iq {
  return $interval_qualities[4 - $iq2index{$_[0]}];
}

# map accidental strings to the represented number of semitones above natural
my %accidental2semitones = (
  "\N{MUSICAL SYMBOL DOUBLE FLAT}" => -2,
  '♭♭' => -2,
  'bb' => -2,
  '♭' => -1,
  'b' => -1,
  '♮' => 0,
  'n' => 0,
  '♯' => 1,
  '#' => 1,
  "\N{MUSICAL SYMBOL DOUBLE SHARP}" => 2,
  '♯♯' => 2,
  '##' => 2
);
my $accidental_re = '(?:' . join('|', keys %accidental2semitones) . ')';
$accidental_re =~ s/#/\\#/g; # escape comment character for use with /x
# don't include these in the re
$accidental2semitones{'double flat'} = -2;
$accidental2semitones{'flat'} = -1;
$accidental2semitones{'natural'} = 0;
$accidental2semitones{'sharp'} = 1;
$accidental2semitones{'double sharp'} = 2;
my $accidental_word_re = qr/\b(?:natural|(?:double\s+)?(?:flat|sharp))\b/i;

my @cardinal_words = qw(one two three four five six seven);
my $cardinal_re = '\\b(?i:' . join('|', @cardinal_words) . ')\\b';
my %cardinal2int = (map { $cardinal_words[$_-1] => $_ } 1..7);

my @ordinal_words = qw(second third fourth fifth sixth seventh octave ninth tenth eleventh twelfth thirteenth);
my @ordinal_numbers = (qw(2nd 3rd), map { $_ . 'th' } 4..13);
my %ordinal2int =
  (map { (
     $ordinal_words[$_-2] => $_,
     $ordinal_numbers[$_-2] => $_,
     $_ => $_ # including the number itself as a key makes things easier later
   ) } 2..13);
my $ordinal_re = '\\b(?i:' . join('|', (grep { $_ ne 'octave' } @ordinal_words), @ordinal_numbers) . ')\\b';
# used internally
$ordinal2int{implicit_5th} = 5;

my @major_triad_intervals = (
  { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
  { type => 'interval', 'scale-degree-span' => 3, quality => 'major' }
);

my @minor_triad_intervals = (
  { type => 'interval', 'scale-degree-span' => 5, quality => 'perfect' },
  { type => 'interval', 'scale-degree-span' => 3, quality => 'minor' }
);

sub copy_intervals {
  map { defined($_) ? +{%$_} : undef } @_;
}

#
# main entry point
#

sub tag_music {
  my ($self, $text, @input_tags) = @_;
  my @intervals = tag_intervals($text);
  my @letters = tag_letter_notes_and_chords($text);
  my @romans = tag_roman_numeral_chords($text, @input_tags);
  # discard intervals contained by letter chords
  @intervals =
    grep {
      my $int = $_;
      not(grep {
	my $let = $_;
	$let->{'domain-specific-info'}->{type} eq 'chord' and
	$let->{start} <= $int->{start} and $int->{end} <= $let->{end}
      } @letters)
    } @intervals;
  my @output_tags = (@intervals, @letters, @romans);
  push @output_tags, tag_sequences($text, @letters, @romans);
  return [@output_tags];
}

#
# sub-taggers
#

my $interval_re =
  qr/
    (?:
      (?: $interval_quality_re | $int_qual_re )
      (?: \s+ | $dash_re )
    )?
    $ordinal_re
  /ix;
   
sub tag_intervals {
  my $text = shift;
  my @tags = ();
  while ($text =~ /$interval_re/g) {
    my $tag = { type => 'sense', lftype => ['PITCH-INTERVAL'], match2tag() };
    my $dsi = { domain => 'music', type => 'interval' };
    if ($tag->{lex} =~ /\s+|$dash_re/) {
      my ($quality, $ordinal) = ($`, $');
      $dsi->{'scale-degree-span'} = $ordinal2int{lc($ordinal)};
      $dsi->{quality} = expand_iq($quality);
      # TODO check for double/doubly diminished/augmented
    } else {
      $dsi->{'scale-degree-span'} = $ordinal2int{lc($tag->{lex})};
    }
    $tag->{'domain-specific-info'} = $dsi;
    push @tags, $tag;
  }
  return @tags;
}

# numbers that *could* be used to indicate intervals
my $loose_int_re = qr/(?:[2-79]|11|13)/;
# numbers that are likely enough to be intervals that we can justify making a
# chord tag when it could also be a pitch with an octave number
my $strict_int_re = qr/^(?:[24679]|11|13)$/;

# return the interval quality to be used, with defaulting behavior dependent on
# the specific interval, and any explicit interval and chord qualities
sub defaulted_interval_quality {
  my ($sds, $interval_quality, $int_accidental, $chord_quality, $prev_quality) = @_;
  # explicit interval quality
  if (defined($interval_quality)) {
    return expand_iq($interval_quality);
  } elsif (defined($int_accidental)) {
    # convert accidental to quality
    # FIXME? I'm uncertain whether the accidental really just stands for an
    # interval quality as Wikipedia suggests, or whether it stands for the
    # actual accidental that would be on the high note in the interval in the
    # current key.
    return [qw(double-diminished diminished perfect augmented double-augmented)]->[$accidental2semitones{$int_accidental}+2];
  } elsif (defined($prev_quality)) {
    # no explicit quality defined, but we have a previous default, so use it
    return $prev_quality;
  # odd-numbered intervals <=7 are affected by chord quality
  } elsif ($sds == 3) {
    if ($chord_quality =~ /^(?:minor|(?:half-)?diminished)$/) {
      return 'minor';
    } else {
      return 'major';
    }
  } elsif ($sds == 5) {
    if ($chord_quality =~ /diminished$/) {
      return 'diminished';
    } elsif ($chord_quality eq 'augmented') {
      return 'augmented';
    } else {
      return 'perfect';
    }
  } elsif ($sds == 7) {
    if ($chord_quality eq 'major' or $chord_quality eq 'diminished') {
      return $chord_quality;
    } else {
      return 'minor';
    }
  } elsif ($sds == 1 or $sds == 4 or $sds == 8 or $sds == 11) {
    return 'perfect';
  } else { # 2,6,9,13 all default to major
    return 'major';
  }
}

sub tag_letter_notes_and_chords {
  my $text = shift;
  my @tags = ();
  while ($text =~ /
    	   (?<! \w ) (?! \W ) # more specific than \b
	   (?:
	     # this one is special
	     (?<middle_c> (?i: middle \s+ c ))
	     |
	     # spelled out in full words
	     (?:
	       (?<root_letter1> [A-G] )
	       (?! $accidental_re | $IQ_re | \/ ) # save these for next case
	       (?: \s+ (?<root_accidental_word1> $accidental_word_re ))?
	       |
	       (?<root_accidental_word2> $accidental_word_re )
	     )?
	     (?<chord_spec1>
	       (?: \s* (?<chord_quality> $chord_quality_re ))?
	       (?: (?: \s* \/ \s* | \s+ )
		   (?<interval_quality> $interval_quality_re ))?
	       (?: \s+ (?<interval_accidental> $accidental_word_re ))?
	       (?: \s+ (?<interval> $ordinal_re ))?
	       (?i: \s+ sus(?:pended)? \s*
	         (?<suspended> second | fourth | 2(?:nd)? | 4(?:th) ))?
	       (?i: \s+ add \s+ (?<interval_add> $loose_int_re ))?
	     )
	     \b
	     (?<chord_spec2> \s* $dash_re? \s* chords? \b )?
	     |
	     # using abbreviations or symbols
	     (?:
	       (?<root_letter2> [A-G] )?
	       (?<root_accidental> $accidental_re )
	       |
	       (?<root_letter3> [A-G] )
	     )
	     (?:
	       (?<chord_spec3>
		 \/
		 (?<bass_letter> [A-G])
		 (?<bass_accidental> $accidental_re)?
		 (?: \s+ (?i: bass ) \b )?
	         |
		 (?! \/ )
		 (?<chord_qual> $ch_qual_re | $IQ_re )?
		 (?: \/? (?<int_qual> $int_qual_re | $IQ_re ))?
		 (?<int_accidental> $accidental_re )?
		 (?<int> $loose_int_re )?
		 (?i: sus (?<sus> [24] ))?
		 (?i: add (?<int_add> $loose_int_re ) \b )?
		 (?! \w ) # not \b, since previous might not be \w
	       )
	       (?<chord_spec4> \s* $dash_re? \s* chords? \b )?
	       |
	       (?<octave> \d \b )
	     )
	   )
         /gx) {
    # everything is optional, but we need at least something in the match, and
    # not just the word "chord" (the lexicon can handle that)
    next if (length($&) == 0 or $& eq $+{chord_spec2} or $& eq $+{chord_spec4});
    my $tag = { type => 'sense', match2tag() };
    # captures
    my (
         $middle_c,
         $root_letter, $root_accidental, $chord_spec,
	 $chord_quality, $interval_quality, $int_accidental, $interval,
	 $suspended, $added,
	 $bass_letter, $bass_accidental,
	 $octave
       ) = (
         $+{middle_c},
         ($+{root_letter1} || $+{root_letter2} || $+{root_letter3}),
	 # short || long forms
	 ($+{root_accidental} ||
	  $+{root_accidental_word1} || $+{root_accidental_word2}),
	 ($+{chord_spec1} || $+{chord_spec2} || $+{chord_spec3} || $+{chord_spec4}),
	 ($+{chord_qual} || $+{chord_quality}),
	 ($+{int_qual} || $+{interval_quality}),
	 ($+{int_accidental} || $+{interval_accidental}),
	 ($+{'int'} || $+{interval}),
	 ($+{sus} || $+{suspended}),
	 ($+{int_add} || $+{interval_add}),
	 $+{bass_letter}, $+{bass_accidental},
	 $+{octave}
       );
#    print STDERR Data::Dumper->Dump([\%+],["*captures"]);
    if (defined($middle_c)) { # special case for "middle C"
      $tag->{lftype} = ['PITCH'];
      $tag->{'domain-specific-info'} = +{
	domain => 'music',
	type => 'pitch',
	letter => 'C',
	octave => 4
      };
      push @tags, $tag;
      next;
    }
    # also, not just the chord quality
    next if ($tag->{lex} eq $chord_quality or
	     # and not just a regular interval
             $tag->{lex} =~ /^$interval_re$/);
    my $dsi = { domain => 'music' };
    my $root = +{
      type => 'pitch',
      (defined($root_letter) ? (letter => $root_letter) : ()),
      (defined($root_accidental) ?
        ('semitones-above-natural' => $accidental2semitones{$root_accidental})
        : ()),
      (defined($octave) ? (octave => 0+$octave) : ())
    };
    my $made_pitch_tag = 0;
    if ($tag->{lex} =~ /^([A-G])($accidental_re)?(\d)?$/) {
      $made_pitch_tag = 1;
      push @tags, +{
	%$tag,
	lftype => ['PITCH'],
	'domain-specific-info' => +{
	  domain => 'music',
	  type => 'pitch',
	  letter => $1,
	  (defined($2) ?
	    ('semitones-above-natural' => $accidental2semitones{$2}) : ()),
	  (defined($3) ? (octave => 0+$3) : ())
	}
      };
    }
    if (defined($chord_spec) and
        not ($made_pitch_tag and defined($interval) and $interval =~ /^\d+$/ and
	     $interval !~ $strict_int_re)) { # chord
      $dsi->{type} = 'chord';
      $tag->{lftype} = ['CHORD'];
      $dsi->{root} = $root
	if (defined($root_letter) or defined($root_accidental));
      my @intervals = (
	undef, # no 4th note by default
	copy_intervals(@major_triad_intervals)
      );
      if (defined($chord_quality)) {
	$chord_quality = expand_iq($chord_quality);
	if (exists($iq2index{$chord_quality})) {
	  if ($chord_quality =~ /^(major|minor)$/) {
	    $intervals[2]{quality} = $chord_quality;
	  } else {
	    $intervals[1]{quality} = $chord_quality;
	    # diminished 5th implies minor 3rd
	    $intervals[2]{quality} = 'minor'
	      if ($chord_quality eq 'diminished');
	  }
	# special cases
	} elsif ($chord_quality eq 'half-diminished') {
	  # 7=minor, 5=diminished, 3=minor
	  $interval = 7 unless (defined($interval));
	  $interval_quality = 'minor';
	  $intervals[1]{quality} = 'diminished';
	  $intervals[2]{quality} = 'minor';
	} elsif ($chord_quality eq 'dominant') {
	  # root is scale degree 5, 5=perfect, 3=major
	  # except this conflicts with test 15, which has someone change a iii chord to a "dominant seventh"
	  # $dsi->{root}{'scale-degree'} = 5;
	  $interval_quality = 'minor'; # assume 7
	}
	$dsi->{quality} = $chord_quality;
      }
      # cover the odd case where we have two qualities but no interval
      $interval = 'implicit_5th'
        if ((defined($int_accidental) or defined($interval_quality)) and
	    not defined($interval));
      if (defined($interval)) {
	my $sds = $ordinal2int{lc($interval)}; # Scale Degree Span
	if ($sds == 5) {
	  my $five_quality =
	    defaulted_interval_quality($sds, $interval_quality, $int_accidental, $chord_quality, $intervals[1]{quality});
	  # the quality of the 5th affects chord quality
	  # TODO factor this and the 3rd version out (maybe put it at the end?)
	  if (defined($chord_quality) or $interval eq 'implicit_5th') {
	    $intervals[1]{quality} = $five_quality;
	    if ($five_quality eq 'augmented') {
	      if ($chord_quality eq 'minor' or
		  $chord_quality eq 'diminished') {
		delete $dsi->{quality}; # minor+augmented is weird
	      } else {
		$dsi->{quality} = $five_quality;
	      }
	    } elsif ($five_quality eq 'diminished') {
	      if ($chord_quality eq 'major' or
		  $chord_quality eq 'augmented') {
		delete $dsi->{quality}; # major+diminished is weird
	      } else {
		$dsi->{quality} = $five_quality;
	      }
	    }
	  } else { # power chord (8-5-1 instead of 5-3-1)
	    $intervals[1]{'scale-degree-span'} = 8;
	    $intervals[2]{'scale-degree-span'} = 5;
	    $intervals[2]{quality} = $five_quality
	  }
	} elsif ($sds == 3) { # weird case
	  my $five_quality = $intervals[1]{quality};
	  my $three_quality = $intervals[2]{quality};
	  $three_quality =
	    defaulted_interval_quality($sds, $interval_quality, $int_accidental, $chord_quality, $three_quality);
	  $intervals[2]{quality} = $three_quality;
	  # the qualities of the 3rd and 5th intervals affect chord quality
	  if ($five_quality eq 'perfect') {
	    if ($three_quality eq 'minor' or $three_quality eq 'major') {
	      $dsi->{quality} = $three_quality;
	    } else {
	      delete $dsi->{quality};
	    }
	  } elsif (
	      ($five_quality eq 'diminished' and $three_quality eq 'minor') or
	      ($five_quality eq 'augmented' and $three_quality eq 'major')) {
	    $dsi->{quality} = $five_quality;
	  } else { # mixed messages
	    delete $dsi->{quality};
	  }
	} elsif (($sds % 2) == 0) { # even (2, 4, 6): added tone
	  my $added = +{
	    type => 'interval',
	    'scale-degree-span' => $sds,
	    quality =>
	      defaulted_interval_quality($sds, $interval_quality, $int_accidental, $chord_quality)
	  };
	  push @intervals, $added;
	} else { # odd: 7, 9, 11, 13
	  $intervals[0] = +{
	    type => 'interval',
	    'scale-degree-span' => $sds,
	    quality =>
	      defaulted_interval_quality($sds, $interval_quality, $int_accidental, $chord_quality)
	  };
	  # fix spelled-out half-diminished chords e.g. Com7
	  # FIXME what if $sds > 7 ?
	  $dsi->{quality} = 'half-diminished'
	    if ($intervals[0]{quality} eq 'minor' and
	        $chord_quality eq 'diminished');
	  # add default intervals between 7 and $sds-1 inclusive
	  for (my $i = 7; $i < $sds; $i += 2) {
	    push @intervals, +{
	      type => 'interval',
	      'scale-degree-span' => $i,
	      quality =>
		defaulted_interval_quality($i, undef, undef, $chord_quality)
	    };
	  }
	}
      }
      if (defined($suspended)) {
	my $sds = $ordinal2int{lc($suspended)}; # Scale Degree Span
	$intervals[2]{'scale-degree-span'} = $sds; # replace 3rd with 2nd or 4th
	$intervals[2]{quality} = ($sds == 2 ? 'major' : 'perfect');
      }
      if (defined($added)) {
	my $sds = $ordinal2int{lc($added)}; # Scale Degree Span
	my $added = +{
	  type => 'interval',
	  'scale-degree-span' => $sds,
	  quality =>
	    defaulted_interval_quality($sds, $interval_quality, $int_accidental, $chord_quality)
	};
	push @intervals, $added;
      }
      if (defined($bass_letter)) {
	$dsi->{bass} = + {
	  type => 'pitch',
	  letter => $bass_letter,
	  (defined($bass_accidental) ? 
	    ('semitones-above-natural' =>
	       $accidental2semitones{$bass_accidental}) : ())
	};
      }
      shift @intervals unless (defined($intervals[0]));
      $dsi->{'intervals-above-root'} =
          [sort { $b->{'scale-degree-span'} <=> $a->{'scale-degree-span'} }
	        @intervals]
	unless (structurally_equal(\@intervals, \@major_triad_intervals));

      $tag->{'domain-specific-info'} = $dsi;
      push @tags, $tag;
    } elsif (not $made_pitch_tag) { # pitch
      $dsi = $root;
      $dsi->{domain} = 'music';
      $tag->{lftype} = ['PITCH'];
      $tag->{'domain-specific-info'} = $dsi;
      push @tags, $tag;
    }
  }
  return @tags;
}

sub tag_roman_numeral_chords {
  my ($text, @input_tags) = @_;
  my @output_tags = ();
  for my $roman (@input_tags) {
    next unless (exists($roman->{'domain-specific-info'}));
    my $dsi = $roman->{'domain-specific-info'};
    next unless ($dsi->{type} eq 'roman-numeral' and $dsi->{value} <= 7);
    my $after = substr($text, $roman->{end});
    $after =~ /^(($dash_re|\s+)?($accidental_re|$IQ_re)?$loose_int_re)*|$IQ_re/;
    my @figures = split(/($loose_int_re)/, $&);

    my $root_scale_degree = $dsi->{value};
    
    # organize @figures into groups of intervals representing chords
    my @chords = ();
    my @chord_offsets = ();
    my $chord_quality = ($dsi->{case} eq 'upper' ? 'major' : 'minor');
    push @chords, [];
    push @chord_offsets, +{ start => $roman->{start}, end => $roman->{end} };
    my $prev_figure = 14; # above highest matching $loose_int_re
    my $offset = $roman->{end}; # beginning of @figures
    # special handling for quality on first (or absent) interval, since it
    # usually says something about the chord quality instead of the interval
    # quality (e.g. viio6 is a diminished chord in first inversion, not a chord
    # with a diminished 6th interval)
    if (@figures and $figures[0] =~ /^$IQ_re$/) {
      my $quality = $IQ{$figures[0]};
      if (($chord_quality eq 'minor' and $quality =~ /diminished$/) or
          ($chord_quality eq 'major' and $quality eq 'augmented')) {
	$chord_quality = $quality;
	$offset += length($figures[0]);
	shift @figures;
	$chord_offsets[-1]{end} = $offset;
      }
    }
    while (@figures) {
      my ($start, $accidental, $quality, $figure);
      if ($figures[0] =~ /\d/) {
	$figure = shift @figures;
	$start = $offset;
	$offset += length($figure);
      } else {
	my $a_or_q = shift @figures;
	$offset += length($a_or_q);
	$a_or_q =~ s/^($dash_re|\s+)//;
	$start = $offset - length($a_or_q);
	if ($a_or_q =~ $accidental_re) {
	  $accidental = $accidental2semitones{$a_or_q};
	} elsif ($a_or_q =~ $IQ_re) {
	  $quality = $IQ{$a_or_q};
	  $chord_quality = $quality if ($quality eq 'half-diminished');
	}
	if (@figures) {
	  $figure = shift @figures;
	  $offset += length($figure);
	} elsif (defined($accidental) or defined($quality)) {
	  $figure = 5; # 5th is implied if we just have a quality with no figure
	}
      }
      defined($figure) or die "WTF";
      if ($figure > $prev_figure) { # new chord
	push @chords, [];
	push @chord_offsets, +{ start => $start, end => $offset };
      }
      push @{$chords[-1]}, +{
	type => 'interval',
	'scale-degree-span' => $figure,
	(defined($quality) ? ('quality' => $quality) : ()),
	(defined($accidental) ? ('semitones-above-natural' => $accidental) : ())
      };
      $chord_offsets[-1]{end} = $offset;
      $prev_figure = $figure;
    }
    # fill in implied intervals and qualities in each chord
    my $prev_chord = [];
    for my $chord (@chords) {
      my $figures = join('-', map { $_->{'scale-degree-span'} } @$chord);
      my $inversion = 0; # root position default
      my $seventh = 0;
      if ($figures eq '') {
	$inversion = 0;
      } elsif ($figures =~ /7(-5)?(-3)?$/) { # root position 7th
        $inversion = 0;
	$seventh = 1;
      } elsif ($figures =~ /6-5(-3)?$/) { # first inversion 7th
        $inversion = 1;
	$seventh = 1;
      } elsif ($figures =~ /4-3$/) { # second inversion 7th
        $inversion = 2;
	$seventh = 1;
      } elsif ($figures =~ /\b2$/) { # third inversion 7th
        $inversion = 3;
	$seventh = 1;
      } elsif ($figures =~ /^(5-3|5|3)$/) { # root position triad
        $inversion = 0;
      } elsif ($figures =~ /^6(-3)?$/) { # first inversion triad
        $inversion = 1;
      } elsif ($figures =~ /6-4$/) { # second inversion triad
        $inversion = 2;
      }
      # NOTE: if it's not an inversion we recognize, we just assume it's root
      # position, and any extra large intervals were explicitly given
      # fill in implied qualities
      for my $interval (@$chord) {
	# skip already-explicit qualities/accidentals
	next if ((exists($interval->{quality}) and
	          $interval->{quality} ne 'half-diminished') or
		 exists($interval->{'semitones-above-natural'}));
	my $inv_sds = $interval->{'scale-degree-span'};
	# convert sds to what it would be in root position, within one octave
	my $sds = ($inv_sds - 1 + $inversion*2) % 7 + 1;
	my $quality =
	  ($sds == 7 ? 'minor' :
	    # this doesn't treat 7ths correctly in this context
	    defaulted_interval_quality($sds, undef, undef, $chord_quality));
	if ($inversion) {
	  # translate quality of root position interval to quality of the
	  # corresponding interval of the inverted chord by "subtracting" the
	  # quality of the interval between the root and the bass
	  # FIXME should these 3rd,5th,7th I'm subtracting use defaulted_interval_quality?
	  my $subtrahend;
	  if ($inversion == 1) {
	    # subtract 3rd
	    if ($chord_quality =~ /^(major|augmented)$/) {
	      $subtrahend = 1; # major
	    } else { # minor or (half-)diminished
	      $subtrahend = -1; # minor
	    }
	  } elsif ($inversion == 2) {
	    # subtract 5th
	    if ($chord_quality eq 'augmented') {
	      $subtrahend = 1; # augmented
	    } elsif ($chord_quality =~ /diminished$/) {
	      $subtrahend = -1; # diminished
	    } else {
	      $subtrahend = 0; # perfect
	    }
	  } elsif ($inversion == 3) {
	    # subtract 7th
	    if ($chord_quality eq 'major' or
	        $chord_quality eq 'half-diminished') {
	      $subtrahend = -1; # minor
	    } else {
	      $subtrahend = $iq2index{$chord_quality} - 2; # perfect=0
	    }
	  }
	  my $minuend = $iq2index{$quality};
	  my $difference = $minuend - $subtrahend;
#	  print Data::Dumper->Dump([$chord_quality, $quality, $inversion, $inv_sds, $sds, $minuend, $subtrahend, $difference],[qw(chord_quality quality inversion inv_sds sds minuend subtrahend difference)]);
	  die "interval quality difference out of range: $minuend - $subtrahend = $difference" if ($difference < 0 || $difference >= @interval_qualities);
	  $quality = $interval_qualities[$difference];
	}
	$interval->{quality} = $quality;
      }
      # add implied 6th interval if this is a 2nd or 3rd inversion 7th chord
      if ($seventh and $inversion >= 2 and
	  not grep { $_->{'scale-degree-span'} == 6 } @$chord) {
	my $quality;
	if ($inversion == 3) {
	  $quality = ($chord_quality =~ /diminished$/ ? 'minor' : 'major');
	} else { # 2
	  $quality = ($chord_quality =~ /^(minor|augmented)$/ ?
		       'minor' : 'major');
	}
	push @$chord, +{
	       type => 'interval',
	       'scale-degree-span' => 6,
	       quality => $quality
	     };
      }
      # add implied 5th interval if we're in root position
      push @$chord, +{
	     type => 'interval',
	     'scale-degree-span' => 5,
	     quality => 'perfect'
	   }
	if ($inversion == 0 and
	    not grep { $_->{'scale-degree-span'} == 5 } @$chord);
      # add implied 4th interval if this is a third inversion 7th chord
      push @$chord, +{
	     type => 'interval',
	     'scale-degree-span' => 4,
	     quality => 'perfect' # FIXME?
	   }
        if ($seventh and $inversion == 3 and
	    not grep { $_->{'scale-degree-span'} == 4 } @$chord);
      # add implied 3rd interval we're in root or 1st inversion
      push @$chord, +{
	     type => 'interval',
	     'scale-degree-span' => 3,
	     quality =>
	       ($inversion == 0 ?
	         ($chord_quality =~ /^minor$|diminished$/ ? 'minor' : 'major') :
		 ($chord_quality =~ /^major$|diminished$/ ? 'minor' : 'major'))
	   }
	if ($inversion <= 1 and
	    not grep { $_->{'scale-degree-span'} == 3 } @$chord);
      # sort @$chord so intervals descend, since we might have added some out
      # of order
      @$chord =
        sort { $b->{'scale-degree-span'} <=> $a->{'scale-degree-span'} }
	     @$chord;
      $prev_chord = $chord;
      my $offsets = shift @chord_offsets;
      push @output_tags, +{
	type => 'sense',
	lex => substr($text, $offsets->{start}, $offsets->{end} - $offsets->{start}),
	%$offsets,
	lftype => ['CHORD'],
	'domain-specific-info' => +{
	  domain => 'music',
	  type => 'chord',
	  # FIXME V-6-4-5-3 should become I-6-4 followed by V-5-3, but this
	  # makes it V-6-4 followed by V-5-3
	  # maybe controversial:
	  # https://medium.com/@michaelkaulkin/name-that-chord-the-confusing-world-of-the-cadential-6-4-df58dd6a86cc
	  root => { type => 'pitch', 'scale-degree' => $root_scale_degree },
	  quality => $chord_quality,
	  ($inversion > 0 ? (inversion => $inversion) : ()),
	  (structurally_equal($chord, \@major_triad_intervals) ? () :
	    ('intervals-above-bass' => $chord))
	  # TODO include bass, intervals above root?
	}
      };
    }
    # special case for V-6-4-5-3 => I-6-4 V-5-3
    if (@chords == 2) {
      my $first = $output_tags[-2]{'domain-specific-info'};
      my $second = $output_tags[-1]{'domain-specific-info'};
      if ($first->{root}{'scale-degree'} == 5 and $first->{inversion} == 2 and
	  $second->{root}{'scale-degree'} == 5 and $second->{inversion} == 0) {
	$first->{root}{'scale-degree'} = 1;
      }
    }
  }
  return @output_tags;
}

sub sequence_item_cmp {
  my ($a, $b) = @_;
  # sort by increasing start offset first
  my $start_cmp = $a->{start} <=> $b->{start};
  return $start_cmp unless ($start_cmp == 0);
  # then prefer chords over pitches
  my $a_is_chord = ($a->{'domain-specific-info'}{type} eq 'chord');
  my $b_is_chord = ($b->{'domain-specific-info'}{type} eq 'chord');
  if ($a_is_chord and not $b_is_chord) {
    return -1;
  } elsif ($b_is_chord and not $a_is_chord) {
    return 1;
  }
  # then prefer longer tags over shorter ones
  return ($b->{end} <=> $a->{end});
}

sub pitch_dsi_to_chord_tag {
  my $pitch = shift;
  my $chord = { domain => 'music', type => 'chord', root => +{ %$pitch } };
  delete @{$chord->{root}}{qw(lex start end)};
  my $chord_tag = +{
    type => 'sense',
    lex => $pitch->{lex},
    start => $pitch->{start},
    end => $pitch->{end},
    lftype => ['CHORD'],
    'domain-specific-info' => $chord
  };
  return $chord_tag;
}

sub tag_to_sequence_item {
  my $tag = shift;
  my $item = +{
    %{$tag->{'domain-specific-info'}}, # copy DSI
    # temp. copy lex/start/end in case we need to promote a pitch to a chord
    lex => $tag->{lex},
    start => $tag->{start},
    end => $tag->{end}
  };
  delete $item->{domain}; # don't need this for internal structures of DSI
  return $item;
}

sub tag_sequences {
  my ($text, @input_tags) = @_;
  # sort input tags so we can easily get the next item in the sequence
  # NOTE: this is a different order from what sortTags uses
  @input_tags = sort { sequence_item_cmp($a, $b) } @input_tags;
  my @output_tags = ();
  my @items = ();
  my $item_type = 'pitch';
  my $start = 0;
  my $end = 0;
  while (@input_tags) {
    my $input_tag = shift @input_tags;
    my $item = tag_to_sequence_item($input_tag);
    if (@items) {
      next unless ($input_tag->{start} >= $end);
      my $between = substr($text, $end, $input_tag->{start} - $end);
      if ($between =~ /^\s*$dash_re?\s*$/) { # continue sequence
	if ($item_type eq 'pitch' and $item->{type} eq 'chord') {
	  $item_type = 'chord';
	  @items = map {
	    my $chord_tag = pitch_dsi_to_chord_tag($_);
	    push @output_tags, $chord_tag;
	    tag_to_sequence_item($chord_tag)
	  } @items;
	} elsif ($item_type eq 'chord' and $item->{type} eq 'pitch') {
	  my $chord_tag = pitch_dsi_to_chord_tag($item);
	  push @output_tags, $chord_tag;
	  $item = tag_to_sequence_item($chord_tag);
	}
	push @items, $item;
      } else {
	# end previous sequence
	if (@items > 1) {
	  for (@items) { delete @{$_}{qw(lex start end)}; }
	  push @output_tags, +{
	    type => 'sense',
	    start => $start, end => $end,
	    lex => substr($text, $start, $end-$start),
	    lftype => ['SEQUENCE'],
	    'domain-specific-info' => +{
	      domain => 'music',
	      type => ($item_type eq 'chord' ? 'progression' : 'pitch-sequence'),
	      members => [@items]
	    }
	  };
	}
	# start new sequence
        @items = ($item);
	$item_type = $item->{type};
	$start = $input_tag->{start};
      }
    } else { # start of sequence
      @items = ($item);
      $item_type = $item->{type};
      $start = $input_tag->{start};
    }
    $end = $input_tag->{end};
  }
  if (@items > 1) { # end final sequence
    for (@items) { delete @{$_}{qw(lex start end)}; }
    push @output_tags, +{
      type => 'sense',
      start => $start, end => $end,
      lex => substr($text, $start, $end-$start),
      lftype => ['SEQUENCE'],
      'domain-specific-info' => +{
	domain => 'music',
	type => ($item_type eq 'chord' ? 'progression' : 'pitch-sequence'),
	members => [@items]
      }
    };
  }
  # also tag sequences of cardinal number words as chord progressions
  while ($text =~ /$cardinal_re(?:(?:$dash_re|\s+)$cardinal_re)+/g) {
    my $sequence_tag = +{
      type => 'sense',
      lftype => ['SEQUENCE'],
      match2tag()
    };
    my @members = ();
    while ($sequence_tag->{lex} =~ /$cardinal_re/g) {
      my $chord_tag = +{
	type => 'sense',
	lftype => ['CHORD'],
	match2tag()
      };
      $chord_tag->{start} += $sequence_tag->{start};
      $chord_tag->{end} += $sequence_tag->{start};
      my $chord_dsi = {
	domain => 'music',
	type => 'chord',
	root => {
	  type => 'pitch',
	  'scale-degree' => $cardinal2int{$chord_tag->{lex}}
	}
      };
      $chord_tag->{'domain-specific-info'} = $chord_dsi;
      push @output_tags, $chord_tag;
      $chord_dsi = +{ %$chord_dsi }; # copy
      delete $chord_dsi->{domain};
      push @members, $chord_dsi;
    }
    $sequence_tag->{'domain-specific-info'} = {
      domain => 'music',
      type => 'progression',
      members => [@members]
    };
    push @output_tags, $sequence_tag;
  }
  return @output_tags;
}

push @TextTagger::taggers, {
  name => "music",
  tag_function => \&tag_music,
  output_types => [qw(sense)],
  input_types => ['number'],
  input_text => 1
};

1;
