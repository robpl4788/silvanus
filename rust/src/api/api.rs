use flutter_rust_bridge::frb;

use crate::api::types::{TimeStampedValue};
use crate::parser::csv_parser::parse_csv;

use crate::engine::engine::{self, Engine};

use crate::frb_generated;
use crate::parser::test_data_generator::{add_test_data};

use std::thread;
use std::sync::{Arc, RwLock};


#[flutter_rust_bridge::frb(opaque)]
pub struct Api {
    engine: Arc<RwLock<Engine>>
}

impl Api {
    #[frb]
    pub fn get_api() -> Api {
        Api {
            engine: Arc::new(RwLock::new(Engine::new())),
        }
    }

    #[frb]
    pub fn load_csv(&mut self, csv_path: String) {
        let mut old_engine = self.engine.write().unwrap();
        old_engine.set_not_in_use();
        drop(old_engine);
        
        self.engine = Arc::new(RwLock::new(parse_csv(csv_path)));
    }

    #[frb]
    pub fn load_test(&mut self) {
        let mut old_engine = self.engine.write().unwrap();
        old_engine.set_not_in_use();
        drop(old_engine);
        

        self.engine = Arc::new(RwLock::new(Engine::new()));

        let engine = self.engine.clone();
        thread::spawn(move || {
            add_test_data(&engine);
        });
    }

    #[frb]
    pub async fn get_available_keys (&self, available_keys_sink: frb_generated::StreamSink<Vec<String>>) {
        let engine = self.engine.clone();
        let mut update_reciever = engine.read().unwrap().get_key_updates_reciever();
        available_keys_sink.add(engine.read().unwrap().get_keys());
        while engine.read().unwrap().in_use(){
            update_reciever.changed().await;
            available_keys_sink.add(engine.read().unwrap().get_keys());

        }
    }

    #[frb]
    pub async fn get_timestamped_series(&self, timestamped_series_sink: frb_generated::StreamSink<Vec<TimeStampedValue>>, key: String){
        let engine = self.engine.clone();
        
        let mut update_reciever = engine.read().unwrap().get_data_updates_reciever();
        timestamped_series_sink.add(engine.read().unwrap().get_series(&key));
        while engine.read().unwrap().in_use(){
            let to_update = update_reciever.recv().await.unwrap();
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

