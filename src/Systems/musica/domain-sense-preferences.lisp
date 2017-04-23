;;  the domain specific sense preferences


(setf om::*domain-sense-preferences* '(
				       (W::step ONT::whole-step)
				       (W::NOTE ONT::NOTE-PITCH)
				       (W::BAR ONT::BAR-MEASURE)
				       (W::MEASURE ONT::BAR-MEASURE)
				       ))
