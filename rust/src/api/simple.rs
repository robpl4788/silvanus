use std::collections::btree_map::Range;
use rand::{self, RngExt};

use crate::frb_generated;


#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

pub struct Point {
    pub x: f64,
    pub y: f64,
}

pub fn get_test_data(sink: frb_generated::StreamSink<Vec<Point>>){
    let mut rng = rand::rng();

    loop {
        let mut out: Vec<Point> = vec![];

        for x in 1..5 {
            out.push(Point{x: x as f64, y: rng.random()});
        }

        sink.add(out);

        std::thread::sleep(std::time::Duration::from_millis(500));
    }
    


}
