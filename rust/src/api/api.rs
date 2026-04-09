use flutter_rust_bridge::frb;

use crate::api::types::{TimeStampedValue};
use crate::parser::csv_parser::parse_csv;

use crate::engine::engine::Engine;

use crate::frb_generated;
use crate::parser::test_data_generator::{add_test_data};

use std::thread;
use std::sync::{Arc, RwLock};
use std::time::Duration;
use tokio::time::timeout;


// Api for flutter to hold it's copy of the engine
#[flutter_rust_bridge::frb(opaque)]
type Api = Arc<RwLock<Engine>>;

// Get an engine with the relevant csv loaded in to it
#[frb]
pub fn load_csv(csv_path: String) -> Api {    
    Arc::new(RwLock::new(parse_csv(csv_path)))
}

// get an engine with nothing loaded in to it
#[frb]
pub fn load_none() -> Api {    
    let mut engine = Engine::new();
    engine.set_name("None".to_string());
    
    Arc::new(RwLock::new(engine))
}


// Get an engine generating random test data
#[frb]
pub fn load_test() -> Api {
    let engine = Arc::new(RwLock::new(Engine::new()));

    let engine_clone = engine.clone();

    // Start a thread to add the test data in
    thread::spawn(move || {
        add_test_data(&engine_clone);
    });

    engine
}

// Get a stream with the currently available keys. The stream tells flutter every time rust changes the available keys
#[frb]
pub async fn get_available_keys (engine: &Api, available_keys_sink: frb_generated::StreamSink<Vec<String>>) {
    let engine = engine.clone();
    
    // Get the reciever for updates to keys. Recieves nothing, the act of recieving tells that new keys are available.
    let mut update_reciever = engine.read().unwrap().get_key_updates_reciever();

    // Add the currently available keys
    available_keys_sink.add(engine.read().unwrap().get_keys());

    // While the engine is still in use
    while engine.read().unwrap().in_use(){

        // If doesn't time out update the sunk keys, otherwise stop to check if the engine this is referencing is still in use
        if let Ok(_) =  timeout(Duration::from_secs(1), update_reciever.changed()).await {
            available_keys_sink.add(engine.read().unwrap().get_keys());                
        };
        

    }
}

// Get a stream with the currently available data in a specific series. The stream tells flutter every time rust changes the available data
#[frb]
pub async fn get_timestamped_series(engine: &Api, timestamped_series_sink: frb_generated::StreamSink<Vec<TimeStampedValue>>, key: String){
    let engine = engine.clone();
    
    // Recieves an update every time any data changed with the key of the series that changed
    let mut update_reciever = engine.read().unwrap().get_data_updates_reciever();

    // Send the currently available data
    timestamped_series_sink.add(engine.read().unwrap().get_series(&key));

    // While the engine is still in use
    while engine.read().unwrap().in_use(){
        // If doesn't time out update the sunk data, otherwise stop to check if the engine this is referencing is still in use
        if let Ok(Ok(to_update)) =  timeout(Duration::from_secs(1), update_reciever.recv()).await {
            if (to_update == key) {
                timestamped_series_sink.add(engine.read().unwrap().get_series(&key));
            }
        }

    }
}

// Not really used but left in in case use becomes desirable
#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

