use std::{string, time::{Duration, SystemTime}};

use crate::engine::engine::Engine;

use rand::RngExt;
use std::sync::{Arc, RwLock};
use regex::Regex;


pub fn add_serial_data(engine: &Arc<RwLock<Engine>>, port: String) {
    let mut port = serialport::new(port, 115200).open().expect("Failed to open port");
    let mut unanalysed_data: String = "".to_string();

    let re: Regex = Regex::new(r"\s*(\S+):\s+(\S+)\s*").unwrap();
    let start_time: SystemTime = SystemTime::now();

    port.flush();
    loop {
        if engine.read().unwrap().in_use() == false {
            break;
        }
        let mut buf = vec![];
        port.read_to_end(&mut buf);


        if (buf.len() > 0) {
            let s = String::from_utf8(buf).unwrap();
            unanalysed_data = s;
            let lines = unanalysed_data.split_terminator("\n");
            for line in lines {
                println!("line: {}", line);
                for caps in re.captures_iter(line) {
                    println!("{} -> {}", &caps[1], &caps[2]);
                    let key = &caps[1];
                    let data = &caps[2];
                    if let Ok(data) = data.parse() {

                        let time: SystemTime = SystemTime::now();
                        let since_starting = time
                            .duration_since(start_time)
                            .expect("time should go forward");
                        
                        let mut e = engine.write().unwrap();
                        e.add_data_point(&key.to_string(), data, since_starting.as_secs_f64());
                    }
                    

                }
            }

            // if unanalysed_data.ends_with('\n') {
            //     unanalysed_data = String::new();
            // } else {
            //     // Otherwise, the last "line" is incomplete
            //     // split_terminator does NOT return it, so we must extract it manually
            //     if let Some(last_newline) = unanalysed_data.rfind('\n') {
            //         unanalysed_data = unanalysed_data[last_newline + 1 ..].to_string();
            //     }
            //     // If no newline at all, leftover stays as-is
            // }
        }

    }
}