use std::{time::{Duration, SystemTime}};

use crate::engine::engine::Engine;

use rand::RngExt;
use std::sync::{Arc, RwLock};



// Generate random test data forever and add it to the engine
pub fn add_test_data(engine: &Arc<RwLock<Engine>>) {
    // Get it's own copy of the engine pointer
    let engine: Arc<RwLock<Engine>> = engine.clone();

    // Set the engines name
    {
        let mut e = engine.write().unwrap();
        e.set_name("Test".to_string());
    }


    // Labels that the test data will be generated with
    let labels = [
        "accel_x".to_string(),
        "accel_z".to_string(),
        "battery_voltage".to_string(),
        "accel_y".to_string(),
    ];

    // Time the test data started getting generated so that data is relative to start of generation
    let start_time: SystemTime = SystemTime::now();

    loop {

        for label in &labels {
            // Get the current time since data generation started
            let time: SystemTime = SystemTime::now();
            let since_starting = time
                .duration_since(start_time)
                .expect("time should go forward");
            
            // Write some random data to the engine at the current time
            {
                let mut rng: rand::prelude::ThreadRng = rand::rng();

                let mut e = engine.write().unwrap();
                e.add_data_point(&label.to_string(), rng.random(), since_starting.as_secs_f64());
            }
            
            // println!("added new data");
            // Sleep for a while
            std::thread::sleep(Duration::from_millis(200));
        }

    }

}