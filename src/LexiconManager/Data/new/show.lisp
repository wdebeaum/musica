;;;;
;;;; W::SHOW
;;;;

(define-words :pos W::n :templ COUNT-PRED-TEMPL
 :tags (:base500)
 :words (
  (W::SHOW
   (SENSES
    ((meta-data :origin trips :entry-date 20060803 :change-date nil :comments nil)
     (LF-PARENT ONT::presentation)
     (preference .97)
     )
    )
   )
))

(define-words :pos W::v :templ AGENT-affected-XP-TEMPL
 :tags (:base500)
 :words (
  (W::SHOW
   (wordfeats (W::morph (:forms (-vb) :pastpart W::shown)))
   (SENSES
     ((LF-PARENT ONT::show)
     (example "show him how to buy a book")
     ;(TEMPL agent-affected-iobj-theme-templ)
     (TEMPL AGENT-ADDRESSEE-THEME-TEMPL (xp (% NP)))
     )
    ((LF-PARENT ONT::show)
     (example "show him (the house)")
     ;(TEMPL AGENT-AFFECTED-IOBJ-NEUTRAL-TEMPL)
     (TEMPL AGENT-ADDRESSEE-NEUTRAL-OPTIONAL-TEMPL)
     )
    ((LF-PARENT ONT::show)
     (example "show the house (to him)")
     ;(TEMPL AGENT-NEUTRAL-TOAFFECTED-TEMPL)
     (TEMPL AGENT-neutral-TO-ADDRESSEE-optional-TEMPL)
     )
    ((LF-PARENT ONT::confirm)
     (example "this diagram shows that it works")
     (TEMPL agent-theme-xp-templ (xp (% w::cp (w::ctype w::s-finite))))
    )
    ((LF-PARENT ONT::confirm)
     (example "We show in this paper that it works")
     (preference .98)
     (TEMPL agent-located-theme-xp-templ (xp (% w::cp (w::ctype w::s-finite))))
     )
    
    ((LF-PARENT ONT::confirm)
     (example "I showed it to be broken")
     (TEMPL agent-effect-affected-objcontrol-templ)
    )
    ((LF-PARENT ONT::correlation)
     (example "these results show that the gene activates the protein")
     (TEMPL neutral-formal-as-comp-templ (xp (% W::cp (W::ctype W::s-finite))))
    )

    )
   )
))

(define-words :pos W::v :templ AGENT-affected-XP-TEMPL
 :words (
  ((W::show W::up)
   (wordfeats (W::morph (:forms (-vb) :pastpart W::shown)))
   (SENSES 
    ((meta-data :origin trips :entry-date 20060414 :change-date nil :comments nil :vn ("appear-48.1.1"))
     (LF-PARENT ONT::appear)
     (TEMPL affected-result-xp-TEMPL )
     (preference .98)
     )
       )
   )
))

