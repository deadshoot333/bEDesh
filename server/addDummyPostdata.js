const pool = require('./db');

// Array of posts to insert
const posts = [
  {
    user_id: 'a1b2c3d4-5678-90ab-cdef-111111111111',
    content: 'Learning JavaScript is fun!',
    post_type: 'text',
    tags: ['javascript', 'programming'],
    images: [],
    is_liked: false,
  },
  {
    user_id: 'a1b2c3d4-5678-90ab-cdef-222222222222',
    content: 'What is the best way to learn Node.js?',
    post_type: 'question',
    tags: ['nodejs', 'backend'],
    images: [],
    is_liked: true,
  },
  {
    user_id: 'a1b2c3d4-5678-90ab-cdef-333333333333',
    content: 'Pro tip: Use async/await instead of callbacks!',
    post_type: 'tips',
    tags: ['javascript', 'async'],
    images: ['https://example.com/tip-image.jpg'],
    is_liked: true,
  },
  {
    user_id: 'a1b2c3d4-5678-90ab-cdef-444444444444',
    content: 'Just another test post with no images or tags.',
    post_type: 'text',
    tags: [],
    images: [],
    is_liked: false,
  },
  {
    user_id: 'a1b2c3d4-5678-90ab-cdef-555555555555',
    content: 'Daily question: What is your favorite VS Code extension?',
    post_type: 'question',
    tags: ['tools', 'vscode'],
    images: [],
    is_liked: true,
  }
];

// Function to insert all posts
async function insertMultiplePosts(posts) {
  const query = `
    INSERT INTO public.posts (
      user_id,
      content,
      post_type,
      tags,
      images,
      is_liked
    ) VALUES ($1, $2, $3, $4, $5, $6)
    RETURNING id;
  `;

  try {
    for (const post of posts) {
      const {
        user_id,
        content,
        post_type,
        tags,
        images,
        is_liked
      } = post;

      const values = [
        user_id,
        content,
        post_type,
        tags,
        images,
        is_liked
      ];

      const res = await pool.query(query, values);
      console.log(`Inserted post with ID: ${res.rows[0].id}`);
    }
  } catch (err) {
    console.error('Error inserting posts:', err);
  } finally {
    await pool.end(); // Close the pool after inserts are done
  }
}

// Run the insert
insertMultiplePosts(posts);
