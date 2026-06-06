use serde::Serialize;
use std::env;
use std::process::{Command, Stdio};
//TODO: Battery %
#[derive(Serialize)]
struct WaybarOutput {
    text: String,
    class: String,
    tooltip: String,
}

fn is_connected(mac: &str) -> bool {
    Command::new("bluetoothctl")
        .args(["info", mac])
        .stderr(Stdio::null())
        .output()
        .map(|out| String::from_utf8_lossy(&out.stdout).contains("Connected: yes"))
        .unwrap_or(false)
}

fn main() {
    let mac = env::var("DEFAULT_HEADPHONES_ADDRESS")
        .unwrap_or_else(|_| String::from("XX:XX:XX:XX:XX:XX"));
    let args: Vec<String> = env::args().collect();

    // --- ACTION: CLICK (FIRE AND FORGET) ---
    if args.contains(&String::from("--action-click")) {
        // Run connect asynchronously in the background via system shell and exit instantly
        let cmd = format!("bluetoothctl connect {} > /dev/null 2>&1 &", mac);
        let _ = Command::new("sh").args(["-c", &cmd]).spawn();

        // Output temporary feedback to Waybar immediately
        let click_output = WaybarOutput {
            text: String::from("󰋋"),
            class: String::from("connecting"),
            tooltip: String::from("Connecting..."),
        };
        println!("{}", serde_json::to_string(&click_output).unwrap());
        std::process::exit(0);
    }

    // --- ACTION: REGULAR POLL / SIGNAL REFRESH ---
    let connected = is_connected(&mac);

    let output = if connected {
        WaybarOutput {
            text: String::from("󰋋"),
            class: String::from("connected"),
            tooltip: String::from("Connected"),
        }
    } else {
        WaybarOutput {
            text: String::from("󰋋"),
            class: String::from("disconnected"),
            tooltip: String::from("Disconnected"),
        }
    };

    println!("{}", serde_json::to_string(&output).unwrap());
}
