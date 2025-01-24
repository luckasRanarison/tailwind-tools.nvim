#![allow(non_snake_case)]
use dioxus::prelude::*;

fn main() {
    dioxus_desktop::launch(App);
}

fn App(cx: Scope) -> Element {
    cx.render(rsx! {
        link { rel: "stylesheet", href: "../dist/output.css" },
        div {
            class: "w-full h-screen bg-gray-300 flex items-center justify-center",
            "Hello, world!"
        }
    })
}
