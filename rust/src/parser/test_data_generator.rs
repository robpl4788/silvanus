use std::{thread::sleep_ms, time::{Duration, SystemTime, UNIX_EPOCH}};

use crate::engine::{self, engine::Engine};

use rand::RngExt;
use std::sync::{Arc, RwLock};


pub fn add_test_data(engine: &Arc<RwLock<Engine>>) {

    let engine: Arc<RwLock<Engine>> = engine.clone();
    {
        let mut e = engine.write().unwrap();
        e.set_name("Test".to_string());
    }


let labels = [
    "accel_x".to_string(),
    "accel_z".to_string(),
    "battery_voltage".to_string(),
    "accel_y".to_string(),
];
    loop {

        for label in &labels {

            let time: SystemTime = SystemTime::now();
            let since_the_epoch = time
                .duration_since(UNIX_EPOCH)
                .expect("time should go forward");
            {
                let mut rng: rand::prelude::ThreadRng = rand::rng();

                let mut e = engine.write().unwrap();
                e.add_data_point(&label.to_string(), rng.random(), since_the_epoch.as_secs_f64());
            }
            
            // println!("added new data");
            std::thread::sleep(Duration::from_millis(200));
        }

    }

}