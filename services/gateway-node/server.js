const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const axios = require('axios');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const server = http.createServer(app);
const io = new Server(server, { cors: { origin: "*" } });

const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://ai-service:10000';
const ML_SERVICE_URL = process.env.ML_SERVICE_URL || 'http://ml-service:8001';

app.post('/api/chat', async (req, res) => {
    try {
        const response = await axios.post(`${AI_SERVICE_URL}/chat`, req.body);
        res.json(response.data);
    } catch (error) {
        res.status(500).json({ error: 'AI Service Unavailable' });
    }
});

io.on('connection', (socket) => {
    console.log('Client connected to Realtime Gateway');
    
    socket.on('subscribe_thoughts', (userId) => {
        console.log(`User ${userId} subscribed to thought stream`);
        // Logic to forward thought events from Redis/AI-Service
    });
});

const PORT = 3000;
server.listen(PORT, () => {
    console.log(`Gateway running on port ${PORT}`);
});
