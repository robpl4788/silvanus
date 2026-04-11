use std::collections::HashMap;
use tokio::sync::broadcast;
use tokio::sync::watch;


use crate::api::types::TimeStampedValue;

pub struct Engine {
    time_stamped_data: HashMap<String, Vec<TimeStampedValue>>,
    in_use: bool,

    key_update_tx: watch::Sender<()>,           // Send if new keys are available
    key_update_rx: watch::Receiver<()>,         // Recieve if new keys are available

    data_update_tx: broadcast::Sender<String>,  // Send if new data is available and the key of the data that was updated
    // data_update_rx: broadcast::Receiver<String>,  // Recieve if new data is available and the key of the data that was updated

    name: String,
}

impl Engine {
    pub fn new () -> Engine {
        // Channel to nofify if keys change
        let (key_update_tx, key_update_rx) = watch::channel(());

        // Channel to notify if data changes
        let (data_update_tx, _) = broadcast::channel(100);

        Engine {
            time_stamped_data: HashMap::new(),
            in_use: true,

            key_update_tx,
            key_update_rx,

            data_update_tx,

            name: "New".to_string(),
        }
    }

    pub fn get_key_updates_reciever(&self) -> watch::Receiver<()> {
        self.key_update_rx.clone()
    }

    pub fn get_data_updates_reciever(&self) -> broadcast::Receiver<String> {
        self.data_update_tx.subscribe()
    }

    pub fn in_use (&self) -> bool {
        self.in_use
    }

    // Add data to the engine
    pub fn add_data_point(&mut self, key: &String, value: f64, time: f64) {

        // Construct the new entry
        let new_entry = TimeStampedValue{
            time,
            value
        };

        match self.time_stamped_data.get_mut(key) {
            // If the engine already has this key
            Some(series) => {
                // Add the data
                series.push(new_entry);
                // Communicate that new data is available
                let _ = self.data_update_tx.send(key.clone());
            },

            // If the engine doesn't already have this key
            None => {
                // Add the data
                self.time_stamped_data.insert(key.clone(), vec![new_entry]);
                
                // Communicate that new keys are available
                let _ = self.key_update_tx.send(());

                // Communicate that new data is available
                let _ = self.data_update_tx.send(key.clone());

            },
        };

    }

    pub fn set_name(&mut self, new_name: String) {
        self.name = new_name;
    }

    pub fn get_name(&self) -> String{
        self.name.clone()
    }

    // Get a series of data with the corresponding key
    pub fn get_series(&self, key: &String) -> Vec<TimeStampedValue> {

        match self.time_stamped_data.get(key) {
            Some(value) => value.clone(),
            None => vec![],
        }
    }

    // Get all the keys to series currently in the engine
    pub fn get_keys(&self) -> Vec<String> {
        let keys:Vec<&String> = self.time_stamped_data.keys().collect();
        let mut result = vec![];
        for key in keys {
            result.push(key.clone());
        }

        result
    }

    pub fn terminate(&mut self) {
        self.in_use = false;

    }


}

impl Drop for Engine {
    fn drop(&mut self) {
        println!("ENGINE DROPPED: {:?}", self.get_name());
    }
}