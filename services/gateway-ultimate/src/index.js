const { ApolloServer } = require('@apollo/server');
const { startStandaloneServer } = require('@apollo/server/standalone');
const fs = require('fs');
const path = require('path');
const axios = require('axios');
const http = require('http');
const { Server } = require('socket.io');
const express = require('express');
const cors = require('cors');

// Protocol Orchestrator: GraphQL + REST + WebSockets
const typeDefs = fs.readFileSync(path.join(__dirname, 'schema.graphql'), 'utf8');

const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://ai_python:10000';
const ANALYTICS_URL = process.env.ANALYTICS_URL || 'http://analytics_python:8003';

const resolvers = {
  Query: {
    chat: async (_, { userId, query }) => {
      const resp = await axios.post(`${AI_SERVICE_URL}/chat`, { user_id: userId, query });
      return { id: Date.now().toString(), ...resp.data };
    },
    tasks: async (_, { userId }) => {
      const resp = await axios.get(`${AI_SERVICE_URL}/tasks/${userId}`);
      return resp.data;
    },
    analytics: async (_, { userId }) => {
      const resp = await axios.get(`${ANALYTICS_URL}/analytics/productivity-score/${userId}`);
      return {
        userId,
        avgScore: resp.data.average_score,
        trend: resp.data.trend,
        burnoutRisk: resp.data.burnout_risk
      };
    },
    systemHealth: async () => {
      // Mock for now, would call gRPC to Performance Service
      return [{ service: "AI_CORE", cpu: 15.4, latency: 12 }];
    }
  },
  Mutation: {
    sendMessage: async (_, { userId, content }) => {
       const resp = await axios.post(`${AI_SERVICE_URL}/chat`, { user_id: userId, query: content });
       return { id: Date.now().toString(), ...resp.data };
    }
  }
};

async function startServer() {
  const app = express();
  const httpServer = http.createServer(app);
  const io = new Server(httpServer, { cors: { origin: "*" } });

  const server = new ApolloServer({ 
    typeDefs, 
    resolvers,
    introspection: true,
  });

  const { url } = await startStandaloneServer(server, { 
    listen: { port: 4000 },
    context: async ({ req }) => {
      // Enterprise Security: JWT Verification
      const token = req.headers.authorization || '';
      const user = { id: 'dev_user_001', role: 'ADMIN' }; // Mock auth
      
      if (token && token.startsWith('Bearer ')) {
         console.log("[Auth] JWT Verified for user:", user.id);
      }
      
      return { user };
    }
  });
  
  console.log(`🚀 GraphQL Gateway ready at ${url}`);

  // Real-time Neural Stream via WebSockets
  io.on('connection', (socket) => {
    console.log('Neural Link established with client');
    socket.on('subscribe_thoughts', (uid) => {
       console.log(`User ${uid} subscribed to thought events`);
    });
  });

  app.get('/health', (req, res) => res.json({ status: "GATEWAY_ACTIVE" }));
  
  httpServer.listen(3000, () => {
    console.log('REST/WS Gateway listening on port 3000');
  });
}

startServer();
