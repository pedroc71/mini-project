const express = require("express");
const { Client } = require("pg");

const app = express();
const port = 3000;

// PostgreSQL connection (CI-safe)
const client = new Client({
  host: process.env.DB_HOST,
  user: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DB,
});

// Connect only if DB is configured (prevents CI failure)
if (process.env.DB_HOST) {
  client
    .connect()
    .then(() => {
      console.log("✅ Connected to PostgreSQL");
    })
    .catch((err) => {
      console.error("❌ DB connection error", err);
    });
}

app.get("/", (req, res) => {
  res.send("Mini-project 4 CI works ✅");
});
const x =5;

app.listen(port, () => {
  console.log(`🚀 App running on port ${port}`);
});
