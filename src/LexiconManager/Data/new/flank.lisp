;;;;
;;;; W::FLANK
;;;;

(define-words :pos W::n
 :words (
  (W::FLANK
  (senses
	   ((LF-PARENT ONT::BEEF)
	    (TEMPL MASS-PRED-TEMPL)
	    (syntax (W::morph (:forms (-none))))
	    )
	   )
)
))

(define-words :pos W::v :templ agent-theme-xp-templ
 :words (
  (W::flank
   (SENSES
    ((meta-data :origin "verbnet-2.0" :entry-date 20060315 :change-date nil :comments nil :vn ("contiguous_location-47.8") :wn ("flank%2:42:00"))
     (LF-PARENT ONT::surround)
     (TEMPL neutral-neutral-xp-templ) ; like cover,surround
     )
    )
   )
))

