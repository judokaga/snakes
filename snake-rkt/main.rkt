#lang racket/gui

(struct world [height width snake apple] #:transparent)
(struct snake [body direction speed delta] #:transparent)
(struct point [x y] #:transparent)

(define (random-point x y)
  (point (random x) (random y)))

(define height 15)
(define width 10)
(define point-size 20)
(define w (world height width (snake (list (point 0 0)) 'right 0.1 0) (random-point width height)))

(define (paint-world psz)
  (lambda (canvas dc)
    (send dc set-pen "white" 0 'transparent)
    (paint-snake (world-snake w) "yellow" dc psz)
    (paint-point (world-apple w) "red" dc psz)))

(define (world-on-tick w)
  (let ([w (struct-copy world w [snake (snake-on-tick (world-snake w))])])
    (if (collide? (world-snake w) (world-apple w))
        (struct-copy world w [snake (grow-snake (world-snake w))] [apple (random-point (world-width w) (world-height w))])
        w)))

(define (world-on-char w ch)
  (let ([key-code (send ch get-key-code)])
    (case key-code
      ([left right up down] (struct-copy world w [snake (snake-change-dir (world-snake w) key-code)]))
      (else w))))

(define (snake-change-dir s dir)
  (let ([snk-dir (snake-direction s)]
        [opps-dir? (lambda (d1 d2) (case (list d1 d2) ([(left right) (right left) (up down) (down up)] #t) (else #f)))])
    (if (opps-dir? dir snk-dir)
        s
        (struct-copy snake s [direction dir]))))

(define (paint-snake s clr dc psz)
  (map (lambda (p) (paint-point p clr dc psz)) (snake-body s)))

(define (paint-point p clr dc psz)
  (send dc set-brush clr 'solid)
  (send dc draw-rectangle (* psz (point-x p)) (* psz (point-y p)) psz psz))

(define (move-point p dir)
  (let ([x (point-x p)] [y (point-y p)])
    (case dir
      ([left] (point (sub1 x) y))
      ([right] (point (add1 x) y))
      ([up] (point x (sub1 y)))
      ([down] (point x (add1 y))))))

(define (snake-on-tick snk)
  (let ([delta (+ (snake-delta snk) (snake-speed snk))])
    (if (>= delta 1)
        (let* ([old-body (snake-body snk)]
               [body (cons (move-point (car old-body) (snake-direction snk))
                           (take old-body (sub1 (length old-body))))])
          (struct-copy snake snk [body body] [delta (sub1 delta)]))
        (struct-copy snake snk [delta delta]))))

(define (grow-snake snk)
  (let* ([old-body (snake-body snk)]
         [old-head (car old-body)]
         [dir (snake-direction snk)])
    (struct-copy snake snk (body (cons (move-point old-head dir) old-body)))))

(define (collide? snk apl)
  (ormap (lambda (p) (equal? p apl)) (snake-body snk)))

(define (new-canvas hegiht width point-size)
  (define snake-canvas%
    (class canvas%
      (define/override (on-char ch)
        (set! w (world-on-char w ch)))
      (super-new)))
  (let ([frame (new frame% [label "Snake"]
                    [width (* width point-size)] [height (* height point-size)])])
    (send frame show #t)
    (new snake-canvas% [parent frame] [paint-callback (paint-world point-size)])))
(define canvas (new-canvas height width point-size))

(define timer (new timer%
                   [notify-callback (lambda ()
                                      (send canvas refresh)
                                      (set! w (world-on-tick w)))]
                   [interval 33]
                   [just-once? #f]))
