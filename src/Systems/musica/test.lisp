
;;;;
;;;; File: test.lisp
;;;; Creator: George Ferguson
;;;; Created: Tue Jun 19 14:35:09 2012
;;;; Time-stamp: <Tue Nov  1 10:21:06 CDT 2016 lgalescu>
;;;;

(unless (find-package :trips)
  (load (make-pathname :directory '(:relative :up :up "config" "lisp")
		       :name "trips")))
;;;
;;; Load our TRIPS system
;;;
(load #!TRIPS"src;Systems;musica;system")

;;;
;;; Load core testing code
;;;
(load #!TRIPS"src;Systems;core;test")

;;;
;;; In USER for convenience of testing
;;;
(in-package :common-lisp-user)

(setf *texttagger-split-mode* nil)

;;; Sample dialogues
;;;
(defvar *sample-dialogues*
  '(
    ;;; from CwC_MUSICA_AnnotatedDialogs_20161118.docx
    (dialogue-0 .  
     ("Give me a two five one (ii-V-I) progression."
      ;S: How about this.
      "I don’t like the G-chord.  Add a seventh."
      ;S: I have added an F.
      "No, put it on the bottom."
      ;S: Ok, I moved the F an octave down.
      ))
    (dialogue-1 .
     ;; Description: Basic functionality for generating sequences of notes, generating rhythmic variants or alterations, and a low cost operation on the data like transposition (Major key to minor key)
     ("give me a 5 note melody in F" ;	[note generation]
      ;S: (F, QN)(G, QN)(A,QN)(F,QN)(C,QN)
      "now vary that rhythm" ;		[rhythmic generation with previous note constraint]
      ;S: (F,EN)(G,QN)(A,EN)(F,WN)(C,EN)
      "put it in a minor key" ;		[transposition]
      ;S: (F,EN)(G,QN)(Ab,EN)(F,WN)(C,EN)
      "extend it" ;			[note generation and append to end]
      ;S: (F,EN)(G,QN)(Ab,EN)(F,WN)(C,EN)(Bb,QN)(Ab,EN)(Ab,EN)(F,WN)(Bb,QN)
      ))
    (dialogue-2 .
     ;; Description: Calling sequences from a database and then performing edit functions on notes in the sequence.
     ("Give me the first five notes of Giant Steps in concert pitch" ;	[database call]
      ;S: (F#,HN)(D,HN)(B,HN)(G,HN)(Bb,WN)
      "Transpose notes 4 and 5 up a 3rd" ;				[transposition]
      ;S: up a minor 3rd or Major 3rd?
      "Up a Major 3rd" ;						[clarification]
      ;S: (F#,HN)(D,HN)(B,HN)(B,HN)(D,WN)			[edit sequence]
      "I don’t like that." ; 						[Undo]
      ;S: (F#,HN)(D,HN)(B,HN)(G,HN)(Bb,WN)
      "Transpose the 3rd note up a half step" ;			[edit sequence]
      ;S: (F#,HN)(D,HN)(C,HN)(G,HN)(Bb,WN)
      "Increase it one more half step" ; 				[edit]
      ;[Here, we should get “increase” and  “it” for free - refers to the 3rd note]
      ;S: (F#,HN)(D,HN)(C#,HN)(G,HN)(Bb,WN)
      "Now, lower the last note a half-step" ;			[edit]
      ;S:  (F#,HN)(D,HN)(C#,HN)(G,HN)(A,WN)
      ))
    (dialogue-3 .
     ;; Description: Chord Sequence Generation and editing.
     ;; **NOTE: Using curly braces { } to indicate chords being played, not single notes
     ("Generate a chord progression in C Major" ;		[chord sequence generation]
      ;[assumptions: what style, alphabet, chord progression type, harmonic rhythm]
      ;S: {(CM,HN) (Amin7,HN) (Dmin7,HN) (G7,HN) (Emin7,HN) (Amin7,HN) (Dmin7,HN) (G7,HN) (CM,HN)}
      "Change the three to a Dominant Seventh chord." ;		[edit one chord in sequence]
      ;S: {(CM,HN) (Amin7,HN) (Dmin7,HN) (G7,HN) (E7,HN) (Amin7,HN) (Dmin7,HN) (G7,HN) (CM,HN)}
      "Now change the second chord to a Dominant Seventh chord." ;	[edit chord]
      ;S: {(CM,HN) (A7,HN) (Dmin7,HN) (G7,HN) (E7,HN) (Amin7,HN) (Dmin7,HN) (G7,HN) (CM,HN)}
      "Change the rhythm to quarter notes." ;			[edit chord length]
      ;S: {(CM,QN) (A7, QN) (Dmin7, QN) (G7, QN) (E7, QN) (Amin7, QN) (Dmin7, QN) (G7, QN) (CM, QN)}
      ))
    (dialogue-4 .
     ;; Description: Modeling Tonal Harmony, Standard Harmonic Progressions
     ("In G Major, play a two-five-one." ;			[Mental Model of Tonal Harmony]
      ;S: What is the chord rhythm?
      "Half note, half note, whole note." ;			[Adding rhythm constraint]
      ;S: {(Am7,HN)(D7,HN)(GM,WN)}
      "Now add a two-five-one of the four chord. Same rhythm." ;	
      ;[Append, Model of Tonal Harmony enables the parse]
      ;S: {(Am7, HN)(D7,HN)(GM,WN)(Dm7,HN)(G7,HN)(CM,WN)}
      ))
    (dialogue-5 .
     ;; Description: Bebop Grammar, generating statements over this grammar with chord progression as constraint.
     ("Play the chord changes from dialogue 4." ;			[database request]
      ;S: {(Am7, HN)(D7,HN)(GM,WN)(Dm7,HN)(G7,HN)(CM,WN)}
      "Generate a bebop melody over that progression." ;		
      ;[generate melodic sequence over grammar, chord progression functions as constraint on production]
      ;S:(A,EN)(B,EN)(C,EN)(D,EN)(E,EN)(C,EN)(B,EN)(A,EN)(D,EN)(C,EN)(B,EN)(A,EN)(G,HN)(G,EN)(Gb,EN)(F,EN)(E,EN)(D,EN)(C,EN)(B,EN)(A,EN)(G,WN)
      "Transpose the first note of measure three up an octave." ;		[edit note]
      ;S: (A,EN)(B,EN)(C,EN)(D,EN)(E,EN)(C,EN)(B,EN)(A,EN)(D,EN)(C,EN)(B,EN)(A,EN)(G,HN)(G,EN)(Gb,EN)(F,EN)(E,EN)(D,EN)(C,EN)(B,EN)(A,EN)(G,WN)
      ))
    (dialogue-6 .
     ;; Description: Generate a statement over the bebop grammar given a longer chord progression as a constraint, chord progressions taken from standard jazz repertoire stored and pulled from database
     ("Play the first four measures of Blues for Alice." ;		[database request]
      ;S: {(CM,HN)(FM7,HN)(Bm7-5,HN)(E7b9,HN)(Am7,HN)(D7,HN)(Gm7,HN)(C7,HN)}
      "Add the next chord in that progression." ;			[database request, append ]
      ;S: [(CM,HN)(FM7,HN)(Bm7-5,HN)(E7b9,HN)(Am7,HN)(D7,HN)(Gm7,HN)(C7,HN)(F7,WN)]
      "Now play a melody over those changes." ;			[generate melodic sequence]
      ;S: (C,QN)(G,EN)(E,EN)(B,QN)(G,EN)(E,EN)(A,EN)(B,EN)(F#,EN)(A,EN)(G#,EN)(F,EN)(D,EN)(D#,EN)(E,QN)(C,EN)(A,EN)(D,EN)(Db,EN)(C,EN)(B,EN)(Bb,3EN)(D,3EN)(F,3EN)(A,EN)(G#,EN)(R,EN)(C,EN)(C,3EN)(D,3EN)(C,3EN)(G,QN)(F,3EN)(C,3EN)(A,3EN)(Eb,EN)(F,EN)
      ))
    (dialogue-7 .
     ;; Description: Edit longer melodic sequences, generative production of longer sequences as part of an interactive editing process.
     ("Play the chords and melody from dialogue 6" ;		[database request]
      ;S: A: (C,QN)(G,EN)(E,EN)(B,QN)(G,EN)(E,EN)(A,EN)(B,EN)(F#,EN)(A,EN)(G#,EN)(F,EN)(D,EN)(D#,EN)(E,QN)(C,EN)(A,EN)(D,EN)(Db,EN)(C,EN)(B,EN)(Bb,3EN)(D,3EN)(F,3EN)(A,EN)(G#,EN)(R,EN)(C,EN)(C,3EN)(D,3EN)(C,3EN)(G,QN)(F,3EN)(C,3EN)(A,3EN)(Eb,EN)(F,EN)
      "That’s Charlie Parker’s Melody. Generate an original melody starting in measure three."
      ;[parser throws out first sentence as non-actionable comment]
      ;[edit sub-sequence, generate melodic sequence, append]
      ;S: (C,QN)(G,EN)(E,EN)(B,QN)(G,EN)(E,EN)(A,EN)(B,EN)(F#,EN)(A,EN)(G#,EN)(F,EN)(D,EN)(D#,EN)(E,QN)(R,QN)(D,EN)(F,EN)(E,EN)(D,EN)(C,EN)(B,EN)(Bb,EN)(A,EN)(G,EN)(A,EN)(Bb,EN)(C,EN)(A,QN)(C,EN)(Eb,EN)(R,QN)
      ))
    (dialogue-8 .
     ;; Description: Pulling and modeling chord progressions for entire pieces in database, generating melodies over longer chord progressions (sequences)
     ("Pull up the chord changes for Anthropology." ;		[database request]
      ;S: {(Bb,HN)(Gmin7,HN)(Cmin7,HN)(F7,HN) (Bb,HN)(G7,HN)(Cmin7,HN)(F7,HN)(Bb7,HN)(Bb7/D,HN)(Eb7,HN)(Edim7,HN)(Dmin7/F,HN)(G7,HN)(Cmin7,HN)(F7,HN)(Bb,HN)(Gmin7,HN)(Cmin7,HN)(F7,HN) (Bb,HN)(G7,HN)(Cmin7,HN)(F7,HN)(Bb7,HN)(Bb7/D,HN)(Eb7,HN)(Edim7,HN)(Dmin7/F,HN)(G7,HN)(Cmin7,HN)(F7,HN)(D7,WN)(D7,WN)(G7,WN)(G7,WN)(C7,WN)(C7,WN)(F7,WN)(F7,WN)(Bb,HN)(Gmin7,HN)(Cmin7,HN)(F7,HN) (Bb,HN)(G7,HN)(Cmin7,HN)(F7,HN)(Bb7,HN)(Bb7/D,HN)(Eb7,HN)(Edim7,HN)(Dmin7/F,HN)(G7,HN)(Cmin7,HN)(F7,HN)
      "H: Now generate a contrafact over those changes."
      ;[riff over that progression; generate new things based on existing ideas]
      ;[generate new melody given long chord sequence as constraint]
      ;S:(Bb,EN)(A,EN)(C,EN)(Bb,EN)(A,EN)(G,EN)(F,EN)(Eb,EN)(D,QN)(C,EN)(Eb,EN)(G,EN)(Bb,EN)(A,EN)(G,EN)(F,EN)(Eb,EN)(D,EN)(C,EN)(B,EN)(D,EN)(F,EN)(Ab,EN)(G,EN)(F,EN)(Eb,EN)(D,EN)(C,QN)(F,EN)(Eb,EN)(D,HN)(Bb,EN)(A,EN)(Ab,EN)(Bb,EN)(G,EN)(F,EN)(Eb,EN)(G,EN)(Bb,EN)(Dd,EN)(C,EN)(Bb,EN)(D,HN)(C,EN)(Bb,EN)(A,EN)(G,EN)(F,EN)(E,EN)(Eb,EN)(F,EN)(D,EN)(C,EN)(R,QN)(Bb,EN)(A,EN)(C,EN)(Bb,EN)(A,EN)(G,EN)(F,EN)(Eb,EN)(D,QN)(C,EN)(Eb,EN)(G,EN)(Bb,EN)(A,EN)(G,EN)(F,EN)(Eb,EN)(D,EN)(C,EN)(B,EN)(D,EN)(F,EN)(Ab,EN)(G,EN)(F,EN)(Eb,EN)(D,EN)(C,QN)(F,EN)(Eb,EN)(D,HN)(Bb,EN)(A,EN)(Ab,EN)(Bb,EN)(G,EN)(F,EN)(Eb,EN)(G,EN)(Bb,EN)(Dd,EN)(C,EN)(Bb,EN)(D,HN)(C,EN)(Bb,EN)(A,EN)(G,EN)(F,EN)(E,EN)(Eb,EN)(F,EN)(D,EN)(C,EN)(R,QN)(R,HN)(D,EN)(Db,EN)(C,EN)(B,EN)(A,EN)(G,EN)(F#,EN)(E,EN)(D,HN)(R,HN)(G,EN)(Gb,EN)(F,EN)(E,EN)(D,EN)(C,EN)(B,EN)(A,EN)(G,HN)(R,HN)(C,EN)(B,EN)(Bb,EN)(A,EN)(G,EN)(F,EN)(E,EN)(D,EN)(C,HN)(R,HN)(F,EN)(E,EN)(Eb,EN)(D,EN)(C,EN)(Bb,EN)(A,EN)(G,EN)(F,HN)(Bb,EN)(A,EN)(C,EN)(Bb,EN)(A,EN)(G,EN)(F,EN)(Eb,EN)(D,QN)(C,EN)(Eb,EN)(G,EN)(Bb,EN)(A,EN)(G,EN)(F,EN)(Eb,EN)(D,EN)(C,EN)(B,EN)(D,EN)(F,EN)(Ab,EN)(G,EN)(F,EN)(Eb,EN)(D,EN)(C,QN)(F,EN)(Eb,EN)(D,HN)(Bb,EN)(A,EN)(Ab,EN)(Bb,EN)(G,EN)(F,EN)(Eb,EN)(G,EN)(Bb,EN)(Dd,EN)(C,EN)(Bb,EN)(D,HN)(C,EN)(Bb,EN)(A,EN)(G,EN)(F,EN)(G,EN)(A,EN)(Bb,EN)(R,HN)
      ))
    )
)

;; see test-utterance-demo sample dialogue below
(defun arbitrary-function-to-be-called ()
  (format t "the test-utterance-demo sample dialogue called this arbitrary function~%")
  ;; Note: use COMM:send and not dfc:send-msg, since we're not in the context
  ;; of a defcomponent TRIPS module.
  (COMM:send 'test '(tell :content (message from arbitrary function)))
  ;; For the same reason, we don't have dfc:send-and-wait. Instead, loop over
  ;; COMM:recv and discard messages until you get the reply.
  (COMM:send 'test '(request
		      :receiver lexiconmanager
		      :content (get-lf w::end)
		      :reply-with test123))
  (loop for incoming = (COMM:recv 'test)
  	while incoming
	until (eq 'test123 (util:find-arg-in-act incoming :in-reply-to))
	finally (format t "(get-lf w::end) returned ~s~%"
			(util:find-arg-in-act incoming :content))
	)
  )

;; demo extra capabilities of test-utterance function
;; Note: we have to push this separately because including the #'function
;; doesn't work in a quoted context like the *sample-dialogues* list above.
;; Everything else does.
(push 
  `(test-utterance-demo . (
      "Send a string to be parsed."
      (tell :content (send a single arbitrary message))
      ( (tell :content (send arbitrary list of))
        (tell :content (kqml messages))
	)
      ,#'arbitrary-function-to-be-called
      ))
  *sample-dialogues*)

;; Default sample dialogue for this domain
(setf *test-dialog*
  (cdr (assoc 'new-sift-demo *sample-dialogues*)))

;(setf *test-dialog*
;  (cdr (assoc 0.1 *sample-dialogues* :test #'eql)))

(defun ptest (key)
  "Make the sample dialogue given by KEY the global *TEST-DIALOG*, then
call TEST. Reports available KEYs on error."
  (let ((dialogue (cdr (assoc key *sample-dialogues* :test #'eql))))
    (cond
     ((not dialogue)
      (format t "~&ptest: unknown sample dialogue: ~S~%" key)
      (format t "~&ptest: possible values: ~S~%" (mapcar #'car *sample-dialogues*)))
     (t
      (setf *test-dialog* dialogue)
      (test)))))


(defun enable-graphviz-display ()
  (COMM::send 'test '(request :receiver graphviz :content (enable-display))))

(defun disable-graphviz-display ()
  (COMM::send 'test '(request :receiver graphviz :content (disable-display))))

;; This function probably belongs in core/test.lisp
(defun test-all ()
  "Invoke TEST on all utterances of *TEST-DIALOG* in order.
This function does not pause between utterance, wait for results to be
finished, or any other smart thing. It simply pumps the messages in using
TEST."
  (loop for x in *test-dialog*
     do (test x)
       ;; add a wait for procesing
       ;(loop for i from 1 to 2
	;  do ;(format t ".")
	 ;   (sleep 1))
       ))

;; Ditto
(defun test-all-of (key)
  "Set *TEST-DIALOG* to the dialog identified by KEY on *SAMPLE-DIALOGUES*,
then invoke TEST-ALL to test all its utterances."
  (setf *test-dialog* (cdr (assoc key *sample-dialogues*)))
  (test-all))
