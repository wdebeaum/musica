;;;;
;;;; W::hold
;;;;

(define-words :pos W::v :templ AGENT-THEME-XP-TEMPL
 :words (
   ((W::hold w::out)
    (wordfeats (W::morph (:forms (-vb) :past W::held)))
    (senses
     ((lf-parent ont::refuse)
      (templ agent-affected-xp-templ)
      (example "he held out the data")
      (meta-data :origin calo-ontology :entry-date 20060125 :change-date nil :comments caloy3)
      )
     )
    )
))

(define-words :pos W::v :templ AGENT-THEME-XP-TEMPL
 :words (
   ((W::hold w::back)
    (wordfeats (W::morph (:forms (-vb) :past W::held)))
    (senses
     ((lf-parent ont::refuse)
      (templ agent-affected-xp-templ)
      (example "he held back his tears")
      (meta-data :origin calo-ontology :entry-date 20060125 :change-date nil :comments caloy3)
      )
     )
    )
))

(define-words :pos W::v :templ AGENT-affected-XP-TEMPL
 :tags (:base500)
 :words (
  (W::hold
   (wordfeats (W::morph (:forms (-vb) :past W::held :nom w::hold)))
   (SENSES
    ((EXAMPLE "The truck held the cargo")
     (LF-PARENT ONT::CONTAINMENT)
     (SEM (F::Aspect F::stage-level) (F::Time-span F::extended))
     (TEMPL neutral-neutral-templ)
     )
    ((meta-data :origin trips :entry-date 20060414 :change-date nil :comments nil :vn ("hold-15.1-1"))
     (EXAMPLE "Hold the cup")
     (LF-PARENT ONT::BODY-MANIPULATION)
     (SEM (F::Cause F::agentive) (F::Aspect F::unbounded) (F::Time-span F::extended))
     )
    ((EXAMPLE "Hold the reservation")
     (meta-data :origin calo-ontology :entry-date 20051214 :change-date nil :comments nil)
     (LF-PARENT ONT::retain)
     (SEM (F::Cause F::agentive) (F::Aspect F::unbounded) (F::Time-span F::extended))
     )
    )
   )
))

(define-words :pos W::UttWord :boost-word t :templ NO-FEATURES-TEMPL
 :words (
  ((W::hold W::on)
   (SENSES
    ((LF (W::WAIT))
     (non-hierarchy-lf t)(SYNTAX (W::SA ONT::SA_DISCOURSE-MANAGE))
     )
    )
   )
))

(define-words :pos W::UttWord :boost-word t :templ NO-FEATURES-TEMPL
 :words (
  ((W::hold W::on W::a W::minute)
   (SENSES
    ((LF (W::WAIT))
     (non-hierarchy-lf t)(SYNTAX (W::SA ONT::SA_DISCOURSE-MANAGE))
     )
    )
   )
))

(define-words :pos W::UttWord :boost-word t :templ NO-FEATURES-TEMPL
 :words (
  ((W::hold W::on W::a W::second)
   (SENSES
    ((LF (W::WAIT))
     (non-hierarchy-lf t)(SYNTAX (W::SA ONT::SA_DISCOURSE-MANAGE))
     )
    )
   )
))

