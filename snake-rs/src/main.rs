extern crate piston_window;

use piston_window::*;

struct World {
    width: u32,
    height: u32,
    snake: Snake,
    apple: Point,
}

struct Snake {
    body: Vec<Point>,
    speed: f64,
    direction: Direction,
    delta: f64,
}

struct Point(u32, u32);

enum Direction {
    Left,
    Right,
    Up,
    Down,
}

const RED: [f32; 4] = [1.0, 0.0, 0.0, 1.0];
const GREEN: [f32; 4] = [0.0, 1.0, 0.0, 1.0];

impl Point {
    fn random(x_max: u32, y_max: u32) -> Self {
        Point(0, 0)
    }

    fn draw(self: &Self, psize: f64) {
        let &Point(x, y) = self;
        let square = rectangle::square(x as f64 * psize, y as f64 * psize, psize);
    }
}

const POINT_SIZE: u32 = 20;
const WIDTH: u32 = 20;
const HEIGHT: u32 = 20;

fn main() {
    let mut window: PistonWindow = WindowSettings::new(
        "Snake",
        [WIDTH * POINT_SIZE, HEIGHT * POINT_SIZE],
    )
        .exit_on_esc(true)
        .build()
        .unwrap();

    let world = World {
        width: WIDTH,
        height: HEIGHT,
        snake: Snake {
            body: vec![Point(0, 0)],
            speed: 1.0,
            direction: Direction::Right,
            delta: 0.0,
        },
        apple: Point::random(WIDTH, HEIGHT),
    };

    while let Some(event) = window.next() {
        if let Some(ua) = event.update_args() {
            println!("dt is {}", ua.dt);
        }
    }
}
