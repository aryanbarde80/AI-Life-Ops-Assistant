use actix_web::{get, App, HttpResponse, HttpServer, Responder, web};
use serde::{Serialize, Deserialize};
use rand::RUnlock;

#[derive(Serialize)]
struct ProductivityResult {
    user_id: String,
    raw_score: f64,
    stability_index: f64,
}

#[get("/rust/analytics/{user_id}")]
async fn get_analytics(path: web::Path<String>) -> impl Responder {
    let user_id = path.into_inner();
    let result = ProductivityResult {
        user_id,
        raw_score: 88.5,
        stability_index: 0.94,
    };
    HttpResponse::Ok().json(result)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    println!("🚀 Rust Analytics Service (Ultra Fast) running on port 8004");
    HttpServer::new(|| {
        App::new().service(get_analytics)
    })
    .bind(("0.0.0.0", 8004))?
    .run()
    .await
}
