use std::env;
use std::fs;
use std::process::{Command, Stdio};
use std::time::{SystemTime, UNIX_EPOCH};
use serde::Serialize;

const FLAG_FILE: &str = "/tmp/waybar_bt_connecting";
const ERROR_FILE: &str = "/tmp/waybar_bt_error";

#[derive(Serialize)]
struct WaybarOutput {
    text: String,
    class: String,
    tooltip: String,
}

fn get_mtime_age(path: &str) -> u64 {
    fs::metadata(path)
        .and_then(|meta| meta.modified())
        .map(|mtime| {
            let now = SystemTime::now().duration_since(UNIX_EPOCH).unwrap_or_default().as_secs();
            let mtime_secs = mtime.duration_since(UNIX_EPOCH).unwrap_or_default().as_secs();
            now.saturating_sub(mtime_secs)
        })
        .unwrap_or(u64::MAX)
}

fn cleanup() {
    let _ = fs::remove_file("/tmp/waybar_bt_connecting");
    let _ = fs::remove_file(ERROR_FILE);
}

fn get_info(mac: &str) -> (String, bool, String) {
    let output = Command::new("bluetoothctl")
        .args(["info", mac])
        .stderr(Stdio::null())
        .output();

    if let Ok(out) = output {
        let res = String::from_utf8_lossy(&out.stdout);
        let connected = res.contains("Connected: yes");
        let mut name = String::from("Unknown");
        let mut battery = String::new();

        for line in res.lines() {
            let trimmed = line.trim();
            if trimmed.starts_with("Name:") {
                name = trimmed.replacen("Name: ", "", 1);
            }
            if trimmed.contains("Battery Percentage:") {
                if let Some(start) = trimmed.find('(') {
                    if let Some(end) = trimmed.find(')') {
                        if start < end {
                            battery = format!(" ({}%)", &trimmed[start + 1..end]);
                        }
                    }
                }
            }
        }
        (name, connected, battery)
    } else {
        (String::from("Error"), false, String::new())
    }
}

fn main() {
    let mac = env::var("DEFAULT_HEADPHONES_ADDRESS").unwrap_or_else(|_| String::from("XX:XX:XX:XX:XX:XX"));
    let args: Vec<String> = env::args().collect();

    let mut output = WaybarOutput {
        text: String::from("󰋋"),
        class: String::from("disconnected"),
        tooltip: String::from("Disconnected"),
    };

    // --- ACTION: CLICK ---
    if args.contains(&String::from("--action-click")) {
        cleanup();
        let _ = fs::write(FLAG_FILE, "connecting");

        let cmd = format!(
            "tmp=$(mktemp); bluetoothctl connect {} > \"$tmp\" 2>&1 || mv \"$tmp\" {}",
            mac, ERROR_FILE
        );

        let _ = Command::new("sh")
            .args(["-c", &cmd])
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .spawn();

        output.class = String::from("connecting");
        output.tooltip = String::from("Connecting...");
        println!("{}", serde_json::to_string(&output).unwrap());
        std::process::exit(0);
    }

    // --- ACTION: REGULAR POLL ---
    let (name, connected, battery) = get_info(&mac);

    if connected {
        cleanup();
        output.class = String::from("connected");
        output.tooltip = format!("Connected: {}{}", name, battery);
    } else if fs::metadata(ERROR_FILE).is_ok() {
        if get_mtime_age(ERROR_FILE) > 20 {
            let _ = fs::remove_file(ERROR_FILE);
            output.class = String::from("disconnected");
        } else {
            let raw_log = fs::read_to_string(ERROR_FILE)
                .map(|content| content.lines().last().unwrap_or("Unknown Connection Error").trim().to_string())
                .unwrap_or_else(|_| String::from("Unknown Connection Error"));

            let _ = fs::remove_file("/tmp/waybar_bt_connecting");
            output.class = String::from("problem");
            output.tooltip = format!("⚠ {}", raw_log);
        }
    } else if fs::metadata(FLAG_FILE).is_ok() {
        if get_mtime_age(FLAG_FILE) > 15 {
        let _ = fs::remove_file(FLAG_FILE);

        output.class = String::from("disconnected");
        } else {
            output.class = String::from("connecting");
            output.tooltip = String::from("Connecting...");
        }
    } else {
        output.class = String::from("disconnected");
    }

    println!("{}", serde_json::to_string(&output).unwrap());
}
