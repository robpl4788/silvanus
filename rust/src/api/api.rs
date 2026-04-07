use flutter_rust_bridge::frb;

use crate::api::types::{TimeStampedValue};
use crate::parser::csv_parser::parse_csv;

use crate::engine::engine::{self, Engine};

use crate::frb_generated;
use crate::parser::test_data_generator::{add_test_data};

use std::thread;
use std::sync::{Arc, RwLock};
use std::time::Duration;
use tokio::time::timeout;


#[flutter_rust_bridge::frb(opaque)]
type Api = Arc<RwLock<Engine>>;


#[frb]
pub fn load_csv(csv_path: String) -> Api {
    println!("Loading CSV");
    
    Arc::new(RwLock::new(parse_csv(csv_path)))
}

#[frb]
pub fn load_none() -> Api {
    println!("Loading None");
    
    let mut engine = Engine::new();
    engine.set_name("None".to_string());
    
    Arc::new(RwLock::new(engine))
}

#[frb]
pub fn load_test() -> Api {
    println!("Loading Test");

    let engine = Arc::new(RwLock::new(Engine::new()));

    let engine_clone = engine.clone();
    thread::spawn(move || {
        add_test_data(&engine_clone);
    });

    engine
}

#[frb]
pub async fn get_available_keys (engine: &Api, available_keys_sink: frb_generated::StreamSink<Vec<String>>) {
    let engine = engine.clone();
    let mut update_reciever = engine.read().unwrap().get_key_updates_reciever();
    available_keys_sink.add(engine.read().unwrap().get_keys());
    while engine.read().unwrap().in_use(){

        // If doesn't time out update the sunk keys, otherwise stop to check if the engine this is referencing is still in use
        if let Ok(_) =  timeout(Duration::from_secs(1), update_reciever.changed()).await {
            available_keys_sink.add(engine.read().unwrap().get_keys());                
        };
        

    }
}

#[frb]
pub async fn get_timestamped_series(engine: &Api, timestamped_series_sink: frb_generated::StreamSink<Vec<TimeStampedValue>>, key: String){
    let engine = engine.clone();
    
    let mut update_reciever = engine.read().unwrap().get_data_updates_reciever();
    timestamped_series_sink.add(engine.read().unwrap().get_series(&key));
    while engine.read().unwrap().in_use(){
        // If doesn't time out update the sunk data, otherwise stop to check if the engine this is referencing is still in use
        if let Ok(Ok(to_update)) =  timeout(Duration::from_secs(1), update_reciever.recv()).await {
            if (to_update == key) {
                timestamped_series_sink.add(engine.read().unwrap().get_series(&key));
            }
        }

    }
}


#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

