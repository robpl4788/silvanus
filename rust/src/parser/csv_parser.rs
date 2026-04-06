use core::time;
use std::env;
use std::fs;
use std::vec;
use crate::engine::engine::Engine;

pub fn parse_csv(csv_path: String) -> Engine {
    let contents = fs::read_to_string(csv_path)
        .expect("Should have been able to read the file");

    let mut engine = Engine::new();
    engine.set_name("CSV".to_string());

    let mut lines = contents.split('\n');


    let column_names: Vec<&str> = lines.next().expect("No first line is bad").split(',').collect();

    assert!(column_names[0] == "time", "Expected the first column to contain the time");

    for line in lines {
        let line = line.replace("\r", "");
        let data_points: Vec<&str> = line.split(',').collect();

        assert!(data_points.len() == column_names.len(), "Different number of datapoints ({:?}) to column names ({:?})", data_points.len(), column_names.len());

        let time: f64 = data_points.get(0).expect("Surely more than one column").parse().unwrap();

        for data_index in 1..column_names.len() {
            engine.add_data_point(&column_names[data_index].to_string(), data_points[data_index].parse().unwrap(), time);
        }
    }

    
    engine
}