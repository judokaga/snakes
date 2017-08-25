#lang racket

(require racket/gui racket/draw)

(struct point [x y] #:transparent)

(struct snake [body direction speed] #:transparent)

(define (new-snake)
  (snake (list (point 0 0)) 'right 1.0))

(define (move-point pnt direction speed)
  (let ([x (point-x pnt)] [y (point-y pnt)])
    (case direction
      ([right] (point (add1 x) y))
      ([left] (point (sub1 x) y))
      ([up] (point x (sub1 y)))
      ([down] (point x (add1 y))))))

(define (move-body body direction speed)
  (map (lambda (point) (move-point point direction speed)) body))

(define (snake-on-tick snk)
  (let ([old-body (snake-body snk)]
        [direction (snake-direction snk)]
        [speed (snake-speed snk)])
    (let ([new-body (move-body old-body direction speed)])
      (snake new-body direction speed))))

(define (draw-snake snk dc)
  (let ([body (snake-body snk)])
    (map (lambda (p) (draw-point p dc)) body)))

(define (draw-point p dc)
  (send dc set-brush "green" 'solid)
  (send dc set-pen "green" 0 'transparent)
  (send dc draw-rectangle
        (point-x p) (point-y p) 20 20))

(define (draw-world w dc)
  (let ([snk (world-snake w)])
    (draw-snake snk dc)))

(define (world-on-tick w)
  (world (snake-on-tick (world-snake w))))

(struct world [snake] #:transparent)

(define (new-world)
  (world (new-snake)))

(struct renderer [frame canvas])

(define paint-callback
  (lambda (canvas dc)
    (send dc set-brush "green" 'solid)
    (send dc set-pen "green" 0 'transparent)
    (draw-world w dc)))

(define (new-renderer width height)
  (let ([frame (new frame%
                    [label "Snake"]
                    [width width]
                    [height height]
                    [style '(no-resize-border)])])
    (let ([canvas (new canvas%
                       [parent frame]
                       [paint-callback paint-callback])])
      (send frame show #t)
      (renderer frame canvas))))

(define (render renderer world)
  (let ([canvas (renderer-canvas renderer)])
    (send canvas refresh)))

(define rr (new-renderer 500 400))
(define w (new-world))

(define (on-tick)
  (set! w (world-on-tick w))
  (render rr w))

(define timer (new timer%
                   [notify-callback (lambda () (on-tick))]
                   [interval 33]
                   [just-once? #f]))
