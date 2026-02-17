const express = require("express");
const { Client } = require("pg");

const app = express();
const PORT = process.env.PORT || 3000;

const client = new Client({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT,
});

async function connectWithRetry() {
  try {
    await client.connect();
    console.log("Connected to PostgreSQL");
  } catch (err) {
    console.error("DB not ready, retrying...", err.message);
    setTimeout(connectWithRetry, 5000);
  }
}

connectWithRetry();

app.get("/", (req, res) => {
  res.send("Mini-Project 5 is running");
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
