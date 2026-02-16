const express = require("express");
const { Client } = require("pg");

const app = express();
const port = 3000;

const client = new Client({
  host: process.env.DB_HOST, // db
  user: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DB,
});

client
  .connect()
  .then(() => console.log("✅ Connected to PostgreSQL"))
  .catch((err) => console.error("❌ DB connection error", err));


app.get("/", (req, res) => {
  res.send("Mini-project Docker works with DB");
});

app.listen(port, () => {
  console.log(`App running on port ${port}`);
});
