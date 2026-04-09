use core::time;
use std::env;
use std::fs;
use std::vec;
use crate::engine::engine::Engine;


// Get an engine with relevant csv loaded in
pub fn parse_csv(csv_path: String) -> Engine {
    // Read the contents of the file
    let contents = fs::read_to_string(csv_path)
        .expect("Should have been able to read the file");

    // Create the engine to be returned
    let mut engine = Engine::new();
    engine.set_name("CSV".to_string());

    // Split the file into lines to be analsysed
    let mut lines = contents.split('\n');

    // Read the first line which should contain names of the series
    let column_names: Vec<&str> = lines.next().expect("No first line is bad").split(',').collect();

    assert!(column_names[0] == "time", "Expected the first column to contain the time");

    // for each line in the file (except the first which was already consumed)
    for line in lines {
        // Strip the \r out of the line
        let line = line.replace("\r", "");

        // Split the line into each data entry
        let data_points: Vec<&str> = line.split(',').collect();

        
        assert!(data_points.len() == column_names.len(), "Different number of datapoints ({:?}) to column names ({:?})", data_points.len(), column_names.len());


        let time: f64 = data_points.get(0).expect("Surely more than one column").parse().unwrap();

        // Add the data to the engine
        for data_index in 1..column_names.len() {
            engine.add_data_point(&column_names[data_index].to_string(), data_points[data_index].parse().unwrap(), time);
        }
    }

    
    engine
}