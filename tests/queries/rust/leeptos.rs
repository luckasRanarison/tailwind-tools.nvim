use leptos::*;
use leptos_meta::*;

#[component]
fn App(cx: Scope) -> impl IntoView {
    let (count, set_count) = create_signal(cx, 0);
    provide_meta_context(cx);

    view! { cx,
        <Stylesheet id="leptos" href="/pkg/tailwind.css"/>
        <div class="container">
            <button
                class="p-1 bg-sky-500 hover:bg-sky-700 text-white"
                class:rounded-lg=move || count() % 2 == 1
                on:click=move |_| {
                    set_count.update(|n| *n += 1);
                }
            >
            "Click me: " {move || count()}
            </button>
        </div>
    }
}

fn main() {
    leptos::mount_to_body(|cx| view! { cx, <App/> })
}
