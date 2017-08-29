extern crate piston_window;
extern crate rand;

use piston_window::*;
use rand::Rng;

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

#[derive(Clone, Copy, Debug, PartialEq)]
struct Point(u32, u32);

#[derive(PartialEq)]
enum Direction {
    Left,
    Right,
    Up,
    Down,
}

const RED: [f32; 4] = [1.0, 0.0, 0.0, 1.0];
const GREEN: [f32; 4] = [0.0, 1.0, 0.0, 1.0];
const WHITE: [f32; 4] = [1.0, 1.0, 1.0, 1.0];

impl World {
    fn draw(self: &Self, psize: u32, c: context::Context, g: &mut G2d) {
        self.snake.draw(GREEN, psize, c, g);
        self.apple.draw(RED, psize, c, g);
    }

    fn on_tick(self: &mut Self, delta_time: f64) {
        if self.snake.try_eat(&self.apple) {
            self.apple = Point::random(self.width, self.height);
        }
        self.snake.on_tick(delta_time);
    }

    fn on_key(self: &mut Self, key: Key) {
        self.snake.on_key(key);
    }
}

impl Snake {
    fn draw(self: &Self, color: types::Color, psize: u32, c: context::Context, g: &mut G2d) {
        for p in &self.body {
            p.draw(color, psize, c, g);
        }
    }

    fn on_tick(self: &mut Self, delta_time: f64) {
        self.delta += self.speed * delta_time;

        if self.delta > 1f64 {
            self.delta -= 1f64;
            self.body = move_body(&mut self.body, &self.direction);
        }
    }

    fn on_key(self: &mut Self, key: Key) {
        match key {
            Key::Up => {
                if self.direction != Direction::Down {
                    self.direction = Direction::Up;
                }
            }
            Key::Down => {
                if self.direction != Direction::Up {
                    self.direction = Direction::Down;
                }
            }
            Key::Left => {
                if self.direction != Direction::Right {
                    self.direction = Direction::Left;
                }
            }
            Key::Right => {
                if self.direction != Direction::Left {
                    self.direction = Direction::Right;
                }
            }
            _ => {}
        }
    }

    fn try_eat(self: &mut Self, apple: &Point) -> bool {
        if self.body[0] == *apple {
            self.body = grow_body(&mut self.body, &self.direction);
            true
        } else {
            false
        }
    }
}

fn move_body(mut body: &mut Vec<Point>, direction: &Direction) -> Vec<Point> {
    let head = body[0];
    let new_head = head.mv(direction);
    let mut new_body = vec![new_head];
    let len = body.len() - 1;
    body.split_off(len);
    new_body.append(&mut body);
    new_body
}

fn grow_body(mut body: &mut Vec<Point>, direction: &Direction) -> Vec<Point> {
    let head = body[0];
    let new_head = head.mv(direction);
    let mut new_body = vec![new_head];
    new_body.append(&mut body);
    new_body
}

impl Point {
    fn random(x_max: u32, y_max: u32) -> Self {
        let mut rng = rand::thread_rng();
        let x = rng.gen_range(0, x_max);
        let y = rng.gen_range(0, y_max);
        Point(x, y)
    }

    fn draw(self: &Self, color: types::Color, psize: u32, c: context::Context, g: &mut G2d) {
        let &Point(x, y) = self;
        let square = rectangle::square((x * psize) as f64, (y * psize) as f64, psize as f64);
        rectangle(color, square, c.transform, g);
    }

    fn mv(self: &Self, direction: &Direction) -> Self {
        let &Point(x, y) = self;
        match direction {
            &Direction::Left => Point(x - 1, y),
            &Direction::Right => Point(x + 1, y),
            &Direction::Up => Point(x, y - 1),
            &Direction::Down => Point(x, y + 1),
        }
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

    let mut world = World {
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
        window.draw_2d(
            &event,
            |c, g| {
                clear(WHITE, g);
                world.draw(POINT_SIZE, c, g);
            }
        );
        
        if let Some(ua) = event.update_args() {
            world.on_tick(ua.dt);
        }

        match event {
            Event::Input(input) => {
                match input {
                    Input::Button(button_args) => {
                        if button_args.state == ButtonState::Press {
                            match button_args.button {
                                Button::Keyboard(key) => {
                                    world.on_key(key);
                                }
                                _ => {}
                            }
                        }
                    }
                    _ => {}
                }
            }
            _ => {}
        };
    }
}
