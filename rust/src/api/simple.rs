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
    pub t: f64,
    pub v: f64,
}

pub fn get_test_data() -> Vec<Point> {
    vec![
        Point { t: 0.0, v: 1.0 },
        Point { t: 1.0, v: 3.0 },
        Point { t: 2.0, v: 2.0 },
        Point { t: 3.0, v: 5.0 },
        Point { t: 4.0, v: 3.0 },
    ]
}