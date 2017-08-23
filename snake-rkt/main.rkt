#lang racket

(require racket/gui racket/draw)

(struct point [x y])

(struct snake [body direction speed])

(define (new-snake)
  (snake (point 0 0) 'right 1.0))

(struct world [snake])

(define (new-world)
  (world (new-snake)))

(struct renderer [frame canvas])

(define (new-renderer width height)
  (let ([frame (new frame%
                    [label "Snake"]
                    [width width]
                    [height height]
                    [style '(no-resize-border)])])
    (let ([canvas (new canvas%
                       [parent frame])])
      (renderer frame canvas))))

(define (render renderer world)
  (let ([canvas (renderer-canvas renderer)]
        [frame (renderer-frame renderer)])
    (send frame show #t)))

(define rr (new-renderer 500 400))
(define w (new-world))

(render rr w)
