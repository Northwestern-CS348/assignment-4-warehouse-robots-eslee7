(define (domain warehouse)
	(:requirements :typing)
	(:types robot pallette - bigobject
        	location shipment order saleitem)

  	(:predicates
    	(ships ?s - shipment ?o - order)
    	(orders ?o - order ?si - saleitem)
    	(unstarted ?s - shipment)
    	(started ?s - shipment)
    	(complete ?s - shipment)
    	(includes ?s - shipment ?si - saleitem)

    	(free ?r - robot)
    	(has ?r - robot ?p - pallette)

    	(packing-location ?l - location)
    	(packing-at ?s - shipment ?l - location)
    	(available ?l - location)
    	(connected ?l - location ?l - location)
    	(at ?bo - bigobject ?l - location)
    	(no-robot ?l - location)
    	(no-pallette ?l - location)

    	(contains ?p - pallette ?si - saleitem)
  )

   (:action startShipment
      :parameters (?s - shipment ?o - order ?l - location)
      :precondition (and (unstarted ?s) (not (complete ?s)) (ships ?s ?o) (available ?l) (packing-location ?l))
      :effect (and (started ?s) (packing-at ?s ?l) (not (unstarted ?s)) (not (available ?l)))
   )
   
   (:action robotMove
      :parameters (?source - location ?dest - location ?robot - robot)
      :precondition (and (connected ?source ?dest)
                         (at ?robot ?source)
                         (no-robot ?dest))
      :effect (and (not (at ?robot ?source))
                   (at ?robot ?dest)
                   (no-robot ?source)
                   (not (no-robot ?dest)))
   )
   
   (:action robotMoveWithPallette
      :parameters (?source - location ?dest - location ?robot - robot ?pallette - pallette)
      :precondition (and (or (free ?robot) (has ?robot ?pallette))
                         (connected ?source ?dest)
                         (at ?robot ?source)
                         (at ?pallette ?source)
                         (no-robot ?dest)
                         (no-pallette ?dest))
      :effect (and (has ?robot ?pallette) 
                   (not (at ?robot ?source)) (not (at ?pallette ?source))
                   (at ?pallette ?dest) (no-pallette ?source) (not (no-pallette ?dest))
                   (at ?robot ?dest) (no-robot ?source) (not (no-robot ?dest)))
   )
   
   (:action moveItemFromPalletteToShipment
      :parameters (?location - location ?shipment - shipment ?saleitem - saleitem ?pallette - pallette ?order - order)
      :precondition (and (ships ?shipment ?order) 
                         (not (complete ?shipment)) 
                         (orders ?order ?saleitem) 
                         (started ?shipment)
                         (contains ?pallette ?saleitem) 
                         (at ?pallette ?location) 
                         (packing-at ?shipment ?location) 
                         (not (includes ?shipment ?saleitem))
                    )
      :effect (and (not (contains ?pallette ?saleitem)) (includes ?shipment ?saleitem))
   )
   
   (:action completeShipment
      :parameters (?shipment - shipment ?order - order ?location - location)
      :precondition (and (packing-at ?shipment ?location)
                         (ships ?shipment ?order)
                         (started ?shipment)
                         (not (complete ?shipment))
                    )
      :effect (and (complete ?shipment)
                   (not (packing-at ?shipment ?location))
                   (available ?location))
   )
  
)
