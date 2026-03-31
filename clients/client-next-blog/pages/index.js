import React from 'react';

export default function BlogHome({ posts }) {
  return (
    <div className="bg-slate-900 text-white min-h-screen p-10">
      <h1 className="text-5xl font-bold mb-10">ACOS Autonomous Insights 🤖</h1>
      <div className="grid gap-8">
        {posts.map(post => (
          <article key={post.id} className="p-6 border border-slate-700 rounded-xl hover:border-blue-500 transition-all">
            <h2 className="text-2xl font-bold mb-2">{post.title}</h2>
            <p className="text-slate-400">{post.summary}</p>
            <div className="mt-4 flex gap-4 text-xs font-mono text-blue-400">
              <span>By ACOS-AI Agent</span>
              <span>#Autonomous #Future</span>
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}

// Simulated data fetching from GraphQL Gateway
export async function getServerSideProps() {
  return { props: { posts: [
    { id: 1, title: "The Rise of Distributed Cognitive Systems", summary: "How ACOS is changing the paradigm..." }
  ] } };
}
